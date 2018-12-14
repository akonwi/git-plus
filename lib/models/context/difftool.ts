import Repository from "../../repository";
import GitDiffTool = require("../git-difftool");

export async function gitDiffToolFromContext(treeView: Services.TreeView) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return atom.notifications.addWarning(`No repository found for ${path}`);
  if (!repo.isPathModified(path)) {
    return atom.notifications.addInfo(`\`${repo.relativize(path)}\` has no changes to diff`);
  }

  GitDiffTool(repo.repo, { file: repo.relativize(path) });
}
