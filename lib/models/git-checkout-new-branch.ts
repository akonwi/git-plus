import { RecordAttributes } from "../activity-logger";
import { Repository } from "../repository";
import { Input } from "../views/InputView";
import { RepositoryCommand } from "./common";

class CheckoutNewBranch extends RepositoryCommand<void> {
  protected execute(repo: Repository) {
    const currentPane = atom.workspace.getActivePane();
    let panel;

    return new Promise<RecordAttributes>(resolve => {
      const destroy = () => {
        panel.destroy();
        currentPane.activate();
      };
      const input = new Input({
        placeholderText: "New branch name",
        cancel: destroy,
        async onValue(name: string) {
          const result = await repo.createBranch(name);
          destroy();
          resolve({ ...result, message: `change to new branch ${name}`, repoName: repo.getName() });
          repo.refresh();
        }
      });

      panel = atom.workspace.addModalPanel({ item: input });
      panel.show();
      (input as any).refs.editor.focus();
    });
  }
}

const gitChangeToNewBranch = new CheckoutNewBranch();

export { gitChangeToNewBranch };
