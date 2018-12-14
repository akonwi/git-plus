import Repository from "../../repository";
import GitPull = require("../git-pull");

export async function gitPullFromContext(treeView: Services.TreeView) {
  const paths = treeView.selectedPaths();
  const reposForPaths = await Promise.all(paths.map(Repository.getForPath));

  const seenRepoDirectories: string[] = [];
  reposForPaths.forEach((repo, index) => {
    if (repo) {
      const repoDirectory = repo.getWorkingDirectory();
      if (!seenRepoDirectories.includes(repoDirectory)) {
        GitPull(repo.repo);
        seenRepoDirectories.push(repoDirectory);
      }
    } else {
      atom.notifications.addWarning(`No repository found for \`${paths[index]}\``);
    }
  });
}
