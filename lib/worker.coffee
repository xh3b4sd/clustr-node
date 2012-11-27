Process = require("./process").Process

class exports.Worker extends Process
  constructor: (@config) ->
    @channels = [ @config.name, "public" ]

    @setup()



  @create: (config) =>
    new Worker(config)



  isWorker: () =>
    @config.workerId?
