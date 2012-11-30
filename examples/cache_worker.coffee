Clustr = require("../index")



###
# Executing that file will spawn a worker as described below. Take a look in
# `./cache_worker_child.coffee` to see how it works.
###



# create process called "cacheWorker"
cacheWorker = Clustr.Worker.create
  group: "cacheWorker"

# cacheWorker receives a public message
cacheWorker.onPublic (message) =>

# cacheWorker receives a group message
cacheWorker.onGroup (message) =>

# cacheWorker receives a private message
cacheWorker.onPrivate (message) =>

# cacheWorker spawns worker
cacheWorker.spawn [
  { name: "cacheWorkerChild", file: "./cache_worker_child.coffee" }
]
