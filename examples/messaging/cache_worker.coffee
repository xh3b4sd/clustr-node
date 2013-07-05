Clustr = require("../../index")



###
# Executing that file will spawn a worker as described below. Take a look in
# `./cache_worker_child.coffee` to see how it works.
###



# create process called "cacheWorker"
cacheWorker = Clustr.Worker.create
  group: "cacheWorker"

# cacheWorker confirm to master
cacheWorker.emitConfirmation("cacheWorker")

# cacheWorker spawns worker
cacheWorker.spawn [
  { name: "cacheWorkerChild", file: "./cache_worker_child.coffee" }
]
