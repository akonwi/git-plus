git = require '../git'
notifier = require '../notifier'

gitStashSave = (repo) ->
  notification = notifier.addInfo('Saving...', dismissable: true)
  git.cmd
    args: ['stash', 'save']
    cwd: repo.getWorkingDirectory()
    options: {
      env: process.env.NODE_ENV
    }
    stdout: (data) ->
      notification.dismiss()
      notifier.addSuccess(data)
      repo.destroy() if repo.destroyable

module.exports = gitStashSave
