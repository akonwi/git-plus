const OutputView = require('./views/output-view')

const view = new OutputView

module.exports = {
  getView() {
    view.reset()
    return view
  }
}
