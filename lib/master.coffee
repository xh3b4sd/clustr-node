ChildProcess = require("child_process")
_        = require("underscore")
Redis    = require("redis")
Optimist = require("optimist")

class exports.Master
  constructor: (options) ->
    @publisher  = Redis.createClient()
    @subscriber = Redis.createClient()
    @slaves     = options.slaves
    @options    = options.master



  @create: (options) =>
    new Master(options)



  setup: () =>
    @subscribe()
    @prepareOptions(@spawnSlave)



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  subscribe: () =>
    @subscriber.subscribe("public")
    @subscriber.subscribe("confirm")
    @subscriber.subscribe(@options.name)



  onPublic: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "public"



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is @options.name



  onConfirm: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, message) =>
      return if channel is not "confirm"
      return if message is not identifier
      return if ++received < requiredMessages

      received = 0
      cb(message)



  isMaster: () =>
    Optimist.argv.mode? is false or Optimist.argv.mode is not "slave"



  ###
  # some possible commands
  #   node                app.js --args=foo
  #   coffee              app.js --args=foo
  #   taskset -c 1 node   app.js --args=foo
  #   taskset -c 1 coffee app.js --args=foo
  ###
  prepareOptions: (cb) =>
    _.each @slaves, (slave) =>
      [ command, filename ] = process.argv
      args = []

      if _.has(slave, "cpu")
        args = [ "-c", slave.cpu, command ]
        command = "taskset"

      args.push(filename)
      args.push("--mode=slave")

      _.each slave, (option, name) =>
        if option is true
          args.push("--#{name}")
        else
          args.push("--#{name}=#{option}")

      cb(command, args)



  spawnSlave: (command, args) =>
    slave = ChildProcess.spawn(command, args)

    slave.stdout.on "data", (data) =>
      console.log(data.toString())

    slave.stderr.on "data", (data) =>
      console.log(data.toString())

    # respawn slave
    slave.on "exit", (code) =>
      console.log "respawn slave: code: #{code} command: #{command} #{args.join(" ")}"

      #@spawnSlave(command, args)



  do: (cb) =>
    cb(@) if @isMaster()
