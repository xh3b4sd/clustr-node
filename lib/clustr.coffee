_        = require("underscore")
Master   = require("./master").Master
Slave    = require("./slave").Slave
Slaves   = require("./slaves").Slaves
Optimist = require("optimist")

class exports.Clustr
  constructor: (@options) ->
    @master = Master.create(@options)
    @slave  = Slave.create(Optimist.argv)
    @slaves = Slaves.create(Optimist.argv)

    @master.do () =>
      @master.setup()

    @slave.do () =>
      @slave.setup()

    @slaves.do () =>
      @slaves.setup()



  @create: (options) =>
    new Clustr(options)
