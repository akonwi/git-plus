const fs = require('fs-plus')
const git = require('../git')
const notifier = require('../notifier')
const ActivityLogger = require('../activity-logger').default
const Repository = require('../repository').default
const BranchListView = require('../views/branch-list-view')

module.exports = (repo, options = { remote: false }) => {
  const args = options.remote ? ['branch', '-r', '--no-color'] : ['branch', '--no-color']
  return git.cmd(args, { cwd: repo.getWorkingDirectory() }).then(data => {
    return new BranchListView(data, ({ name }) => {
      const args = options.remote ? ['checkout', name, '--track'] : ['checkout', name]
      const repoName = new Repository(repo).getName()
      git
        .cmd(args, { cwd: repo.getWorkingDirectory() })
        .then(output => {
          ActivityLogger.record({ repoName, message: `checkout to ${name}`, output })
          atom.workspace.getTextEditors().forEach(editor => {
            try {
              const path = editor.getPath()
              console.log(`Git-plus: editor.getPath() returned '${path}'`)
              if (path && path.toString) {
                fs.exists(path.toString(), exists => {
                  if (!exists) editor.destroy()
                })
              }
            } catch (error) {
              notifier.addWarning(
                'There was an error closing windows for non-existing files after the checkout. Please check the dev console.'
              )
              console.info(
                'Git-plus: please take a screenshot of what has been printed in the console and add it to the issue on github at https://github.com/akonwi/git-plus/issues/139',
                error
              )
            }
          })
          git.refresh(repo)
        })
        .catch(error => {
          ActivityLogger.record({
            repoName,
            message: `checkout to ${name}`,
            output: error,
            failed: true
          })
        })
    })
  })
}
