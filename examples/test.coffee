Clustr  = require("../index")

options =
  defaults:
    test: false
    ppid: process.pid
  cluster:
    master:
      { name: "master", port: 8000 }
    workers: [
      { name: "web", port: 8001, cpu: 1, respawn: true, deamon: true }
      { name: "web", port: 8002, cpu: 2, respawn: true, deamon: true }
      { name: "cache", deamon: true }
      { name: "cache", deamon: true }
    ]

clustr  = Clustr.create(options.cluster)



# executed by master
clustr.master.do (master) =>

  # master receives a public message
  master.onPublic (message) =>

  # master receives a private message
  master.onPrivate (message) =>

  # master executes callback if "cacheWorker" was received 2 times
  master.onConfirm 2, "cache", () =>

  # master publishs a message to channel
  master.publish("channel", "message")



# executed by each cacheWorker
clustr.worker.do "cache", (cacheWorker) =>

  # cacheWorker receives a public message
  cacheWorker.onPublic (message) =>

  # cacheWorker receives a private message
  cacheWorker.onPrivate (message) =>

  # cacheWorker publishs a message to channel
  cacheWorker.publish("channel", "message")

  # cacheWorker confirm to master
  cacheWorker.publish("confirm", "cache")



# executed by each worker
clustr.workers.do (workers) =>

  # all workers receives a message
  workers.onMessage (message) =>

  # all workers publishs a message to channel
  workers.publish("channel", "message")
