Clustr = require("../index")



###
# Executing that file will spawn a worker as described below. Take a look in
# `./web_worker_child.coffee` to see how it works.
###



# create process called "webWorker"
webWorker = Clustr.Worker.create
  group: "webWorker"

# webWorker receives a public message
webWorker.onPublic (message) =>

# webWorker receives a group message
webWorker.onGroup (message) =>

# webWorker receives a private message
webWorker.onPrivate (message) =>

# webWorker publishs a message to master
webWorker.emitGroup("master", "kill me")

# webWorker confirm to master
webWorker.emitConfirmation("webWorker")

# webWorker sends exit code 1 to an worker
webWorker.emitKill("processId", 1)

# webWorker spawns worker
webWorker.spawn [
  { file: "./web_worker_child.coffee" }
]
