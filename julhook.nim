import arraymancer
import tables

import nimjl

type
  A = object
    dict : Table[string, float32]
    dat: Tensor[float64]

  B = tuple
    x: int
    y: int
    z: int

  O = ref object
    a: A
    b: B

proc main*() =
    jlVmInit()
    let juliaCustomPath = "pymod/hooks.jl"
    # let juliaCustomPath = getHomeDir() / "DeepColor" / "Julia" / "customAlgo.jl"
    jlInclude(juliaCustomPath)

    var o : O
    new(o)
    o.a = A(dict: {"A": 1.0'f32,"B": 2.0'f32}.toTable, dat: randomTensor[float64](3, 4, 5, 8.0))
    o.b = (x: 36, y: 48, z: 60)
    var res = jlCall("testMeBaby", o[])
    echo typeof(res)

    jlVmExit()

when isMainModule:
  main()
