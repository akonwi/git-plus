module.exports =
  title: 'Git-Plus'
  addInfo: (message) -> atom.notifications.addInfo(@title, detail: message)
  addSuccess: (message) -> atom.notifications.addSuccess(@title, detail: message)
  addError: (message) -> atom.notifications.addError(@title, detail: message)
