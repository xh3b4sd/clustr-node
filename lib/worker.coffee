_             = require("underscore")
Optimist      = require("optimist")
Mixin         = require("./mixin").Mixin
Process       = require("./process").Process
WorkerSetup   = require("./worker_setup").WorkerSetup
WorkerEmitter = require("./worker_emitter").WorkerEmitter

class exports.Worker extends Mixin(Process, WorkerSetup, WorkerEmitter)
  @create: (config) =>
    new Worker(config)



  constructor: (@config = {}) ->
    return Worker.missingGroupNameError() if not @config.group?

    @config.reloadDelay = @config.reloadDelay || 500

    @setup()
    @setupConfig()



  ready: () ->
    @setupEmitRegistration()



  setupConfig: () ->
    @masterPid = Optimist.argv?["cluster-master-pid"]

    _.each Optimist.argv, (val, key) =>
      return if /^cluster-/.test(key) || key == "_" || key == "$0"
      @config[key] = val
