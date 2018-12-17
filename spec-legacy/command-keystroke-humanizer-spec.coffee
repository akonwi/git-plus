CommandKeystrokeFinder = require '../lib/command-keystroke-humanizer'
_ = require 'underscore-plus'

selector =
  Darwin:             '.platform-darwin'
  DarwinEditor:       '.platform-darwin atom-text-editor'
  Win32:              '.platform-win32'
  Linux:              '.platform-linux'
  Win32Linux:         '.platform-win32, .platform-linux'
  Win32LinuxEditor:   '.platform-win32 atom-text-editor, .platform-linux atom-text-editor'

DarwinKeyMap =
  'cmd-shift-h':      'git-plus:menu'
  'cmd-shift-a s':    'git-plus:status'
  'cmd-shift-a q':    'git-plus:add-and-commit-and-push'

Win32LinuxKeyMap =
  'ctrl-shift-h':     'git-plus:menu'
  'ctrl-shift-x':     'git-plus:commit'
  'ctrl-shift-a s':   'git-plus:status'
  'ctrl-shift-a q':   'git-plus:add-and-commit-and-push'
  'ctrl-shift-a a':   'git-plus:add-all-and-commit'
  'ctrl-shift-a p':   'git-plus:add-all-commit-and-push'

DarwinEditorKeyMap =
  'cmd-shift-a':      'git-plus:add'
  'cmd-shift-a c':    'git-plus:add-and-commit'

Win32LinuxEditorKeyMap =
  'ctrl-shift-a':     'git-plus:add'
  'ctrl-shift-a c':   'git-plus:add-and-commit'

getCommandsFromKeymap = (keymap) ->
  commands = []
  for ks, cmd of keymap
    commands.push [cmd]
  commands

mockFindKeyBindings = (bindings) ->
  ({command}) ->
    bindings.filter (binding) -> binding.command is command

setupKeyBindings = (keymaps, selector)->
  keybindings = []
  for keystrokes, gitCommand of keymaps
    keybindings.push {command: gitCommand, selector: selector, keystrokes: keystrokes}
  spyOn(atom.keymaps, "findKeyBindings").andCallFake(mockFindKeyBindings(keybindings))


describe "Git-Plus command keystroke humanizer", ->
  describe "On any platform", ->
    describe "when an empty command list is provided", ->
      it "returns empty map", ->
        keymaps = [{command: 'cmd-shift-a', selector: selector.Darwin}]
        spyOn(atom.keymaps, "findKeyBindings").andCallFake mockFindKeyBindings(keymaps)
        expect(CommandKeystrokeFinder().get([])).toEqual {}

  describe "when platform is Darwin", ->
    humanizer = null
    beforeEach -> humanizer = CommandKeystrokeFinder("darwin")

    describe "when selector is #{selector.Darwin}" , ->
      it "it must return all keystrokes in humanized form", ->
        setupKeyBindings(DarwinKeyMap, selector.Darwin)
        humanizedKeystrokes = humanizer.get(getCommandsFromKeymap(DarwinKeyMap))
        for keystrokes, gitCommand of DarwinKeyMap
          expect(humanizedKeystrokes[gitCommand]).toEqual(_.humanizeKeystroke(keystrokes))

    describe "when selector is #{selector.DarwinEditor}" , ->
      it "it must return all keystrokes in humanized form", ->
        setupKeyBindings(DarwinEditorKeyMap, selector.DarwinEditor)
        humanizedKeystrokes = humanizer.get(getCommandsFromKeymap(DarwinEditorKeyMap))
        for keystrokes, gitCommand of DarwinEditorKeyMap
          expect(humanizedKeystrokes[gitCommand]).toEqual(_.humanizeKeystroke(keystrokes))

    describe "when selector is #{selector.Win32Linux}" , ->
      it "it must return empty map", ->
        setupKeyBindings(Win32LinuxKeyMap, selector.Win32Linux)
        expect(humanizer.get(getCommandsFromKeymap(Win32LinuxKeyMap))).toEqual {}

    describe "when selector is #{selector.Win32LinuxEditor}" , ->
      it "it must return empty map", ->
        setupKeyBindings(Win32LinuxEditorKeyMap, selector.Win32LinuxEditor)
        expect(humanizer.get(getCommandsFromKeymap(Win32LinuxEditorKeyMap))).toEqual {}

  describe "when platform is #{selector.Win32} or #{selector.Linux}", ->
    humanizer = null
    beforeEach -> humanizer = CommandKeystrokeFinder("win32")

    describe "when selector is #{selector.Win32Linux}" , ->
      it "it must return all keystrokes in humanized form", ->
        setupKeyBindings(Win32LinuxKeyMap, selector.Win32Linux)
        humanizedKeystrokes = humanizer.get(getCommandsFromKeymap(Win32LinuxKeyMap))
        for keystrokes, gitCommand of Win32LinuxKeyMap
          expect(humanizedKeystrokes[gitCommand]).toEqual(_.humanizeKeystroke(keystrokes))

    describe "when selector is #{selector.Win32LinuxEditor}" , ->
      it "it must return all keystrokes in humanized form", ->
        setupKeyBindings(Win32LinuxEditorKeyMap, selector.Win32LinuxEditor)
        humanizedKeystrokes = humanizer.get(getCommandsFromKeymap(Win32LinuxEditorKeyMap))
        for keystrokes, gitCommand of Win32LinuxEditorKeyMap
          expect(humanizedKeystrokes[gitCommand]).toEqual(_.humanizeKeystroke(keystrokes))

    describe "when selector is #{selector.Darwin}" , ->
      it "it must return empty map", ->
        setupKeyBindings(DarwinKeyMap, selector.Darwin)
        expect(humanizer.get(getCommandsFromKeymap(DarwinKeyMap))).toEqual {}

    describe "when selector is #{selector.DarwinEditor}" , ->
      it "it must return empty map", ->
        setupKeyBindings(DarwinEditorKeyMap, selector.DarwinEditor)
        expect(humanizer.get(getCommandsFromKeymap(DarwinEditorKeyMap))).toEqual {}
