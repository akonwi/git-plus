import Repository from "../../repository";
import GitCommit = require("../git-commit");
import { gitAddFromContext } from "./add";

export const gitAddAndCommitFromContext = async treeView => {
  await gitAddFromContext(treeView);

  const [path] = treeView.selectedPaths();
  const repo = await Repository.getForPath(path);

  if (!repo) return atom.notifications.addInfo("No repository found");
  GitCommit(repo.repo);
};
