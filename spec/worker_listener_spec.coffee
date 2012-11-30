_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "worker receiving", () =>
  [ worker, cb, channel, subCb ] = []

  dataTypes =
    string: "message"
    number: 5
    object: { message: "object" }
    array:  [ "message", "array" ]

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()



  describe "public listener", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ cb, subCb ] = []

        beforeEach () =>
          cb = jasmine.createSpy()

          worker.onPublic(cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("public", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("public",  JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith({ meta: { processId: "processId", group: "worker" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("private",      JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)



  describe "private listener", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ cb, subCb ] = []

        beforeEach () =>
          cb = jasmine.createSpy()

          worker.onPrivate(cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("private:mocked-uuid", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("private:mocked-uuid", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith(            { meta: { processId: "processId", group: "worker" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("public",       JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)



  describe "group listener", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ cb, subCb ] = []

        beforeEach () =>
          cb = jasmine.createSpy()

          worker.onGroup(cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("group:worker", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("group:worker", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith(            { meta: { processId: "processId", group: "worker" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("public",       JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)




  describe "kill listener", () =>
    [ channel, subCb ] = []

    beforeEach () =>
      spyOn(process, "exit")

      # the first subscription is caused by the kill listener
      [ [ channel, subCb ] ] = worker.subscriber.on.argsForCall



    it "should kill process on kill channel", () =>
      subCb("kill:mocked-uuid", '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":0}')
      expect(process.exit.callCount).toEqual(1)



    it "should not kill process on other channels", () =>
      subCb("mocked-uuid", '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":0}')
      subCb("kill-uuid",   '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":1}')
      subCb("public",      '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":2}')
      subCb("private",     '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":3}')
      subCb("master",      '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":4}')

      expect(process.exit.callCount).toEqual(0)



    it "should kill process with exit code 0", () =>
      subCb("kill:mocked-uuid", '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":0}')
      expect(process.exit).toHaveBeenCalledWith(0)



    it "should kill process with exit code 1", () =>
      subCb("kill:mocked-uuid", '{"meta":{"processId":"mocked-uuid","group":"worker"},"data":1}')
      expect(process.exit).toHaveBeenCalledWith(1)
