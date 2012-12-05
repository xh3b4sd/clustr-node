_       = require("underscore")
Process = require("./process").Process

class exports.Master extends Process
  @create: (config) =>
    new Master(config)



  constructor: (@config = {}) ->
    @config.group = "master"

    ###
    # @clusterInfo =
    #   webWorker:   [ 5182, 5184 ]
    #   cacheWorker: [ 5186, 5188 ]
    ###
    @clusterInfo  = {}

    @setup()
    @setupTermination()
    @setupOnClusterInfo()
    @setupOnRegistration()
    @setupOnDeregistration()
    @setupMasterSubscriptions()



  setupTermination: () =>
    process.on "SIGHUP", () =>
      process.exit(1)

    process.on "exit", (code) =>
      pids = _.flatten(_.toArray(@clusterInfo))
      @emitKill(pid, code ) for pid in pids when pid isnt @pid
      @log("cluster died with #{pids.length} processes")



  setupOnClusterInfo: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.clusterInfo(@pid)

      { meta: { pid } } = JSON.parse(payload)
      @publisher.publish(@channels.clusterInfo(pid), @prepareOutgogingPayload(@clusterInfo))



  ###
  # Master registers workers if they start
  ###
  setupOnRegistration: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.registration(@pid)

      { meta: { group, pid } } = JSON.parse(payload)
      @clusterInfo[group] ?= []
      @clusterInfo[group].push(pid)



  ###
  # Master deregisters workers if they exit.
  ###
  setupOnDeregistration: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.deregistration(@pid)

      { meta: { group, pid } } = JSON.parse(payload)
      return if not @clusterInfo[group]?

      pid = @clusterInfo[group].splice(index, 1) for ppid, index in @clusterInfo[group] when ppid is pid
      @log("master deregistered worker pid #{pid}")



  setupMasterSubscriptions: () =>
    @subscriber.subscribe(@channels.registration(@pid))
    @subscriber.subscribe(@channels.deregistration(@pid))
