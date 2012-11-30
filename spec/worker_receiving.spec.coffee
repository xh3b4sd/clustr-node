_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "worker receiving", () =>
  [ worker, cb, channel, subCb ] = []

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()



  describe "string", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPublic(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       "message"



      it "should not receive messages on other channels", () =>
        subCb("private",      '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPrivate(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       "message"



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')

        expect(cb.callCount).toEqual(0)



    describe "group channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onGroup(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       "message"



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":"message"}')

        expect(cb.callCount).toEqual(0)



  describe "number", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPublic(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       5



      it "should not receive messages on other channels", () =>
        subCb("private",      '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPrivate(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       5



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')

        expect(cb.callCount).toEqual(0)



    describe "group channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onGroup(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       5



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":5}')

        expect(cb.callCount).toEqual(0)



  describe "object", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPublic(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:
            message:  "object"



      it "should not receive messages on other channels", () =>
        subCb("private",      '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPrivate(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:
            message:  "object"



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')

        expect(cb.callCount).toEqual(0)



    describe "group channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onGroup(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:
            message:  "object"



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":{"message":"object"}}')

        expect(cb.callCount).toEqual(0)



  describe "array", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPublic(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("public", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       [ "message", "array" ]



      it "should not receive messages on other channels", () =>
        subCb("private",      '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPrivate(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       [ "message", "array" ]



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')

        expect(cb.callCount).toEqual(0)



    describe "group channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onGroup(cb)
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb("worker", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        expect(cb).toHaveBeenCalledWith
          meta:
            workerId: "mocked-uuid"
            group:    "worker"
          data:       [ "message", "array" ]



      it "should not receive messages on other channels", () =>
        subCb("public",       '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')
        subCb("all",          '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":["message","array"]}')

        expect(cb.callCount).toEqual(0)
