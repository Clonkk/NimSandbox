import os
import nimpy


# TODO fix exit loop condition with readLine
var shouldRun = true
proc stopLoop*() {.noconv.} =
  shouldRun = false

# Import pymod folder
# If you use a package in a pip environment it should not be needed
doAssert(pyImport("os").getcwd().to(string) == getCurrentDir())
discard pyImport("sys").path.append("pymod")
let importlib = pyImport("importlib")
let pyhooks = pyImport("hooks")

proc pyLoop2() =
  echo "-- BEGIN --"
  discard importlib.reload(pyhooks)
  var param = 36.36
  var res = pyhooks.testMeBaby(param)
  echo res.to(float)
  echo "-- END -- "

proc mainPy2() {.used.} =
  while shouldRun:
    pyLoop2()
    discard readLine(stdin)
    pyLoop2()

when isMainModule:
  setControlCHook(stopLoop)
  mainPy2()
