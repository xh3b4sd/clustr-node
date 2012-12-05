class exports.WorkerSetup
  setupEmitRegistration: () =>
    @publisher.publish(@channels.registration(@masterPid), @prepareOutgogingPayload("registration"))
