arrayEquals = (arr1, arr2) ->
  arr1.forEach (a, i) ->
    expect(a).toEqual arr2[i]

objectEquals = (o1, o2) ->
  Object.keys(o1).forEach (prop) ->
    expect(o1[prop]).toEqual o2[prop]

module.exports = (obj, fn) ->
  spy = spyOn(obj, fn)
  return mock =
    do: (method) ->
      spy.andCallFake method
      return mock
    verifyCalledWith: (args...) ->
      calledWith = spy.mostRecentCall.args
      args.forEach (arg, i) ->
        if arg.forEach?
          arrayEquals arg, calledWith[i]
        if arg.charAt?
          expect(arg).toEqual calledWith[i]
        else
          objectEquals arg, calledWith[i]
