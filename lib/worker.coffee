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

    @setup()
    @masterPid = Optimist.argv["cluster-master-pid"]
    @setupEmitRegistration()
