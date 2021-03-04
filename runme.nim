import osproc
import os
import zmq
import nimpy

var shouldRun = true
proc stopLoop*() {.noconv.} =
  shouldRun = false

proc deserialize(strbuf: string) : PyObject =
  let pickle = pyImport("pickle")
  result = pickle.loads(strbuf)

proc pyLoop() =
  var conn = listen("ipc:///tmp/execpycom", PAIR)
  # I trust Nim's compiler to not recompile a file he knows
  discard execCmd("nim r execpy.nim") # TODO pass argument on command line
  # Otherwise it should be: if fileExists("execpy"): execCmd(./execpy)
  # On a prod environment you could imagine to ship the built binary directly
  var strbuf = conn.receive()
  let py = pyBuiltinsModule()
  discard py.print(strbuf.deserialize())

proc mainPy() =
  while shouldRun:
    pyLoop()
    discard readLine(stdin)
    pyLoop()

import nimjl
proc jlLoop() =
  echo "-- BEGIN --"
  jlInclude("pymod/hooks.jl")
  let jlArg = jlBox(36.36'f64)
  var res = (jlCall("testMeBaby", jlArg)).to(float64)
  echo res
  echo "-- END -- "
proc mainJl() =
  jlVmInit()
  while shouldRun:
    jlLoop()
    discard readLine(stdin)
    jlLoop()
  jlVmExit(0)

when isMainModule:
  # mainJl()
  mainPy()
