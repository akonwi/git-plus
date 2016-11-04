AnsiToHtml = require 'ansi-to-html'
ansiToHtml = new AnsiToHtml()
OutputView = require '../../lib/views/output-view'

text = "foo bar baz"

describe "OutputView", ->
  beforeEach ->
    @view = new OutputView

  it "displays a default message", ->
    expect(@view.find('.output').text()).toContain 'Nothing new to show'

  it "displays the new message when ::finish is called", ->
    @view.setContent text
    @view.finish()
    expect(@view.find('.output').text()).toBe text

  it "resets its html property when ::reset is called", ->
    @view.setContent text
    @view.reset()
    expect(@view.find('.output').text()).toContain 'Nothing new to show'

  describe "::setContent", ->
    it "accepts terminal color encoded text and transforms it into html", ->
      @view.setContent "foo[m * [32mmaster[m"
      @view.finish()
      expect(@view.find('.output').html()).toBe 'foo * <span style="color:#0A0">master</span>'

    it "returns the instance of the view to allow method chaining", ->
      @view.setContent(text).finish()
      expect(@view.find('.output').text()).toBe text
