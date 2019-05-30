import { gitDo } from "../git-es";
import { Repository } from "../repository";
import { RepositoryCommand } from "./common";
import { getChosenItem } from "./pull";

interface ChangeBranchOptions {
  remote: boolean;
}

export const changeBranch: RepositoryCommand<ChangeBranchOptions | void> = {
  id: "change-branch",

  async run(repo: Repository, options: ChangeBranchOptions = { remote: false }) {
    const branches = (await repo.getBranches(options.remote)).filter(
      branch => !branch.startsWith("*")
    );

    if (branches.length === 0) {
      atom.notifications.addInfo("There are no other branches");
      return;
    }

    const infoMessage = async () => {
      const currentBranch = await repo.getCurrentBranch();
      if (options.remote) {
        if (currentBranch.upstream) {
          return `Current branch ${currentBranch.name} is tracking ${currentBranch.upstream}`;
        }
        return `Current branch is ${currentBranch.name}`;
      }
      return `Current branch is ${currentBranch.name}`;
    };

    const chosen = await getChosenItem(branches, {
      infoMessage: await infoMessage(),
      elementForItem: (branch: string) => {
        const li = document.createElement("li");
        li.textContent = branch;
        return li;
      }
    });

    if (chosen === undefined) return;

    const args = ["checkout", chosen];
    if (options.remote) args.push("--track");

    const result = await gitDo(args, { cwd: repo.workingDirectory });

    repo.refresh();

    return { ...result, message: `change to branch ${chosen}` };
  }
};

export const changeBranchRemote: RepositoryCommand = {
  id: "change-branch-remote",
  displayName: "Change To Remote Branch",

  run(repo) {
    return changeBranch.run(repo, { remote: true });
  }
};
