import { CompositeDisposable, Disposable } from "atom";
import { RecordAttributes } from "./activity-logger";
import { getRepoCommands, run } from "./commands";
import { init } from "./commands/init";
import { showCommandPalette } from "./commands/show-command-palette";
import { Container } from "./container";
import { getWorkspaceRepos } from "./git-es";
import diffGrammars = require("./grammars/diff.js");
import service = require("./service");
import { AutoSave } from "./types/auto-save";
import { StatusBar } from "./types/status-bar";
import { TreeView } from "./types/tree-view";
import { StatusBarTileView } from "./views/status-bar-tile";
import { TreeViewBranchManager } from "./views/tree-view-branches";

export class GitPlusPackage {
  private commandResources: CompositeDisposable;

  constructor() {
    this.commandResources = new CompositeDisposable();
    this.setDiffGrammar();
    this.registerCommands();

    atom.project.onDidChangePaths(_paths => {
      this.resetCommands();
    });
  }

  private registerCommands() {
    const repos = getWorkspaceRepos();
    if (repos.length === 0 && atom.project.getDirectories().length > 0) {
      this.commandResources.add(
        atom.commands.add("atom-workspace", `git-plus:${init.id}`, async () => {
          const result = await init.run(undefined);
          if (result) Container.logger.record(result as RecordAttributes);

          this.resetCommands();
        })
      );
    } else {
      const commandDescriptors = {
        "git-plus:menu": showCommandPalette
      };
      getRepoCommands().forEach(command => {
        commandDescriptors[`git-plus:${command.id}`] = {
          displayName: command.displayName,
          didDispatch: () => run(command)
        };
      });

      this.commandResources.add(atom.commands.add("atom-workspace", commandDescriptors));
    }
  }

  private resetCommands() {
    this.commandResources.dispose();
    this.commandResources = new CompositeDisposable();
    this.registerCommands();
  }

  provideService() {
    return service;
  }

  deserializeOutputView() {
    return Container.viewController.getOutputView();
  }

  deactivate() {
    Container.viewController.dispose();
    this.commandResources.dispose();
    Container.logger.dispose();
  }

  private setDiffGrammar() {
    const enableSyntaxHighlighting = atom.config.get("git-plus.diffs.syntaxHighlighting");
    const wordDiff = atom.config.get("git-plus.diffs.wordDiff");
    let diffGrammar: any = null;

    if (wordDiff) {
      diffGrammar = diffGrammars.wordGrammar;
    } else {
      diffGrammar = diffGrammars.lineGrammar;
    }
    if (enableSyntaxHighlighting) {
      while (atom.grammars.grammarForScopeName("source.diff")) {
        atom.grammars.removeGrammarForScopeName("source.diff");
      }
      atom.grammars.addGrammar(diffGrammar);
    }
  }

  consumeAutosave({ dontSaveIf }: AutoSave) {
    dontSaveIf(paneItem => paneItem.getPath().includes("COMMIT_EDITMSG"));
  }

  consumeStatusBar(statusBar: StatusBar) {
    const disposable = new CompositeDisposable();
    if (atom.config.get("git-plus.general.enableStatusBarIcon")) {
      const statusBarTile = statusBar.addRightTile({
        item: new StatusBarTileView({ viewController: Container.viewController }),
        priority: 0
      });
      disposable.add(new Disposable(() => statusBarTile.destroy()));
    }
    // if (getWorkspaceRepos().length > 0) this.setupBranchesMenuToggle();
    return disposable;
  }

  consumeTreeView(treeView: TreeView) {
    const treeViewBranchManager = new TreeViewBranchManager(treeView);

    return new Disposable(() => {
      treeViewBranchManager.destroy();
    });
  }

  // TODO: make this a replacement of the github package's branch name in case that package is disabled
  // private setupBranchesMenuToggle() {
  //   const branchDiv = document.querySelector(".github-StatusBarTileController .github-branch");
  //   if (branchDiv) {
  //     branchDiv.addEventListener("click", event => {
  //       const { newBranchKey } = atom.config.get("git-plus.general");
  //       const wasPressed = key => event[`${key}Key`];
  //       const workspaceNode = atom.views.getView(atom.workspace);
  //       debugger;
  //       if (wasPressed(newBranchKey)) {
  //         atom.commands.dispatch(workspaceNode, "git-plus:new-branch");
  //       } else atom.commands.dispatch(workspaceNode, "git-plus:checkout");
  //     });
  //   }
  // }
}
