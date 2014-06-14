# Fuzzy
# https://github.com/myork/fuzzy
#
# Copyright (c) 2012 Matt York
# Licensed under the MIT license.

fuzzy = {}
module.exports = fuzzy

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
    # Ignore Whitespaces
    patternIdx++ if pattern[patternIdx] is ' '

    ch = string[idx]
    if compareString[idx] is pattern[patternIdx]
      ch = pre + ch + post
      patternIdx += 1

      currScore += 1 + currScore
    else
      currScore = 0
    totalScore += currScore
    result[result.length] = ch
    idx++
  return {rendered: result.join(""), score: totalScore} if patternIdx is pattern.length

fuzzy.filter = (pattern, arr, opts={}) ->
  highlighted = arr.reduce(
    (prev, element, idx, arr) ->
      str = element
      str = opts.extract(element) if opts.extract
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
    if compare is 0
      return opts.extract(a.original).length - opts.extract(b.original).length if opts.extract
      return a.original.length - b.original.length
    return compare if compare
    a.index - b.index

  # No matches? Sort the original array using Damerau-Levenshtein.
  if highlighted.length < 1
    highlighted = arr.reduce(
      (prev, element, idx, arr) ->
        str = element
        str = opts.extract(element) if opts.extract
        prev[prev.length] =
          string: str
          score: levenshtein(pattern, str)
          index: idx
          original: element
        prev
      ,[]
    ).sort (a, b) ->
      compare = a.score - b.score
      return compare if compare
      b.index - a.index
  highlighted

###
# Copyright (c) 2011 Andrei Mackenzie
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

# Compute the edit distance between the two given strings
levenshtein = (a, b) ->
  return b.length  if a.length is 0
  return a.length  if b.length is 0
  matrix = []

  # increment along the first column of each row
  i = undefined
  i = 0
  while i <= b.length
    matrix[i] = [i]
    i++

  # increment each column in the first row
  j = undefined
  j = 0
  while j <= a.length
    matrix[0][j] = j
    j++

  # Fill in the rest of the matrix
  i = 1
  while i <= b.length
    j = 1
    while j <= a.length
      if b.charAt(i - 1) is a.charAt(j - 1)
        matrix[i][j] = matrix[i - 1][j - 1]
      else
        # substitution
        # insertion
        matrix[i][j] = Math.min(matrix[i - 1][j - 1] + 1, Math.min(matrix[i][j - 1] + 1, matrix[i - 1][j] + 1)) # deletion
      j++
    i++
  matrix[b.length][a.length]
