_       = require("underscore")
Jasmine = require("jasmine-node")
Clustr  = require("../index")
Mock    = require("./lib/mock")

describe "confirmation", () =>
  [ clustr ] = []



  beforeEach () =>
    config =
      master:
        { name: "master", publisher: Mock.pub(), subscriber: Mock.sub(), childProcess: Mock.chiPro() }
      workers: [
        { name: "web",    publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "web",    publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache",  publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache",  publisher: Mock.pub(), subscriber: Mock.sub() }
      ]

    clustr = Clustr.create(config)



  describe "master", () =>
    describe "subscription", () =>
      [ channels ] = []

      beforeEach () =>
        channels = _.flatten(clustr.master.subscriber.subscribe.argsForCall)



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

      beforeEach () =>
        clustr.master.publish("channel", "message")
        [ [ channel, message ] ] = clustr.master.publisher.publish.argsForCall



      it "should publish correct channel", () =>
        expect(channel).toEqual("channel")



      it "should publish correct message", () =>
        expect(message).toEqual("message")



    describe "receiving", () =>
      [ cb, channel, subCb ] = []

      describe "public channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          clustr.master.onPublic(cb)
          [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("public", "message")
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("public", "message")
          expect(cb).toHaveBeenCalledWith("message")



        it "should not receive messages on other channels", () =>
          subCb("private", "message")
          subCb("all", "message")
          subCb("confirmation", "message")

          expect(cb.callCount).toEqual(0)



      describe "private channel", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          clustr.master.onPrivate(cb)
          [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("master", "message")
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("master", "message")
          expect(cb).toHaveBeenCalledWith("message")



        it "should not receive messages on other channels", () =>
          subCb("public", "message")
          subCb("all", "message")
          subCb("confirmation", "message")

          expect(cb.callCount).toEqual(0)
