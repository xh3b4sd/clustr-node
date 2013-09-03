_    = require("underscore")
Util = require("util")



class exports.MasterSetup
  setupTermination: () ->
    process.on "SIGTERM", () ->
      process.exit(15)

    process.on "exit", (code) =>
      pids = _.flatten(_.toArray(@clusterInfo))
      @emitKill(pid, code) for pid in pids when pid isnt @pid
      @log "info - masterModule - onExit - #{Util.inspect { clusterState: "stopped", workerCount: pids.length }, @logOptions}"



  setupReload: () ->
    workerPidsToReload = []

    emitReload = () =>
      @emitKill workerPidsToReload.pop(), 1 # send 1 to respawn

    @on "workerRegistered", (pid) =>
      # emit the next worker to reload in delay
      setTimeout =>
        emitReload(workerPidsToReload) if workerPidsToReload.length > 0
      , @config.reloadDelay

    process.on "SIGHUP", () =>
      # save all pids to reload and reset the @clusterInfo. in that way
      # @clusterInfo is fresh for the newly joined workers, and ready to be
      # filled again. further we prevent memory leaks.
      workerPidsToReload = _.flatten(_.toArray(@clusterInfo))
      @clusterInfo = {}
      emitReload()

      @log "info - masterModule - onReload - #{Util.inspect { clusterState: "initializing" }, @logOptions}"



  setupOnClusterInfo: () ->
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.clusterInfo(@pid)

      { meta: { pid } } = JSON.parse(payload)
      @publisher.publish(@channels.clusterInfo(pid), @prepareOutgogingPayload(@clusterInfo))



  ###
  # Master registers workers if they start
  ###
  setupOnRegistration: () ->
    registeredWorkersCount = 0

    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.registration(@pid)

      { meta: { group, pid } } = JSON.parse(payload)
      @clusterInfo[group] ?= []
      @clusterInfo[group].push(pid)

      @emit "workerRegistered", pid

      # TODO log levels.
      # cluster state logging.
      workerCount = @workerConfigs.length

      if workerCount == ++registeredWorkersCount
        @onClusterStartedCb workerCount if @onClusterStartedCb?
        @log "info - masterModule - onWorkerRegistered - #{Util.inspect { clusterState: "started", workerCount: workerCount }, @logOptions}"

      else if registeredWorkersCount % workerCount == 0
        @onClusterReloadedCb workerCount if @onClusterReloadedCb?
        @log "info - masterModule - onWorkerRegistered - #{Util.inspect { clusterState: "reloaded", workerCount: workerCount }, @logOptions}"



  setupOnStarted: () ->
    @onClusterStarted = (cb) =>
      @onClusterStartedCb = cb



  setupOnReloaded: () ->
    @onClusterReloaded = (cb) =>
      @onClusterReloadedCb = cb



  ###
  # Master deregisters workers if they exit.
  ###
  setupOnDeregistration: () ->
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.deregistration(@pid)

      { meta: { group, pid } } = JSON.parse(payload)
      return if not @clusterInfo[group]?

      pid = @clusterInfo[group].splice(index, 1) for ppid, index in @clusterInfo[group] when ppid is pid
      #@log "info - masterModule - onDeregistration - #{Util.inspect { workerState: "deregistered", workerPid: pid }, @logOptions}"



  setupMasterSubscriptions: () ->
    @subscriber.subscribe(@channels.registration(@pid))
    @subscriber.subscribe(@channels.deregistration(@pid))
