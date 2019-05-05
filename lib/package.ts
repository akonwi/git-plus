import { CompositeDisposable } from "atom";
import { ActivityLogger } from "./activity-logger";
import { getRepoCommands } from "./commands";
import { init } from "./commands/init";
import { showCommandPalette } from "./commands/show-command-palette";
import { getWorkspaceRepos } from "./git-es";
import diffGrammars = require("./grammars/diff.js");
import { Repository } from "./repository";
import service = require("./service");
import { ViewController } from "./views/controller";

export class GitPlusPackage {
  configs: any;
  private commandResources: CompositeDisposable;
  readonly logger: ActivityLogger;
  readonly viewController: ViewController;

  constructor(configs: any) {
    this.configs = configs;
    this.commandResources = new CompositeDisposable();
    this.logger = new ActivityLogger();
    this.viewController = new ViewController(this);
    this.setDiffGrammar();
    this.registerCommands();
  }

  private registerCommands() {
    const repos = getWorkspaceRepos();
    if (repos.length === 0 && atom.project.getDirectories().length > 0) {
      this.commandResources.add(
        atom.commands.add("atom-workspace", `git-plus:${init.id}`, async () => {
          const result = await init.run(undefined);
          if (result) this.logger.record(result);

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
          didDispatch: async () => {
            const repo = await Repository.getCurrent();
            if (repo === undefined) return atom.notifications.addInfo("No repository found");
            const result = await command.run(repo!, undefined);
            if (result) this.logger.record(result);
          }
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
    return this.viewController.getOutputView();
  }

  deactivate() {
    // this.viewController.dispose();
    this.commandResources.dispose();
  }

  setDiffGrammar() {
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
}
