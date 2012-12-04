Process = require("./process").Process

class exports.Worker extends Process
  @create: (config) =>
    new Worker(config)



  constructor: (@config = {}) ->
    return Worker.missingGroupNameError() if not @config.group?

    @setup()
    @setupEmitRegistration()



  setupEmitRegistration: () =>
    payload = @prepareOutgogingPayload(@pid, @config.group, "registration")
    @publisher.publish(@channels.registration(@masterPid), JSON.stringify(payload))



  emitDeregistration: () =>
    payload = @prepareOutgogingPayload(@pid, @config.group, "deregistration")
    @publisher.publish(@channels.deregistration(@masterPid), JSON.stringify(payload))
