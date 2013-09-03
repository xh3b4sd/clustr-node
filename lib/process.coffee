Util             = require("util")
Redis            = require("redis")
Optimist         = require("optimist")
{ EventEmitter } = require("events")

Mixin        = require("./mixin").Mixin
Channels     = require("./channels").Channels
Emitter      = require("./emitter").Emitter
Listener     = require("./listener").Listener
Spawning     = require("./spawning").Spawning

class exports.Process extends Mixin(Channels, Emitter, Listener, Spawning, EventEmitter)
  @missingGroupNameError: () =>
    throw new Error("group name is missing")



  setup: () =>
    @stats =
      emitPublic:              0
      emitPrivate:             0
      emitGroup:               0
      emitKill:                0
      emitConfirmation:        0
      onMessage:               0
      onPublic:                0
      onGroup:                 0
      onPrivate:               0
      spawnChildProcess:       0
      respawnChildProcess:     0
      receivedConfirmations:   0
      successfulConfirmations: 0

    @pid        = process.pid
    @logger     = @config.logger     or console.log
    @publisher  = @config.publisher  or Redis.createClient()
    @subscriber = @config.subscriber or Redis.createClient()
    @logOptions = { colors: true, showHidden: true, depth: 5 }

    @setupProcessSubscriptions()
    @setupOnKill()



  setupProcessSubscriptions: () =>
    @subscriber.subscribe(@channels.confirmation())
    @subscriber.subscribe(@channels.public())
    @subscriber.subscribe(@channels.private(@pid))
    @subscriber.subscribe(@channels.group(@config.group))
    @subscriber.subscribe(@channels.kill(@pid))
    @subscriber.subscribe(@channels.clusterInfo(@pid))



  setupOnKill: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.kill(@pid)

      @onKillCb () =>
        { meta: { group }, data } = JSON.parse(payload)

        #@log "info - processModule - onKill - #{Util.inspect { sender: group, exitCode: data }, @logOptions}"
        @close(data)



  close: (code = 1) =>
    @emitDeregistration() if @config.group isnt "master"
    @publisher.quit()
    @subscriber.quit()
    process.removeAllListeners()
    process.exit(code)



  prepareOutgogingPayload: (data) =>
    JSON.stringify
      meta:
        pid:   @pid
        group: @config.group
      data:    data



  setLogger: (logger) ->
    @logger = logger



  log: (message) =>
    # TODO configure command line arguments and use optimist only at initialization
    # TODO think about that logging stuff, how would it be cool to handle custom logger?
    @logger(message) if Optimist.argv["verbose"] is true or Optimist.argv["cluster-verbose"] is true
