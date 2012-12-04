Redis        = require("redis")
Optimist     = require("optimist")
ChildProcess = require("child_process")

Mixin        = require("./mixin").Mixin
Channels     = require("./channels").Channels
Emitter      = require("./emitter").Emitter
Listener     = require("./listener").Listener
Spawning     = require("./spawning").Spawning

class exports.Process extends Mixin(Channels, Emitter, Listener, Spawning)
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

    ###
    # @clusterInfo =
    #   webWorker:   [ 5182, 5184 ]
    #   cacheWorker: [ 5186, 5188 ]
    ###
    @clusterInfo  = {}

    @logger       = @config.logger       or console.log
    @optimist     = @config.optimist     or Optimist
    @publisher    = @config.publisher    or Redis.createClient()
    @subscriber   = @config.subscriber   or Redis.createClient()
    @childProcess = @config.childProcess or ChildProcess
    @pid          = process.pid
    @masterPid    = @optimist.argv["cluster-master-pid"] || @pid

    @setupProcessSubscriptions()
    @setupOnKill()



  setupProcessSubscriptions: () =>
    @subscriber.subscribe(@channels.confirmation())
    @subscriber.subscribe(@channels.public())
    @subscriber.subscribe(@channels.private(@pid))
    @subscriber.subscribe(@channels.group(@config.group))
    @subscriber.subscribe(@channels.kill(@pid))



  setupOnKill: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt @channels.kill(@pid)

      @onKillCb () =>
        message = JSON.parse(payload)
        @log("#{message.meta.group} sent exit code #{message.data} to #{@config.group}")
        @emitDeregistration() if @config.group isnt "master"

        # kill own process
        process.exit(message.data)



  close: () =>
    process.removeAllListeners()
    @publisher.quit()
    @subscriber.quit()



  prepareOutgogingPayload: (pid, group, data) =>
    meta:
      pid:   pid
      group: group
    data:    data



  log: (message) =>
    @logger(message) if @optimist.argv["verbose"] is true or @optimist.argv["cluster-verbose"] is true
