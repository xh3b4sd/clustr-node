Clustr = require("../../index")



# Executing that file will spawn a worker.



# create process called "webWorker"
worker = Clustr.Worker.create
  group: "webWorker"
console.log "worker started with pid:", worker.pid
