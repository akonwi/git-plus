git = require '../../lib/git'
{repo} = require '../fixtures'
GitOpenChangedFiles = require '../../lib/models/git-open-changed-files'

describe "GitOpenChangedFiles", ->
  beforeEach ->
    spyOn(atom.workspace, 'open')

  describe "when file is modified", ->
    beforeEach ->
      spyOn(git, 'status').andReturn Promise.resolve [' M file1.txt']
      waitsForPromise -> GitOpenChangedFiles(repo)

    it "opens changed file", ->
      expect(atom.workspace.open).toHaveBeenCalledWith("file1.txt")

  describe "when file is added", ->
    beforeEach ->
      spyOn(git, 'status').andReturn Promise.resolve ['?? file2.txt']
      waitsForPromise -> GitOpenChangedFiles(repo)

    it "opens added file", ->
      expect(atom.workspace.open).toHaveBeenCalledWith("file2.txt")

  describe "when file is renamed", ->
    beforeEach ->
      spyOn(git, 'status').andReturn Promise.resolve ['R  file3.txt']
      waitsForPromise -> GitOpenChangedFiles(repo)

    it "opens renamed file", ->
      expect(atom.workspace.open).toHaveBeenCalledWith("file3.txt")
