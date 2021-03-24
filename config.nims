proc enableOptim() =
  switch("define", "danger")
  switch("stacktrace", "off")
  switch("threads", "on")
  switch("define", "openmp")

enableOptim()
switch("outdir", "bin")
