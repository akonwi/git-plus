import ActivityLogger from "../activity-logger";
import Repository from "../repository";
import { PushOptions } from "../repository";
import ListView from "../views/list-view";

export default async (setUpstream: boolean = false) => {
  const repo = await Repository.getCurrent();
  if (!repo) return atom.notifications.addInfo("No repository found");
  const repoName = repo.getName();
  const pushOptions: PushOptions = { setUpstream };

  const remotes = await repo.getRemoteNames();
  if (remotes.length === 0) atom.notifications.addInfo("There is no remote repository to push to.");
  else {
    if (setUpstream) {
      pushOptions.setUpstream = true;
      pushOptions.remote = remotes[0];
      pushOptions.branch = "HEAD";
    } else {
      if (atom.config.get("git-plus.remoteInteractions.promptForBranch")) {
        let chosenRemote;
        if (remotes.length === 1) chosenRemote = remotes[0];
        else chosenRemote = await new ListView(remotes).result;

        let chosenBranch;
        const branches = await repo.getBranchesForRemote(chosenRemote);
        if (branches.length === 1) chosenBranch = branches[0];
        else {
          chosenBranch = await new ListView(branches, {
            infoMessage: `Select branch on ${chosenRemote}`
          }).result;
        }
        pushOptions.remote = chosenRemote;
        pushOptions.branch = chosenBranch;
      }

      if (atom.config.get("git-plus.remoteInteractions.pullBeforePush")) {
        const result = await repo.pull({
          rebase: atom.config.get("git-plus.remoteInteractions.pullRebase") === true,
          autostash: atom.config.get("git-plus.remoteInteractions.pullAutostash") === true,
          remote: pushOptions.remote,
          branch: pushOptions.remote
        });
        ActivityLogger.record({
          message: "pull before push",
          repoName,
          ...result
        });
        if (result.failed) return;
      }
    }

    const notification = atom.notifications.addInfo("Pushing...", { dismissable: true });
    const result = await repo.push(pushOptions);
    notification.dismiss();
    ActivityLogger.record({
      message: `push`,
      repoName,
      ...result
    });
  }
};
