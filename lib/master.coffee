_       = require("underscore")
Mixin = require("./mixin").Mixin
Process = require("./process").Process
MasterSetup = require("./master_setup").MasterSetup

class exports.Master extends Mixin(Process, MasterSetup)
  @create: (config) =>
    new Master(config)



  constructor: (@config = {}) ->
    @config.group = "master"

    ###
    # @clusterInfo =
    #   webWorker:   [ 5182, 5184 ]
    #   cacheWorker: [ 5186, 5188 ]
    ###
    @clusterInfo  = {}

    @setup()
    @setupTermination()
    @setupOnClusterInfo()
    @setupOnRegistration()
    @setupOnDeregistration()
    @setupMasterSubscriptions()
