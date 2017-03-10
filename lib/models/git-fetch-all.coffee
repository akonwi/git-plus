git = require '../git'

module.exports = (repos) ->
  repos.map (repo) ->
    cwd = repo.getWorkingDirectory()
    git.cmd(['fetch','--all'], {cwd})
    .then (message) ->
      if atom.config.get('git-plus.remoteInteractions.autoFetchNotify')
        fork = cwd.split('/').pop()
        notification =
          icon: 'repo-pull'
          detail: message.replace(/(Fetch)ing/g, '$1ed')
        atom.notifications.addSuccess("Git-Plus: #{fork}", notification)
