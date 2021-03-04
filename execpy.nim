import nimpy
import zmq
import os

block:
  # Import pymod folder
  # If you use a package in a pip environment it should not be needed
  doAssert(pyImport("os").getcwd().to(string) == getCurrentDir())
  discard pyImport("sys").path.append("pymod")

proc serialize(pyObj: PyObject): string =
  # Here I'm gonna cheat because I don't want to deal with the serialization since the RawPyBuffer method will not work for PyObject that are not byte like
  # pickle performance and limitations are the weakness of this solutions
  let pickle = pyImport("pickle")
  result = pickle.dumps(pyObj).to(string)

# TODO this should take argument based on command line
proc mainPy() =
  var conn = connect("ipc:///tmp/execpycom", PAIR)
  defer: conn.close()
  echo "-- BEGIN --"

  # TODO this should be parameters
  let pymodule = "hooks"
  let pyhooks = pyImport(pymodule)
  var param = 36.36
  var res = pyhooks.testMeBaby(param)
  conn.send(res.serialize())

  echo res.to(float)
  echo "-- END -- "

when isMainModule:
  mainPy()
