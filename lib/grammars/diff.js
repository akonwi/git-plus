(function() {
  var _ = require('underscore-plus')
  var path = require('path')
  var registry = atom.grammars

  var baseWordGrammar = registry.readGrammarSync(path.join(__dirname, 'word-diff.json'))
  baseWordGrammar.packageName = 'git-plus'
  var wordGrammar = Object.create(baseWordGrammar)
  wordGrammar.tokenizeLine = tokenizeLine

  var baseLineGrammar = registry.readGrammarSync(path.join(__dirname, 'line-diff.json'))
  baseLineGrammar.packageName = 'git-plus'
  var lineGrammar = Object.create(baseLineGrammar)
  lineGrammar.tokenizeLine = tokenizeLine

  module.exports = {
    wordGrammar: wordGrammar,
    lineGrammar: lineGrammar
  }

  function tokenizeLine(line, ruleStack, firstLine) {
    var grammar = null
    var codeStack = []
    var stack = ruleStack
    if (stack && stack.length > 1) {
      var grammarIndex = stack.findIndex(item => _.isUndefined(item.rule))
      if (grammarIndex !== -1) {
        codeStack = stack.slice(grammarIndex + 1)
        grammar = stack[grammarIndex]
        stack = stack.slice(0, grammarIndex)
      }
    }
    var tokenizeResult = this.__proto__.tokenizeLine(line, stack, firstLine)
    var tags = tokenizeResult.tags
    var openScopeTags = tokenizeResult.openScopeTags.slice()
    var tokens = tokenizeResult.tokens
    stack = tokenizeResult.ruleStack
    var tokenTagIndices = []
    for (let i = 0; i < tags.length; i++) {
      if (tags[i] > 0) {
        tokenTagIndices.push(i)
      }
    }
    if (!grammar && stack && stack.length == 1) {
      for (let i = 0; i < tokens.length; i++) {
        var isFileName = tokens[i].scopes.some(scope => {
          return scope.indexOf('header.from-file') != -1 ||
						scope.indexOf('header.to-file') != -1
        })
        if (isFileName) {
          var ext = path.extname(tokens[i].value)
          if (ext && ext !== '') {
            grammar = atom.grammars.selectGrammar(tokens[i].value)
            if (grammar.scopeName) {
              grammar = atom.grammars.grammarForScopeName(grammar.scopeName)
            }
          }
        }
      }
    } else if (grammar) {
      if (codeStack.length === 0) {
        codeStack = null
      }
      var res = runCodeGrammar(grammar, tags, tokens, tokenTagIndices, codeStack)
      tags = res.tags
      codeStack = res.codeStack

      if (line.indexOf('diff --git a/') === 0) {
        grammar = null
      }
    }
    if (grammar) {
      stack.push(grammar)
      if (codeStack) {
        stack = stack.concat(codeStack)
      }
    }
    return _.extend(tokenizeResult, { tags: tags, ruleStack: stack, openScopeTags: openScopeTags })
  }

  function runCodeGrammar(grammar, tags, tokens, tokenTagIndices, codeStack) {
    var removedLine = ''
    var addedLine = ''

    for (let i = 0; i < tokens.length; i++) {
      var notCode = isNotCode(tokens[i].scopes)
      if (notCode) {
        continue
      }
      if (_.contains(tokens[i].scopes, 'markup.added.diff')) {
        addedLine += tokens[i].value
      } else if (_.contains(tokens[i].scopes, 'markup.removed.diff')) {
        removedLine += tokens[i].value
      } else {
        addedLine += tokens[i].value
        removedLine += tokens[i].value
      }
    }

    var removedResult
    var removedIdx = 0
    var addedResult
    var addedIdx = 0
    if (removedLine && removedLine.trim().length) {
      removedResult = grammar.tokenizeLine(removedLine, codeStack)
      removedIdx = removedLine.length
    }
    if (addedLine && addedLine.trim().length !== undefined) {
      addedResult = grammar.tokenizeLine(addedLine, codeStack)
      addedIdx = addedLine.length
    }
    var replacementTags = []
    var newIdx = {}
    if (removedIdx) {
      newIdx.removed = removedIdx
    }
    if (addedIdx) {
      newIdx.added = addedIdx
    }
    for (let i = tokens.length - 1; i >= 0; i--) {
      notCode = isNotCode(tokens[i].scopes)
      if (notCode) {
        continue
      }
      var tagStack = []
      if (codeStack) {
        for (let j = 0; j < codeStack.length; j++) {
          var scope = codeStack[j].scopeName || codeStack[j].contentScopeName
          if (scope) {
            tagStack.push(atom.grammars.startIdForScope(scope))
          }
        }
      }
      var replaceIdx = tokenTagIndices[i]
      var oldTag = tags[replaceIdx]
      var currentLength = 0
      var currentIdx = 0
      var newTags
      removedIdx = _.isUndefined(newIdx.removed) ? removedIdx : newIdx.removed
      addedIdx = _.isUndefined(newIdx.added) ? addedIdx : newIdx.added
      if (_.contains(tokens[i].scopes, 'markup.removed.diff')) {
        newTags = removedResult && removedResult.tags
        newIdx = { removed: removedIdx }
      } else if (_.contains(tokens[i].scopes, 'markup.added.diff')) {
        newTags = addedResult && addedResult.tags
        newIdx = { added: addedIdx }
      } else {
        newTags = (addedResult && addedResult.tags) || (removedResult && removedResult.tags)
        newIdx = { added: addedIdx, removed: removedIdx }
      }
      if (!newTags) {
        continue
      }
      addToIndices(newIdx, -tokens[i].value.length)
      var startIdx = _.isUndefined(newIdx.added) ? newIdx.removed : newIdx.added
      var tagLength = 0
      let j = 0
      if (currentIdx < startIdx) {
        for (; j < newTags.length; j++) {
          if (!isLengthTag(newTags[j])) {
            continue
          }

          if (currentIdx + newTags[j] > startIdx) {
            tagLength = currentIdx + newTags[j] - startIdx
            currentIdx += tagLength
            while (j - 1 > 0 && isStartTag(newTags[j - 1])) {
              j--
            }
            break
          } else if (currentIdx + newTags[j] === startIdx) {
            currentIdx += newTags[j]
            break
          } else {
            currentIdx += newTags[j]
          }
        }
      }
      for (var k = 0; k < j; k++) {
        if (isLengthTag(newTags[k])) {
          continue
        }
        if (isStartTag(newTags[k])) {
          tagStack.push(newTags[k])
        } else {
          tagStack.pop()
        }
      }
      for (let k = 0; k < tagStack.length; k++) {
        replacementTags.push(tagStack[k])
      }
      for (; j < newTags.length; j++) {
        if (isLengthTag(newTags[j])) {
          if (currentLength >= oldTag) {
            break
          }

          tagLength = tagLength || newTags[j]
          if (currentLength + tagLength > oldTag) {
            var tokenLength = oldTag - currentLength
            replacementTags.push(tokenLength)
            currentLength += tokenLength
            addToIndices(newIdx, tokenLength)
          } else {
            replacementTags.push(tagLength)
            currentLength += tagLength
            addToIndices(newIdx, tagLength)
          }
          tagLength = 0
        } else {
          if (isStartTag(newTags[j])) {
            if (currentLength < oldTag) {
              tagStack.push(newTags[j])
            } else {
              break
            }
          } else if (isEndTag(newTags[j]) && newTags[j] === tagStack[tagStack.length - 1] - 1) {
            tagStack.pop()
          } else if (isEndTag(newTags[j])) {
            replacementTags.push(newTags[j] + 1)
          }
          replacementTags.push(newTags[j])
        }
      }
      for (let j = tagStack.length - 1; j >= 0; j--) {
        replacementTags.push(tagStack[j] - 1) //end tag for start tag
      }

			//go back to beginning of replaced tag, since we are going backwards through old tags
      addToIndices(newIdx, -oldTag)
      tags.splice(replaceIdx, 1, ...replacementTags)
      replacementTags = []
    }

    codeStack = (addedResult && addedResult.ruleStack) || (removedResult && removedResult.ruleStack) || codeStack || null
    return { tags: tags, codeStack: codeStack }
  }

  function addToIndices(indices, num) {
    if (!_.isUndefined(indices.removed)) {
      indices.removed = Math.max(indices.removed + num, 0)
    }
    if (!_.isUndefined(indices.added)) {
      indices.added = Math.max(indices.added + num, 0)
    }
  }

  function isNotCode(scopes) {
    return _.contains(scopes, 'unimportant') ||
			_.contains(scopes, 'insertion') ||
			_.contains(scopes, 'deletion') ||
			_.contains(scopes, 'info') ||
			_.contains(scopes, 'meta.diff.info.header.from-file') ||
			_.contains(scopes, 'meta.diff.info.header.to-file')
  }

  function isStartTag(tag) {
    return (tag % 2) === -1
  }

  function isEndTag(tag) {
    return tag < 0 && !isStartTag(tag)
  }

  function isLengthTag(tag) {
    return tag >= 0
  }
})()
