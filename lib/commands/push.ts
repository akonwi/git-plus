import { Repository } from "../repository";
import { PushOptions } from "../repository";
import { run } from "./";
import { RepositoryCommand } from "./common";
import { getChosenItem, pull } from "./pull";

export const push: RepositoryCommand<PushOptions | void> = {
  id: "push",

  async run(repo: Repository, options?: PushOptions) {
    const remotes = await repo.getRemoteNames();
    if (remotes.length === 0) {
      atom.notifications.addInfo("There is no remote repository to push to.");
      return;
    }

    const pushOptions: PushOptions = { ...options };

    if (options && options.setUpstream) {
      pushOptions.setUpstream = true;
      pushOptions.remote = remotes[0];
      pushOptions.branch = "HEAD";
    } else {
      if (atom.config.get("git-plus.remoteInteractions.promptForBranch")) {
        let chosenRemote: string;
        if (remotes.length === 1) chosenRemote = remotes[0];
        else {
          const chosen = await getChosenItem(remotes);
          if (!chosen) return;
          chosenRemote = chosen;
        }

        let chosenBranch: string;
        const branches = await repo.getBranchesForRemote(chosenRemote);
        if (branches.length === 1) chosenBranch = branches[0];
        else {
          const chosen = await getChosenItem(branches, {
            infoMessage: `Select branch on ${chosenRemote}`
          });
          if (!chosen) return;
          chosenBranch = chosen;
        }
        pushOptions.remote = chosenRemote;
        pushOptions.branch = chosenBranch;
      }

      if (atom.config.get("git-plus.remoteInteractions.pullBeforePush")) {
        const success = await run(async () => {
          const result = await pull.run(repo, {
            rebase: atom.config.get("git-plus.remoteInteractions.pullRebase") === true,
            autostash: atom.config.get("git-plus.remoteInteractions.pullAutostash") === true,
            remote: pushOptions.remote,
            branch: pushOptions.branch
          });
          if (result) {
            return { ...result, message: "pull before push" };
          }
        });

        if (!success) {
          return;
        }
      }
    }

    const notification = atom.notifications.addInfo("Pushing...", {
      dismissable: true,
      detail: " "
    });
    const view = (atom.views.getView(notification) as any).element;
    const content = view.querySelector(".detail-content") as HTMLElement;
    content.innerHTML = `<div class='block'>
      <progress class='inline-block' style="width: 100%;"></progress>
    </div>`;

    const result = await repo.push(pushOptions);
    notification.dismiss();

    return { ...result, message: "push" };
  }
};
