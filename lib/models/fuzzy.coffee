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
          score: DamerauLevenshtein(pattern, str)
          index: idx
          original: element
        prev
      ,[]
    ).sort (a, b) ->
      compare = a.score - b.score
      return compare if compare
      b.index - a.index
  highlighted
  
DamerauLevenshtein = (down, across, prices={}, damerau=true) ->
  # https://github.com/cbaatz/damerau-levenshtein
  switch typeof prices.insert
    when "function"
      insert = prices.insert
    when "number"
      insert = (c) ->
        prices.insert
    else
      insert = (c) ->
        1
  switch typeof prices.remove
    when "function"
      remove = prices.remove
    when "number"
      remove = (c) ->
        prices.remove
    else
      remove = (c) ->
        1
  switch typeof prices.substitute
    when "function"
      substitute = prices.substitute
    when "number"
      substitute = (from, to) ->
        prices.substitute
    else
      substitute = (from, to) ->
        1
  switch typeof prices.transpose
    when "function"
      transpose = prices.transpose
    when "number"
      transpose = (backward, forward) ->
        prices.transpose
    else
      transpose = (backward, forward) ->
        1
# ---------------------------------------------------------------------------- #
  ds = []
  if down is across
    return 0
  else
    down = down.split("")
    down.unshift null
    across = across.split("")
    across.unshift null
    down.forEach (d, i) ->
      ds[i] = []  unless ds[i]
      across.forEach (a, j) ->
        if i is 0 and j is 0
          ds[i][j] = 0
        else if i is 0
          ds[i][j] = ds[i][j - 1] + insert(a)
        else if j is 0
          ds[i][j] = ds[i - 1][j] + remove(d)
        else
          ds[i][j] = Math.min(ds[i - 1][j] + remove(d), ds[i][j - 1] + insert(a), ds[i - 1][j - 1] + ((if d is a then 0 else substitute(d, a))))
          ds[i][j] = Math.min(ds[i][j], ds[i - 2][j - 2] + ((if d is a then 0 else transpose(d, down[i - 1]))))  if damerau and i > 1 and j > 1 and down[i - 1] is a and d is across[j - 1]
    ds[down.length - 1][across.length - 1]
