_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "master emitter", () =>
  [ master ] = []

  dataTypes =
    string: "message"
    number: 5
    object: { message: "object" }
    array:  [ "message", "array" ]

  beforeEach () =>
    master = Clustr.Master.create
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()



  describe "public emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ channel, message ] = []

        beforeEach () =>
          master.emitPublic(expectedMessage)
          [ [ channel, message ] ] = master.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("public")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              processId: "mocked-uuid"
              group:     "master"
            data:        expectedMessage



  describe "private emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ channel, message ] = []

        beforeEach () =>
          master.emitPrivate("processId", expectedMessage)
          [ [ channel, message ] ] = master.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("private:processId")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              processId: "mocked-uuid"
              group:     "master"
            data:        expectedMessage



  describe "group emitter", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ channel, message ] = []

        beforeEach () =>
          master.emitGroup("group", expectedMessage)
          [ [ channel, message ] ] = master.publisher.publish.argsForCall



        it "should publish correct channel", () =>
          expect(channel).toEqual("group:group")



        it "should publish correct message", () =>
          expect(message).toEqual JSON.stringify
            meta:
              processId: "mocked-uuid"
              group:     "master"
            data:        expectedMessage



  describe "kill emitter", () =>
    it "should publish on kill channel", () =>
      master.emitKill("processId")

      [ [ channel, message ] ] = master.publisher.publish.argsForCall
      expect(channel).toEqual("kill:processId")



    it "should publish default exit code 0", () =>
      master.emitKill("processId")

      [ [ channel, message ] ] = master.publisher.publish.argsForCall
      expect(message).toEqual('{"meta":{"processId":"mocked-uuid","group":"master"},"data":0}')



    it "should publish given exit code", () =>
      master.emitKill("processId", 1)

      [ [ channel, message ] ] = master.publisher.publish.argsForCall
      expect(message).toEqual('{"meta":{"processId":"mocked-uuid","group":"master"},"data":1}')
