import Repository from "../../repository";
import GitPush = require("../git-push");

export async function gitPushFromContext(treeView: Services.TreeView) {
  const paths = treeView.selectedPaths();
  const reposForPaths = await Promise.all(paths.map(Repository.getForPath));

  const seenRepoDirectories: string[] = [];
  reposForPaths.forEach((repo, index) => {
    if (repo) {
      const repoDirectory = repo.getWorkingDirectory();
      if (!seenRepoDirectories.includes(repoDirectory)) {
        GitPush(repo.repo);
        seenRepoDirectories.push(repoDirectory);
      }
    } else {
      atom.notifications.addWarning(`No repository found for \`${paths[index]}\``);
    }
  });
}
