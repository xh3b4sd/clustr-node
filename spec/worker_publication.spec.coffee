_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "worker publication", () =>
  [ worker, channel, message ] = []

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()



  describe "string", () =>
    beforeEach () =>
      worker.publish("channel", "message")
      [ [ channel, message ] ] = worker.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       "message"



  describe "number", () =>
    beforeEach () =>
      worker.publish("channel", 5)
      [ [ channel, message ] ] = worker.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       5



  describe "object", () =>
    beforeEach () =>
      worker.publish "channel"
        message: "object"

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:
            message: "object"



  describe "array", () =>
    beforeEach () =>
      worker.publish("channel", [ "message", "array" ])
      [ [ channel, message ] ] = worker.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       [ "message", "array" ]
