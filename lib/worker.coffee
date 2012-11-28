Uuid    = require("node-uuid")
Process = require("./process").Process

class exports.Worker extends Process
  constructor: (@config) ->
    @uuid     = @config.uuid or Uuid
    @workerId = @uuid.v4()
    @channels = [ @workerId, @config.group, "public" ]

    @setup()



  @create: (config) =>
    new Worker(config)



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @workerId
      cb(@prepareIncommingPayload(payload))



  onGroup: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @config.group
      cb(@prepareIncommingPayload(payload))



  isWorker: () =>
    @config.workerId?
