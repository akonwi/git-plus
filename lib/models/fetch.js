// @flow
import RemoteListView from '../views/remote-list-view-beta'
import Repository from '../repository'
import type { FetchOptions } from '../repository'
import ActivityLogger from '../activity-logger'

export default async (options: FetchOptions = { prune: false }) => {
  const repo = await Repository.getCurrent()
  const remotes = await repo.getRemoteNames()
  let chosenRemote
  if (remotes.length === 1) chosenRemote = remotes[0]
  else chosenRemote = await new RemoteListView(remotes).result

  const result = await repo.fetch(chosenRemote, options)
  ActivityLogger.record({
    message: `fetch ${options.prune ? '--prune' : ''} from ${chosenRemote}`,
    ...result
  })
}
