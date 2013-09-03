_           = require("underscore")
Util        = require("util")
Mixin       = require("./mixin").Mixin
Process     = require("./process").Process
MasterSetup = require("./master_setup").MasterSetup

class exports.Master extends Mixin(Process, MasterSetup)
  @create: (config) =>
    new Master(config)



  constructor: (@config = {}) ->
    @config.group       = "master"
    @config.reloadDelay = @config.reloadDelay || 500

    ###
    # @clusterInfo =
    #   webWorker:   [ 5182, 5184 ]
    #   cacheWorker: [ 5186, 5188 ]
    ###
    @clusterInfo   = {}
    @workerConfigs = []

    @setup()
    @setupReload()
    @setupOnStarted()
    @setupOnReloaded()
    @setupTermination()
    @setupOnClusterInfo()
    @setupOnRegistration()
    @setupOnDeregistration()
    @setupMasterSubscriptions()

    @log "info - masterModule - onConstruction - #{Util.inspect { clusterState: "initializing" }, @logOptions}"
