import ActivityLogger from "../activity-logger";
import Repository from "../repository";

const getCurrentFileInRepo = (repo: Repository) => {
  const activeEditor = atom.workspace.getActiveTextEditor();
  const path = activeEditor && activeEditor.getPath();
  if (!path) return null;
  return repo.relativize(path);
};

export default async (stageEverything: boolean = false) => {
  const repo = await Repository.getCurrent();

  if (!repo) return atom.notifications.addInfo("No repository found");

  const path = stageEverything ? "." : getCurrentFileInRepo(repo) || ".";
  const result = await repo.stage([path]);
  ActivityLogger.record({
    repoName: repo.getName(),
    message: `add ${path}`,
    ...result
  });
};
