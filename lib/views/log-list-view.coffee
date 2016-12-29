{Disposable} = require 'atom'
{BufferedProcess} = require 'atom'
{$, $$$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'
git = require '../git'
GitShow = require '../models/git-show'

numberOfCommitsToShow = -> atom.config.get('git-plus.logs.numberOfCommitsToShow')

module.exports =
class LogListView extends View
  @content: ->
    @div class: 'git-plus-log', tabindex: -1, =>
      @table id: 'git-plus-commits', outlet: 'commitsListView'
      @div class: 'show-more', =>
        @a id: 'show-more', 'Show More'

  getURI: -> 'atom://git-plus:log'

  getTitle: -> 'git-plus: Log'

  initialize: ->
    @skipCommits = 0
    @finished = false
    loadMore = _.debounce( =>
      @getLog() if @prop('scrollHeight') - @scrollTop() - @height() < 20
    , 50)
    @on 'click', '.commit-row', ({currentTarget}) =>
      @showCommitLog currentTarget.getAttribute('hash')
    @on 'click', '#show-more', loadMore
    @scroll(loadMore)

  attached: ->
    @commandSubscription = atom.commands.add @element,
      'core:move-down': => @selectNextResult()
      'core:move-up': => @selectPreviousResult()
      'core:page-up': => @selectPreviousResult(10)
      'core:page-down': => @selectNextResult(10)
      'core:move-to-top': =>
        @selectFirstResult()
      'core:move-to-bottom': =>
        @selectLastResult()
      'core:confirm': =>
        hash = @find('.selected').attr('hash')
        @showCommitLog hash if hash
        false

  detached: ->
    @commandSubscription.dispose()
    @commandSubscription = null

  parseData: (data) ->
    if data.length < 1
      @finished = true
      return

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
    @skipCommits += numberOfCommitsToShow()

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
    return if @finished

    args = ['log', "--pretty=%h;|%H;|%aN;|%aE;|%s;|%ai_.;._", "-#{numberOfCommitsToShow()}", '--skip=' + @skipCommits]
    args.push @currentFile if @onlyCurrentFile and @currentFile?
    git.cmd(args, cwd: @repo.getWorkingDirectory())
    .then (data) => @parseData data

  selectFirstResult: ->
    @selectResult(@find('.commit-row:first'))
    @scrollToTop()

  selectLastResult: ->
    @selectResult(@find('.commit-row:last'))
    @scrollToBottom()

  selectNextResult: (skip = 1) ->
    selectedView = @find('.selected')
    return @selectFirstResult() if selectedView.length < 1
    nextView = @getNextResult(selectedView, skip)

    @selectResult(nextView)
    @scrollTo(nextView)

  selectPreviousResult: (skip = 1) ->
    selectedView = @find('.selected')
    return @selectFirstResult() if selectedView.length < 1
    prevView = @getPreviousResult(selectedView, skip)

    @selectResult(prevView)
    @scrollTo(prevView)

  getNextResult: (element, skip) ->
    return unless element?.length
    items = @find('.commit-row')
    itemIndex = items.index(element)
    $(items[Math.min(itemIndex + skip, items.length - 1)])

  getPreviousResult: (element, skip) ->
    return unless element?.length
    items = @find('.commit-row')
    itemIndex = items.index(element)
    $(items[Math.max(itemIndex - skip, 0)])

  selectResult: (resultView) ->
    return unless resultView?.length
    @find('.selected').removeClass('selected')
    resultView.addClass('selected')

  scrollTo: (element) ->
    return unless element?.length
    top = @scrollTop() + element.offset().top - @offset().top
    bottom = top + element.outerHeight()

    @scrollBottom(bottom) if bottom > @scrollBottom()
    @scrollTop(top) if top < @scrollTop()
