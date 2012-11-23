_        = require("underscore")
Master   = require("./master").Master
Worker    = require("./worker").Worker
Workers   = require("./workers").Workers
Optimist = require("optimist")

class exports.Clustr
  constructor: (@options) ->
    @master = Master.create(@options)
    @worker  = Worker.create(Optimist.argv)
    @workers = Workers.create(Optimist.argv)

    @master.do () =>
      @master.setup()

    @worker.do () =>
      @worker.setup()

    @workers.do () =>
      @workers.setup()



  @create: (options) =>
    new Clustr(options)
