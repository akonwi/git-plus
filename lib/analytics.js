/** @babel */

const Config = atom.config
const ua = require('universal-analytics')
const trackingId = 'UA-47544457-3'

let user = null

function getUser() {
  let userId = atom.config.get("git-plus.general._analyticsUserId")
  if (!atom.config.get("git-plus.general._analyticsUserId")) {
    userId = require("uuid").v4()
    atom.config.set("git-plus.general._analyticsUserId", userId)
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

function trackBooleanConfigIsOn(name) {
  getUser().event('Config', 'ON', name, {anonymizeIp: true}).send()
}

function trackBooleanConfigIsOff(name) {
  getUser().event('Config', 'OFF', name, {anonymizeIp: true}).send()
}

function trackIntConfigIsOn(name, value) {
  getUser().event('Config', 'ON', name, value, {anonymizeIp: true}).send()
}

function trackStringConfig(name, value) {
  getUser().event('Config', 'ON', `${name}:${value}`, {anonymizeIp: true}).send()
}

function trackConfig(name, value) {
  if (parseInt(value) >= 0) {
    trackIntConfigIsOn(name, value)
  }
  else if (value === true) {
    trackBooleanConfigIsOn(name)
  }
  else if (value === false) {
    trackBooleanConfigIsOff(name)
  }
  else if (value.charAt) {
    trackStringConfig(name, value)
  }
}

function track(name) {
  const configKey = `git-plus.${name}`
  const config = Config.get(configKey)
  const schema = Config.getSchema(configKey)
  if (configKey === 'git-plus.general._analyticsUserId') return
  if (schema.type === 'object') {
    Object.keys(schema.properties).forEach(property => track(`${name}.${property}`))
  }
  else {
    trackConfig(configKey, config)
  }
}

// function trackConfigChanged(name, {oldValue, newValue}) {
//   getUser().event('Config', 'CHANGED', name, {anonymizeIp: true}).send()
// }

export default function() {
  let userConfigs = Config.getAll('git-plus')[0]
  userConfigs = userConfigs.value
  Object.keys(userConfigs).forEach(track)
  // Object.keys(userConfigs).forEach(config => {
  //   atom.config.onDidChange(`git-plus.${config}`, event => trackConfigChanged(name, event))
  // })
}
