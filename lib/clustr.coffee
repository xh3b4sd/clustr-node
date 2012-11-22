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

    @prepare(@spawn)



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
    [ command, filename ] = process.argv

    _.each @options.cluster.slaves, (slaveOptions) =>
      args = []
      if _.has(slaveOptions, "cpu")
        args = [ "taskset", "-c", slaveOptions.cpu ]

      args.push(command)
      args.push(filename)
      args.push("--mode=slave")

      _.each slaveOptions, (option, name) =>
        args.push("--#{name}=#{option}")

    command = args.shift()

    cb(command, args)



  spawn: (command, args) ->
    slave = spawn(command, args)

    slave.stdout.on("data",  (data) {
      console.log(data)

    slave.stderr.on("data",  (data) {
      console.log(data)

    # respawn slave
    slave.on("exit", (code) =>
      console.log("slave", id, "respawn")
      @spawn(command, args)
