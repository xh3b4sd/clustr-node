Process = require("./process").Process

class exports.Worker extends Process
  @create: (config) =>
    new Worker(config)



  constructor: (@config = {}) ->
    return Worker.missingGroupNameError() if not @config.group?

    @setup()
    @masterPid = @optimist.argv["cluster-master-pid"]
    @setupEmitRegistration()



  setupEmitRegistration: () =>
    @publisher.publish(@channels.registration(@masterPid), @prepareOutgogingPayload("registration"))



  emitDeregistration: () =>
    @publisher.publish(@channels.deregistration(@masterPid), @prepareOutgogingPayload("deregistration"))



  emitClusterInfo: (cb) =>
    messageCb = (channel, payload) =>
      return if channel isnt @channels.clusterInfo(@pid)

      @subscriber.removeListener("message", messageCb)
      cb(JSON.parse(payload))

    @subscriber.on("message", messageCb)
    @publisher.publish(@channels.clusterInfo(@masterPid), @prepareOutgogingPayload("clusterInfo"))
