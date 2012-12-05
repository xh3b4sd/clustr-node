class exports.Emitter
  emitPublic: (message) =>
    @publisher.publish(@channels.public(), @prepareOutgogingPayload(message))
    @stats.emitPublic++



  emitPrivate: (pid, message) =>
    @publisher.publish(@channels.private(pid), @prepareOutgogingPayload(message))
    @stats.emitPrivate++



  emitGroup: (group, message) =>
    @publisher.publish(@channels.group(group), @prepareOutgogingPayload(message))
    @stats.emitGroup++



  emitKill: (pid, code = 0) =>
    @publisher.publish(@channels.kill(pid), @prepareOutgogingPayload(code))
    @stats.emitKill++



  emitConfirmation: (message) =>
    @publisher.publish(@channels.confirmation(), @prepareOutgogingPayload(message))
    @stats.emitConfirmation++
