_            = require("underscore")
Uuid         = require("node-uuid")
Path         = require("path")
Redis        = require("redis")
ChildProcess = require("child_process")

class exports.Process
  setup: () =>
    @stats =
      emitPublic:          0
      emitPrivate:         0
      emitGroup:           0
      emitKill:            0
      onPublic:            0
      onGroup:             0
      onPrivate:           0
      onConfirmation:      0
      spawnChildProcess:   0
      respawnChildProcess: 0

    @processId    = @config.uuid?.v4()   or Uuid.v4()
    @childProcess = @config.childProcess or ChildProcess
    @publisher    = @config.publisher    or Redis.createClient()
    @subscriber   = @config.subscriber   or Redis.createClient()

    @channels ?= []
    @channels.push("public")
    @channels.push("private:#{@processId}")
    @channels.push("group:#{@config.group}")
    @channels.push("kill:#{@processId}")

    @setupSubscriptions()
    @setupKill()



  setupSubscriptions: () =>
    @subscriber.subscribe(channel) for channel in @channels



  setupKill: () =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "kill:#{@processId}"

      message = JSON.parse(payload)
      # console.log("#{message.meta.group} kill #{@config.group} - exit code: #{message.data}")
      process.exit(message.data)



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



  #
  # listener
  #



  onPublic: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "public"

      cb(JSON.parse(payload))
      @stats.onPublic++



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "private:#{@processId}"

      cb(JSON.parse(payload))
      @stats.onPrivate++



  onGroup: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "group:#{@config.group}"

      cb(JSON.parse(payload))
      @stats.onGroup++



  #
  # spawning
  #



  spawn: (workers) =>
    @prepareChildProcess workers, (command, args) =>
      @spawnChildProcess(command, args)



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

      if _.has(worker, "cpu")
        args = [ "-c", worker.cpu, command ]
        command = "taskset"

      # check worker file
      return @missingWorkerFileError() if not worker.file?
      args.push(Path.resolve(filename, "../", worker.file))

      cb(command, args)



  spawnChildProcess: (command, args) =>
    worker = @childProcess.spawn(command, args)
    @stats.spawnChildProcess++
    # console.log "spawned worker: command: #{command} #{args.join(" ")}"

    worker.stdout.on "data", (data) =>
      console.log(data.toString())

    worker.stderr.on "data", (data) =>
      console.log(data.toString())

    # respawn worker
    worker.on "exit", (code) =>
      return if code is 0

      @spawnChildProcess(command, args)
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
