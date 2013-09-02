class exports.WorkerSetup
  setupEmitRegistration: () =>
    setTimeout =>
      @publisher.publish(@channels.registration(@masterPid), @prepareOutgogingPayload("registration"))
    , @config.reloadDelay
