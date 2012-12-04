class exports.Emitter
  emitPublic: (message) =>
    payload = @prepareOutgogingPayload(@pid, @config.group, message)
    @publisher.publish(@channels.public(), JSON.stringify(payload))
    @stats.emitPublic++



  emitPrivate: (pid, message) =>
    payload = @prepareOutgogingPayload(@pid, @config.group, message)
    @publisher.publish(@channels.private(pid), JSON.stringify(payload))
    @stats.emitPrivate++



  emitGroup: (group, message) =>
    payload = @prepareOutgogingPayload(@pid, @config.group, message)
    @publisher.publish(@channels.group(group), JSON.stringify(payload))
    @stats.emitGroup++



  emitKill: (pid, code = 0) =>
    payload = @prepareOutgogingPayload(@pid, @config.group, code)
    @publisher.publish(@channels.kill(pid), JSON.stringify(payload))
    @stats.emitKill++



  emitConfirmation: (message) =>
    payload = @prepareOutgogingPayload(@pid, @config.group, message)
    @publisher.publish(@channels.confirmation(), JSON.stringify(payload))
    @stats.emitConfirmation++
