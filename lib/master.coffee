ChildProcess = require("child_process")
_        = require("underscore")
Redis    = require("redis")
Optimist = require("optimist")

class exports.Master
  constructor: (config) ->
    return if not @isMaster()

    @config       = config.master
    @workers      = config.workers
    @childProcess = @config.childProcess or ChildProcess
    @publisher    = @config.publisher or Redis.createClient()
    @subscriber   = @config.subscriber or Redis.createClient()



  @create: (config) =>
    new Master(config)



  setup: () =>
    @subscribe()
    @prepareConfig(@spawnWorker)



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  subscribe: () =>
    @subscriber.subscribe("public")
    @subscriber.subscribe("confirmation")
    @subscriber.subscribe(@config.name)



  onPublic: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "public"



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is @config.name



  onConfirmation: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, message) =>
      return if channel is not "confirm"
      return if message is not identifier
      return if ++received < requiredMessages

      received = 0
      cb(message)



  isMaster: () =>
    Optimist.argv.mode? is false or Optimist.argv.mode is not "worker"



  ###
  # some possible commands
  #   node                app.js --args=foo
  #   coffee              app.js --args=foo
  #   taskset -c 1 node   app.js --args=foo
  #   taskset -c 1 coffee app.js --args=foo
  ###
  prepareConfig: (cb) =>
    _.each @workers, (worker, id) =>
      [ command, filename ] = process.argv
      args = []

      if _.has(worker, "cpu")
        args = [ "-c", worker.cpu, command ]
        command = "taskset"

      args.push(filename)
      args.push("--mode=worker")
      args.push("--id=#{id}")

      _.each worker, (option, name) =>
        return if option is false
        return args.push("--#{name}") if option is true
        args.push("--#{name}=#{option}")

      cb(command, args)



  spawnWorker: (command, args) =>
    worker = @childProcess.spawn(command, args)

    worker.stdout.on "data", (data) =>
      console.log(data.toString())

    worker.stderr.on "data", (data) =>
      console.log(data.toString())

    # respawn worker
    worker.on "exit", (code) =>
      return if code is 0 or "--respawn" not in args

      console.log "respawn worker: code: #{code} command: #{command} #{args.join(" ")}"
      @spawnWorker(command, args)



  do: (cb) =>
    cb(@) if @isMaster()
