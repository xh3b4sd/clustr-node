_        = require("underscore")
Master   = require("./master").Master
Worker    = require("./worker").Worker
Workers   = require("./workers").Workers
Optimist = require("optimist")

class exports.Clustr
  constructor: (@config) ->
    @master  = Master.create(@config)
    @worker  = Worker.create(@config)
    @workers = Workers.create(@config)

    @master.do () =>
      @master.setup()

    @worker.do () =>
      @worker.setup()

    @workers.do () =>
      @workers.setup()



  @create: (config) =>
    new Clustr(config)
