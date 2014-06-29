_      = require 'underscore-plus'
fs     = require 'fs-plus'
path   = require 'path'
wrench = require 'wrench'
temp   = require('temp').track()

git = require '../lib/git'

fixturePath = path.join __dirname, 'fixtures', 'testDir'

describe 'Git-Plus git cli wrapper', ->
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

  describe 'git.status', ->
    it 'returns a split git porcelain status', ->
      dummy = jasmine.createSpy('git.status')

      git.status(dummy)
      waitsFor ->
        dummy.callCount > 0
      runs ->
        exp = [
          'M  a.coffee'
          ' M b.coffee'
          '?? d.coffee'
          ''
        ]
        expect(dummy).toHaveBeenCalledWith(exp)

  describe 'git.stagedFiles', ->
    it 'returns an array of staged files', ->
      dummy = jasmine.createSpy('git.stagedFiles')
      git.stagedFiles(dummy)
      waitsFor ->
        dummy.callCount > 0
      runs ->
        exp = [
          mode: 'M'
          path: 'a.coffee'
        ]
        expect(dummy).toHaveBeenCalledWith(exp)

  describe 'git.unstagedFiles', ->
    it 'returns an array of unstaged files', ->
      dummy = jasmine.createSpy('git.unstagedFiles')

      git.unstagedFiles(dummy)
      waitsFor ->
        dummy.callCount > 0
      runs ->
        exp = [
          mode: 'M'
          path: 'b.coffee'
        ]
        expect(dummy).toHaveBeenCalledWith(exp)

  describe 'git.diff', ->
    it 'returns an array with diff hunks', ->
      dummy = jasmine.createSpy('git.diff')

      git.diff(dummy, 'b.coffee')
      waitsFor ->
        dummy.callCount > 0
      runs ->
        exp = [
           '''diff --git a/b.coffee b/b.coffee
              index 3463c49..6232e25 100644
              --- a/b.coffee
              +++ b/b.coffee\n''',
           """@@ -6,3 +6,3 @@ grade = (student) ->
                 else
              -    "C"
              +    "F"\n \n#{ }"""
        ]
        expect(dummy).toHaveBeenCalledWith(exp)
