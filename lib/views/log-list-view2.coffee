git = require '../git'

Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

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

  parseData: (data) ->
    separator = ';|'
    newline = '_.;._'
    data = data.substring(0, data.length - newline.length - 1)

    commits = data.split(newline).map (line) ->
      if line.trim() isnt ''
        tmpData = line.trim().split(separator)
        commit = {}

        commit.hashShort = tmpData[0]
        commit.hash =  tmpData[1]
        commit.author = tmpData[2]
        commit.email = tmpData[3]
        commit.message = tmpData[4]
        commit.date = tmpData[5]

        return commit

    @renderLog commits

  renderHeader: ->
    headerRow = $$$ ->
      @tr =>
        @td 'Date'
        @td 'Message'
        @td class: 'hashShort', 'Short Hash'

    @commitsListView.append(headerRow)

  renderLog: (commits) ->
    commits.forEach (commit) =>
      @renderCommit commit

    @skipCommits += amountOfCommitsToShow()

  renderCommit: (commit) ->
    commitRow = $$$ ->
      @tr =>
        @td class: 'date', "#{commit.date} by #{commit.author}"
        @td class: 'message', "#{commit.message}"
        @td class: 'hashShort', "#{commit.hashShort}"

    @commitsListView.append(commitRow)

  branchLog: ->
    @skipCommits = 0
    @commitsListView.empty()
    @onlyCurrentFile = false
    @currentFile = null
    @renderHeader()
    @getLog()

  currentFileLog: (@onlyCurrentFile, @currentFile) ->
    @skipCommits = 0
    @commitsListView.empty()
    @renderHeader()
    @getLog()

  getLog: () ->
    args = ['log', "--pretty=%h;|%H;|%aN;|%aE;|%s;|%ai_.;._", "-#{amountOfCommitsToShow()}", '--skip=' + @skipCommits]
    args.push @currentFile if @onlyCurrentFile and @currentFile?

    console.log args

    git.cmd
      args: args
      options:
        cwd: git.dir(false)
      stdout: (data) =>
        @parseData data
