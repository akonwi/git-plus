// import { TextEditor } from "atom";
// import { readFile, writeFile, writeFileSync } from "fs";
// import { absolute, readFileSync } from "fs-plus";
// import * as emoji from "node-emoji";
// import { join } from "path";
// import { RecordAttributes } from "../activity-logger";
// import { git } from "../git-es";
import { RepositoryCommand } from "../models/common";
import oldCommit = require("../models/git-commit");
import { Repository } from "../repository";

interface CommitParams {
  stageChanges?: boolean;
  andPush?: boolean;
}

class Commit extends RepositoryCommand<CommitParams | void> {
  readonly id = "git-plus:commit";

  protected execute(repo: Repository, params = { stageChanges: false, andPush: false }) {
    oldCommit(repo.repo, params);
  }
}

export const gitCommit = new Commit();

//
// const scissorsLine = "------------------------ >8 ------------------------";
//
// const verboseCommitsEnabled = () => atom.config.get("git-plus.commits.verboseCommits") as boolean;
//
// class Commit extends RepositoryCommand<void> {
//   readonly id = "git-plus:commit";
//
//   protected async execute(repo: Repository, params: void) {
//     const commitFilePath = join(repo.repo.getPath(), "COMMIT_EDITMSG");
//     const commentChar = repo.getConfig("core.commentchar") || "#";
//
//     const stagedFiles = await repo.getStagedFiles();
//     if (stagedFiles.length === 0) {
//       atom.notifications.addInfo("Nothing to commit.");
//       return;
//     }
//     const statusResponse = await this.getStatus(repo);
//
//     if (statusResponse.failed) {
//       atom.notifications.addWarning("Git-Plus is unable to get repo status");
//       return;
//     }
//
//     let template: string;
//     try {
//       template = await this.getTemplate(repo);
//     } catch (error) {
//       atom.notifications.addError("Your configured commit template file can't be found.");
//       return;
//     }
//
//     let diff: string | undefined;
//     if (verboseCommitsEnabled()) {
//       const args = ["diff", "--color=never", "--staged"];
//       if (atom.config.get("git-plus.diffs.wordDiff") === true) args.push("--word-diff");
//       const diffResponse = await git(args, { cwd: repo.getWorkingDirectory() });
//       if (diffResponse.failed) {
//         console.error("Git-Plus: Unable to get diff for verbose commit", diffResponse.output);
//         diff = "Unable to get diff";
//       } else diff = diffResponse.output;
//     }
//
//     try {
//       await this.prepFile(statusResponse.output, commitFilePath, commentChar, template, diff);
//     } catch (error) {
//       atom.notifications.addError("Git-Plus: Error creating commit file", {
//         detail: error.message
//       });
//       return;
//     }
//
//     const editor = await this.show(commitFilePath);
//
//     return new Promise<RecordAttributes>(resolve => {
//       const subscription = editor.onDidSave(async () => {
//         this.trimFile(commitFilePath, commentChar);
//         resolve(this.commit(repo, commitFilePath));
//         repo.refresh();
//         const commitEditor = Editor.getEditor(commitFilePath);
//         commitEditor && (commitEditor as any).destroy();
//         subscription.dispose();
//       });
//     });
//   }
//
//   private async getStatus(repo: Repository) {
//     return git(["-c", "color.ui=false", "status"], { cwd: repo.getWorkingDirectory() });
//   }
//
//   private async getTemplate(repo: Repository) {
//     const filePath = repo.getConfig("commit.template");
//     if (filePath && filePath.trim() !== "") {
//       return new Promise<string>((resolve, reject) => {
//         readFile(absolute(filePath), (error, data) => {
//           if (error) {
//             console.error("Git-Plus: error getting commit template", error);
//             reject(error);
//           } else resolve(data.toString().trim());
//         });
//       });
//     }
//     return "";
//   }
//
//   private async prepFile(
//     status: string,
//     commitFile: string,
//     commentChar: string,
//     template: string,
//     diff?: string
//   ) {
//     const commitPane = atom.workspace.paneForURI(commitFile);
//     const commitEditor = commitPane && (commitPane.itemForURI(commitFile) as TextEditor);
//     if (commitEditor) {
//       const text = commitEditor.getText();
//       const indexOfComments = text.indexOf(commentChar);
//       if (indexOfComments > 0) template = text.substring(0, indexOfComments - 1);
//     }
//
//     status = status
//       .replace(/\s*\(.*\)\n/g, "\n")
//       .trim()
//       .replace(/\n/g, `\n${commentChar} `);
//
//     let content = `${template}
// ${commentChar} ${scissorsLine}
// ${commentChar} Do not touch the line above.
// ${commentChar} Everything below will be removed.
// ${commentChar} Please enter the commit message for your changes. Lines starting
// ${commentChar} with '${commentChar}' will be ignored, and an empty message aborts the commit.
// ${commentChar}
// ${commentChar} ${status}`;
//     if (diff) {
//       content += `\n${commentChar}\n${diff}`;
//     }
//
//     return new Promise((resolve, reject) => {
//       writeFile(commitFile, content, error => {
//         if (error) {
//           console.error("Git-Plus: Unable to create commit file", error);
//           reject(error);
//         } else resolve();
//       });
//     });
//   }
//
//   private show(filePath: string) {
//     const commitPane = atom.workspace.paneForURI(filePath);
//     const commitEditor = commitPane && (commitPane.itemForURI(filePath) as TextEditor);
//     if (commitEditor) {
//       if (atom.config.get("git-plus.general.openInPane")) {
//         atom.workspace.paneForURI(filePath)!.activate();
//       } else atom.workspace.paneForURI(filePath)!.activateItemForURI(filePath);
//       return Promise.resolve(commitEditor);
//     } else {
//       if (atom.config.get("git-plus.general.openInPane")) {
//         const splitDirection = atom.config.get("git-plus.general.splitPane");
//         atom.workspace
//           .getCenter()
//           .getActivePane()
//           [`split${splitDirection}`]();
//       }
//       return atom.workspace.open(filePath) as Promise<TextEditor>;
//     }
//   }
//
//   private trimFile(filePath: string, commentChar: string) {
//     const findScissorsLine = line => line.includes(`${commentChar} ${scissorsLine}`);
//
//     let content = readFileSync(absolute(filePath)).toString();
//     const startOfComments = content.indexOf(content.split("\n").find(findScissorsLine));
//     content = startOfComments > 0 ? content.substring(0, startOfComments) : content;
//     return writeFileSync(filePath, content);
//   }
//
//   private async commit(repo: Repository, filePath: string) {
//     const response = await git(["commit", "--cleanup=whitespace", `--file=${filePath}`], {
//       cwd: repo.getWorkingDirectory()
//     });
//
//     return {
//       ...response,
//       repoName: repo.getName(),
//       message: "commit",
//       output: emoji.emojify(response.output)
//     };
//     // .then(function(data) {
//     //   ActivityLogger.record({ repoName, message: 'commit', output: emoji.emojify(data)});
//     //   destroyCommitEditor(filePath);
//     //   return git.refresh();}).catch(function(data) {
//     //   ActivityLogger.record({repoName,  message: 'commit', output: data, failed: true });
//     //   return destroyCommitEditor(filePath);
//     // });
//   }
// }
