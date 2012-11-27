Clustr = require("../index")



###
# Executing that file will just create a worker.
###



# create process called "webWorkerChild"
webWorkerChild = Clustr.Worker.create
  name: "webWorkerChild"

# webWorkerChild receives a public message
webWorkerChild.onPublic (message) =>

# webWorkerChild receives a private message
webWorkerChild.onPrivate (message) =>

# webWorkerChild publishs a message to channel
webWorkerChild.publish("channel", "message")

# webWorkerChild confirm to master
webWorkerChild.publish("confirmation", "webWorkerChild")
