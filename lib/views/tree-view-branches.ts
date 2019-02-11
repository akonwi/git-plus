import { CompositeDisposable, Disposable, GitRepository } from "atom";
import { getRepoForPath } from "../git-es";

export class TreeViewBranchManager {
  private treeView: Services.TreeView;
  private renderedBranches = new Map<string, HTMLElement>();
  private subscriptions = new CompositeDisposable();
  private repoSubscriptions = new Map<String, Disposable>();
  private isEnabled = false;

  constructor(treeView: Services.TreeView) {
    this.treeView = treeView;

    atom.config.observe("git-plus.general.showBranchInTreeView", (isEnabled: boolean) => {
      this.isEnabled = isEnabled;
      if (isEnabled) {
        this.initialize();
      } else {
        this.destroy();
        this.subscriptions = new CompositeDisposable();
      }
    });
  }

  initialize() {
    atom.project.getPaths().forEach(this.renderBranch);
    this.subscriptions.add(
      atom.project.onDidChangePaths(async paths => {
        await Promise.all(paths.map(this.renderBranch));
        for (const path of this.renderedBranches.keys()) {
          if (!paths.includes(path)) {
            this.renderedBranches.delete(path);
            this.repoSubscriptions.delete(path);
          }
        }
      })
    );
  }

  renderBranch = async (path: string) => {
    if (!this.isEnabled) return;
    const repo = (await getRepoForPath(path)) as GitRepository;
    if (!repo) return;
    const branchName = `[${repo!.getShortHead()}]`;
    const entry = this.treeView.entryForPath(repo.getWorkingDirectory());

    let div = this.renderedBranches.get(path);
    if (div) {
      div.innerText = branchName;
      entry.querySelector(".project-root-header").appendChild(div);
      return;
    }

    div = document.createElement("div");
    div.style.display = "inline";
    div.style.marginLeft = "10px";
    div.innerText = branchName;
    entry.querySelector(".project-root-header").appendChild(div);
    this.renderedBranches.set(repo.getWorkingDirectory(), div);
    this.updateRepoSubscription(
      repo.getWorkingDirectory(),
      repo.onDidChangeStatuses(() => {
        this.renderBranch(repo.getWorkingDirectory());
      })
    );
  }

  updateRepoSubscription(path: string, disposable: Disposable) {
    const subscription = this.repoSubscriptions.get(path);
    if (subscription) subscription.dispose();
    this.repoSubscriptions.set(path, disposable);
  }

  destroy() {
    this.subscriptions.dispose();
    this.renderedBranches.forEach(div => div.remove());
  }
}
