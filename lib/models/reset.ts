import ActivityLogger from "../activity-logger";
import Repository from "../repository";

export default async () => {
  const repo = await Repository.getCurrent();
  if (!repo) return atom.notifications.addInfo("No repository found");

  const result = await repo.reset();
  ActivityLogger.record({
    repoName: repo.getName(),
    message: "reset index",
    ...result
  });
};
