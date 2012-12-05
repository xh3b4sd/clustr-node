_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "channels", () =>
  [ worker, channels ] = []

  describe "master", () =>
    beforeEach () =>
      Mock.optimist()

      worker = Clustr.Master.create
        group:        "master"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      channels = _.flatten(worker.subscriber.subscribe.argsForCall)



    it "should subscribe to correct channels", () =>
      expect(channels).toEqual [
        "confirmation"
        "public"
        "private:#{process.pid}"
        "group:master"
        "kill:#{process.pid}"
        "clusterInfo:#{process.pid}"
        "registration:#{process.pid}"
        "deregistration:#{process.pid}"
      ]



  describe "worker", () =>
    beforeEach () =>
      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      channels = _.flatten(worker.subscriber.subscribe.argsForCall)



    it "should subscribe to correct channels", () =>
      expect(channels).toEqual [
        "confirmation"
        "public"
        "private:#{process.pid}"
        "group:worker"
        "kill:#{process.pid}"
        "clusterInfo:#{process.pid}"
      ]
