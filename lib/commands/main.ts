import { gitAdd, gitAddModified } from "./add";
import { gitCommit } from "./commit";

export function getRepoCommands() {
  return [
    gitAdd,
    {
      id: "git-plus:add-all",
      invoke: () => {
        gitAdd.invoke({ stageEverything: true });
      }
    },
    gitAddModified,
    gitCommit
  ];
}
