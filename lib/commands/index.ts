import { Container } from "../container";
import { Repository } from "../repository";
import { add, addAll, addModified } from "./add";
import { commit, commitAll, commitAmend } from "./commit";
import { RepositoryCommand } from "./common";

const commands = [add, addAll, addModified, commit, commitAll, commitAmend];

export function getRepoCommands(): RepositoryCommand<any>[] {
  return commands;
}

export async function run(command: RepositoryCommand<any>, repo?: Repository) {
  repo = repo || (await Repository.getCurrent());
  if (repo === undefined) return atom.notifications.addInfo("No repository found");
  const result = await command.run(repo, undefined);
  if (result) {
    Container.logger.record({ ...result, repoName: repo.name });
    return result.failed === false;
  }
  return true;
}