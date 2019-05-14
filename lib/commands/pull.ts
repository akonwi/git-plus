import { Panel } from "atom";
import SelectList = require("atom-select-list");
import { PullOptions, Repository } from "../repository";
import { RepositoryCommand } from "./common";

export const pull: RepositoryCommand<PullOptions | void> = {
  id: "pull",

  async run(repo: Repository, options?: PullOptions) {
    const remotes = await repo.getRemoteNames();
    if (remotes.length === 0) {
      atom.notifications.addInfo("There is no remote repository to pull from.");
      return;
    }

    let pullOptions: PullOptions;

    if (options) {
      pullOptions = options;
    } else {
      const shouldRebase = atom.config.get("git-plus.remoteInteractions.pullRebase") === true;
      const shouldAutostash = atom.config.get("git-plus.remoteInteractions.pullAutostash") === true;
      pullOptions = { rebase: shouldRebase, autostash: shouldAutostash };

      if (atom.config.get("git-plus.remoteInteractions.promptForBranch") === true) {
        let chosenRemote: string;
        if (remotes.length === 1) chosenRemote = remotes[0];
        else {
          const chosen = await getChosenItem(remotes);
          if (chosen === undefined) return;
          chosenRemote = chosen;
        }

        let chosenBranch: string;
        const branches = await repo.getBranchesForRemote(chosenRemote);
        if (branches.length === 1) chosenBranch = branches[0];
        else {
          const chosen = await getChosenItem(branches, {
            infoMessage: `Select branch on ${chosenRemote}`
          });
          if (chosen === undefined) return;
          chosenBranch = chosen;
        }

        pullOptions.remote = chosenRemote;
        pullOptions.branch = chosenBranch;
      }
    }

    const notification = atom.notifications.addInfo("Pulling...", {
      dismissable: true,
      detail: " "
    });
    const view = (atom.views.getView(notification) as any).element;
    const content = view.querySelector(".detail-content") as HTMLElement;
    content.innerHTML = `<div class='block'>
      <progress class='inline-block' style="width: 100%;"></progress>
    </div>`;

    const result = await repo.pull(pullOptions);
    notification.dismiss();

    return { ...result, message: "pull" };
  }
};

export async function getChosenItem(items: string[], options = {}) {
  const previouslyFocusedElement = document.activeElement as HTMLElement | null;
  let panel: Panel;

  return new Promise<string | undefined>(resolve => {
    const listView = new SelectList({
      items,
      emptyMessage: "No matches for query",
      filterKeyForItem: item => item,
      elementForItem: item => {
        const li = document.createElement("li");
        li.textContent = item;
        return li;
      },
      didCancelSelection: () => {
        resolve();
        previouslyFocusedElement && previouslyFocusedElement.focus();
        panel && panel.destroy();
      },
      didConfirmSelection: item => {
        resolve(item);
        previouslyFocusedElement && previouslyFocusedElement.focus();
        panel && panel.destroy();
      },
      ...options
    });
    panel = atom.workspace.addModalPanel({ item: listView.element });
    panel.onDidDestroy(() => {
      listView.destroy();
    });
    listView.focus();
  });
}
