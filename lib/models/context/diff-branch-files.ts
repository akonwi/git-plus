import Repository from "../../repository";
import GitDiffBranchFiles = require("../git-diff-branch-files");

export async function gitDiffBranchFilesContext(treeView: Services.TreeView) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return atom.notifications.addWarning(`No repository found for \`${path}\``);

  GitDiffBranchFiles(repo.repo, path);
}
