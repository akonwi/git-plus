import { BufferedProcess, Directory, File, GitRepository } from "atom";
import * as fs from "fs";
import * as Path from "path";
import chooseRepo from "./models/choose-repo";

const reposByDirectory: Map<Directory, GitRepository> = new Map();

const getRepoForDirectory = async (directory: Directory): Promise<GitRepository | undefined> => {
  const repo = await atom.project.repositoryForDirectory(directory);
  if (repo) {
    reposByDirectory.set(directory, repo);
    return repo;
  }
};

const getCachedRepo = (path: string): GitRepository | undefined => {
  const iterator = reposByDirectory.entries();
  let entry = iterator.next();
  while (!entry.done) {
    const [directory, repo] = entry.value;
    if (directory.contains(path)) {
      if (repo.isDestroyed()) {
        reposByDirectory.delete(directory);
        return undefined;
      } else return repo;
    }

    entry = iterator.next();
  }
};

export async function getRepo(): Promise<GitRepository | undefined> {
  const activeEditor = atom.workspace.getCenter().getActiveTextEditor();
  if (activeEditor) {
    const path = activeEditor.getPath();
    if (path) {
      let repo = getCachedRepo(path);
      if (repo) return repo;

      const directory = new File(path).getParent();
      repo = await getRepoForDirectory(directory);
      if (repo) return repo;
    }
  }

  const repos: GitRepository[] = (await Promise.all(
    atom.project.getDirectories().map(getRepoForDirectory)
  ).then(results => results.filter(Boolean))) as GitRepository[];

  if (repos.length === 0) return undefined;
  if (repos.length === 1) return repos[0];
  if (repos.length > 1) return chooseRepo(repos);
}

export const getRepoForPath = async (path: string) => {
  const repo = getCachedRepo(path);
  if (repo) return repo;

  const stat = fs.statSync(path);
  const directory = new Directory(stat.isFile() ? Path.dirname(path) : path);
  return await getRepoForDirectory(directory);
};

const defaultCmdOptions = { color: false, env: process.env };

interface GitCliOptions {
  cwd?: string;
  color?: boolean;
  env?: {};
}
export interface GitCliResponse {
  output: string;
  failed: boolean;
}

export default async function cmd(
  args: string[],
  options: GitCliOptions = defaultCmdOptions
): Promise<GitCliResponse> {
  if (options.color) {
    args = ["-c", "color.ui=always"].concat(args);
    delete options.color;
  }

  return new Promise((resolve, reject) => {
    let output = "";
    const gitProcess = new BufferedProcess({
      // $FlowFixMe
      command: atom.config.get("git-plus.general.gitPath") || "git",
      args,
      options,
      stdout: data => (output += data.toString()),
      stderr: data => (output += data.toString()),
      exit: code => {
        resolve({
          output: output.trim(),
          failed: code !== 0
        });
      }
    });
    // TODO: clean up the disposable from this subscription
    gitProcess.onWillThrowError(_error => {
      atom.notifications.addError(
        "Git Plus is unable to locate the git command. Please ensure process.env.PATH can access git."
      );
      reject(Error("Couldn't find git"));
    });
  });
}
