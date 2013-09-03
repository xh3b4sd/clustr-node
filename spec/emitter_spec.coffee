_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "emitter", () =>
  [ worker, channel, message ] = []

  dataTypes =
    string: "message"
    number: 5
    object: { message: "object" }
    array:  [ "message", "array" ]

  beforeEach () =>
    GLOBAL.setTimeout = (cb) -> cb()

    worker = Clustr.Worker.create
      group:        "worker"
      publisher:    Mock.publisher()
      subscriber:   Mock.subscriber()

    worker.emitReady()



  describe "public emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        beforeEach () =>
          worker.emitPublic(expectedMessage)
          # first call is for cluster registration
          [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("public")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              pid:       process.pid
              group:     "worker"
            data:        expectedMessage



  describe "private emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        beforeEach () =>
          worker.emitPrivate("processId", expectedMessage)
          # first call is for cluster registration
          [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("private:processId")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              pid:       process.pid
              group:     "worker"
            data:        expectedMessage



  describe "group emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        beforeEach () =>
          worker.emitGroup("group", expectedMessage)
          # first call is for cluster registration
          [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("group:group")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              pid:       process.pid
              group:     "worker"
            data:        expectedMessage



  describe "kill emitter", () =>
    it "should publish on kill channel", () =>
      worker.emitKill("processId")

      # first call is for cluster registration
      [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(channel).toEqual("kill:processId")



    it "should publish default exit code 0", () =>
      worker.emitKill("processId")

      # first call is for cluster registration
      [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: 0 }))



    it "should publish given exit code", () =>
      worker.emitKill("processId", 1)

      # first call is for cluster registration
      [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: 1 }))



  describe "confirmation emitter", () =>
    beforeEach () =>
      worker.emitConfirmation("identifier")
      # first call is for cluster registration
      [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("confirmation")



    it "should publish correct message", () =>
      expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: "identifier" }))
