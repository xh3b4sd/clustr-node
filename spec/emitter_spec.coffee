_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "emitter", () =>
  [ worker ] = []

  dataTypes =
    string: "message"
    number: 5
    object: { message: "object" }
    array:  [ "message", "array" ]

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.publisher()
      subscriber:   Mock.subscriber()
      childProcess: Mock.childProcess()



  describe "public emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ channel, message ] = []

        beforeEach () =>
          worker.emitPublic(expectedMessage)
          [ [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("public")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              processId: "mocked-uuid"
              group:     "worker"
            data:        expectedMessage



  describe "private emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ channel, message ] = []

        beforeEach () =>
          worker.emitPrivate("processId", expectedMessage)
          [ [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("private:processId")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              processId: "mocked-uuid"
              group:     "worker"
            data:        expectedMessage



  describe "group emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ channel, message ] = []

        beforeEach () =>
          worker.emitGroup("group", expectedMessage)
          [ [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("group:group")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              processId: "mocked-uuid"
              group:     "worker"
            data:        expectedMessage



  describe "kill emitter", () =>
    it "should publish on kill channel", () =>
      worker.emitKill("processId")

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(channel).toEqual("kill:processId")



    it "should publish default exit code 0", () =>
      worker.emitKill("processId")

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(message).toEqual('{"meta":{"processId":"mocked-uuid","group":"worker"},"data":0}')



    it "should publish given exit code", () =>
      worker.emitKill("processId", 1)

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(message).toEqual('{"meta":{"processId":"mocked-uuid","group":"worker"},"data":1}')



  describe "confirmation emitter", () =>
    [ channel, message ] = []

    beforeEach () =>
      worker.emitConfirmation("identifier")
      [ [ channel, message ] ] = worker.publisher.publish.argsForCall



    it "should publish correct channel", () =>
      expect(channel).toEqual("confirmation")



    it "should publish correct message", () =>
      expect(message).toEqual('{"meta":{"processId":"mocked-uuid","group":"worker"},"data":"identifier"}')
