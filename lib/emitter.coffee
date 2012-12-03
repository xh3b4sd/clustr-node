class exports.Emitter
  @prepareOutgogingPayload: (processId, group, message) =>
    meta:
      processId: processId
      group:     group
    data:        message



  emitPublic: (message) =>
    payload = Emitter.prepareOutgogingPayload(@processId, @config.group, message)
    @publisher.publish("public", JSON.stringify(payload))
    @stats.emitPublic++



  emitPrivate: (processId, message) =>
    payload = Emitter.prepareOutgogingPayload(@processId, @config.group, message)
    @publisher.publish("private:#{processId}", JSON.stringify(payload))
    @stats.emitPrivate++



  emitGroup: (group, message) =>
    payload = Emitter.prepareOutgogingPayload(@processId, @config.group, message)
    @publisher.publish("group:#{group}", JSON.stringify(payload))
    @stats.emitGroup++



  emitKill: (processId, code = 0) =>
    payload = Emitter.prepareOutgogingPayload(@processId, @config.group, code)
    @publisher.publish("kill:#{processId}", JSON.stringify(payload))
    @stats.emitKill++



  emitConfirmation: (message) =>
    payload = Emitter.prepareOutgogingPayload(@processId, @config.group, message)
    @publisher.publish("confirmation", JSON.stringify(payload))
    @stats.emitConfirmation++
