Clustr = require("../index")



###
# Executing that file will just create a worker.
###



# create process called "cacheWorkerChild"
cacheWorkerChild = Clustr.Worker.create
  group: "cacheWorkerChild"

# cacheWorkerChild receives a public message
cacheWorkerChild.onPublic (message) =>

# cacheWorkerChild receives a group message
cacheWorkerChild.onGroup (message) =>

# cacheWorkerChild receives a private message
cacheWorkerChild.onPrivate (message) =>

# cacheWorkerChild publishs a message to channel
cacheWorkerChild.publish("channel", "message")

# cacheWorkerChild confirm to master
cacheWorkerChild.publish("confirmation", "cacheWorkerChild")
