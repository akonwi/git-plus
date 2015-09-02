{Disposable} = require 'atom'
{BufferedProcess} = require 'atom'
{$, $$$, ScrollView} = require 'atom-space-pen-views'
git = require '../git'
GitShow = require '../models/git-show'

amountOfCommitsToShow = ->
  atom.config.get('git-plus.amountOfCommitsToShow')

module.exports =
class LogListView extends ScrollView
  @content: ->
    @div class: 'git-plus-log native-key-bindings', tabindex: -1, =>
      @table id: 'git-plus-commits', outlet: 'commitsListView'

  onDidChangeTitle: -> new Disposable
  onDidChangeModified: -> new Disposable

  getURI: -> 'atom://git-plus:log'

  getTitle: -> 'git-plus: Log'

  initialize: ->
    super
    @skipCommits = 0
    @on 'click', '.commit-row', ({currentTarget}) =>
      @showCommitLog currentTarget.getAttribute('hash')
    @scroll =>
      @getLog() if @scrollTop() + @height() is @prop('scrollHeight')

  parseData: (data) ->
    if data.length > 0
      separator = ';|'
      newline = '_.;._'
      data = data.substring(0, data.length - newline.length - 1)

      commits = data.split(newline).map (line) ->
        if line.trim() isnt ''
          tmpData = line.trim().split(separator)
          return {
            hashShort: tmpData[0]
            hash: tmpData[1]
            author: tmpData[2]
            email: tmpData[3]
            message: tmpData[4]
            date: tmpData[5]
          }

      @renderLog commits

  renderHeader: ->
    headerRow = $$$ ->
      @tr class: 'commit-header', =>
        @td 'Date'
        @td 'Message'
        @td class: 'hashShort', 'Short Hash'

    @commitsListView.append(headerRow)

  renderLog: (commits) ->
    commits.forEach (commit) => @renderCommit commit
    @skipCommits += amountOfCommitsToShow()

  renderCommit: (commit) ->
    commitRow = $$$ ->
      @tr class: 'commit-row', hash: "#{commit.hash}", =>
        @td class: 'date', "#{commit.date} by #{commit.author}"
        @td class: 'message', "#{commit.message}"
        @td class: 'hashShort', "#{commit.hashShort}"

    @commitsListView.append(commitRow)

  showCommitLog: (hash) ->
    GitShow(@repo, hash, @currentFile if @onlyCurrentFile)

  branchLog: (@repo) ->
    @skipCommits = 0
    @commitsListView.empty()
    @onlyCurrentFile = false
    @currentFile = null
    @renderHeader()
    @getLog()

  currentFileLog: (@repo, @currentFile) ->
    @onlyCurrentFile = true
    @skipCommits = 0
    @commitsListView.empty()
    @renderHeader()
    @getLog()

  getLog: ->
    args = ['log', "--pretty=%h;|%H;|%aN;|%aE;|%s;|%ai_.;._", "-#{amountOfCommitsToShow()}", '--skip=' + @skipCommits]
    args.push @currentFile if @onlyCurrentFile and @currentFile?
    git.cmd(args, cwd: @repo.getWorkingDirectory())
    .then (data) => @parseData data
