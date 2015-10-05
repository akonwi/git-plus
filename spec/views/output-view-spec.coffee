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

  it "resets to the default message when ::reset is called", ->
    @view.addLine text
    @view.reset()
    expect(@view.find('.output').text()).toContain 'Nothing'
