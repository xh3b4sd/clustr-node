_    = require("underscore")
Path = require("path")

class exports.Spawning
  @formatCommandLineOption: (val, arg) =>
    if val is true then "--#{arg}" else "--#{arg}=#{val}"



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

      [ command, filename ] = process.argv
      args = []

      # change worker command
      command = worker.command if worker.command?

      # set cpu affinity
      if "cpu" of worker
        args = [ "-c", worker.cpu, command ]
        command = "taskset"

      # set executed file
      args.push(Path.resolve(filename, "../", worker.file))

      # merge own options
      for arg, val of worker.args
        args.push(Spawning.formatCommandLineOption(val, arg))

      # bubble cluster options
      for arg, val of @optimist.argv when /^cluster-/.test(arg) and val isnt false
        args.push(Spawning.formatCommandLineOption(val, arg))

      cb.call(@, command, args, worker.respawn)



  spawnChildProcess: (command, args, respawn) =>
    worker = @childProcess.spawn(command, args)
    @log("#{@config.group} spawned worker - command: #{command} #{args.join(" ")}")

    @workerPids.push(worker.pid)
    @stats.spawnChildProcess++

    # bubble streams
    worker.stdout.on "data", (data) =>
      @log(data.toString().replace(/\n$/, ""))

    worker.stderr.on "data", (data) =>
      @log(data.toString().replace(/\n$/, ""))

    # respawn worker
    worker.on "exit", (code) =>
      @log("#{@config.group} killed worker - command: #{command} #{args.join(" ")} - code: #{code} ")

      return if code is 0        # worker ends as expected
      return if respawn is false # worker shouldn`t respawn

      @spawnChildProcess(command, args, respawn)
      @stats.respawnChildProcess++
      @log("#{@config.group} respawned worker - command: #{command} #{args.join(" ")}")
