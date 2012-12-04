_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "channels", () =>
  [ worker, channels ] = []

  describe "master", () =>
    beforeEach () =>
      worker = Clustr.Master.create
        group:        "master"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()
        childProcess: Mock.childProcess()

      channels = _.flatten(worker.subscriber.subscribe.argsForCall)



    it "should subscribe to correct channels", () =>
      expect(channels).toEqual [
        "confirmation"
        "public"
        "private:#{process.pid}"
        "group:master"
        "kill:#{process.pid}"
        "registration:#{process.pid}"
        "deregistration:#{process.pid}"
      ]



  describe "worker", () =>
    beforeEach () =>
      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()
        childProcess: Mock.childProcess()

      channels = _.flatten(worker.subscriber.subscribe.argsForCall)



    it "should subscribe to correct channels", () =>
      expect(channels).toEqual [
        "confirmation"
        "public"
        "private:#{process.pid}"
        "group:worker"
        "kill:#{process.pid}"
      ]
