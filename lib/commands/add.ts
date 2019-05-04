import Repository from "../repository";
import { RepositoryCommand } from "./common";

const getCurrentFileInRepo = (repo: Repository) => {
  const activeEditor = atom.workspace.getActiveTextEditor();
  const path = activeEditor && activeEditor.getPath();
  if (!path) return null;
  return repo.relativize(path);
};

interface AddParams {
  stageEverything?: boolean;
}

export const add: RepositoryCommand<void | AddParams> = {
  id: "add",

  async run(repo: Repository, params: AddParams = { stageEverything: false }) {
    const path = params.stageEverything ? "." : getCurrentFileInRepo(repo) || ".";
    const result = await repo.stage([path]);
    return {
      ...result,
      repoName: repo.getName(),
      message: `add ${path}`
    };
  }
};

export const addAll: RepositoryCommand<void> = {
  id: "add-all",
  run(repo) {
    add.run(repo, { stageEverything: true });
  }
};
