import * as fs from "fs-plus";
import * as os from "os";
import * as path from "path";
import { CommitView } from "../views/commit-view";
import { CommandResult, RepositoryCommand } from "./common";

function splitPaneIfNecessary() {
  if (atom.workspace.getCenter().getPaneItems().length === 0) return;
  if (atom.config.get("git-plus.general.openInPane")) {
    const splitDirection = atom.config.get("git-plus.general.splitPane");
    atom.workspace
      .getCenter()
      .getActivePane()
      [`split${splitDirection}`]();
  }
}

function writeFile(filePath: string, text: string) {
  return new Promise((resolve, reject) => {
    fs.writeFile(filePath, text, error => {
      if (error) reject(error);
      else resolve();
    });
  });
}

export const commit: RepositoryCommand = {
  id: "commit",

  async run(repo) {
    if (atom.workspace.paneForURI(CommitView.URI)) {
      atom.workspace.open(CommitView.URI);
      return;
    }

    const stagedFiles = await repo.getStagedFiles();
    if (stagedFiles.length === 0) {
      atom.notifications.addInfo("There are no staged files to commit.");
      return;
    }

    splitPaneIfNecessary();

    const cleanUp = () => {
      const pane = atom.workspace.paneForURI(CommitView.URI);
      pane && pane.destroy();
    };

    return new Promise<CommandResult | void>(async resolve => {
      const view = new CommitView({
        stagedFiles,
        repo,
        onDidCancel: () => {
          resolve();
          cleanUp();
        },
        onDidSave: async text => {
          const filePath = path.join(os.tmpdir(), "git-plus_commit");
          await writeFile(filePath, text);
          const result = await repo.do(["commit", "--cleanup=whitespace", `--file=${filePath}`]);
          resolve({ ...result, message: "commit" });
          cleanUp();
        }
      });

      await atom.workspace.open(view);
    });
  }
};
