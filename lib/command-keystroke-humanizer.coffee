_ = require 'underscore-plus'

humanizeKeystroke = (binding) -> _.humanizeKeystroke(binding.keystrokes)

module.exports = (platform = process.platform) ->
    cache = {}
    currentPlatformRegex = new RegExp("\\.platform\\-#{ platform }([,:#\\s]|$)")

    transform = (name, bindings) ->
      if bindings?
        bindings.every (binding) ->
          (cache[name] = humanizeKeystroke(binding)) if currentPlatformRegex.test(binding.selector)

    return {
      get: (commands) ->
        for c in commands
          unless c[0] of cache
            transform(c[0], atom.keymaps.findKeyBindings {command: c[0]})
        cache
    }
