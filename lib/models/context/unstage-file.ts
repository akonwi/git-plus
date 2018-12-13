import ActivityLogger from "../../activity-logger";
import Repository from "../../repository";

export function gitUnstageFileFromContext(treeView: Services.TreeView) {
  treeView.selectedPaths().forEach(async path => {
    const repo = await Repository.getForPath(path);

    if (!repo) return atom.notifications.addWarning(`No repository found for ${path}`);

    const pathIsStaged = await repo.isPathStaged(path);
    if (!pathIsStaged) {
      return atom.notifications.addInfo(`\`${repo.relativize(path)}\` can't be unstaged.`, {
        detail: "This file has no staged changes"
      });
    }

    const result = await repo.resetChanges(path);
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `reset changes in ${path}`,
      ...result
    });
  });
}
