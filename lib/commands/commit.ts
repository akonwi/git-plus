import { CompositeDisposable, TextEditor } from "atom";
import fs = require("fs-plus");
import emoji = require("node-emoji");
import Path = require("path");
import { RecordAttributes } from "../activity-logger";
import { gitDo } from "../git-es";
import { Repository } from "../repository";
import { run } from "./";
import { addModified } from "./add";
import { CommandResult, guard, RepositoryCommand } from "./common";

const verboseCommitsEnabled = () => atom.config.get("git-plus.commits.verboseCommits") === true;

const scissorsLine = "------------------------ >8 ------------------------";

const getStatus = async (repo: Repository) => {
  return gitDo(["-c", "color.ui=false", "status"], {
    cwd: repo.workingDirectory
  });
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
    return new Promise<CommandResult>(async resolve => {
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
          failed: true,
          output: ""
        });
      }

      const init = async () => {
        let status: string;
        try {
          const files = await repo.getStagedFiles();
          if (files.length === 0) {
            atom.notifications.addInfo("Nothing to commit");
            resolve();
            throw new Error();
          }
          const statusResult = await getStatus(repo);
          if (statusResult.failed) {
            return resolve({
              ...statusResult,
              message: "Failed to get repository status for commit"
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
                  message: "commit"
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
            output: message.toString()
          });
        }
      }
    });
  }
};

function parsePreviousCommit(prevCommit: string) {
  let message = "";
  const messageResult = /\n{2,}/.exec(prevCommit);
  if (messageResult) {
    message = prevCommit.substring(0, messageResult.index);
    prevCommit = prevCommit.substring(messageResult.index).trim();
  }

  const fileStatusRegex = /[ MADRCU?!]\s+/;
  const changedFiles = prevCommit
    .split("\n")
    .map(line => {
      const fileStatusResult = fileStatusRegex.exec(line);
      if (fileStatusResult) {
        const [mode, path] = line.substring(fileStatusResult.index).split(/\s+/);
        return {
          mode,
          path
        };
      }
    })
    .filter(Boolean);

  return { message, changedFiles };
}

function uniqueOfBothSets(previousFiles, currentFiles) {
  const currentPaths = currentFiles.map(({ path }) => path);
  return previousFiles.filter(p => Array.from(currentPaths).includes(p.path) === false);
}

function prettifyFileStatuses(files: { mode: string; path: string }[]) {
  return files.map(function({ mode, path }) {
    switch (mode) {
      case "M":
        return `modified:   ${path}`;
      case "A":
        return `new file:   ${path}`;
      case "D":
        return `deleted:   ${path}`;
      case "R":
        return `renamed:   ${path}`;
    }
  }) as string[];
}

const cleanupUnstagedText = function(status) {
  const unstagedFiles = status.indexOf("Changes not staged for commit:");
  if (unstagedFiles >= 0) {
    const text = status.substring(unstagedFiles);
    return (status = `${status.substring(0, unstagedFiles - 1)}\n${text.replace(
      /\s*\(.*\)\n/g,
      ""
    )}`);
  } else {
    return status;
  }
};

function prepAmendFile(
  status: string,
  filePath: string,
  commentChar: string,
  message: string,
  prevChangedFiles: string[]
) {
  status = cleanupUnstagedText(status);
  status = status.replace(/\s*\(.*\)\n/g, "\n").replace(/\n/g, `\n${commentChar} `);
  if (prevChangedFiles.length > 0) {
    status = `Changes to be committed:
${prevChangedFiles.map(f => `${commentChar}   ${f}`).join("\n")}
${commentChar}
${commentChar} ${status}`;
  }
  return fs.writeFileSync(
    filePath,
    `${message}
${commentChar} Please enter the commit message for your changes. Lines starting
${commentChar} with '${commentChar}' will be ignored, and an empty message aborts the commit.
${commentChar}
${commentChar} ${status}`
  );
}

export const commitAll: RepositoryCommand = {
  id: "commit-all",

  async run(repo: Repository) {
    const staged = await run(addModified, repo);
    if (staged) {
      return commit.run(repo);
    }
  }
};

export const commitAmend: RepositoryCommand = {
  id: "commit-amend",

  async run(repo: Repository) {
    const filePath = Path.join(repo.repo.getPath(), "COMMIT_EDITMSG");
    const currentPane = atom.workspace.getActivePane();
    const commentChar = repo.getConfig("core.commentchar") || "#";

    const logResult = await gitDo(["whatchanged", "-1", "--format=%B"], {
      cwd: repo.workingDirectory
    });

    if (logResult.failed) {
      atom.notifications.addError("Unable to get log for previous commit");
      return;
    }

    const { message, changedFiles } = parsePreviousCommit(logResult.output);

    if (message === "") {
      atom.notifications.addError("Unable to determine previous commit message");
      return;
    }

    const stagedFiles = await repo.getStagedFiles();
    const stagedFilesForCommit = prettifyFileStatuses(uniqueOfBothSets(changedFiles, stagedFiles));

    const statusResult = await getStatus(repo);
    if (statusResult.failed) {
      return {
        ...statusResult,
        message: "Failed to get repository status for commit"
      };
    }

    prepAmendFile(statusResult.output, filePath, commentChar, message, stagedFilesForCommit);

    const disposables = new CompositeDisposable();

    const editor = await showFile(filePath);

    let resolved = false;
    return new Promise<CommandResult | void>(resolve => {
      disposables.add(
        editor.onDidSave(async () => {
          const args = ["commit", "--amend", "--cleanup=strip", `--file=${filePath}`];
          const result = await gitDo(args, { cwd: repo.workingDirectory });

          if (!result.failed) {
            repo.refresh();
          }
          resolved = true;
          destroyCommitEditor(filePath);
          resolve({
            ...result,
            output: emoji.emojify(result.output),
            message: "commit"
          });
        }),

        editor.onDidDestroy(() => {
          if (!resolved) resolve();
          if (!currentPane.isDestroyed()) {
            currentPane.activate();
          }
          disposables.dispose();
        })
      );
    });
  }
};
