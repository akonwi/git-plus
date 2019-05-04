import { add, addAll } from "./add";
import { RepositoryCommand } from "./common";

const commands = [add, addAll];
export function getRepoCommands(): RepositoryCommand<any>[] {
  return commands;
}
