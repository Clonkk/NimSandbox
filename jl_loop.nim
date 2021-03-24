import nimjl
import tables

# TODO fix exit loop condition with readLine
var shouldRun = true
proc stopLoop*() {.noconv.} =
  shouldRun = false

proc jlLoop() =
  echo "-- BEGIN --"
  jlInclude("pymod/hooks.jl")
  var tab = {"A": 12.12, "B": 13.13, "C": 14.14}.toTable
  var res = jlCall("testMeBaby", tab).to(float64)
  echo res
  echo "-- END -- "

# I don't like unused warnings
proc mainJl() {.used.} =
  jlVmInit()
  while shouldRun:
    jlLoop()
    discard readLine(stdin)
    jlLoop()
  jlVmExit(0)

when isMainModule:
  setControlCHook(stopLoop)
  mainJl()
