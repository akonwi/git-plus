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
    const branches = await repo.getBranches(options.remote);

    if (branches.length === 0) {
      return;
    } else if (branches.length === 1) {
      atom.notifications.addWarning("There are no other branches");
      return;
    }

    const chosen = await getChosenItem(branches, {
      elementForItem: branch => {
        const [current, name] = branch.startsWith("*")
          ? [true, branch.substring(1)]
          : [false, branch];
        const li = document.createElement("li");
        const div = document.createElement("div");
        div.classList.add("pull-right");
        if (current) {
          const span = document.createElement("span");
          span.innerText = "HEAD";
          div.appendChild(span);
        }
        li.textContent = name;
        li.appendChild(div);
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
