ChildProcess = require("child_process")
_        = require("underscore")
Optimist = require("optimist")
Master   = require("./master").Master
Slave    = require("./slave").Slave

class exports.Clustr
  ###
  # Options contains the cluster configuration.
  ###
  constructor: (@options) ->
    @master = Master.create(Optimist.argv)
    @slave  = Slave.create(Optimist.argv)

    @prepare (command, args) =>
      @spawn(command, args)



  @create: (options) ->
    new Clustr(options)



  ###
  # Possible commands
  #   node                app.js --args=foo
  #   coffee              app.js --args=foo
  #   taskset -c 1 node   app.js --args=foo
  #   taskset -c 1 coffee app.js --args=foo
  ###
  prepare: (cb) ->
    _.each @options.slaves, (slave) =>
      [ command, filename ] = process.argv
      args = []

      if _.has(slave, "cpu")
        args = [ "-c", slave.cpu, command ]
        command = "taskset"

      args.push(filename)
      args.push("--mode=slave")

      _.each slave, (option, name) =>
        args.push("--#{name}=#{option}")

      cb(command, args)



  spawn: (command, args) ->
    slave = ChildProcess.spawn(command, args)

    slave.stdout.on "data", (data) =>
      console.log(data.toString())

    slave.stderr.on "data", (data) =>
      console.log(data.toString())

    # respawn slave
    slave.on "exit", (code) =>
      console.log("respawn slave", args)
      @spawn(command, args)
