module.exports =
  title: 'Git-Plus'
  addInfo: (message, {dismissable}={}) ->
    atom.notifications.addInfo(@title, detail: message, dismissable: dismissable)
  addSuccess: (message, {dismissable}={}) ->
    atom.notifications.addSuccess(@title, detail: message, dismissable: dismissable)
  addError: (message, {dismissable}={}) ->
    atom.notifications.addError(@title, detail: message, dismissable: dismissable)
