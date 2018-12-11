import ActivityLogger from "../activity-logger";
import Repository from "../repository";
import { PullOptions } from "../repository";
import ListView from "../views/list-view";

export default async () => {
  const repo = await Repository.getCurrent();

  if (!repo) return atom.notifications.addInfo("No repository found");

  const remotes = await repo.getRemoteNames();
  if (remotes.length === 0) {
    atom.notifications.addInfo("There is no remote repository to pull from.");
  } else {
    const shouldRebase = atom.config.get("git-plus.remoteInteractions.pullRebase") === true;
    const shouldAutostash = atom.config.get("git-plus.remoteInteractions.pullAutostash") === true;
    const pullOptions: PullOptions = { rebase: shouldRebase, autostash: shouldAutostash };

    if (atom.config.get("git-plus.remoteInteractions.promptForBranch") === true) {
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

      pullOptions.remote = chosenRemote;
      pullOptions.branch = chosenBranch;
    }

    const notification = atom.notifications.addInfo("Pulling...", { dismissable: true });
    const result = await repo.pull(pullOptions);
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `pull`,
      ...result
    });
    notification.dismiss();
  }
};
