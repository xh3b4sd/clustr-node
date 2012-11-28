Clustr = require("../index")



###
# Executing that file will spawn a worker as described below. Take a look in
# `./web_worker_child.coffee` to see how it works.
###



# create process called "webWorker"
webWorker = Clustr.Worker.create
  name: "webWorker"

# webWorker receives a public message
webWorker.onPublic (message) =>

# webWorker receives a group message
webWorker.onGroup (message) =>

# webWorker receives a private message
webWorker.onPrivate (message) =>

# webWorker publishs a message to channel
webWorker.publish("channel", "message")

# webWorker confirm to master
webWorker.publish("confirmation", "web")

# webWorker spawns worker
webWorker.spawn [
  { file: "./web_worker_child.coffee" }
]
