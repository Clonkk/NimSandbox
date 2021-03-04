import osproc
import os
import zmq
import nimpy
import nimjl

# TODO fix exit loop condition with readLine
var shouldRun = true
proc stopLoop*() {.noconv.} =
  shouldRun = false

proc deserialize(strbuf: string) : PyObject =
  # Same comment as serialize : see execpy.nim
  let pickle = pyImport("pickle")
  result = pickle.loads(strbuf)

proc pyLoop() =
  # PAIR pattern by default but PUB/SUB or PUSH/PULL are possibilites for more complex application
  var conn = listen("ipc:///tmp/execpycom", PAIR)
  defer: conn.close()
  if not fileExists("execpy"):
    # Should we trust Nim's compiler to not recompile a file he knows it hasn't changed ?
    discard execCmd("nim c -r execpy.nim") # TODO pass argument on command line
  else:
    # On a prod environment you could imagine to ship the built binary directly
    discard execCmd("./execpy")

  var strbuf = conn.receive()
  let py = pyBuiltinsModule()
  discard py.print(strbuf.deserialize())

proc mainPy() {.used.} =
  while shouldRun:
    pyLoop()
    discard readLine(stdin)
    pyLoop()

proc jlLoop() =
  echo "-- BEGIN --"
  jlInclude("pymod/hooks.jl")
  let jlArg = jlBox(36.36'f64)
  var res = jlCall("testMeBaby", jlArg).to(float64)
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
  # mainJl()
  mainPy()
