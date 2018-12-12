import { CompositeDisposable, Disposable, Emitter, Panel } from "atom";
import SelectList = require("atom-select-list");

interface Item {
  name: string;
}

interface ListViewOptions {
  infoMessage?: string;
}

export default class ListView {
  disposables = new CompositeDisposable();
  emitter = new Emitter();
  isAttached = false;
  listView: SelectList<Item>;
  panel?: Panel;
  previouslyFocusedElement?: HTMLElement;
  result: Promise<string>;

  constructor(remotes: string[], options: ListViewOptions = {}) {
    this.listView = new SelectList({
      items: remotes.map(remote => ({
        name: remote
      })),
      emptyMessage: "No remotes for this repository",
      filterKeyForItem: item => item.name,
      elementForItem: (item, _options) => {
        const li = document.createElement("li");
        li.textContent = item.name;
        return li;
      },
      didCancelSelection: () => {
        this.destroy();
        this.emitter.emit("did-cancel", "User aborted");
      },
      didConfirmSelection: item => {
        this.emitter.emit("did-confirm", item.name);
        this.destroy();
      },
      ...options
    });
    this.disposables.add(new Disposable(() => this.listView.destroy()));
    this.result = new Promise((resolve, reject) => {
      this.emitter.once("did-cancel", reject);
      this.emitter.once("did-confirm", resolve);
    });
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
