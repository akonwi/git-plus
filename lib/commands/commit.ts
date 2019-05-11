import { CompositeDisposable, TextEditor } from "atom";
import fs = require("fs-plus");
import emoji = require("node-emoji");
import Path = require("path");
import { RecordAttributes } from "../activity-logger";
import { gitDo } from "../git-es";
import { Repository } from "../repository";
import { run } from "./";
import { addModified } from "./add";
import { guard, RepositoryCommand } from "./common";

const verboseCommitsEnabled = () => atom.config.get("git-plus.commits.verboseCommits") === true;

const scissorsLine = "------------------------ >8 ------------------------";

const getStatus = async (repo: Repository) => {
  const files = await repo.getStagedFiles();
  if (files.length >= 1) {
    return gitDo(["-c", "color.ui=false", "status"], {
      cwd: repo.workingDirectory
    });
  } else {
    return undefined;
  }
};

const getTemplate = function(filePath?: string) {
  if (!filePath) return "";
  else {
    try {
      return fs
        .readFileSync(fs.absolute(filePath.trim()))
        .toString()
        .trim();
    } catch (e) {
      throw new Error("Your configured commit template file can't be found.");
    }
  }
};

const prepFile = function(
  status: string,
  filePath: string,
  commentChar: string,
  template: string,
  diff?: string
) {
  const commitEditor = guard(
    atom.workspace.paneForURI(filePath),
    x => x.itemForURI(filePath) as TextEditor | undefined
  );
  if (commitEditor) {
    const text = commitEditor.getText();
    const indexOfComments = text.indexOf(commentChar);
    if (indexOfComments > 0) {
      template = text.substring(0, indexOfComments - 1);
    }
  }

  const cwd = Path.dirname(filePath);
  status = status.replace(/\s*\(.*\)\n/g, "\n");
  status = status.trim().replace(/\n/g, `\n${commentChar} `);
  let content = `${template}
${commentChar} ${scissorsLine}
${commentChar} Do not touch the line above.
${commentChar} Everything below will be removed.
${commentChar} Please enter the commit message for your changes. Lines starting
${commentChar} with '${commentChar}' will be ignored, and an empty message aborts the commit.
${commentChar}
${commentChar} ${status}`;
  if (diff) {
    content += `\n${commentChar}
${diff}`;
  }
  return fs.writeFileSync(filePath, content);
};

const destroyCommitEditor = (filePath: string) => {
  const pane = atom.workspace.paneForURI(filePath);
  if (pane) {
    const editor = pane.itemForURI(filePath) as TextEditor | undefined;
    if (editor) editor.destroy();
  }
};

const trimFile = function(filePath: string, commentChar: string) {
  const findScissorsLine = (line: string) => line.includes(`${commentChar} ${scissorsLine}`);

  let content = fs.readFileSync(fs.absolute(filePath)).toString();
  const startOfComments = content.indexOf(content.split("\n").find(findScissorsLine));
  content = startOfComments > 0 ? content.substring(0, startOfComments) : content;
  return fs.writeFileSync(filePath, content);
};

const showFile = function(filePath: string) {
  const commitEditor = guard(atom.workspace.paneForURI(filePath), x => x.itemForURI(filePath));
  if (!commitEditor) {
    if (atom.config.get("git-plus.general.openInPane")) {
      const splitDirection = atom.config.get("git-plus.general.splitPane");
      atom.workspace
        .getCenter()
        .getActivePane()
        [`split${splitDirection}`]();
    }
    return atom.workspace.open(filePath) as Promise<TextEditor>;
  } else {
    if (atom.config.get("git-plus.general.openInPane")) {
      atom.workspace.paneForURI(filePath)!.activate();
    } else {
      atom.workspace.paneForURI(filePath)!.activateItemForURI(filePath);
    }
    return Promise.resolve(commitEditor) as Promise<TextEditor>;
  }
};

interface CommitParams {
  andPush?: boolean;
}

export const commit: RepositoryCommand<CommitParams | void> = {
  id: "commit",

  async run(repo: Repository, params: CommitParams = {}) {
    return new Promise<RecordAttributes>(async resolve => {
      const { andPush } = params;
      const filePath = Path.join(repo.repo.getPath(), "COMMIT_EDITMSG");
      const currentPane = atom.workspace.getActivePane();
      const commentChar = repo.getConfig("core.commentchar") || "#";
      let template: string;
      try {
        template = getTemplate(repo.getConfig("commit.template"));
      } catch (e) {
        atom.notifications.addError(e.message);
        return resolve({
          message: e.message,
          repoName: repo.getName(),
          failed: true,
          output: ""
        });
      }

      const init = async () => {
        let status: string;
        try {
          const statusResult = await getStatus(repo);
          if (!statusResult) {
            atom.notifications.addInfo("Nothing to commit");
            resolve();
            throw new Error();
          }
          if (statusResult.failed) {
            return resolve({
              ...statusResult,
              message: "Failed to get repository status for commit",
              repoName: repo.getName()
            });
          }
          status = statusResult.output;
        } catch (error) {
          atom.notifications.addInfo(error);
          resolve();
          throw new Error(error);
        }
        let diff: string | undefined;
        if (verboseCommitsEnabled()) {
          const args = ["diff", "--color=never", "--staged"];
          if (atom.config.get("git-plus.diffs.wordDiff")) {
            args.push("--word-diff");
          }
          const result = await gitDo(args, { cwd: repo.getWorkingDirectory() }); // .then(diff =>
          if (result.failed) {
            atom.notifications.addWarning("Unable to get diff for verbose commit");
          } else diff = result.output;
        }
        return prepFile(status, filePath, commentChar, template, diff);
      };

      const disposables = new CompositeDisposable();

      const startCommit = () => {
        return showFile(filePath)
          .then(function(textEditor) {
            disposables.add(
              textEditor.onDidSave(async () => {
                trimFile(filePath, commentChar);
                const result = await gitDo(
                  ["commit", "--cleanup=whitespace", `--file=${filePath}`],
                  {
                    cwd: repo.getWorkingDirectory()
                  }
                );
                if (!result.failed) {
                  repo.refresh();
                }
                destroyCommitEditor(filePath);
                resolve({
                  ...result,
                  output: emoji.emojify(result.output),
                  message: "commit",
                  repoName: repo.getName()
                });
                // if (andPush) {
                //   return GitPush(repo);
                // }
              })
            );
            return disposables.add(
              textEditor.onDidDestroy(() => {
                if (!currentPane.isDestroyed()) {
                  currentPane.activate();
                }
                return disposables.dispose();
              })
            );
          })
          .catch(atom.notifications.addError);
      };

      try {
        await init();
        startCommit();
      } catch (message) {
        if (typeof message.includes === "function" && message.includes("CRLF")) {
          startCommit();
        } else {
          resolve({
            failed: true,
            message: "Error during commit command",
            output: message.toString(),
            repoName: repo.getName()
          });
        }
      }
    });
  }
};

export const commitAll: RepositoryCommand = {
  id: "commit-all",

  async run(repo: Repository) {
    const staged = await run(addModified, repo);
    if (staged) {
      return commit.run(repo);
    }
  }
};
