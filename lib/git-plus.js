import "@babel/polyfill";
import { CompositeDisposable, Disposable } from "atom";
import { OutputViewContainer } from "./views/output-view/container";
import { TreeViewBranchManager } from "./views/tree-view-branches";
import git from "./git";
import configurations from "./config";
import { initializeContextMenu } from "./context-menu";
import service from "./service";
import gitAdd from "./models/add";
import gitAddModified from "./models/add-modified";
import GitPaletteView from "./views/git-palette-view";
import * as treeViewCommands from "./models/tree-view";
import GitCheckoutNewBranch from "./models/git-checkout-new-branch";
import GitCheckoutBranch from "./models/git-checkout-branch";
import GitDeleteBranch from "./models/git-delete-branch";
import gitCheckoutFile from "./models/checkout-file";
import gitReset from "./models/reset";
import GitCherryPick from "./models/git-cherry-pick";
import GitCommit from "./models/git-commit";
import GitCommitAmend from "./models/git-commit-amend";
import GitDiff from "./models/git-diff";
import GitDiffBranches from "./models/git-diff-branches";
import GitDiffBranchFiles from "./models/git-diff-branch-files";
import GitDifftool from "./models/git-difftool";
import GitDiffAll from "./models/git-diff-all";
import gitFetch from "./models/fetch";
import gitFetchInAllRepos from "./models/fetch-in-all-repos";
import GitInit from "./models/git-init";
import GitLog from "./models/git-log";
import gitPull from "./models/pull";
import gitPush from "./models/push";
import GitRemove from "./models/git-remove";
import GitShow from "./models/git-show";
import GitStageFiles from "./models/git-stage-files";
import GitStageHunk from "./models/git-stage-hunk";
import ManageStashes from "./models/manage-stashes";
import GitStashApply from "./models/git-stash-apply";
import GitStashDrop from "./models/git-stash-drop";
import GitStashPop from "./models/git-stash-pop";
import GitStashSave from "./models/git-stash-save";
import GitStashSaveMessage from "./models/git-stash-save-message";
import GitStatus from "./models/git-status";
import GitTags from "./models/git-tags";
import GitRun from "./models/git-run";
import GitMerge from "./models/git-merge";
import GitRebase from "./models/git-rebase";
import GitOpenChangedFiles from "./models/git-open-changed-files";
import diffGrammars from "./grammars/diff.js";
import { viewController } from "./views/controller";

const currentFile = repo => {
  const activeEditor = atom.workspace.getActiveTextEditor();
  if (!activeEditor) return null;
  return repo.relativize(activeEditor.getPath());
};

const setDiffGrammar = () => {
  const enableSyntaxHighlighting = atom.config.get("git-plus.diffs.syntaxHighlighting");
  const wordDiff = atom.config.get("git-plus.diffs.wordDiff");
  let diffGrammar = null;

  if (wordDiff) {
    diffGrammar = diffGrammars.wordGrammar;
  } else {
    diffGrammar = diffGrammars.lineGrammar;
  }
  if (enableSyntaxHighlighting) {
    while (atom.grammars.grammarForScopeName("source.diff"))
      atom.grammars.removeGrammarForScopeName("source.diff");
    atom.grammars.addGrammar(diffGrammar);
  }
};

const getWorkspaceRepos = () => atom.project.getRepositories().filter(Boolean);

const onPathsChanged = gp => {
  if (gp) gp.activate();
};

const getWorkspaceNode = () => document.querySelector("atom-workspace");

module.exports = {
  config: configurations,
  subscriptions: new CompositeDisposable(),
  outputView: null,
  provideService: () => service,

  activate(_state) {
    setDiffGrammar();
    const repos = getWorkspaceRepos();

    atom.project.onDidChangePaths(_paths => onPathsChanged(this));

    if (repos.length === 0 && atom.project.getDirectories().length > 0)
      this.subscriptions.add(
        atom.commands.add("atom-workspace", "git-plus:init", () => GitInit().then(this.activate))
      );
    if (repos.length > 0) {
      initializeContextMenu();
      this.subscriptions.add(
        atom.commands.add("atom-workspace", {
          "git-plus:menu": () => new GitPaletteView(),
          "git-plus:add": () => gitAdd(),
          "git-plus:add-all": () => gitAdd(true),
          "git-plus:add-modified": () => gitAddModified(),
          "git-plus:commit": () => {
            git.getRepo().then(repo => GitCommit(repo));
          },
          "git-plus:commit-all": () => {
            git.getRepo().then(repo => GitCommit(repo, { stageChanges: true }));
          },
          "git-plus:commit-amend": () => {
            git.getRepo().then(repo => new GitCommitAmend(repo));
          },
          "git-plus:add-and-commit": () => {
            git
              .getRepo()
              .then(repo => git.add(repo, { file: currentFile(repo) }).then(() => GitCommit(repo)));
          },
          "git-plus:add-and-commit-and-push": () => {
            git
              .getRepo()
              .then(repo =>
                git
                  .add(repo, { file: currentFile(repo) })
                  .then(() => GitCommit(repo, { andPush: true }))
              );
          },
          "git-plus:add-all-and-commit": () => {
            git.getRepo().then(repo => git.add(repo).then(() => GitCommit(repo)));
          },
          "git-plus:add-all-commit-and-push": () => {
            git
              .getRepo()
              .then(repo => git.add(repo).then(() => GitCommit(repo, { andPush: true })));
          },
          "git-plus:commit-all-and-push": () => {
            git.getRepo().then(repo => GitCommit(repo, { stageChanges: true, andPush: true }));
          },
          "git-plus:checkout": () => git.getRepo().then(repo => GitCheckoutBranch(repo)),
          "git-plus:checkout-remote": () => {
            git.getRepo().then(repo => GitCheckoutBranch(repo, { remote: true }));
          },
          "git-plus:checkout-current-file": () => gitCheckoutFile(),
          "git-plus:checkout-all-files": () => gitCheckoutFile(true),
          "git-plus:new-branch": () => git.getRepo().then(repo => GitCheckoutNewBranch(repo)),
          "git-plus:delete-local-branch": () => git.getRepo().then(repo => GitDeleteBranch(repo)),
          "git-plus:delete-remote-branch": () => {
            git.getRepo().then(repo => GitDeleteBranch(repo, { remote: true }));
          },
          "git-plus:cherry-pick": () => git.getRepo().then(repo => GitCherryPick(repo)),
          "git-plus:diff": () => {
            git.getRepo().then(repo => GitDiff(repo, { file: currentFile(repo) }));
          },
          "git-plus:difftool": () => {
            git.getRepo().then(repo => GitDifftool(repo, { file: currentFile(repo) }));
          },
          "git-plus:diff-all": () => git.getRepo().then(repo => GitDiffAll(repo)),
          "git-plus:fetch": () => gitFetch(),
          "git-plus:fetch-prune": () => gitFetch({ prune: true }),
          "git-plus:pull": () => gitPull(),
          "git-plus:push": () => gitPush(),
          "git-plus:push-set-upstream": () => gitPush(true),
          "git-plus:remove": () => {
            git.getRepo().then(repo => GitRemove(repo, { showSelector: true }));
          },
          "git-plus:remove-current-file": () => git.getRepo().then(repo => GitRemove(repo)),
          "git-plus:reset": () => gitReset(),
          "git-plus:show": () => git.getRepo().then(repo => GitShow(repo)),
          "git-plus:log": () => git.getRepo().then(repo => GitLog(repo)),
          "git-plus:log-current-file": () => {
            git.getRepo().then(repo => GitLog(repo, { onlyCurrentFile: true }));
          },
          "git-plus:stage-hunk": () => git.getRepo().then(repo => GitStageHunk(repo)),
          "git-plus:manage-stashes": ManageStashes,
          "git-plus:stash-save": () => git.getRepo().then(repo => GitStashSave(repo)),
          "git-plus:stash-save-message": () => {
            git.getRepo().then(repo => GitStashSaveMessage(repo));
          },
          "git-plus:stash-pop": () => git.getRepo().then(repo => GitStashPop(repo)),
          "git-plus:stash-apply": () => git.getRepo().then(repo => GitStashApply(repo)),
          "git-plus:stash-delete": () => git.getRepo().then(repo => GitStashDrop(repo)),
          "git-plus:status": () => git.getRepo().then(repo => GitStatus(repo)),
          "git-plus:tags": () => git.getRepo().then(repo => GitTags(repo)),
          "git-plus:run": () => git.getRepo().then(repo => new GitRun(repo)),
          "git-plus:merge": () => git.getRepo().then(repo => GitMerge(repo)),
          "git-plus:merge-remote": () => {
            git.getRepo().then(repo => GitMerge(repo, { remote: true }));
          },
          "git-plus:merge-no-fast-forward": () => {
            git.getRepo().then(repo => GitMerge(repo, { noFastForward: true }));
          },
          "git-plus:rebase": () => git.getRepo().then(repo => GitRebase(repo)),
          "git-plus:git-open-changed-files": () => {
            git.getRepo().then(repo => GitOpenChangedFiles(repo));
          },
          "git-plus:toggle-output-view": () => {
            viewController.getOutputView().toggle();
          }
        })
      );
      this.subscriptions.add(
        atom.commands.add("atom-workspace", "git-plus:fetch-all", {
          displayName: "Fetch All (Repos & Remotes)",
          didDispatch: _event => gitFetchInAllRepos()
        })
      );
      this.subscriptions.add(
        atom.commands.add(".tree-view", {
          "git-plus-context:add": () => treeViewCommands.add(this.treeView),
          "git-plus-context:add-and-commit": () => treeViewCommands.addAndCommit(this.treeView),
          "git-plus-context:checkout-file": () => treeViewCommands.checkoutFile(this.treeView),
          "git-plus-context:diff": () => treeViewCommands.diff(this.treeView),
          "git-plus-context:diff-all": () => treeViewCommands.diff(this.treeView, true),
          "git-plus-context:diff-branches": () => treeViewCommands.diffBranches(this.treeView),
          "git-plus-context:diff-branch-files": () =>
            treeViewCommands.diffFileAgainstBranch(this.treeView),
          "git-plus-context:difftool": () => treeViewCommands.diffTool(this.treeView),
          "git-plus-context:pull": () => treeViewCommands.pull(this.treeView),
          "git-plus-context:push": () => treeViewCommands.push(this.treeView),
          "git-plus-context:unstage-file": () => treeViewCommands.unstage(this.treeView)
        })
      );
      if (atom.config.get("git-plus.experimental.diffBranches")) {
        this.subscriptions.add(
          atom.commands.add("atom-workspace", {
            "git-plus:diff-branches": () => git.getRepo().then(repo => GitDiffBranches(repo)),
            "git-plus:diff-branch-files": () => git.getRepo().then(repo => GitDiffBranchFiles(repo))
          })
        );
      }
      this.subscriptions.add(
        atom.commands.add("atom-workspace", "git-plus:stage-files", () =>
          git.getRepo().then(GitStageFiles)
        )
      );
      this.subscriptions.add(
        atom.config.observe("git-plus.diffs.syntaxHighlighting", setDiffGrammar),
        atom.config.observe("git-plus.diffs.wordDiff", setDiffGrammar),
        atom.config.observe("git-plus.experimental.autoFetch", interval => this.autoFetch(interval))
      );
    }
  },

  deserializeOutputView(_state) {
    return viewController.getOutputView();
  },

  deactivate() {
    this.subscriptions.dispose();
    this.statusBarTile && this.statusBarTile.destroy();
    this.outputView && this.outputView.destroy();
    clearInterval(this.autoFetchInterval);
  },

  autoFetch(interval) {
    clearInterval(this.autoFetchInterval);
    const fetchIntervalMs = interval * 60 * 1000;
    if (fetchIntervalMs) {
      this.autoFetchInterval = setInterval(
        () => atom.commands.dispatch(getWorkspaceNode(), "git-plus:fetch-all"),
        fetchIntervalMs
      );
    }
  },

  consumeAutosave({ dontSaveIf }) {
    dontSaveIf(paneItem => paneItem.getPath().includes("COMMIT_EDITMSG"));
  },

  consumeStatusBar(statusBar) {
    this.statusBar = statusBar;
    if (atom.config.get("git-plus.general.enableStatusBarIcon"))
      this.setupOutputViewToggle(this.statusBar);
    if (getWorkspaceRepos().length > 0) this.setupBranchesMenuToggle();
  },

  consumeTreeView(treeView) {
    this.treeView = treeView;
    this.treeViewBranchManager = new TreeViewBranchManager(treeView);

    this.subscriptions.add(
      new Disposable(() => {
        this.treeView = null;
        this.treeViewBranchManager.destroy();
        this.treeViewBranchManager = null;
      })
    );
  },

  setupOutputViewToggle(statusBar) {
    const div = document.createElement("div");
    div.classList.add("inline-block");
    const icon = document.createElement("span");
    icon.textContent = "git+";
    const link = document.createElement("a");
    link.appendChild(icon);
    link.onclick = _e => {
      viewController.getOutputView().toggle();
    };
    atom.tooltips.add(div, { title: "Toggle Git-Plus Output" });
    div.appendChild(link);
    this.statusBarTile = statusBar.addRightTile({ item: div, priority: 0 });
  },

  setupBranchesMenuToggle() {
    const branchDiv = document.querySelector(".git-view .git-branch");
    if (branchDiv) {
      branchDiv.addEventListener("click", event => {
        const { newBranchKey } = atom.config.get("git-plus.general");
        const wasPressed = key => event[`${key}Key`];
        if (wasPressed(newBranchKey)) {
          atom.commands.dispatch(getWorkspaceNode(), "git-plus:new-branch");
        } else atom.commands.dispatch(getWorkspaceNode(), "git-plus:checkout");
      });
    }
  }
};
