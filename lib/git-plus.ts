import { CompositeDisposable } from "atom";
import { configs } from "./config";
import { getWorkspaceRepos } from "./git-es";
import diffGrammars = require("./grammars/diff.js");
import service = require("./service");
import { viewController } from "./views/controller";

class GitPlusPackage {
  configs: any;
  commandResources: CompositeDisposable;

  constructor(configs: any) {
    this.configs = configs;
    this.commandResources = new CompositeDisposable();
    this.setDiffGrammar();
    this.registerCommands();
  }

  registerCommands() {
    const repos = getWorkspaceRepos();
    if (repos.length === 0 && atom.project.getDirectories().length > 0) {
      this.commandResources.add(
        atom.commands.add("atom-workspace", "git-plus:init", () => {
          // GitInit().then(() => {
          //   this.resetCommands();
          // });
        })
      );
    } else {
      // this.commandResources.add(
      //   ...getRepoCommands().map(command => {
      //     return atom.commands.add("atom-workspace", command.id, () => command.invoke());
      //   })
      // );
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
    return viewController.getOutputView();
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
let gitPlus;
const packageWrapper = {
  initialize(_state) {
    gitPlus = new GitPlusPackage(configs);
  }
};

export = new Proxy(packageWrapper, {
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
