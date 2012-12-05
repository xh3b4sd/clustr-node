_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

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

