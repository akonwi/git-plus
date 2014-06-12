#
# * Fuzzy
# * https://github.com/myork/fuzzy
# *
# * Copyright (c) 2012 Matt York
# * Licensed under the MIT license.

fuzzy = {}

# Use in node or in browser
if typeof exports isnt "undefined"
  module.exports = fuzzy
else
  @fuzzy = fuzzy

# Return all elements of `array` that have a fuzzy
# match against `pattern`.
fuzzy.simpleFilter = (pattern, array) ->
  array.filter (string) ->
    fuzzy.test pattern, string

# Does `pattern` fuzzy match `string`?
fuzzy.test = (pattern, string) ->
  fuzzy.match(pattern, string) isnt null

# If `pattern` (input) matches `string` (test against), wrap each matching
# character in `opts.pre` and `opts.post`. If no match, return null
fuzzy.match = (pattern, string, opts={}) ->
  patternIdx = 0
  result = []
  len = string.length
  totalScore = 0
  currScore = 0

  # prefix
  pre = opts.pre or ""

  # suffix
  post = opts.post or ""

  # String to compare against. This might be a lowercase version of the
  # raw string
  compareString = opts.caseSensitive and string or string.toLowerCase()
  ch = undefined
  compareChar = undefined
  pattern = opts.caseSensitive and pattern or pattern.toLowerCase()

  # For each character in the string, either add it to the result
  # or wrap in template if its the next string in the pattern
  idx = 0

  while idx < len
    ch = string[idx]
    if compareString[idx] is pattern[patternIdx]
      ch = pre + ch + post
      patternIdx += 1

      # consecutive characters should increase the score more than linearly
      currScore += 1 + currScore
    else
      currScore = 0
    totalScore += currScore
    result[result.length] = ch
    idx++

  # return rendered string if we have a match for every char
  if patternIdx is pattern.length
    return (
      rendered: result.join("")
      score: totalScore
    )
  null


# The normal entry point. Filters `arr` for matches against `pattern`.
# It returns an array with matching values of the type:
#
#     [{
#         string:   '<b>lah' // The rendered string
#       , index:    2        // The index of the element in `arr`
#       , original: 'blah'   // The original element in `arr`
#     }]
#
# `opts` is an optional argument bag. Details:
#
#    opts = {
#        // string to put before a matching character
#        pre:     '<b>'
#
#        // string to put after matching character
#      , post:    '</b>'
#
#        // Optional function. Input is an element from the passed in
#        // `arr`, output should be the string to test `pattern` against.
#        // In this example, if `arr = [{crying: 'koala'}]` we would return
#        // 'koala'.
#      , extract: function(arg) { return arg.crying; }
#    }
fuzzy.filter = (pattern, arr, opts) ->
  opts = opts or {}

  # Sort by score. Browsers are inconsistent wrt stable/unstable
  # sorting, so force stable by using the index in the case of tie.
  # See http://ofb.net/~sethml/is-sort-stable.html
  arr.reduce(
    (prev, element, idx, arr) ->
      str = element
      str = opts.extract(element)  if opts.extract
      rendered = fuzzy.match(pattern, str, opts)
      if rendered?
        prev[prev.length] =
          string: rendered.rendered
          score: rendered.score
          index: idx
          original: element
      prev
    ,[]
  ).sort (a, b) ->
    compare = b.score - a.score
    return compare if compare
    a.index - b.index
