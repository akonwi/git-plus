meta = #Key
  define: "https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/metaKey"
  key:
    switch process.platform
      when "darwin" then "⌘"
      when "linux" then "Super"
      when "win32" then "❖"

module.exports =
  general:
    order: 1
    type: "object"
    properties:
      gitPath:
        order: 1
        title: "Git Path"
        type: "string"
        default: "git"
        description: "If git is not in your PATH, specify where the executable is"
      enableStatusBarIcon:
        order: 2
        title: "Status-bar Icon"
        type: "boolean"
        default: true
        description: "The 'git+' icon in the bottom-right of the status-bar toggles the output view above the status-bar"
      openInPane:
        order: 3
        title: "Allow commands to open new panes"
        type: "boolean"
        default: true
        description: "Commands like `Commit`, `Log`, `Show`, `Diff` can be split into new panes"
      splitPane:
        order: 4
        title: "Split pane direction"
        type: "string"
        default: "Down"
        description: "Where should new panes go?"
        enum: ["Up", "Right", "Down", "Left"]
      showFormat:
        order: 5
        title: "Format option for 'Git Show'"
        type: "string"
        default: "full"
        enum: ["oneline", "short", "medium", "full", "fuller", "email", "raw", "none"]
        description: "Which format to use for `git show`? (`none` will use your git config default)"
      alwaysOpenDockWithResult:
        order: 6
        title: "Always show result output"
        type: "boolean"
        default: false
        description: "Always display the output view after a command completes (regardless of dock visibility). If the view has been destroyed, it will need to be manually toggled."
      newBranchKey:
        order: 7
        title: "Status-bar New Branch modifier key"
        type: "string"
        default: "alt"
        description: "Holding this modifier key while clicking on the branch name in the status bar will trigger creatinga a new branch. Note that _[`meta`](#{meta.define})_ is <kbd>#{meta.key}</kbd>"
        enum: ["alt", "shift", "meta", "ctrl"]
      showBranchInTreeView:
        order: 8
        title: "Show current branch name in tree view."
        type: "boolean"
        default: true
        description: "The branch name will be displayed next to repo root in the tree view as `[branch-name]`."
  commits:
    order: 2
    type: "object"
    properties:
      verboseCommits:
        title: "Verbose Commits"
        description: "Show diffs in commit pane?"
        type: "boolean"
        default: false
  diffs:
    order: 3
    type: "object"
    properties:
      includeStagedDiff:
        order: 1
        title: "Include staged diffs?"
        type: "boolean"
        default: true
      wordDiff:
        order: 2
        title: "Word diff"
        type: "boolean"
        default: false
        description: "Should diffs be generated with the `--word-diff` flag?"
      syntaxHighlighting:
        order: 3
        title: "Enable syntax highlighting in diffs?"
        type: "boolean"
        default: true
      useSplitDiff:
        order: 4
        title: "Split diff"
        type: "boolean"
        default: false
        description: "Use the split-diff package to show diffs for a single file. Only works with `Diff` command when a file is open."
  logs:
    order: 4
    type: "object"
    properties:
      numberOfCommitsToShow:
        order: 1
        title: "Number of commits to load"
        type: "integer"
        default: 25
        minimum: 1
        description: "Initial amount of commits to load when running the `Log` command"
  remoteInteractions:
    order: 5
    type: "object"
    properties:
      pullRebase:
        order: 1
        title: "Pull Rebase"
        type: "boolean"
        default: false
        description: "Pull with `--rebase` flag?"
      pullAutostash:
        order: 2
        title: "Pull AutoStash"
        type: "boolean"
        default: false
        description: "Pull with `--autostash` flag?"
      pullBeforePush:
        order: 3
        title: "Pull Before Pushing"
        type: "boolean"
        default: false
        description: "Pull from remote before pushing"
      promptForBranch:
        order: 4
        title: "Prompt for branch selection when pulling/pushing"
        type: "boolean"
        default: false
        description: "If false, it defaults to current branch upstream"
  tags:
    order: 6
    type: "object"
    properties:
      signTags:
        title: "Sign git tags with GPG"
        type: "boolean"
        default: false
        description: "Use a GPG key to sign Git tags"
  experimental:
    order: 7
    type: "object"
    properties:
      customCommands:
        order: 1
        title: "Custom Commands"
        type: "boolean"
        default: false
        description: "Declared custom commands in your `init` file that can be run from the Git-plus command palette"
      diffBranches:
        order: 2
        title: "Show diffs across branches"
        type: "boolean"
        default: false
        description: "Diffs will be shown for the current branch against a branch you choose. The `Diff branch files` command will allow choosing which file to compare. The file feature requires the 'split-diff' package to be installed."
      autoFetch:
        order: 3
        title: "Auto-fetch"
        type: "integer"
        default: 0
        maximum: 60
        description: "Automatically fetch remote repositories every `x` minutes (`0` will disable this feature)"
      autoFetchNotify:
        order: 4
        title: "Auto-fetch notification"
        type: "boolean"
        default: false
        description: "Show notifications while running `fetch --all`?"
