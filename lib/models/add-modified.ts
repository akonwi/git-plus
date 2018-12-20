import ActivityLogger from "../activity-logger";
import Repository from "../repository";

export default async () => {
  const repo = await Repository.getCurrent();
  if (!repo) {
    return atom.notifications.addInfo("No repository found");
  }

  const result = await repo.stage(["."], { update: true });
  ActivityLogger.record({
    repoName: repo.getName(),
    message: `add modified files`,
    ...result
  });
};
