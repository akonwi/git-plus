import { CompositeDisposable, Disposable, Emitter, GitRepository, Panel } from "atom";
import SelectList = require("atom-select-list");

interface RepoItem {
  repo: GitRepository;
  name: string;
}

class RepoListView {
  disposables = new CompositeDisposable();
  isAttached = false;
  list: SelectList<RepoItem>;
  previouslyFocusedElement?: HTMLElement;
  panel?: Panel;
  result: Promise<GitRepository>;
  emitter: Emitter;

  constructor(repos: GitRepository[]) {
    this.emitter = new Emitter();
    this.list = new SelectList({
      items: repos.map(repository => {
        const path = repository.getWorkingDirectory();
        return {
          repo: repository,
          name: path.substring(path.lastIndexOf("/") + 1)
        };
      }),
      filterKeyForItem(item) {
        return item.name;
      },
      infoMessage: "Which Repo?",
      elementForItem(item, _options) {
        const li = document.createElement("li");
        li.textContent = item.name;
        return li;
      },
      didCancelSelection: () => {
        this.destroy();
        this.emitter.emit("did-cancel", "User aborted");
      },
      didConfirmSelection: item => {
        this.emitter.emit("did-confirm", item.repo);
        this.destroy();
      }
    });
    this.result = new Promise((resolve, reject) => {
      this.emitter.once("did-cancel", reject);
      this.emitter.once("did-confirm", resolve);
    });
    this.disposables.add(
      new Disposable(() => {
        this.list.destroy();
        this.emitter.dispose();
      })
    );
    this.attach();
  }

  attach() {
    this.previouslyFocusedElement = document.activeElement as HTMLElement;
    this.panel = atom.workspace.addModalPanel({ item: this.list.element });
    this.list.focus();
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
  }
}

export default async (repos: GitRepository[]): Promise<GitRepository> => {
  return new RepoListView(repos).result;
};
