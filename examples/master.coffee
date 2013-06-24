Clustr = require("../index")



###
# Executing that file will spawn 4 workers as described below. Each of that
# spawned worker will also spawn a worker. Take a look in `./web_worker.coffee`
# and `cache_worker.coffee` to see how it works.
###



# create the clusters master process
master = Clustr.Master.create()

# master executes callback if "webWorker" was received 2 times
master.onConfirmation 2, "webWorker", (messages) =>
  # master kills the last confirmed worker
  master.emitKill(messages[1].meta.pid, exitCode = 1)

# master executes callback if "cacheWorker" was received 2 times
master.onConfirmation 2, "cacheWorker", (messages) =>
  # master kills the last confirmed worker
  master.emitKill(messages[1].meta.pid, exitCode = 1)

# master spawns worker
master.spawn [
  { file: "./web_worker.coffee", }
  { file: "./web_worker.coffee", args: { "cluster-option": "foo", private: "option" } }
  { file: "./cache_worker.coffee", respawn: false }
  { file: "./cache_worker.coffee", respawn: false }
  { file: "./bashscript", command: "bash" }
]

setTimeout () =>
  console.log ""
  console.log "master shows stats:"
  console.log master.stats
, 3000
