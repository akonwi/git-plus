import Repository from "../../repository";
import GitPush = require("../git-push");

export async function gitPushFromContext(treeView: Services.TreeView) {
  const paths = treeView.selectedPaths();
  const reposForPaths = await Promise.all(paths.map(Repository.getForPath));

  const seenRepoDirectories: string[] = [];
  reposForPaths.forEach(async (repo, index) => {
    if (repo) {
      const repoDirectory = repo.getWorkingDirectory();
      if (!seenRepoDirectories.includes(repoDirectory)) {
        if ((await repo.getUpstreamBranchFor("HEAD")) === null) {
          const notification = atom.notifications.addWarning(
            `The current branch \`${repo.repo.getShortHead()}\` has no upstream branch`,
            {
              dismissable: true,
              detail: "Do you want to create an upstream branch for it?",
              buttons: [
                {
                  text: "Yes",
                  onDidClick() {
                    GitPush(repo.repo, { setUpstream: true });
                    seenRepoDirectories.push(repoDirectory);
                    notification.dismiss();
                  }
                },
                {
                  text: "No",
                  onDidClick() {
                    notification.dismiss();
                  }
                }
              ]
            }
          );
        } else {
          GitPush(repo.repo);
          seenRepoDirectories.push(repoDirectory);
        }
      }
    } else {
      atom.notifications.addWarning(`No repository found for \`${paths[index]}\``);
    }
  });
}
