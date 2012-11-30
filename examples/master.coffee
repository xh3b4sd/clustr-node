Clustr = require("../index")



###
# Executing that file will spawn 4 workers as described below. Each of that
# spawned worker will also spawn a worker. Take a look in `./web_worker.coffee`
# and `cache_worker.coffee` to see how it works.
###



# create the clusters master process
master = Clustr.Master.create()

# master receives a public message
master.onPublic (message) =>

# master receives a private message and kill that worker
master.onPrivate (message) =>
  master.killWorker(message.meta.workerId)

# master executes callback if "cacheWorker" was received 2 times
master.onConfirmation 2, "cache", (message) =>
  # master kills the last confirmed worker
  master.killWorker(message.meta.workerId, 1)

# master publishs a message to channel
master.publish("channel", "message")

# master sends exit code 1 to an worker
master.killWorker("workerId", 1)

# master spawns worker
master.spawn [
  { file: "./web_worker.coffee",   cpu: 1          }
  { file: "./web_worker.coffee",   cpu: 1          }
  { file: "./cache_worker.coffee", cpu: 2          }
  { file: "./cache_worker.coffee", cpu: 2          }
  { file: "./bashscript",          command: "bash" }
]
