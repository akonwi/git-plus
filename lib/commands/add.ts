import { Editor, RepositoryCommand } from "../models/common";
import Repository from "../repository";

interface AddParams {
  stageEverything?: boolean;
}

class Add extends RepositoryCommand<AddParams | void> {
  readonly id = "git-plus:add";

  async execute(repo: Repository, params = { stageEverything: false }) {
    const path = params.stageEverything ? "." : Editor.getCurrentFileInRepo(repo) || ".";
    const result = await repo.stage([path]);
    return {
      repoName: repo.getName(),
      message: `add ${path}`,
      ...result
    };
  }
}

class AddModified extends RepositoryCommand<void> {
  readonly id = "git-plus:add-modified";

  async execute(repo: Repository) {
    const result = await repo.stage(["."], { update: true });

    return {
      repoName: repo.getName(),
      message: `add modified files`,
      ...result
    };
  }
}

const gitAdd = new Add();
const gitAddModified = new AddModified();

export { gitAdd, gitAddModified };
