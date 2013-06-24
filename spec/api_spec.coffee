_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")
Optimist = require("optimist")

describe "api", () =>
  [ worker, properties ] = []

  describe "master", () =>
    beforeEach () =>
      worker = Clustr.Master.create
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      properties = _.keys(worker)



    it "should provide correct properties", () =>
      expect(properties).toEqual [
        "config"
        "clusterInfo"
        "stats"
        "pid"
        "logger"
        "publisher"
        "subscriber"
      ]



  describe "worker", () =>
    beforeEach () =>
      Optimist.argv.port = 3000

      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      properties = _.keys(worker)



    it "should provide correct properties", () =>
      expect(properties).toEqual [
        "config"
        "stats"
        "pid"
        "logger"
        "publisher"
        "subscriber"
        "masterPid"
      ]



    it "should provide propagated command line arguments", ->
      expect(worker.config.port).toEqual 3000
      expect(worker.config["_"]).toBeUndefined()
      expect(worker.config["$0"]).toBeUndefined()
