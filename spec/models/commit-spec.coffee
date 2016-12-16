os = require 'os'
fs = require 'fs-plus'
Path = require 'path'
{GitRepository} = require 'atom'
git = require '../../lib/git'
GitCommit = require '../../lib/models/git-commit'
notifier = require '../../lib/notifier'

workingDirectory = Path.join(os.homedir(), 'fixture-repo')
commitFilePath = Path.join(workingDirectory, 'COMMIT_EDITMSG')
fileName = 'fake.file'
fakeFile = Path.join(workingDirectory, fileName)
repo = null

describe "GitCommit", ->
  # beforeEach ->
  #   waitsForPromise ->
  #     git.cmd(['init'], cwd: workingDirectory).then ->
  #       repo = GitRepository.open(workingDirectory)
  #       fs.writeFileSync fakeFile, 'initial content'
  #   waitsForPromise -> git.cmd(['add'], cwd: workingDirectory)
  #   waitsForPromise -> git.cmd(['commit', '--allow-empty', '--allow-empty-message', '-m', '', 'ROOT'], cwd: workingDirectory)
  #   waitsForPromise -> git.cmd(['tag', '-a', '-m', '', 'ROOT'], cwd: workingDirectory)

  afterEach -> fs.removeSync(workingDirectory)

  describe "a regular commit", ->
    describe "when openInNewPane config is false", ->
      # beforeEach ->
      #   waitsForPromise ->
      #     fs.writeFileSync fakeFile, Math.random()
      #     git.cmd(['add', '.'], cwd: workingDirectory)
        # waitsForPromise -> GitCommit(repo)

      fit "gets staged files", ->
        waitsForPromise ->
          git.cmd(['init'], cwd: workingDirectory, shell: '/bin/zsh').then ->
            repo = GitRepository.open(workingDirectory)
            fs.writeFileSync fakeFile, 'initial content'
        waitsForPromise -> git.cmd(['add'], cwd: workingDirectory, shell: '/bin/zsh')
        waitsForPromise -> git.cmd(['commit', '--allow-empty', '--allow-empty-message', '-m', '', 'ROOT'], cwd: workingDirectory, shell: '/bin/zsh')
        waitsForPromise -> git.cmd(['tag', '-a', '-m', '', 'ROOT'], cwd: workingDirectory, shell: '/bin/zsh')
        waitsForPromise -> GitCommit(repo)
        runs ->
          editor = atom.workspace.getActiveTextEditor()
          expect(editor.getText()).toContain fileName

      it "removes lines with '(...)' from status", ->
        status = atom.workspace.getActiveTextEditor().getText()
        expect(status).not.toContain '(use "git '

      it "writes to a file", ->
        expect(fs.existsSync(commitFilePath)).toBe true

      it "commits the file on textEditor save and destroys only the textEditor", ->
        waitsForPromise -> git.cmd(['reset', 'ROOT'], cwd: workingDirectory)
        waitsForPromise ->
          fs.writeFileSync Path.join(workingDirectory, fileName), Math.random()
          git.cmd(['add', '.'], cwd: workingDirectory)
        runs ->
          commitMessage = 'some commit'
          editor = atom.workspace.getActiveTextEditor()
          editor.insertText commitMessage
          editor.save()
          spyOn(editor, 'destroy')
          waitsFor -> editor.destroy.callCount > 0
          runs ->
            git.cmd(['whatchanged', '-1', '--name-status', '--format=%B'], cwd: workingDirectory)
            .then (commit) -> expect(commit).toContain commitMessage

    describe "when git-plus.openInNewPane config is true", ->
      beforeEach ->
        atom.config.set "git-plus.openInNewPane", true
        waitsForPromise ->
          fs.writeFileSync Path.join(workingDirectory, fileName), Math.random()
          git.cmd(['add', '.'], cwd: workingDirectory)
        waitsForPromise -> GitCommit(repo)

      it "destroys the new pane during cleanup", ->
        editor = atom.workspace.getActiveTextEditor()
        pane = atom.workspace.getActivePane()
        spyOn(pane, 'destroy')
        editor.save()
        waitsFor -> pane.destroy.callCount > 0
        runs ->
          expect(pane.destroy).toHaveBeenCalled()

    it "notifies of success when commit is successful", ->
      waitsForPromise -> git.cmd(['reset', 'ROOT'], cwd: workingDirectory)
      waitsForPromise ->
        fs.writeFileSync Path.join(workingDirectory, fileName), Math.random()
        git.cmd(['add', '.'], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)
      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editor.insertText 'some commit'
        editor.save()
        spyOn(notifier, 'addSuccess')
        waitsFor -> notifier.addSuccess.callCount > 0
        runs -> expect(notifier.addSuccess).toHaveBeenCalled()

    it "deletes the file and activates the original pane on textEditor destroy", ->
      originalPane = atom.workspace.getActivePane()
      waitsForPromise ->
        fs.writeFileSync Path.join(workingDirectory, fileName), Math.random()
        git.cmd(['add', '.'], cwd: workingDirectory)
      waitsForPromise -> GitCommit(repo)
      waitsFor -> atom.workspace.getActiveTextEditor()?
      runs ->
        editor = atom.workspace.getActiveTextEditor()
        spyOn(originalPane, 'activate')
        editor.destroy()
        waitsFor -> originalPane.activate.callCount > 0
        runs ->
          expect(originalPane.isActive()).toBe true
          expect(fs.existsSync(commitFilePath)).toBe false

  # describe "when core.commentchar config is not set", ->
  #   it "uses the '#' as the commentchar", ->
  #     waitsForPromise ->
  #       fs.writeFileSync Path.join(workingDirectory, fileName), Math.random()
  #       git.cmd(['add', '.'], cwd: workingDirectory)
  #     waitsForPromise -> GitCommit(repo)
  #     runs ->
  #       editor = atom.workspace.getActiveTextEditor()
  #       expect(editor.getText().trim()[0]).toBe '#'
  #
  # describe "when core.commentchar config is set to '$'", ->
  #   afterEach ->
  #     waitsForPromise -> git.cmd(['config', '--unset', 'core.commentchar', ''], cwd: workingDirectory)
  #
  #   it "uses '$' as the commentchar", ->
  #     waitsForPromise -> git.cmd(['config', 'core.commentchar', '$'], cwd: workingDirectory)
  #     waitsForPromise ->
  #       fs.writeFileSync Path.join(workingDirectory, fileName), Math.random()
  #       git.cmd(['add', '.'], cwd: workingDirectory)
  #     waitsForPromise -> GitCommit(repo)
  #     runs ->
  #       editor = atom.workspace.getActiveTextEditor()
  #       expect(editor.getText().trim()[0]).toBe '$'
  #
  # describe "when commit.template config is not set", ->
  #   it "commit file starts with a blank line", ->
  #     setupMocks()
  #     waitsForPromise ->
  #       GitCommit(repo).then ->
  #         argsTo_fsWriteFile = fs.writeFileSync.mostRecentCall.args
  #         expect(argsTo_fsWriteFile[1].charAt(0)).toEqual "\n"
  #
  # describe "when commit.template config is set", ->
  #   it "commit file starts with content of that file", ->
  #     template = 'template'
  #     setupMocks({template})
  #     GitCommit(repo)
  #     waitsFor ->
  #       fs.writeFileSync.callCount > 0
  #     runs ->
  #       args = fs.writeFileSync.mostRecentCall.args
  #       expect(args[1].indexOf(template)).toBe 0
  #
  # describe "when 'stageChanges' option is true", ->
  #   it "calls git.add with update option set to true", ->
  #     setupMocks()
  #     GitCommit(repo, stageChanges: true).then ->
  #       expect(git.add).toHaveBeenCalledWith repo, update: true
  #
  # describe "a failing commit", ->
  #   beforeEach ->
  #     atom.config.set "git-plus.openInNewPane", false
  #     atom.config.set "core.destroyEmptyPanes", true
  #     commitResolution = Promise.reject 'commit error'
  #     setupMocks()
  #     waitsForPromise ->
  #       GitCommit(repo)
  #
  #   it "notifies of error and closes commit pane", ->
  #     spyOn(textEditor, 'destroy')
  #     textEditor.save()
  #     waitsFor -> notifier.addError.callCount > 0
  #     runs ->
  #       expect(notifier.addError).toHaveBeenCalledWith 'commit error'
  #       expect(textEditor.destroy).toHaveBeenCalled()
  #
  # describe "when the verbose commit setting is true", ->
  #   beforeEach ->
  #     atom.config.set "git-plus.openInNewPane", false
  #     atom.config.set "git-plus.verboseCommits", true
  #     setupMocks()
  #
  #   it "calls git.cmd with the --verbose flag", ->
  #     waitsForPromise -> GitCommit(repo)
  #     runs ->
  #       expect(git.cmd).toHaveBeenCalledWith ['diff', '--color=never', '--staged'], cwd: repo.getWorkingDirectory()
  #
  #   it "trims the commit file", ->
  #     textEditor.save()
  #     waitsFor -> commitFileContent.substring.callCount > 0
  #     runs ->
  #       expect(commitFileContent.substring).toHaveBeenCalledWith 0, commitFileContent.indexOf()
  #
  ## atom.config.get('git-plus.openInNewPane') is always false inside the module
  # describe "when the `git-plus.openInNewPane` setting is true", ->
  #   it "defaults to opening to the right", ->
  #     setupMocks()
  #     atom.config.set 'git-plus.openInNewPane', false
  #     waitsForPromise -> GitCommit(repo).then ->
  #       expect(commitPane.splitRight).toHaveBeenCalled()
#
#   ## Tough as nails to test because GitPush is called outside of test
#   # describe "when 'andPush' option is true", ->
#   #   it "calls git.cmd with ['remote'...] as args", ->
#   #     setupMocks()
#   #     GitCommit(repo, andPush: true).then ->
#   #       runs ->
#   #         textEditor.save()
#   #       waitsFor((->
#   #         git.cmd.mostRecentCall.args[0][0] is 'remote'),
#   #         "some stuff", 10000
#   #       )
#   #       expect(git.cmd).toHaveBeenCalledWith ['remote']
