git = require '../git'

module.exports = (repos) ->
  repos.map (repo) ->
    cwd = repo.getWorkingDirectory()
    git.cmd(['fetch','--all'], {cwd})
    .then (message) ->
      if atom.config.get('git-plus.experimental.autoFetchNotify')
        repoName = cwd.split('/').pop()
        options =
          icon: 'repo-pull'
          detail: "In #{repoName} repo:"
          description: message.replace(/(Fetch)ing/g, '$1ed')
        atom.notifications.addSuccess('Git-Plus', options)
