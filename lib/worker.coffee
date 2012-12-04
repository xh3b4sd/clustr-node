Uuid         = require("node-uuid")
Redis        = require("redis")
Optimist     = require("optimist")
ChildProcess = require("child_process")

Mixin        = require("./mixin").Mixin
Emitter      = require("./emitter").Emitter
Listener     = require("./listener").Listener
Spawning     = require("./spawning").Spawning

class exports.Worker extends Mixin(Emitter, Listener, Spawning)
  @create: (config) =>
    new Worker(config)



  @missingGroupNameError: () =>
    throw new Error("group name is missing")



  constructor: (@config = {}) ->
    return Worker.missingGroupNameError() if not @config.group?

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

    @logger          = @config.logger       or console.log
    @optimist        = @config.optimist     or Optimist
    @publisher       = @config.publisher    or Redis.createClient()
    @subscriber      = @config.subscriber   or Redis.createClient()
    @childProcess    = @config.childProcess or ChildProcess
    @processId       = @config.uuid?.v4()   or Uuid.v4()
    @masterProcessId = @optimist.argv?["cluster-master-process-id"]

    @workers   = []
    @channels     = [
      "confirmation"
      "public"
      "private:#{@processId}"
      "group:#{@config.group}"
      "kill:#{@processId}"
    ]

    @setupSubscriptions()
    @setupKillListener()
    @setupProcessExit()



  setupSubscriptions: () =>
    @subscriber.subscribe(channel) for channel in @channels



  setupKillListener: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "kill:#{@processId}"

      @onKillCb () =>
        message = JSON.parse(payload)
        @log("#{message.meta.group} sent exit code #{message.data} to #{@config.group}")

        # kill own process
        process.exit(message.data)



  setupProcessExit: () =>
    # just bind once and prevent event emitter memory leaks
    return if process.listeners("exit").length is 1

    process.on "exit", (code) =>
      # kill child processes
      worker.kill() for worker in @workers
      @log("#{@config.group} killed #{@workers.length} children")



  log: (message) =>
    @logger(message) if @optimist.argv["verbose"] is true or @optimist.argv["cluster-verbose"] is true
