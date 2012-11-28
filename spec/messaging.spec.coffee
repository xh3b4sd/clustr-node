_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "messaging", () =>
  describe "master", () =>
    [ master ] = []

    beforeEach () =>
      master = Clustr.Master.create
        publisher: Mock.pub()
        subscriber: Mock.sub()
        childProcess: Mock.chiPro()



    describe "subscription", () =>
      [ channels ] = []

      beforeEach () =>
        channels = _.flatten(master.subscriber.subscribe.argsForCall)



      it "should subscribe to public channel", () =>
        expect(channels).toContain("public")



      it "should subscribe to confirmation channel", () =>
        expect(channels).toContain("confirmation")



      it "should subscribe to private channel", () =>
        expect(channels).toContain("master")



      it "should only subscribe to 3 channels", () =>
        expect(channels.length).toEqual(3)



    describe "publication", () =>
      [ channel, message ] = []

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
              dataType: "string"
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
              dataType: "number"
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
              dataType: "object"
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
              dataType: "object"
            data:       [ "message", "object" ]



    describe "receiving", () =>
      [ cb, channel, subCb ] = []

      describe "public channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          master.onPublic(cb)
          [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb "public"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb "public"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          expect(cb).toHaveBeenCalledWith
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"



        it "should not receive messages on other channels", () =>
          subCb("private", "message")
          subCb("all", "message")
          subCb("confirmation", "message")

          expect(cb.callCount).toEqual(0)



      describe "private channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          master.onPrivate(cb)
          [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb "master"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb "master"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          expect(cb).toHaveBeenCalledWith
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"



        it "should not receive messages on other channels", () =>
          subCb "confirmation"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          subCb "all"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          subCb "public"
            meta:
              group:    "master"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(0)



  describe "worker", () =>
    [ worker ] = []

    beforeEach () =>
      worker = Clustr.Worker.create
        group:        "worker"
        uuid:         Mock.uuid()
        publisher:    Mock.pub()
        subscriber:   Mock.sub()
        childProcess: Mock.chiPro()



    describe "subscription", () =>
      [ channels ] = []

      beforeEach () =>
        channels = _.flatten(worker.subscriber.subscribe.argsForCall)



      it "should subscribe to public channel", () =>
        expect(channels).toContain("public")



      it "should subscribe to group channel", () =>
        expect(channels).toContain("worker")



      it "should subscribe to private channel", () =>
        expect(channels).toContain("mocked-uuid")



      it "should only subscribe to 3 channels", () =>
        expect(channels.length).toEqual(3)



    describe "publication", () =>
      [ channel, message ] = []

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
              dataType: "string"
            data:       "message"



    describe "receiving", () =>
      [ cb, channel, subCb ] = []

      describe "public channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          worker.onPublic(cb)
          [ [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb "public"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb "public"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb).toHaveBeenCalledWith
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"



        it "should not receive messages on other channels", () =>
          subCb "private"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          subCb "all"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          subCb "confirmation"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(0)



      describe "private channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          worker.onPrivate(cb)
          [ [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb "mocked-uuid"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb "mocked-uuid"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb).toHaveBeenCalledWith
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"



        it "should not receive messages on other channels", () =>
          subCb "public"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          subCb "confirmation"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          subCb "all"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(0)



      describe "group channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          worker.onGroup(cb)
          [ [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb "worker"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb "worker"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb).toHaveBeenCalledWith
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"



        it "should not receive messages on other channels", () =>
          subCb "public"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          subCb "confirmation"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          subCb "all"
            meta:
              workerId: "mocked-uuid"
              group:    "worker"
              dataType: "string"
            data:       "message"

          expect(cb.callCount).toEqual(0)
