Process = require("./process").Process

class exports.Master extends Process
  constructor: (@config) ->
    @channels = [ @config.name, "public", "confirmation" ]

    @setup()



  @create: (config) =>
    new Master(config)



  onConfirmation: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, message) =>
      return if channel is not "confirmation"
      return if message is not identifier
      return if ++received < requiredMessages

      received = 0
      cb(message)



  isMaster: () =>
    not @config.workerId?
