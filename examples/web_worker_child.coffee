Clustr = require("../index")



###
# Executing that file will just create a worker.
###



# create process called "webWorkerChild"
webWorkerChild = Clustr.Worker.create
  group: "webWorkerChild"

# webWorkerChild receives a public message
webWorkerChild.onPublic (message) =>

# webWorkerChild receives a group message
webWorkerChild.onGroup (message) =>

# webWorkerChild receives a private message
webWorkerChild.onPrivate (message) =>
