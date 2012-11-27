Clustr = require("../index")



###
# Executing that file will spawn 4 workers as described below. Each of that
# spawned worker will also spawn a worker. Take a look in `./web_worker.coffee`
# and `cache_worker.coffee` to see how it works.
###



# create the clusters master process
master = Clustr.Master.create
  name: "master"

# master receives a public message
master.onPublic (message) =>

# master receives a private message
master.onPrivate (message) =>

# master executes callback if "cacheWorker" was received 2 times
master.onConfirmation 2, "cache", () =>

# master publishs a message to channel
master.publish("channel", "message")

# master spawns worker
master.spawn [
  { file: "./web_worker.coffee",   cpu: 1 }
  { file: "./web_worker.coffee",   cpu: 1 }
  { file: "./cache_worker.coffee", cpu: 2 }
  { file: "./cache_worker.coffee", cpu: 2 }
]
