import { add, addAll } from "./add";
import { commit } from "./commit";
import { RepositoryCommand } from "./common";

const commands = [add, addAll, commit];

export function getRepoCommands(): RepositoryCommand<any>[] {
  return commands;
}
