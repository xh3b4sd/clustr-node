Process = require("./process").Process

class exports.Worker extends Process
  constructor: (@config = {}) ->
    return @missingGroupNameError() if not @config.group?

    @setup()



  @create: (config) =>
    new Worker(config)



  #
  # emitter
  #



  emitConfirmation: (message) =>
    payload = @prepareOutgogingPayload(message)
    @publisher.publish("confirmation", JSON.stringify(payload))
    @stats.emitPublic++



  #
  # private
  #



  missingGroupNameError: () =>
    throw new Error("group name is missing")
