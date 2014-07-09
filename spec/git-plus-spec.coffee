_      = require 'underscore-plus'
fs     = require 'fs-plus'
path   = require 'path'
wrench = require 'wrench'
temp   = require('temp').track()

{$, WorkspaceView}    = require 'atom'
git    = require '../lib/git'

GitAdd                 = require '../lib/models/git-add'
GitAddAllAndCommit     = require '../lib/models/git-add-all-and-commit'
GitAddAndCommit        = require '../lib/models/git-add-and-commit'
GitBranch              = require '../lib/models/git-branch'
GitCheckoutAllFiles    = require '../lib/models/git-checkout-all-files'
GitCheckoutCurrentFile = require '../lib/models/git-checkout-current-file'
GitCherryPick          = require '../lib/models/git-cherry-pick'
GitCommitAmend         = require '../lib/models/git-commit-amend'
GitDiff                = require '../lib/models/git-diff'
GitDiffAll             = require '../lib/models/git-diff-all'
GitFetch               = require '../lib/models/git-fetch'
GitInit                = require '../lib/models/git-init'
GitLog                 = require '../lib/models/git-log'
GitPull                = require '../lib/models/git-pull'
GitPush                = require '../lib/models/git-push'
GitRemove              = require '../lib/models/git-remove'
GitShow                = require '../lib/models/git-show'
GitStageFiles          = require '../lib/models/git-stage-files'
GitStageHunk           = require '../lib/models/git-stage-hunk'
GitStatus              = require '../lib/models/git-status'
GitTags                = require '../lib/models/git-tags'
GitUnstageFiles        = require '../lib/models/git-unstage-files'
GitCommit              = require '../lib/models/git-commit'

StatusView             = require '../lib/views/status-view'

fixturePath = path.join __dirname, 'fixtures', 'testDir'

describe 'Git-Plus commands', ->
  tempPath = null
  [editor, editorView] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    tempPath = temp.mkdirSync('git-plus-spec')
    wrench.copyDirSyncRecursive(fixturePath, tempPath, forceDelete: true)
    fs.renameSync(path.join(tempPath, 'git.git'), path.join(tempPath, '.git'))
    atom.project.setPath tempPath

    initDummy = jasmine.createSpy('git.init')

    git.init(initDummy)
    git.refresh(initDummy)

    waitsFor ->
      initDummy.callCount is 2

    waitsForPromise ->
      atom.workspace.open 'a.coffee', activatePane: true

  afterEach ->
    temp.cleanupSync()
    tempPath = null

  describe 'git-add', ->
    describe 'unstaged file', ->
      it 'adds the unstaged changes to the index', ->
        spyOn(atom.workspaceView, 'append').andCallThrough()

        waitsForPromise ->
          atom.workspace.open 'b.coffee', activatePane: true
          .then (o) ->
            editor = o

        runs ->
          atom.workspaceView.append.reset()
          GitAdd()

        waitsFor ->
          atom.workspaceView.append.callCount > 0

        runs ->
          activeEditor = atom.workspace.getActiveEditor()
          message = atom.workspaceView.append.mostRecentCall.args[0].text()

          expect(editor.getPath()).toBe activeEditor.getPath()
          expect(message).toEqual 'Added b.coffee'
