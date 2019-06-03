import { Repository } from "../repository";
import { CommandResult, getCurrentFileInRepo, RepositoryCommand } from "./common";

export const resetFiles: RepositoryCommand = {
  id: "checkout-current-file",

  async run(repo: Repository) {
    const currentFile = getCurrentFileInRepo(repo);
    if (currentFile === undefined) return;

    if (await repo.isPathStaged(currentFile)) {
      try {
        const unstageResult = await new Promise<CommandResult>((resolve, reject) => {
          let notificationAlive = true;
          const notification = atom.notifications.addInfo(
            `${repo.relativize(currentFile)} can't be reset to HEAD.`,
            {
              description: "It has staged changes, which must be unstaged first.",
              dismissable: true,
              buttons: [
                {
                  text: "Unstage",
                  onDidClick: async () => {
                    notification.dismiss();
                    notificationAlive = false;
                    const result = await repo.do(["reset", "HEAD", currentFile]);
                    resolve({
                      ...result,
                      message: `unstage ${repo.relativize(currentFile)}`
                    });
                  }
                }
              ]
            }
          );
          setTimeout(() => {
            if (notificationAlive) notification.dismiss();
            reject();
          }, 5000);
        });

        if (unstageResult.failed) {
          return unstageResult;
        }
      } catch (error) {
        return;
      }
    }

    const result = await repo.resetChanges(currentFile);

    return { ...result, message: `discard changes in ${repo.relativize(currentFile)}` };
  }
};
