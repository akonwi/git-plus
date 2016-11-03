AnsiToHtml = require 'ansi-to-html'
ansiToHtml = new AnsiToHtml()
OutputView = require '../../lib/views/output-view'

text = "new line"
describe "OutputView", ->
  beforeEach ->
    @view = new OutputView

  it "displays a default message", ->
    expect(@view.find('.output').text()).toContain 'Nothing'

  it "changes its message when ::addLine is called", ->
    @view.addLine text
    expect(@view.message).toBe text

  it "displays the new message when ::finish is called", ->
    @view.addLine text
    @view.finish()
    expect(@view.find('.output').text()).toBe text

  it "resets message and html properties when ::reset is called", ->
    @view.addLine text
    @view.reset()
    expect(@view.find('.output').text()).toContain 'Nothing'
    expect(@view.html).toBeUndefined()

  describe "::setColorEncodedContent", ->
    it "displays html rather than just text when ::finish is called", ->
      @view.setColorEncodedContent "foo[m * [32mmaster[m"
      @view.finish()
      expect(@view.find('.output').html()).toBe 'foo * <span style="color:#0A0">master</span>'
