_       = require("underscore")
Mixin = require("./mixin").Mixin
Process = require("./process").Process
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
    @clusterInfo  = {}
    @workerPidsToReload   = []

    @setup()
    @setupReload()
    @setupTermination()
    @setupOnClusterInfo()
    @setupOnRegistration()
    @setupOnDeregistration()
    @setupMasterSubscriptions()
