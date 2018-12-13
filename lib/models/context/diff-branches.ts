import Repository from "../../repository";
import GitDiffBranches = require("../git-diff-branches");

export async function gitDiffBranchesFromContext(treeView: Services.TreeView) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);
  if (!repo) return atom.notifications.addWarning(`No repository found for \`${path}\``);

  GitDiffBranches(repo.repo);
}
