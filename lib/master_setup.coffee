_       = require("underscore")



class exports.MasterSetup
  setupTermination: () ->
    process.on "SIGTERM", () ->
      process.exit(15)

    process.on "exit", (code) =>
      pids = _.flatten(_.toArray(@clusterInfo))
      @emitKill(pid, code) for pid in pids when pid isnt @pid
      @log("cluster died with #{pids.length} processes")



  setupReload: () ->
    @on "workerRegistered", (pid) =>
      # emit the next worker to reload in delay
      setTimeout =>
        @emitReload(@workerPids) if @workerPids.length > 0
      , @config.reloadDelay

    process.on "SIGHUP", () =>
      @workerPids = _.flatten(_.toArray(@clusterInfo))
      @emitReload()



  emitReload: () ->
    @emitKill @workerPids.pop(), 1 # send 1 to respawn



  setupOnClusterInfo: () ->
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.clusterInfo(@pid)

      { meta: { pid } } = JSON.parse(payload)
      @publisher.publish(@channels.clusterInfo(pid), @prepareOutgogingPayload(@clusterInfo))



  ###
  # Master registers workers if they start
  ###
  setupOnRegistration: () ->
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.registration(@pid)

      { meta: { group, pid } } = JSON.parse(payload)
      @clusterInfo[group] ?= []
      @clusterInfo[group].push(pid)

      @emit "workerRegistered", pid



  ###
  # Master deregisters workers if they exit.
  ###
  setupOnDeregistration: () ->
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.deregistration(@pid)

      { meta: { group, pid } } = JSON.parse(payload)
      return if not @clusterInfo[group]?

      pid = @clusterInfo[group].splice(index, 1) for ppid, index in @clusterInfo[group] when ppid is pid
      @log("master deregistered worker pid #{pid}")



  setupMasterSubscriptions: () ->
    @subscriber.subscribe(@channels.registration(@pid))
    @subscriber.subscribe(@channels.deregistration(@pid))
