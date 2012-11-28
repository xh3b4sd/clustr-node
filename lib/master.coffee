Process = require("./process").Process

class exports.Master extends Process
  constructor: (@config) ->
    @config.group = "master"
    @channels     = [ @config.group, "public", "confirmation" ]

    @setup()



  @create: (config) =>
    new Master(config)



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @config.group
      cb(JSON.parse(payload))



  onConfirmation: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, message) =>
      return if channel isnt "confirmation"
      return if message isnt identifier
      return if ++received < requiredMessages

      received = 0
      cb(message)
