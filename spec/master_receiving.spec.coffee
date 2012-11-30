_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "master receiving", () =>
  [ master, cb, channel, subCb ] = []

  beforeEach () =>
    master = Clustr.Master.create
      publisher: Mock.pub()
      subscriber: Mock.sub()
      childProcess: Mock.chiPro()



  describe "string", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPublic(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:       "message"

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:       "message"

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:       "message"



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:       "message"

        subCb "all"
          meta:
            group:    "master"
          data:       "message"

        subCb "private"
          meta:
            group:    "master"
          data:       "message"

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPrivate(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:       "message"

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:       "message"

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:       "message"



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:       "message"

        subCb "all"
          meta:
            group:    "master"
          data:       "message"

        subCb "public"
          meta:
            group:    "master"
          data:       "message"

        expect(cb.callCount).toEqual(0)



  describe "number", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPublic(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:       5

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:       5

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:       5



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:       5

        subCb "all"
          meta:
            group:    "master"
          data:       5

        subCb "private"
          meta:
            group:    "master"
          data:       5

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPrivate(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:       5

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:       5

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:       5



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:       5

        subCb "all"
          meta:
            group:    "master"
          data:       5

        subCb "public"
          meta:
            group:    "master"
          data:       5

        expect(cb.callCount).toEqual(0)



  describe "object", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPublic(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:
            message: "object"

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:
            message: "object"

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:
            message: "object"



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:
            message: "object"

        subCb "all"
          meta:
            group:    "master"
          data:
            message: "object"

        subCb "private"
          meta:
            group:    "master"
          data:
            message: "object"

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPrivate(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:
            message: "object"

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:
            message: "object"

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:
            message: "object"



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:
            message: "object"

        subCb "all"
          meta:
            group:    "master"
          data:
            message: "object"

        subCb "public"
          meta:
            group:    "master"
          data:
            message: "object"

        expect(cb.callCount).toEqual(0)



  describe "array", () =>
    describe "public channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPublic(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "public", JSON.stringify
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:       [ "message", "array" ]



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        subCb "all"
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        subCb "private"
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        expect(cb.callCount).toEqual(0)



    describe "private channel", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        master.onPrivate(cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should receive 1 messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        expect(cb.callCount).toEqual(1)



      it "should receive correct messages", () =>
        subCb "master", JSON.stringify
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        expect(cb).toHaveBeenCalledWith
          meta:
            group:    "master"
          data:       [ "message", "array" ]



      it "should not receive messages on other channels", () =>
        subCb "confirmation"
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        subCb "all"
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        subCb "public"
          meta:
            group:    "master"
          data:       [ "message", "array" ]

        expect(cb.callCount).toEqual(0)
