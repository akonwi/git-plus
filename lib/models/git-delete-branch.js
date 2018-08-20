const git = require('../git')
const notifier = require('../notifier')
const ActivityLogger = require('../activity-logger').default
const Repository = require('../repository').default
const BranchListView = require('../views/branch-list-view')

module.exports = (repo, options = { remote: false }) => {
  const args = options.remote ? ['branch', '-r', '--no-color'] : ['branch', '--no-color']
  return git.cmd(args, { cwd: repo.getWorkingDirectory() }).then(data => {
    return new BranchListView(data, ({ name }) => {
      let args, notification
      if (options.remote) {
        const remote = name.substring(0, name.indexOf('/'))
        const branch = name.substring(name.indexOf('/') + 1)
        notification = notifier.addInfo(`Deleting remote branch ${branch}`, { dismissable: true })
        args = ['push', remote, '--delete', branch]
      } else {
        const branch = name
        args = ['branch', '-D', branch]
      }

      const message = `delete ${options.remote ? 'remote ' : ''} branch '${args[args.length - 1]}'`
      const repoName = new Repository(repo).getName()

      git
        .cmd(args, { cwd: repo.getWorkingDirectory() })
        .then(output => {
          notification && notification.dismiss()
          notifier.addSuccess(output)
          ActivityLogger.record({
            repoName,
            message,
            output
          })
        })
        .catch(error => {
          notification && notification.dismiss()
          notifier.addError(error)
          ActivityLogger.record({
            repoName,
            message,
            output: error,
            failed: true
          })
        })
    })
  })
}
