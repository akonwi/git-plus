import { GitRepository } from "atom";
import ActivityLogger from "../activity-logger";
import Repository from "../repository";
import GitCheckoutFile = require("./git-checkout-file");
import GitCommit = require("./git-commit");
import GitDiff = require("./git-diff");
import GitDiffAll = require("./git-diff-all");
import GitDiffBranchFiles = require("./git-diff-branch-files");
import GitDiffBranches = require("./git-diff-branches");
import GitDiffTool = require("./git-difftool");
import GitPull = require("./git-pull");
import GitPush = require("./git-push");

const logNoRepoFound = () => atom.notifications.addInfo("No repository found");

export async function add(treeView: Services.TreeView) {
  const filesPerRepo = new Map<GitRepository, string[]>();

  const paths = treeView.selectedPaths();

  await Promise.all(
    paths.map(async path => {
      const repo = await Repository.getForPath(path);

      if (!repo) {
        return atom.notifications.addInfo(
          `No repository found for ${atom.project.relativizePath(path)[1]}`
        );
      }

      const files = filesPerRepo.get(repo.repo) || [];
      files.push(path);
      filesPerRepo.set(repo.repo, files);
    })
  );

  for (const [gitRepo, files] of filesPerRepo.entries()) {
    const repo = await new Repository(gitRepo);
    const result = await repo.stage(files);

    let localizedPaths;
    if (files.length === 1 && files[0] === repo.getWorkingDirectory()) {
      localizedPaths = "all changes";
    } else localizedPaths = files.map(file => repo.relativize(file)).join(", ");
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `add ${localizedPaths}`,
      ...result
    });
  }
}

export async function addAndCommit(treeView: Services.TreeView) {
  await add(treeView);

  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return logNoRepoFound();
  GitCommit(repo.repo);
}

export async function checkoutFile(treeView: Services.TreeView) {
  treeView.selectedPaths().forEach(async path => {
    const repo = await Repository.getForPath(path);
    if (!repo) return atom.notifications.addWarning(`No repository found for \`${path}\``);

    const entry = treeView.entryForPath(path);
    if (entry.classList.contains("file") && !repo.isPathModified(path)) {
      return atom.notifications.addInfo(`\`${repo.relativize(path)}\` has no changes to reset.`);
    }
    if (await repo.isPathStaged(path)) {
      return atom.notifications.addWarning(`\`${repo.relativize(path)}\` can't be reset.`, {
        detail: "It has staged changes, which must be unstaged first"
      });
    }
    atom.confirm({
      message: `Are you sure you want to reset ${repo.relativize(path)} to HEAD`,
      buttons: {
        Yes: () => GitCheckoutFile(repo.repo, { file: path }),
        No: () => {}
      }
    });
  });
}

export async function diffFileAgainstBranch(treeView: Services.TreeView) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return atom.notifications.addWarning(`No repository found for \`${path}\``);

  GitDiffBranchFiles(repo.repo, path);
}

export async function diffBranches(treeView: Services.TreeView) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);
  if (!repo) return atom.notifications.addWarning(`No repository found for \`${path}\``);

  GitDiffBranches(repo.repo);
}

export async function diffTool(treeView: Services.TreeView) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return atom.notifications.addWarning(`No repository found for ${path}`);
  if (!repo.isPathModified(path)) {
    return atom.notifications.addInfo(`\`${repo.relativize(path)}\` has no changes to diff`);
  }

  GitDiffTool(repo.repo, { file: repo.relativize(path) });
}

export async function diff(treeView: Services.TreeView, all = false) {
  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return atom.notifications.addWarning(`No repository found for \`${path}\``);
  if (!all && !repo.isPathModified(path)) {
    return atom.notifications.addInfo(`\`${repo.relativize(path)}\` has no changes to diff`);
  }

  all ? GitDiffAll(repo.repo) : GitDiff(repo.repo, { file: repo.relativize(path) });
}

export async function pull(treeView: Services.TreeView) {
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

export async function push(treeView: Services.TreeView) {
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

export function unstage(treeView: Services.TreeView) {
  treeView.selectedPaths().forEach(async path => {
    const repo = await Repository.getForPath(path);

    if (!repo) return atom.notifications.addWarning(`No repository found for ${path}`);

    const pathIsStaged = await repo.isPathStaged(path);
    if (repo.getWorkingDirectory() !== path && !pathIsStaged) {
      return atom.notifications.addInfo(`\`${repo.relativize(path)}\` can't be unstaged.`, {
        detail: "This file has no staged changes"
      });
    }

    const result = await repo.unstage(path);
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `Unstage ${path}`,
      ...result
    });
  });
}
