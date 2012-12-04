_       = require("underscore")
Process = require("./process").Process

class exports.Master extends Process
  @create: (config) =>
    new Master(config)



  constructor: (@config = {}) ->
    @config.group = "master"

    @setup()
    @setupTermination()
    @setupOnRegistration()
    @setupOnDeregistration()
    @setupMasterSubscriptions()



  setupTermination: () =>
    # just bind once and prevent event emitter memory leaks
    return if process.listeners("exit").length is 1

    process.on "SIGHUP", () =>
      process.exit(1)

    process.on "exit", (code) =>
      pids = _.flatten(_.toArray(@clusterInfo))
      @emitKill(pid, code ) for pid in pids when pid isnt @pid

      @log("cluster dies with #{pids.length} processes")



  ###
  # Master registers workers if they start
  ###
  setupOnRegistration: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.registration(@masterPid)

      message = JSON.parse(payload)
      @clusterInfo[message.meta.group] = [] if not @clusterInfo[message.meta.group]?
      @clusterInfo[message.meta.group].push(message.meta.pid)



  ###
  # Master deregisters workers if they exit.
  ###
  setupOnDeregistration: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.deregistration(@masterPid)

      message = JSON.parse(payload)
      return if not @clusterInfo[message.meta.group]?

      for pid, index in @clusterInfo[message.meta.group] when pid is message.meta.pid
        pid = @clusterInfo[message.meta.group].splice(index, 1)

      @log("master deregistered worker pid #{pid}")



  setupMasterSubscriptions: () =>
    @subscriber.subscribe(@channels.registration(@masterPid))
    @subscriber.subscribe(@channels.deregistration(@masterPid))
