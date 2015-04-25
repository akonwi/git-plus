Os = require 'os'
Path = require 'path'
fs = require 'fs-plus'

{Disposable} = require 'atom'
{BufferedProcess} = require 'atom'
{$, $$$, ScrollView} = require 'atom-space-pen-views'

git = require '../git'
GitShow = require '../models/git-show'

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
    headerRow = $$$ ->
      @tr =>
        @td 'Date'
        @td 'Message'
        @td 'Short Hash'

    @commitsListView.append(headerRow)

  parseData: (@data) ->
    separator = ';|'
    newline = '_.;._'
    @data = @data.substring(0, @data.length - newline.length - 1)

    @commits = @data.split(newline).map (line) ->
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

  renderLog: ->
    @commits.forEach (commit) =>
      @renderCommit commit

  renderCommit: (commit) ->
    commitRow = $$$ ->
      @tr =>
        # @td class: 'author', "#{commit.author.substring(0, 1)}"
        @td class: 'date', "#{commit.date} by #{commit.author}"
        @td class: 'message', "#{commit.message}"
        @td class: 'hashShort', "#{commit.hashShort}"

    @commitsListView.append(commitRow)
