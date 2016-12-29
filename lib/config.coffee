configs =
  general:
    order: 1
    type: "object"
    properties:
      analytics:
        order: 1
        title: "Anonymous Analytics"
        type : "boolean"
        default : true
        description : "[Google Analytics](http://www.google.com/analytics/) is used to track which features are being used the most and causing the most errors. Everything is anonymized and no personal information, source code, or repository information is sent."
      _analyticsUserId:
        order: 2
        title: "Analytics User Id"
        type : "string"
        default : ""
        description : "Unique identifier for this user for tracking usage analytics"
      gitPath:
        order: 3
        title: "Git Path"
        type: "string"
        default: "git"
        description: "If git is not in your PATH, specify where the executable is"
      enableStatusBarIcon:
        order: 4
        title: "Status-bar Pin Icon"
        type: "boolean"
        default: true
        description: "The pin icon in the bottom-right of the status-bar toggles the output view above the status-bar"
      openInPane:
        order: 5
        title: "Allow commands to open new panes"
        type: "boolean"
        default: true
        description: "Commands like `Commit`, `Log`, `Show`, `Diff` can be split into new panes"
      splitPane:
        order: 6
        title: "Split pane direction"
        type: "string"
        default: "Down"
        description: "Where should new panes go?"
        enum: ["Up", "Right", "Down", "Left"]
      messageTimeout:
        order: 7
        title: "Output view timeout"
        type: "integer"
        default: 5
        description: "For how many seconds should the output view above the status-bar stay open?"
      showFormat:
        order: 9
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
      alwaysPullFromUpstream:
        order: 3
        title: "Pull From Upstream"
        type: "boolean"
        default: false
        description: "Always pull from current branch upstream?"
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
        description: "Allow custom commands to be declared in your `init` file and run within Git-plus"

module.exports = ->
  # Cleanup user's config.cson if config properties change
  if userConfigs = atom.config.getAll('git-plus')[0]?.value
    Object.keys(userConfigs).forEach (key) =>
      atom.config.unset "git-plus.#{key}" if not configs[key]

  configs
