import Repository from "../../repository";
import GitCheckoutFile = require("../git-checkout-file");

export const gitCheckoutFileFromContext = async (treeView: Services.TreeView) => {
  treeView.selectedPaths().forEach(async path => {
    const repo = await Repository.getForPath(path);
    if (!repo) return atom.notifications.addWarning(`No repository found for ${path}`);
    if (await repo.isPathStaged(path)) {
      return atom.notifications.addWarning(`${repo.relativize(path)} can't be reset.`, {
        detail: "This file has staged changes"
      });
    }
    atom.confirm({
      message: `Are you sure you want to reset ${repo.relativize(path)} to HEAD`,
      buttons: {
        Yes: () => GitCheckoutFile(repo.repo, { file: path }),
        No: () => {}
      }
    });
  });
};
