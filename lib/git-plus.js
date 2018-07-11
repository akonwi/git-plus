import '@babel/polyfill'
import { CompositeDisposable } from 'atom'
import { $ } from 'atom-space-pen-views'
import OutputView from './views/output-view-beta/output-view-container'
import git from './git'
import configurations from './config'
import contextMenu from './context-menu'
import service from './service'
import OutputViewManager from './output-view-manager'
import GitPaletteView from './views/git-palette-view'
import GitAddContext from './models/context/git-add-context'
import GitDiffContext from './models/context/git-diff-context'
import GitAddAndCommitContext from './models/context/git-add-and-commit-context'
import GitCheckoutNewBranch from './models/git-checkout-new-branch'
import GitCheckoutBranch from './models/git-checkout-branch'
import GitDeleteBranch from './models/git-delete-branch'
import GitCheckoutAllFiles from './models/git-checkout-all-files'
import GitCheckoutFile from './models/git-checkout-file'
import GitCheckoutFileContext from './models/context/git-checkout-file-context'
import GitCherryPick from './models/git-cherry-pick'
import GitCommit from './models/git-commit'
import GitCommitAmend from './models/git-commit-amend'
import GitDiff from './models/git-diff'
import GitDiffBranches from './models/git-diff-branches'
import GitDiffBranchesContext from './models/context/git-diff-branches-context'
import GitDiffBranchFiles from './models/git-diff-branch-files'
import GitDiffBranchFilesContext from './models/context/git-diff-branch-files-context'
import GitDifftool from './models/git-difftool'
import GitDifftoolContext from './models/context/git-difftool-context'
import GitDiffAll from './models/git-diff-all'
import GitFetch from './models/git-fetch'
import GitFetchAll from './models/git-fetch-all'
import GitFetchPrune from './models/git-fetch-prune.coffee'
import GitInit from './models/git-init'
import GitLog from './models/git-log'
import GitPull from './models/git-pull'
import GitPullContext from './models/context/git-pull-context'
import GitPush from './models/git-push'
import GitPushContext from './models/context/git-push-context'
import GitRemove from './models/git-remove'
import GitShow from './models/git-show'
import GitStageFiles from './models/git-stage-files'
import GitStageHunk from './models/git-stage-hunk'
import ManageStashes from './models/manage-stashes'
import GitStashApply from './models/git-stash-apply'
import GitStashDrop from './models/git-stash-drop'
import GitStashPop from './models/git-stash-pop'
import GitStashSave from './models/git-stash-save'
import GitStashSaveMessage from './models/git-stash-save-message'
import GitStatus from './models/git-status'
import GitTags from './models/git-tags'
import GitUnstageFileContext from './models/context/git-unstage-file-context'
import GitRun from './models/git-run'
import GitMerge from './models/git-merge'
import GitRebase from './models/git-rebase'
import GitOpenChangedFiles from './models/git-open-changed-files'
import diffGrammars from './grammars/diff.js'

const baseWordGrammar = __dirname + '/grammars/word-diff.json'
const baseLineGrammar = __dirname + '/grammars/line-diff.json'

const currentFile = repo => {
  const activeEditor = atom.workspace.getActiveTextEditor()
  if (!activeEditor) return null
  return repo.relativize(activeEditor.getPath())
}

const setDiffGrammar = () => {
  const enableSyntaxHighlighting = atom.config.get('git-plus.diffs.syntaxHighlighting')
  const wordDiff = atom.config.get('git-plus.diffs.wordDiff')
  let diffGrammar = null
  let baseGrammar = null

  if (wordDiff) {
    diffGrammar = diffGrammars.wordGrammar
    baseGrammar = baseWordGrammar
  } else {
    diffGrammar = diffGrammars.lineGrammar
    baseGrammar = baseLineGrammar
  }
  if (enableSyntaxHighlighting) {
    while (atom.grammars.grammarForScopeName('source.diff'))
      atom.grammars.removeGrammarForScopeName('source.diff')
    atom.grammars.addGrammar(diffGrammar)
  }
}

const getWorkspaceRepos = () => atom.project.getRepositories().filter(Boolean)

const onPathsChanged = gp => {
  if (gp) {
    gp.deactivate()
    gp.activate()
    if (gp.statusBar) gp.consumeStatusBar(gp.statusBar)
  }
}

const getWorkspaceNode = () => document.querySelector('atom-workspace')

module.exports = {
  config: configurations,
  subscriptions: null,
  outputView: null,
  provideService: () => service,

  activate(state) {
    setDiffGrammar()
    this.subscriptions = new CompositeDisposable()
    const repos = getWorkspaceRepos()

    if (atom.project.getDirectories().length === 0)
      atom.project.onDidChangePaths(paths => onPathsChanged(this))
    if (repos.length === 0 && atom.project.getDirectories().length > 0)
      this.subscriptions.add(
        atom.commands.add('atom-workspace', 'git-plus:init', () => GitInit().then(this.activate))
      )
    if (repos.length > 0) {
      this.outputView = new OutputView()
      atom.project.onDidChangePaths(paths => onPathsChanged(this))
      contextMenu()
      this.subscriptions.add(
        atom.commands.add('atom-workspace', {
          'git-plus:menu': () => new GitPaletteView(),
          'git-plus:add': () => {
            git.getRepo().then(repo => git.add(repo, { file: currentFile(repo) }))
          },
          'git-plus:add-modified': () => {
            git.getRepo().then(repo => git.add(repo, { update: true }))
          },
          'git-plus:add-all': () => {
            git.getRepo().then(repo => git.add(repo))
          },
          'git-plus:commit': () => {
            git.getRepo().then(repo => GitCommit(repo))
          },
          'git-plus:commit-all': () => {
            git.getRepo().then(repo => GitCommit(repo, { stageChanges: true }))
          },
          'git-plus:commit-amend': () => {
            git.getRepo().then(repo => new GitCommitAmend(repo))
          },
          'git-plus:add-and-commit': () => {
            git
              .getRepo()
              .then(repo => git.add(repo, { file: currentFile(repo) }).then(() => GitCommit(repo)))
          },
          'git-plus:add-and-commit-and-push': () => {
            git
              .getRepo()
              .then(repo =>
                git
                  .add(repo, { file: currentFile(repo) })
                  .then(() => GitCommit(repo, { andPush: true }))
              )
          },
          'git-plus:add-all-and-commit': () => {
            git.getRepo().then(repo => git.add(repo).then(() => GitCommit(repo)))
          },
          'git-plus:add-all-commit-and-push': () => {
            git.getRepo().then(repo => git.add(repo).then(() => GitCommit(repo, { andPush: true })))
          },
          'git-plus:commit-all-and-push': () => {
            git.getRepo().then(repo => GitCommit(repo, { stageChanges: true, andPush: true }))
          },
          'git-plus:checkout': () => git.getRepo().then(repo => GitCheckoutBranch(repo)),
          'git-plus:checkout-remote': () => {
            git.getRepo().then(repo => GitCheckoutBranch(repo, { remote: true }))
          },
          'git-plus:checkout-current-file': () => {
            git.getRepo().then(repo => GitCheckoutFile(repo, { file: currentFile(repo) }))
          },
          'git-plus:checkout-all-files': () => {
            git.getRepo().then(repo => GitCheckoutAllFiles(repo))
          },
          'git-plus:new-branch': () => git.getRepo().then(repo => GitCheckoutNewBranch(repo)),
          'git-plus:delete-local-branch': () => git.getRepo().then(repo => GitDeleteBranch(repo)),
          'git-plus:delete-remote-branch': () => {
            git.getRepo().then(repo => GitDeleteBranch(repo, { remote: true }))
          },
          'git-plus:cherry-pick': () => git.getRepo().then(repo => GitCherryPick(repo)),
          'git-plus:diff': () => {
            git.getRepo().then(repo => GitDiff(repo, { file: currentFile(repo) }))
          },
          'git-plus:difftool': () => {
            git.getRepo().then(repo => GitDifftool(repo, { file: currentFile(repo) }))
          },
          'git-plus:diff-all': () => git.getRepo().then(repo => GitDiffAll(repo)),
          'git-plus:fetch': () => git.getRepo().then(repo => GitFetch(repo)),
          'git-plus:fetch-all': () => git.getAllRepos().then(repos => GitFetchAll(repos)),
          'git-plus:fetch-prune': () => git.getRepo().then(repo => GitFetchPrune(repo)),
          'git-plus:pull': () => git.getRepo().then(repo => GitPull(repo)),
          'git-plus:push': () => git.getRepo().then(repo => GitPush(repo)),
          'git-plus:push-set-upstream': () => {
            git.getRepo().then(repo => GitPush(repo, { setUpstream: true }))
          },
          'git-plus:remove': () => {
            git.getRepo().then(repo => GitRemove(repo, { showSelector: true }))
          },
          'git-plus:remove-current-file': () => git.getRepo().then(repo => GitRemove(repo)),
          'git-plus:reset': () => git.getRepo().then(repo => git.reset(repo)),
          'git-plus:show': () => git.getRepo().then(repo => GitShow(repo)),
          'git-plus:log': () => git.getRepo().then(repo => GitLog(repo)),
          'git-plus:log-current-file': () => {
            git.getRepo().then(repo => GitLog(repo, { onlyCurrentFile: true }))
          },
          'git-plus:stage-hunk': () => git.getRepo().then(repo => GitStageHunk(repo)),
          'git-plus:manage-stashes': ManageStashes,
          'git-plus:stash-save': () => git.getRepo().then(repo => GitStashSave(repo)),
          'git-plus:stash-save-message': () => {
            git.getRepo().then(repo => GitStashSaveMessage(repo))
          },
          'git-plus:stash-pop': () => git.getRepo().then(repo => GitStashPop(repo)),
          'git-plus:stash-apply': () => git.getRepo().then(repo => GitStashApply(repo)),
          'git-plus:stash-delete': () => git.getRepo().then(repo => GitStashDrop(repo)),
          'git-plus:status': () => git.getRepo().then(repo => GitStatus(repo)),
          'git-plus:tags': () => git.getRepo().then(repo => GitTags(repo)),
          'git-plus:run': () => git.getRepo().then(repo => new GitRun(repo)),
          'git-plus:merge': () => git.getRepo().then(repo => GitMerge(repo)),
          'git-plus:merge-remote': () => {
            git.getRepo().then(repo => GitMerge(repo, { remote: true }))
          },
          'git-plus:merge-no-fast-forward': () => {
            git.getRepo().then(repo => GitMerge(repo, { noFastForward: true }))
          },
          'git-plus:rebase': () => git.getRepo().then(repo => GitRebase(repo)),
          'git-plus:git-open-changed-files': () => {
            git.getRepo().then(repo => GitOpenChangedFiles(repo))
          }
        })
      )
      this.subscriptions.add(
        atom.commands.add('.tree-view', {
          'git-plus-context:add': GitAddContext,
          'git-plus-context:add-and-commit': GitAddAndCommitContext,
          'git-plus-context:checkout-file': GitCheckoutFileContext,
          'git-plus-context:diff': GitDiffContext,
          'git-plus-context:diff-branches': GitDiffBranchesContext,
          'git-plus-context:diff-branch-files': GitDiffBranchFilesContext,
          'git-plus-context:difftool': GitDifftoolContext,
          'git-plus-context:pull': GitPullContext,
          'git-plus-context:push': GitPushContext,
          'git-plus-context:push-set-upstream': () => GitPushContext({ setUpstream: true }),
          'git-plus-context:unstage-file': GitUnstageFileContext
        })
      )
      if (atom.config.get('git-plus.experimental.diffBranches')) {
        this.subscriptions.add(
          atom.commands.add('atom-workspace', {
            'git-plus:diff-branches': () => git.getRepo().then(repo => GitDiffBranches(repo)),
            'git-plus:diff-branch-files': () => git.getRepo().then(repo => GitDiffBranchFiles(repo))
          })
        )
      }
      this.subscriptions.add(
        atom.commands.add('atom-workspace', 'git-plus:stage-files', () =>
          git.getRepo().then(GitStageFiles)
        )
      )
      this.subscriptions.add(
        atom.config.observe('git-plus.diffs.syntaxHighlighting', setDiffGrammar),
        atom.config.observe('git-plus.diffs.wordDiff', setDiffGrammar),
        atom.config.observe('git-plus.experimental.autoFetch', interval => this.autoFetch(interval))
      )
    }
  },

  deactivate() {
    this.subscriptions.dispose()
    this.statusBarTile && this.statusBarTile.destroy()
    this.outputView && this.outputView.destroy()
    clearInterval(this.autoFetchInterval)
  },

  autoFetch(interval) {
    clearInterval(this.autoFetchInterval)
    const fetchIntervalMs = interval * 60 * 1000
    if (Boolean(fetchIntervalMs)) {
      this.autoFetchInterval = setInterval(
        () => atom.commands.dispatch(getWorkspaceNode(), 'git-plus:fetch-all'),
        fetchIntervalMs
      )
    }
  },

  consumeAutosave({ dontSaveIf }) {
    dontSaveIf(paneItem => paneItem.getPath().includes('COMMIT_EDITMSG'))
  },

  consumeStatusBar(statusBar) {
    this.statusBar = statusBar
    if (getWorkspaceRepos().length > 0) this.setupBranchesMenuToggle(this.statusBar)
    if (atom.config.get('git-plus.general.enableStatusBarIcon'))
      this.setupOutputViewToggle(this.statusBar)
  },

  setupOutputViewToggle(statusBar) {
    const div = document.createElement('div')
    div.classList.add('inline-block')
    const icon = document.createElement('span')
    icon.textContent = 'git+'
    const link = document.createElement('a')
    link.appendChild(icon)
    link.onclick = e => OutputViewManager.getView().toggle()
    atom.tooltips.add(div, { title: 'Toggle Git-Plus Output Console' })
    div.appendChild(link)
    this.statusBarTile = statusBar.addRightTile({ item: div, priority: 0 })
  },

  setupBranchesMenuToggle(statusBar) {
    statusBar.getRightTiles().some(({ item }) => {
      if (item && item.classList && item.classList.contains('git-view')) {
        $(item)
          .find('.git-branch')
          .on('click', e => {
            $(item)
              .find('.git-branch')
              .on('click', e => {
                const { newBranchKey } = atom.config.get('git-plus.general')
                const wasPressed = key => e['#{key}Key']
                if (wasPressed(newBranchKey))
                  atom.commands.dispatch(getWorkspaceNode(), 'git-plus:new-branch')
                else atom.commands.dispatch(getWorkspaceNode(), 'git-plus:checkout')
              })
          })
        return true
      }
    })
  }
}
