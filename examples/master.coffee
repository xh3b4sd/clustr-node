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

# master receives a private message and kills worker
master.onGroup (message) =>
  master.emitKill(message.meta.processId)

# master executes callback if "cacheWorker" was received 2 times
master.onConfirmation 2, "cacheWorker", (message) =>
  # master kills the last confirmed worker
  master.killWorker(message.meta.processId, 1)

# master publishs a public message to channel
master.emitPublic("message")

# master publishs a private message
master.emitPrivate("processId", "message")

# master publishs a group message
master.emitGroup("group", "message")

# master sends exit code 1 to an worker
master.emitKill("processId", 1)

# master spawns worker
master.spawn [
  { file: "./web_worker.coffee",   cpu: 1          }
  { file: "./web_worker.coffee",   cpu: 1          }
  { file: "./cache_worker.coffee", cpu: 2          }
  { file: "./cache_worker.coffee", cpu: 2          }
  { file: "./bashscript",          command: "bash" }
]
