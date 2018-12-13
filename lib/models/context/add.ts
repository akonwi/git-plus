import ActivityLogger from "../../activity-logger";
import Repository from "../../repository";

export const gitAddFromContext = (treeView: Services.TreeView) => {
  const paths = treeView.selectedPaths();

  paths.forEach(async path => {
    const repo = await Repository.getForPath(path);

    if (!repo) return atom.notifications.addInfo("No repository found");

    const result = await repo.add(path);
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `add ${repo.relativize(path)}`,
      ...result
    });
  });
};
