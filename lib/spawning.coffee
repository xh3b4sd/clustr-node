_            = require("underscore")
Path         = require("path")
Optimist     = require("optimist")
ChildProcess = require("child_process")

class exports.Spawning
  @formatOption: (arg, val) =>
    if val is true then "--#{arg}" else "--#{arg}=#{val}"



  @setWorkerCommand: (worker) =>
    return worker.command if worker.command?
    workerCommand = process.argv[0]
    if workerCommand == "coffee" then return "node" else return workerCommand



  @setCpuAffinity: (worker, args) =>
    return [] if not worker.cpu?
    [ "taskset", "-c", worker.cpu, args.shift() ]



  @setExecutionFile: (worker) =>
    executionFile    = Path.resolve(process.argv[1], "../", worker.file)
    coffeeExecutable = Path.resolve(process.argv[1], "../", "./node_modules/coffee-script/bin/coffee")
    isCoffeeFile     = /\.coffee$/.test executionFile

    if !isCoffeeFile then return executionFile else [ coffeeExecutable, executionFile ]



  @setWorkerOptions: (worker) =>
    (@formatOption(arg, val) for arg, val of worker.args)



  @setClusterMasterPid: (pid, group) =>
    return [] if group isnt "master"
    "--cluster-master-pid=#{pid}"



  @setClusterOptions: (argv) =>
    (@formatOption(arg, val) for arg, val of argv when /^cluster-/.test(arg) and val isnt false)



  @missingWorkerFileError: () =>
    throw new Error("worker file is missing")



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
      return Spawning.missingWorkerFileError() if not worker.file?

      args = []
      args.push(Spawning.setWorkerCommand(worker))
      args.push(Spawning.setCpuAffinity(worker, args))
      args.push(Spawning.setExecutionFile(worker))
      args.push(Spawning.setWorkerOptions(worker))
      args.push(Spawning.setClusterMasterPid(@pid, @config.group))
      args.push(Spawning.setClusterOptions(Optimist.argv))
      args = _.flatten(args)

      cb.call(@, args.shift(), args, worker.respawn)



  spawnChildProcess: (command, args, respawn = true) =>
    worker = ChildProcess.spawn command, args
    @log "#{@config.group} spawned worker - command: #{command} #{args.join(" ")}"

    @stats.spawnChildProcess++

    # bubble streams
    worker.stdout.on "data", (data) =>
      @log data.toString().replace(/\n$/, "")

    worker.stderr.on "data", (data) =>
      @log data.toString().replace(/\n$/, "")

    # respawn worker
    worker.on "exit", (code) =>
      @log "#{@config.group} killed worker code #{code} - command: #{command} #{args.join(" ")}"

      return if code is 0        # worker ends as expected
      return if respawn is false # worker shouldn't respawn

      @stats.respawnChildProcess++
      @log "#{@config.group} attempts to respawn worker - command: #{command} #{args.join(" ")}"
      @spawnChildProcess command, args, respawn
