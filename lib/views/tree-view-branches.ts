import { CompositeDisposable, GitRepository } from "atom";
import { getRepoForPath } from "../git-es";

export class TreeViewBranchManager {
  private treeView: Services.TreeView;
  private renderedBranches = new Map<string, HTMLElement>();
  private subscriptions = new CompositeDisposable();

  constructor(treeView: Services.TreeView) {
    this.treeView = treeView;
    atom.project.getPaths().forEach(this.renderBranch);
    this.subscriptions.add(
      atom.project.onDidChangePaths(async paths => {
        await Promise.all(paths.map(this.renderBranch));
        for (const path of this.renderedBranches.keys()) {
          if (!paths.includes(path)) this.renderedBranches.delete(path);
        }
      })
    );
  }

  renderBranch = async (path: string) => {
    const repo = (await getRepoForPath(path)) as GitRepository;
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
  }

  destroy() {
    this.subscriptions.dispose();
    this.renderedBranches.forEach(div => div.remove());
  }
}
