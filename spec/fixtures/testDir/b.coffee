grade = (student) ->
  if student.excellentWork
    "A+"
  else if student.okayStuff
    if student.triedHard then "B" else "B-"
  else
    "F"

eldest = if 24 > 21 then "Liz" else "Ike"
