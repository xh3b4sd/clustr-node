ChildProcess = require("child_process")
_        = require("underscore")
Master   = require("./master").Master
Slave    = require("./slave").Slave
Optimist = require("optimist")

class exports.Clustr
  constructor: (@options) ->
    @master = Master.create(@options.master)
    @slave  = Slave.create(Optimist.argv)

    @master.do () =>
      @prepareOptions(@spawnSlave)

    @slave.do () =>
      @setupSlave()



  @create: (options) =>
    new Clustr(options)



  ###
  # some possible commands
  #   node                app.js --args=foo
  #   coffee              app.js --args=foo
  #   taskset -c 1 node   app.js --args=foo
  #   taskset -c 1 coffee app.js --args=foo
  ###
  prepareOptions: (cb) =>
    _.each @options.slaves, (slave) =>
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



  setupSlave: () =>
    if Optimist.argv.deamon is true
      anonym = () ->
      setInterval(anonym, 60000)
