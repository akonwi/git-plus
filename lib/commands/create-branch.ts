import { Panel } from "atom";
import { gitDo } from "../git-es";
import { Repository } from "../repository";
import { InputView } from "../views/input-view";
import { RepositoryCommand } from "./common";

export const createBranch: RepositoryCommand = {
  id: "create-branch",

  run(repo: Repository) {
    let inputPanel: Panel;
    const lastPane = atom.workspace.getActivePane();

    const cleanUp = () => {
      inputPanel.destroy();
      lastPane.activate();
    };

    return new Promise(resolve => {
      const input = new InputView({
        placeholder: "New branch name",
        async onSubmit(value: string) {
          if (value === "") return;

          const result = await gitDo(["checkout", "-b", value], {
            cwd: repo.workingDirectory
          });
          resolve({ ...result, message: `Create branch ${value}` });
          repo.refresh();
          cleanUp();
        },
        onCancel() {
          cleanUp();
          resolve();
        }
      });

      inputPanel = atom.workspace.addModalPanel({ item: input });
      input.refs.editor.focus();
    });
  }
};
