import ActivityLogger from "../activity-logger";
import Repository from "../repository";

export default async () => {
  const repos: Repository[] = (await Promise.all(
    atom.project.getDirectories().map(atom.project.repositoryForDirectory.bind(atom.project))
  ))
    .filter(Boolean)
    .map(r => new Repository(r!));

  repos.forEach(async repo => {
    const result = await repo.fetch();
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `fetching from all remotes in ${repo.getName()}`,
      ...result
    });
  });
};
