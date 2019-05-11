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
  stageModified?: boolean;
}

export const add: RepositoryCommand<void | AddParams> = {
  id: "add",

  async run(repo: Repository, params: AddParams = {}) {
    let path;
    let messagePath;

    if (params.stageEverything) {
      path = ".";
      messagePath = "all";
    } else if (params.stageModified) {
      path = ".";
      messagePath = "modified";
    } else {
      path = getCurrentFileInRepo(repo) || ".";
      messagePath = path === "." ? "all" : path;
    }

    const result = await repo.stage([path], { update: params.stageModified });
    return {
      ...result,
      message: `add ${messagePath}`
    };
  }
};

export const addAll: RepositoryCommand<void> = {
  id: "add-all",
  run: repo => add.run(repo, { stageEverything: true })
};

export const addModified: RepositoryCommand = {
  id: "add-modified",
  run: async repo => add.run(repo, { stageModified: true })
};
