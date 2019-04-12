import { Repository } from "../repository";
import { Editor, RepositoryCommand } from "./common";

export const LogViewURI = "atom://git-plus:log";

interface Params {
  onlyCurrentFile: boolean;
}

class ShowLog extends RepositoryCommand<Params | void> {
  async execute(repo: Repository, params = { onlyCurrentFile: false }) {
    const currentFile = Editor.getCurrentFileInRepo(repo);
    const view = await atom.workspace.open<any>(LogViewURI);

    if (params.onlyCurrentFile) view.currentFileLog(repo.repo, currentFile);
    else view.branchLog(repo.repo);
  }
}

const showLog = new ShowLog();

export { showLog };
