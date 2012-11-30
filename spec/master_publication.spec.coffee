_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "master publication", () =>
  [ master, channel, message ] = []

  beforeEach () =>
    master = Clustr.Master.create
      publisher: Mock.pub()
      subscriber: Mock.sub()
      childProcess: Mock.chiPro()



  describe "strings", () =>
    beforeEach () =>
      master.publish("channel", "message")
      [ [ channel, message ] ] = master.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
        meta:
          group:    "master"
        data:       "message"



  describe "number", () =>
    beforeEach () =>
      master.publish("channel", 5)

      [ [ channel, message ] ] = master.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
        meta:
          group:    "master"
        data:       5



  describe "object", () =>
    beforeEach () =>
      master.publish "channel"
        message: "object"

      [ [ channel, message ] ] = master.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
        meta:
          group:    "master"
        data:
          message:  "object"



  describe "array", () =>
    beforeEach () =>
      master.publish("channel", [ "message", "object" ])

      [ [ channel, message ] ] = master.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("channel")



    it "should publish correct message", () =>
      expect(message).toEqual JSON.stringify
        meta:
          group:    "master"
        data:       [ "message", "object" ]
