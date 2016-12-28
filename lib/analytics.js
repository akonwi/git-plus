/** @babel */

const ua = require('universal-analytics')
const trackingId = 'UA-47544457-3'

let user = null

function getUser() {
  let userId = atom.config.get("git-plus._analyticsUserId")
  if (!atom.config.get("git-plus._analyticsUserId")) {
    userId = require("uuid").v4()
    atom.config.set("git-plus._analyticsUserId", userId)
  }
  if (user === null) {
    user = ua(trackingId, userId, {
      headers: {
        "User-Agent": navigator.userAgent
      }
    })
  }
  return user
}

function trackConfigIsOn(name, value) {
  getUser().event('Config', 'ACTIVE', name, value, {anonymizeIp: true}).send()
}

function trackConfigChanged(name, {oldValue, newValue}) {
  getUser().event('Config', 'CHANGED', name, newValue, {anonymizeIp: true}).send()
}

export default function() {
  Object.keys(atom.config.getAll('git-plus')[0].value).forEach(name => {
    atom.config.observe(`git-plus.${name}`, value => { if (value !== undefined || value !== null || value !== '') {trackConfigIsOn(name, value)} })
    atom.config.onDidChange(`git-plus.${name}`, event => trackConfigChanged(name, event))
  })
}
