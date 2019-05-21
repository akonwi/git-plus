import { Container } from "../container";
import { Repository } from "../repository";
import { add, addAll, addModified } from "./add";
import { changeBranch, changeBranchRemote } from "./change-branch";
import { commit, commitAll, commitAmend } from "./commit";
import { CommandResult, RepositoryCommand } from "./common";
import { pull } from "./pull";
import { push } from "./push";

const commands = [
  add,
  addAll,
  addModified,
  commit,
  commitAll,
  commitAmend,
  pull,
  push,
  changeBranch,
  changeBranchRemote
];

export function getRepoCommands(): RepositoryCommand<any>[] {
  return commands;
}

type CommandFunction = () => Promise<CommandResult | undefined>;

export async function run<P>(
  command: RepositoryCommand<P> | CommandFunction,
  repo?: Repository,
  options?: P
) {
  repo = repo || (await Repository.getCurrent());
  if (repo === undefined) {
    atom.notifications.addInfo("No repository found");
    return false;
  }

  let result: CommandResult | undefined | void;
  if (isRepositoryCommand(command)) {
    result = await command.run(repo, options as any);
  } else {
    result = await command();
  }

  if (result) {
    Container.logger.record({ ...result, repoName: repo.name });
    return result.failed === false;
  }
  return true;
}

function isRepositoryCommand(
  thing: RepositoryCommand<any> | CommandFunction
): thing is RepositoryCommand<any> {
  const t = thing as any;
  return t.id && t.run;
}
