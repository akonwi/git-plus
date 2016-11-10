module.exports =
  includeStagedDiff:
    title: 'Include staged diffs?'
    type: 'boolean'
    default: true
  openInPane:
    type: 'boolean'
    default: true
    description: 'Allow commands to open new panes'
  splitPane:
    title: 'Split pane direction'
    type: 'string'
    default: 'Down'
    description: 'Where should new panes go? (Defaults to Right)'
    enum: ['Up', 'Right', 'Down', 'Left']
  wordDiff:
    type: 'boolean'
    default: true
    description: 'Should word diffs be highlighted in diffs?'
  syntaxHighlighting:
    title: 'Enable syntax highlighting in diffs?'
    type: 'boolean'
    default: true
  numberOfCommitsToShow:
    type: 'integer'
    default: 25
    minimum: 1
  gitPath:
    type: 'string'
    default: 'git'
    description: 'Where is your git?'
  messageTimeout:
    type: 'integer'
    default: 5
    description: 'How long should success/error messages be shown?'
  showFormat:
    description: 'Which format to use for git show? (none will use your git config default)'
    type: 'string'
    default: 'full'
    enum: ['oneline', 'short', 'medium', 'full', 'fuller', 'email', 'raw', 'none']
  pullBeforePush:
    description: 'Pull from remote before pushing'
    type: 'string'
    default: 'no'
    enum: ['no', 'pull', 'pull --rebase']
  experimental:
    description: 'Enable beta features and behavior'
    type: 'boolean'
    default: false
  verboseCommits:
    description: '(Experimental) Show diffs in commit pane?'
    type: 'boolean'
    default: false
  alwaysPullFromUpstream:
    description: '(Experimental) Always pull from current branch upstream?'
    type: 'boolean'
    default: false
  enableStatusBarIcon:
    type: 'boolean'
    default: true
