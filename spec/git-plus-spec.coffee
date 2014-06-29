_      = require 'underscore-plus'
fs     = require 'fs-plus'
path   = require 'path'
wrench = require 'wrench'
temp   = require('temp').track()

git = require '../lib/git'

fixturePath = path.join __dirname, 'fixtures', 'testDir'

describe 'Git-Plus commands', ->
  tempPath = null

  beforeEach ->
    tempPath = temp.mkdirSync('git-plus-spec')
    wrench.copyDirSyncRecursive(fixturePath, tempPath, forceDelete: true)
    fs.renameSync(path.join(tempPath, 'git.git'), path.join(tempPath, '.git'))
    atom.project.setPath tempPath

    initDummy = jasmine.createSpy('git.init')

    git.init(initDummy)
    git.refresh(initDummy)

    waitsFor ->
      initDummy.callCount is 2

  afterEach ->
    temp.cleanupSync()
    tempPath = null
