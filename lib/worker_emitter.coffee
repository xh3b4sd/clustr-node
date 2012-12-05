class exports.WorkerEmitter
  emitDeregistration: () =>
    @publisher.publish(@channels.deregistration(@masterPid), @prepareOutgogingPayload("deregistration"))



  emitClusterInfo: (cb) =>
    messageCb = (channel, payload) =>
      return if channel isnt @channels.clusterInfo(@pid)

      @subscriber.removeListener("message", messageCb)
      cb(JSON.parse(payload))

    @subscriber.on("message", messageCb)
    @publisher.publish(@channels.clusterInfo(@masterPid), @prepareOutgogingPayload("clusterInfo"))
