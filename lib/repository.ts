import { GitRepository } from "atom";
import * as path from "path";
import git, { getRepo, getRepoForPath, GitCliResponse } from "./git-es";

export interface Stash {
  index: string;
  label: string;
  content: string;
}

export interface StashCommand {
  name: string;
  pastTense: string;
  presentTense: string;
}

export const StashCommands: { [label: string]: StashCommand } = {
  Apply: { name: "apply", pastTense: "applied", presentTense: "applying" },
  Pop: { name: "pop", pastTense: "popped", presentTense: "popping" },
  Drop: { name: "drop", pastTense: "dropped", presentTense: "dropping" }
};

export interface AddOptions {
  update?: boolean;
}

export interface FetchOptions {
  prune?: boolean;
}

export interface PullOptions {
  rebase?: boolean;
  autostash?: boolean;
  remote?: string;
  branch?: string;
}

export interface PushOptions {
  remote?: string;
  branch?: string;
  setUpstream?: boolean;
}

export default class Repository {
  repo: GitRepository;

  static async getCurrent(): Promise<Repository | undefined> {
    const repo = await getRepo();
    return repo ? new Repository(repo) : undefined;
  }

  static async getForPath(path: string): Promise<Repository | undefined> {
    const repo = await getRepoForPath(path);
    return repo ? new Repository(repo) : undefined;
  }

  constructor(repo: GitRepository) {
    this.repo = repo;
  }

  getWorkingDirectory() {
    return this.repo.getWorkingDirectory();
  }

  stage(paths: string[], options: AddOptions = { update: false }): Promise<GitCliResponse> {
    const args = ["add"];
    if (options.update) args.push("--update");
    else args.push("--all");
    args.push(...paths);

    return git(args, { cwd: this.repo.getWorkingDirectory() });
  }

  getName() {
    return path.basename(this.repo.getWorkingDirectory());
  }

  async getBranchesForRemote(remote: string): Promise<string[]> {
    const { failed, output } = await git(["branch", "-r", "--no-color"], {
      cwd: this.repo.getWorkingDirectory()
    });

    if (failed) return [];

    const branches: string[] = [];
    output.split("\n").forEach(ref => {
      ref = ref.trim();
      if (ref.startsWith(`${remote}/`) && !ref.includes("/HEAD")) {
        branches.push(ref.substring(ref.indexOf("/") + 1));
      }
    });
    return branches;
  }

  async getRemoteNames(): Promise<string[]> {
    const { failed, output } = await git(["remote"], { cwd: this.repo.getWorkingDirectory() });

    if (failed) return [];
    return output.split("\n").filter(Boolean);
  }

  async getStashes(): Promise<Stash[]> {
    const { failed, output } = await git(["stash", "list"], {
      cwd: this.repo.getWorkingDirectory()
    });

    if (failed) return [];

    return output
      .split("\n")
      .filter(Boolean)
      .map(stashInfo => {
        const [indexInfo, ...rest] = stashInfo.split(":");
        const indexMatch = indexInfo.match(/\d+/);
        if (!indexMatch) return null;
        return { index: indexMatch[0], label: rest.join().trim(), content: stashInfo };
      })
      .filter(Boolean) as Stash[];
  }

  actOnStash(stash: Stash, command: StashCommand): Promise<GitCliResponse> {
    const args = ["stash", command.name, stash.index];
    return git(args, { cwd: this.repo.getWorkingDirectory() });
  }

  fetch(remote?: string, options: FetchOptions = {}): Promise<GitCliResponse> {
    const args = ["fetch", remote || "--all"];
    if (options.prune) args.push("--prune");
    return git(args, { cwd: this.repo.getWorkingDirectory(), color: true });
  }

  pull(options: PullOptions = {}): Promise<GitCliResponse> {
    const args = ["pull"];
    if (options.autostash) args.push("--autostash");
    if (options.rebase) args.push("--rebase");
    if (options.remote) args.push(options.remote);
    if (options.branch) args.push(options.branch);

    return git(args, { cwd: this.repo.getWorkingDirectory() });
  }

  push(options: PushOptions = {}): Promise<GitCliResponse> {
    const args = ["push"];
    if (options.setUpstream) args.push("--set-upstream");
    if (options.remote) args.push(options.remote);
    if (options.branch) args.push(options.branch);
    return git(args, { cwd: this.repo.getWorkingDirectory() });
  }

  refresh() {
    (this.repo as any).refreshIndex();
    (this.repo as any).refreshStatus();
  }

  relativize(path: string): string | undefined {
    if (path === this.getWorkingDirectory()) return this.getName();
    return (this.repo as any).relativize(path);
  }

  reset(): Promise<GitCliResponse> {
    return git(["reset", "HEAD"], { cwd: this.repo.getWorkingDirectory() });
  }

  async resetChanges(path: string): Promise<GitCliResponse> {
    const result = await git(["checkout", "--", path], { cwd: this.repo.getWorkingDirectory() });
    this.refresh();
    return result;
  }

  async isPathStaged(path: string): Promise<boolean> {
    const result = await git(["diff", "--cached", "--name-only", path], {
      cwd: this.repo.getWorkingDirectory()
    });
    if (path === this.getWorkingDirectory() && result.output !== "") return true;
    return result.output.includes(this.relativize(path)!);
  }

  isPathModified(path: string): boolean {
    return this.repo.isPathModified(path);
  }

  async getUpstreamBranchFor(branch: string): Promise<[string, string] | null> {
    const result = await git(["rev-parse", "--abbrev-ref", `${branch}@{upstream}`], {
      cwd: this.repo.getWorkingDirectory()
    });
    if (result.failed && result.output.includes("fatal: no upstream configured")) return null;
    else return result.output.split("/") as [string, string];
  }

  async unstage(path: string): Promise<GitCliResponse> {
    return await git(["reset", path], { cwd: this.repo.getWorkingDirectory() });
  }
}

export { Repository };
