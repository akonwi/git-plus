git = require('../git')
notifier = require('../notifier')
BranchListView = require('../views/branch-list-view')

module.exports = (repo) => {
  return git.cmd(['branch', '--no-color'], {cwd: repo.getWorkingDirectory()})
  .then(data => {
    return new BranchListView(repo, data, ({name}) => {
      const branch = name.match(/\*?(.*)/)[1]
      git.cmd(['checkout'].concat(branch), {cwd: repo.getWorkingDirectory()})
      .then(message => {
        notifier.addSuccess(message)
        atom.workspace.observeTextEditors(editor => {
          try {
            const path = editor.getPath()
            console.log(`Git-plus: editor.getPath() returned '${path}'`)
            if (path && path.toString) {
              fs.exists(filepath, exists => {if (!exists) editor.destroy()})
            }
          }
          catch (error) {
            notifier.addWarning("There was an error closing windows for non-existing files after the checkout. Please check the dev console.")
            console.info("Git-plus: please take a screenshot of what has been printed in the console and add it to the issue on github at https://github.com/akonwi/git-plus/issues/139", error)
          }
        })
        git.refresh(repo)
      })
      .catch(notifier.addError)
    })
  })
}
