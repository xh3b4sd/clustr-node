Clustr = require("../index")



###
# Executing that file will spawn a worker as described below. Take a look in
# `./web_worker_child.coffee` to see how it works.
###



# create process called "webWorker"
webWorker = Clustr.Worker.create
  group: "webWorker"

# use propagated private options
console.log webWorker.config.private # "option"

# webWorker confirm to master
webWorker.emitConfirmation("webWorker")

# webWorker do his last action before his own termination
webWorker.onKill (cb) =>
  #console.log("that is webWorker´s last message before termination")
  cb()

# webWorker spawns worker
webWorker.spawn [
  { file: "./web_worker_child.coffee" }
]
