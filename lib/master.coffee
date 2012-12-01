Process = require("./process").Process

class exports.Master extends Process
  constructor: (@config = {}) ->
    @config.group = "master"
    @channels     = [ "confirmation" ]

    @setup()



  @create: (config) =>
    new Master(config)



  #
  # listener
  #



  onConfirmation: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++

      message = JSON.parse(payload)
      return if channel      isnt "confirmation"
      return if message.data isnt identifier

      @stats.receivedConfirmations++

      return if ++received < requiredMessages

      received = 0
      cb(message)
      @stats.successfulConfirmations++
