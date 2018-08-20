// @flow
import Repository from '../repository'
import ActivityLogger from '../activity-logger'

export default async () => {
  const repos: Repository[] = (await Promise.all(
    atom.project.getDirectories().map(atom.project.repositoryForDirectory.bind(atom.project))
  )).map(r => new Repository(r))

  repos.forEach(async repo => {
    const result = await repo.fetch()
    ActivityLogger.record({
      repoName: repo.getName(),
      message: `fetching from all remotes in ${repo.getName()}`,
      ...result
    })
  })
}
