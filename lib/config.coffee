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
        title: "Status-bar Pin Icon"
        type: "boolean"
        default: true
        description: "The pin icon in the bottom-right of the status-bar toggles the output view above the status-bar"
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
      messageTimeout:
        order: 5
        title: "Output view timeout"
        type: "integer"
        default: 5
        description: "For how many seconds should the output view above the status-bar stay open?"
      showFormat:
        order: 6
        title: "Format option for 'Git Show'"
        type: "string"
        default: "full"
        enum: ["oneline", "short", "medium", "full", "fuller", "email", "raw", "none"]
        description: "Which format to use for `git show`? (`none` will use your git config default)"
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
        default: true
        description: "Should diffs be generated with the `--word-diff` flag?"
      syntaxHighlighting:
        order: 3
        title: "Enable syntax highlighting in diffs?"
        type: "boolean"
        default: true
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
      pullBeforePush:
        order: 2
        title: "Pull Before Pushing"
        type: "boolean"
        default: false
        description: "Pull from remote before pushing"
      promptForBranch:
        order: 3
        title: "Prompt for branch selection when pulling/pushing"
        type: "boolean"
        default: false
        description: "If false, it defaults to current branch upstream"
  experimental:
    order: 6
    type: "object"
    properties:
      stageFilesBeta:
        order: 1
        title: "Stage Files Beta"
        type: "boolean"
        default: true
        description: "Stage and unstage files in a single command"
      customCommands:
        order: 2
        title: "Custom Commands"
        type: "boolean"
        default: false
        description: "Declared custom commands in your `init` file that can be run from the Git-plus command palette"
      diffBranches:
        order: 3
        title: "Show diffs across branches"
        type: "boolean"
        default: false
        description: "Diffs will be shown for the current branch against a branch you choose. The `Diff branch files` command will allow choosing which file to compare. The file feature requires the 'split-diff' package to be installed."
      useSplitDiff:
        order: 4
        title: "Split diff"
        type: "boolean"
        default: false
        description: "Use the split-diff package to show diffs for a single file. Only works with `Diff` command when a file is open."
