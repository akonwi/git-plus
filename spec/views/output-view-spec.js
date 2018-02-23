'use babel'
const OutputView = require('../../lib/views/output-view')

const text = "foo bar baz"
const view = new OutputView

const getContent = () => view.element.querySelector('#content')

describe("OutputView", () => {
  it("displays a default message", () => {
    expect(getContent().textContent).toContain('Nothing new to show')
  })

  it("displays the new message when ::finish is called", () =>  {
    view.showContent(text)
    expect(getContent().textContent).toBe(text)
  })

  it("resets its html property when ::reset is called", () => {
    view.showContent(text)
    view.reset()
    expect(getContent().textContent).toContain('Nothing new to show')
  })

  describe("::showContent", () => {
    it("accepts terminal color encoded text and transforms it into html", () => {
      view.showContent("foo[m * [32mmaster[m")
      expect(getContent().innerHTML).toBe('foo * <span style="color:#0A0">master</span>')
    })

    it("returns the instance of the view to allow method chaining", () => {
      view.showContent(text)
      expect(getContent().textContent).toBe(text)
    })
  })
})
