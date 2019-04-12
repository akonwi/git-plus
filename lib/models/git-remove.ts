import git from "../git-es";
import { Repository } from "../repository";
import { Editor, RepositoryCommand } from "./common";

// git = require '../git'
// ActivityLogger = require('../activity-logger').default
// Repository = require('../repository').default
// RemoveListView = require '../views/remove-list-view'
//
// gitRemove = (repo, {showSelector}={}) ->
// cwd = repo.getWorkingDirectory()
// currentFile = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
// if currentFile? and not showSelector
// if repo.isPathModified(currentFile) is false or window.confirm('Are you sure?')
// atom.workspace.getActivePaneItem().destroy()
// repoName = new Repository(repo).getName()
// git.cmd(['rm', '-f', '--ignore-unmatch', currentFile], {cwd})
// .then (data) -> ActivityLogger.record({repoName, message: "Remove '#{prettify data}'", output: data})
// .catch (data) -> ActivityLogger.record({repoName, message: "Remove '#{prettify data}'", output: data, failed: true})
// else
// git.cmd(['rm', '-r', '-n', '--ignore-unmatch', '-f', '*'], {cwd})
// .then (data) -> new RemoveListView(repo, prettify(data))
//
// prettify = (data) ->
// data = data.match(/rm ('.*')/g)
// if data
// for file, i in data
// data[i] = file.match(/rm '(.*)'/)[1]
// else
// data
//
// module.exports = gitRemove

interface Params {
  showSelector: boolean;
}

// data = data.match(/rm ('.*')/g)
// if data
// for file, i in data
// data[i] = file.match(/rm '(.*)'/)[1]
// else
// data

class Remove extends RepositoryCommand<Params | void> {
  async execute(repo: Repository, options = { showSelector: false }) {
    if (options.showSelector) {
      atom.notifications.addWarning("TODO: implement this feature");
      // git(['rm', '-r', '-n', '--ignore-unmatch', '-f', '*'], {cwd})
      // .then (data) -> new RemoveListView(repo, prettify(data))
    } else {
      let currentFile = Editor.getCurrentFileInRepo(repo);
      if (currentFile === undefined) return;
      currentFile = repo.relativize(currentFile)!;

      if (!repo.isPathModified(currentFile) || window.confirm("Are you sure?")) {
        const result = await git(["rm", "-f", "--ignore-unmatch", currentFile], {
          cwd: repo.getWorkingDirectory()
        });

        return {
          ...result,
          message: `Remove ${this.prettify(result.output)}`,
          repoName: repo.getName()
        };
      }
    }
    return;
  }

  private prettify(text: string): string {
    const regex = /rm ('.*')/g;

    const data = text.match(regex);

    if (!data) return text;

    data.forEach((file, i) => {
      data[i] = file.match(regex)![1] || "";
    });

    return data.toString();
  }
}

const gitRemove = new Remove();

export { gitRemove };
