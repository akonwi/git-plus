_                         = require 'underscore-plus'
path                      = require 'path'

{$, WorkspaceView, Workspace}  = require 'atom'
git = require '../lib/git'

describe 'Git-Plus git cli wrapper', ->

  beforeEach ->
    atom.project.setPath # path.join
    atom.workspaceView = new WorkspaceView

  describe 'git.status', ->
    it 'returns a split git porcelain status', ->
      dummy = jasmine.createSpy('dummy')

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
      dummy = jasmine.createSpy('dummy')

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
      dummy = jasmine.createSpy('dummy')

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
      dummy = jasmine.createSpy('dummy')

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
