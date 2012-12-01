_            = require("underscore")
Uuid         = require("node-uuid")
Path         = require("path")
Redis        = require("redis")
ChildProcess = require("child_process")

class exports.Worker
  constructor: (@config = {}) ->
    return @missingGroupNameError() if not @config.group?

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

    @processId    = @config.uuid?.v4()   or Uuid.v4()
    @childProcess = @config.childProcess or ChildProcess
    @publisher    = @config.publisher    or Redis.createClient()
    @subscriber   = @config.subscriber   or Redis.createClient()

    @workerPids   = []
    @channels     = [
      "confirmation"
      "public"
      "private:#{@processId}"
      "group:#{@config.group}"
      "kill:#{@processId}"
    ]

    @setupSubscriptions()
    @setupKill()
    @setupKillChildren()



  @create: (config) =>
    new Worker(config)



  setupSubscriptions: () =>
    @subscriber.subscribe(channel) for channel in @channels



  setupKill: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "kill:#{@processId}"

      @onKillCb () =>
        message = JSON.parse(payload)
        # console.log("#{message.meta.group} kill #{@config.group} - pid: #{process.pid} - exit code: #{message.data}")
        process.exit(message.data)



  setupKillChildren: () =>
    # prevent event emitter memory leaking
    return if process.listeners("exit").length is 1

    process.on "exit", (code) =>
      process.kill(pid, "SIGTERM") for pid in @workerPids
      # console.log "#{@config.group} and #{@workerPids.length} children killed"



  close: () =>
    @publisher.quit()
    @subscriber.quit()



  #
  # emitter
  #



  emitPublic: (message) =>
    payload = @prepareOutgogingPayload(message)
    @publisher.publish("public", JSON.stringify(payload))
    @stats.emitPublic++



  emitPrivate: (processId, message) =>
    payload = @prepareOutgogingPayload(message)
    @publisher.publish("private:#{processId}", JSON.stringify(payload))
    @stats.emitPrivate++



  emitGroup: (group, message) =>
    payload = @prepareOutgogingPayload(message)
    @publisher.publish("group:#{group}", JSON.stringify(payload))
    @stats.emitGroup++



  emitKill: (processId, code = 0) =>
    payload = @prepareOutgogingPayload(code)
    @publisher.publish("kill:#{processId}", JSON.stringify(payload))
    @stats.emitKill++



  emitConfirmation: (message) =>
    payload = @prepareOutgogingPayload(message)
    @publisher.publish("confirmation", JSON.stringify(payload))
    @stats.emitConfirmation++



  #
  # listener
  #



  onPublic: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++
      return if channel isnt "public"

      cb(JSON.parse(payload))
      @stats.onPublic++



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++
      return if channel isnt "private:#{@processId}"

      cb(JSON.parse(payload))
      @stats.onPrivate++



  onGroup: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++
      return if channel isnt "group:#{@config.group}"

      cb(JSON.parse(payload))
      @stats.onGroup++



  onConfirmation: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++

      message = JSON.parse(payload)
      return if channel      isnt "confirmation"
      return if message.data isnt identifier

      @stats.receivedConfirmations++

      return if ++received < requiredMessages

      received = 0
      cb(message)
      @stats.successfulConfirmations++



  onKill: (cb) =>
    @onKillCb = cb



  onKillCb: (cb) =>
    cb()



  #
  # spawning
  #



  spawn: (workers) =>
    @prepareChildProcess(workers, @spawnChildProcess)



  ###
  # some possible commands
  #   node                app.js
  #   coffee              app.js
  #   taskset -c 1 node   app.js
  #   taskset -c 1 coffee app.js
  ###
  prepareChildProcess: (workers, cb) =>
    _.each workers, (worker, id) =>
      [ command, filename ] = process.argv
      args = []

      # change worker command
      command = worker.command if worker.command?

      # set cpu affinity
      if "cpu" of worker
        args = [ "-c", worker.cpu, command ]
        command = "taskset"

      # check worker file
      return @missingWorkerFileError() if not worker.file?
      args.push(Path.resolve(filename, "../", worker.file))

      cb.call(@, command, args, worker.respawn)



  spawnChildProcess: (command, args, respawn) =>
    worker = @childProcess.spawn(command, args)
    # console.log "spawned worker: command: #{command} #{args.join(" ")}"

    @workerPids.push(worker.pid)
    @stats.spawnChildProcess++

    worker.stdout.on "data", (data) =>
      console.log("stdout:", data.toString())

    worker.stderr.on "data", (data) =>
      console.log("stderr:", data.toString())

    # respawn worker
    worker.on "exit", (code) =>
      return if code is 0        # worker ends as expected
      return if respawn is false # worker shouldn`t respawn

      @spawnChildProcess(command, args, respawn)
      @stats.respawnChildProcess++
      # console.log "respawn worker: code: #{code} command: #{command} #{args.join(" ")}"



  #
  # private
  #



  prepareOutgogingPayload: (message) =>
    meta:
      processId: @processId
      group:     @config.group
    data:        message



  missingWorkerFileError: () =>
    throw new Error("worker file is missing")



  missingGroupNameError: () =>
    throw new Error("group name is missing")
