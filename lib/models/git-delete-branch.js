const git = require('../git')
const notifier = require('../notifier')
const BranchListView = require('../views/branch-list-view')

module.exports = (repo, options={remote: false}) => {
  const args = options.remote ? ['branch', '-r', '--no-color'] : ['branch', '--no-color']
  return git.cmd(args, {cwd: repo.getWorkingDirectory()})
  .then(data => {
    return new BranchListView(data, ({name}) => {
      let args, notification
      if (options.remote) {
        const remote = name.substring(0, name.indexOf('/'))
        const branch = name.substring(name.indexOf('/') + 1)
        notification = notifier.addInfo(`Deleting remote branch ${branch}`, {dismissable: true})
        args = ['push', remote, '--delete', branch]
      }
      else {
        const branch = name
        notification = notifier.addInfo(`Deleting branch ${branch}`, {dismissable: true})
        args = ['branch', '-D', branch]
      }

      git.cmd(args, {cwd: repo.getWorkingDirectory()})
      .then(message => {
        notification.dismiss()
        notifier.addSuccess(message)
      })
      .catch(error => {
        notification.dismiss()
        notifier.addError(error)
      })
    })
  })
}
