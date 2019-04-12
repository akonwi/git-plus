import { CompositeDisposable } from "atom";
import { configs } from "./config";
import { getWorkspaceRepos } from "./git-es";
import diffGrammars from "./grammars/diff";
import GitInit from "./models/git-init";
import { LogViewURI } from "./models/git-log";
import service from "./service";
import LogListView from "./views/log-list-view";
import { OutputViewContainer } from "./views/output-view/container";
import { getRepoCommands } from "./commands/main";

class ViewController {
  _outputView;

  constructor() {
    atom.workspace.addOpener(uri => {
      if (uri === OutputViewContainer.URI) {
        return this.createOutputView();
      }
      if (uri === LogViewURI) {
        return new LogListView();
      }
    });
  }

  createOutputView() {
    if (!this._outputView) {
      this._outputView = new OutputViewContainer();
      this._outputView.onDidDestroy(() => {
        this._outputView = undefined;
      });
    }
    return this._outputView;
  }

  get outputView() {
    return this._outputView;
  }

  dispose() {
    if (this._outputView) {
      this._outputView.destroy();
    }
  }
}

class GitPlusPackage {
  constructor(configs) {
    this.configs = configs;
    this.viewController = new ViewController();
    this.commandResources = new CompositeDisposable();
    this.setDiffGrammar();
    this.registerCommands();
  }

  registerCommands() {
    const repos = getWorkspaceRepos();
    if (repos.length === 0 && atom.project.getDirectories().length > 0) {
      this.commandResources.add(
        atom.commands.add("atom-workspace", "git-plus:init", () => {
          GitInit().then(() => {
            this.resetCommands();
          });
        })
      );
    } else {
      this.commandResources.add(
        ...getRepoCommands().map(command => {
          return atom.commands.add("atom-workspace", command.id, () => command.invoke());
        })
      );
    }
  }

  resetCommands() {
    this.commandResources.dispose();
    this.commandResources = new CompositeDisposable();
    this.registerCommands();
  }

  provideService() {
    return service;
  }

  deserializeOutputView() {
    return this.viewController.createOutputView();
  }

  deactivate() {
    this.viewController.dispose();
    this.commandResources.dispose();
  }

  setDiffGrammar() {
    const enableSyntaxHighlighting = atom.config.get("git-plus.diffs.syntaxHighlighting");
    const wordDiff = atom.config.get("git-plus.diffs.wordDiff");
    let diffGrammar = null;

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

let gitPlus;
const packageWrapper = {
  initialize(_state) {
    gitPlus = new GitPlusPackage(configs);
  }
};

module.exports = new Proxy(packageWrapper, {
  get(target, name) {
    if (gitPlus && Reflect.has(gitPlus, name)) {
      let property = gitPlus[name];
      if (typeof property === "function") {
        property = property.bind(gitPlus);
      }
      return property;
    } else {
      return target[name];
    }
  }
});
