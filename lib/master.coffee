_       = require("underscore")
Process = require("./process").Process

class exports.Master extends Process
  @create: (config) =>
    new Master(config)



  constructor: (@config = {}) ->
    @config.group = "master"

    @setup()
    @setupOnExit()
    @setupOnRegistration()
    @setupOnDeregistration()
    @setupMasterSubscriptions()



  setupOnExit: () =>
    # just bind once and prevent event emitter memory leaks
    return if process.listeners("exit").length is 1

    process.on "SIGHUP", () =>
      process.exit(1)

    process.on "exit", (code) =>
      pids = _.flatten(_.toArray(@clusterInfo))
      @emitKill(pid, code ) for pid in pids when pid isnt @pid

      @log("cluster dies with #{pids.length} processes")



  setupOnRegistration: () =>
    return if @config.group isnt "master"

    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.registration(@masterPid)

      message = JSON.parse(payload)
      @clusterInfo[message.meta.group] = [] if not @clusterInfo[message.meta.group]?
      @clusterInfo[message.meta.group].push(message.meta.pid)



  setupOnDeregistration: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.deregistration(@masterPid)

      message = JSON.parse(payload)
      for pid, index in @clusterInfo[message.meta.group] when pid is message.meta.pid
        @clusterInfo[message.meta.group].splice(index, 1)



  setupMasterSubscriptions: () =>
    @subscriber.subscribe(@channels.registration(@masterPid))
    @subscriber.subscribe(@channels.deregistration(@masterPid))
