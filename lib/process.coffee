_            = require("underscore")
Path         = require("path")
Redis        = require("redis")
ChildProcess = require("child_process")

class exports.Process
  setup: () =>
    @childProcess = @config.childProcess or ChildProcess
    @publisher    = @config.publisher    or Redis.createClient()
    @subscriber   = @config.subscriber   or Redis.createClient()

    @subscribe()



  publish: (channel, message) =>
    payload = @prepareOutgogingPayload(message)
    @publisher.publish(channel, JSON.stringify(payload))



  subscribe: () =>
    @subscriber.subscribe(channel) for channel in @channels



  onPublic: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      return if channel isnt "public"
      cb(JSON.parse(payload))



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
    # console.log "spawned worker: command: #{command} #{args.join(" ")}"

    worker.stdout.on "data", (data) =>
      console.log(data.toString())

    worker.stderr.on "data", (data) =>
      console.log(data.toString())

    # respawn worker
    worker.on "exit", (code) =>
      return if code is 0

      # console.log "respawn worker: code: #{code} command: #{command} #{args.join(" ")}"
      @spawnChildProcess(command, args)



  prepareOutgogingPayload: (message) =>
    meta:
      workerId: @workerId
      group:    @config.group
    data:       message



  missingWorkerFileError: () =>
    throw new Error("worker file is missing")
