import { CompositeDisposable, Disposable, Panel } from "atom";
import SelectList = require("atom-select-list");
import ActivityLogger from "../activity-logger";
import Repository, { StashCommands } from "../repository";
import { Stash, StashCommand } from "../repository";

class StashListView {
  disposables = new CompositeDisposable();
  isAttached = false;
  listView: SelectList<Stash>;
  panel?: Panel;
  previouslyFocusedElement?: HTMLElement;

  constructor(stashes: Stash[], handleSelection: (stash: Stash) => any) {
    this.listView = new SelectList({
      items: stashes,
      emptyMessage: "Your stash is empty",
      filterKeyForItem: stash => stash.content,
      elementForItem: (stash, _options) => {
        const li = document.createElement("li");
        li.textContent = `${stash.index}: ${stash.label}`;
        return li;
      },
      didCancelSelection: () => {
        this.destroy();
      },
      didConfirmSelection: stash => {
        handleSelection(stash);
        this.destroy();
      }
    });
    this.disposables.add(new Disposable(() => this.listView.destroy()));
    this.attach();
  }

  attach() {
    this.previouslyFocusedElement = document.activeElement as HTMLElement;
    this.panel = atom.workspace.addModalPanel({ item: this.listView.element });
    this.listView.focus();
    this.isAttached = true;
    this.disposables.add(
      new Disposable(() => {
        this.panel!.destroy();
        this.previouslyFocusedElement && this.previouslyFocusedElement.focus();
      })
    );
  }

  destroy = () => {
    this.disposables.dispose();
  };
}

type StashOptionItem = StashCommand & {
  label: string;
};

class StashOptionsView {
  disposables = new CompositeDisposable();
  isAttached = false;
  listView: SelectList<StashOptionItem>;
  panel?: Panel;
  previouslyFocusedElement?: HTMLElement;

  constructor(stash: Stash, handleSelection: (command: StashCommand) => any) {
    this.listView = new SelectList<StashOptionItem>({
      items: Object.entries(StashCommands).map(entry => ({ label: entry[0], ...entry[1] })),
      filterKeyForItem: command => command.label,
      elementForItem: (command, _options) => {
        const li = document.createElement("li");
        const labelDiv = document.createElement("div");
        labelDiv.classList.add("text-highlight");
        labelDiv.textContent = command.label;
        const infoDiv = document.createElement("div");
        infoDiv.classList.add("text-info");
        infoDiv.textContent = stash.label;
        li.append(labelDiv, infoDiv);
        return li;
      },
      didCancelSelection: this.destroy,
      didConfirmSelection: (command: StashCommand) => {
        handleSelection(command);
        this.destroy();
      }
    });
    this.disposables.add(new Disposable(() => this.listView.destroy()));
    this.attach();
  }

  attach() {
    this.previouslyFocusedElement = document.activeElement as HTMLElement;
    this.panel = atom.workspace.addModalPanel({ item: this.listView.element });
    this.listView.focus();
    this.isAttached = true;
    this.disposables.add(
      new Disposable(() => {
        this.panel!.destroy();
        this.previouslyFocusedElement && this.previouslyFocusedElement.focus();
      })
    );
  }

  focus() {
    if (this.isAttached) this.listView.focus();
  }

  destroy = () => {
    this.disposables.dispose();
  };
}

export default async () => {
  const repo = await Repository.getCurrent();
  if (!repo) return atom.notifications.addInfo("No repository found");

  const stashes = await repo.getStashes();
  new StashListView(stashes, stash => {
    const optionsView = new StashOptionsView(stash, async command => {
      repo.actOnStash(stash, command).then(result => {
        ActivityLogger.record({
          repoName: repo.getName(),
          message: `stash@{${stash.index}} ${command.pastTense}`,
          ...result
        });
      });
    });
    optionsView.focus();
  });
};
