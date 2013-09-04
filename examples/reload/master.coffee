Clustr = require("../../index")



# Executing that file will spawn 4 workers as described below.



# create the clusters master process
master = Clustr.Master.create()

console.log "to reload all workers of the cluster, send SIGHUP to master pid:", master.pid, "\n"
console.log "just do: kill -s SIGHUP #{master.pid}\n"



# master spawns worker
master.spawn [
  { file: "./worker.coffee", }
  { file: "./worker.coffee", }
  { file: "./worker.coffee", }
  { file: "./worker.coffee", }
]
