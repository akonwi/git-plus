import { File } from "atom";
import { gitDo } from "../git-es";
import { Repository } from "../repository";
import ProjectsListView = require("../views/projects-list-view");
import { guard, NonRepositoryCommand } from "./common";

export const init: NonRepositoryCommand<void> = {
  id: "init",
  async run(_) {
    const workspacePaths = atom.project.getPaths();
    const currentFile = guard(atom.workspace.getActiveTextEditor(), e => e.getPath());

    let folderPath: string;
    if (workspacePaths.length === 1) {
      folderPath = workspacePaths[0];
    } else if (currentFile) {
      folderPath = new File(currentFile).getParent().getPath();
    } else {
      folderPath = await new ProjectsListView().result;
    }

    const result = await gitDo(["init"], { cwd: folderPath });
    const repo = await Repository.getForPath(folderPath);
    atom.project.setPaths(atom.project.getPaths());
    return { ...result, message: "init", repoName: repo!.getName() };
  }
};
