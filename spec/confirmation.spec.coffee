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



  describe "2 required confirmations", () =>
    [ requiredMessages, identifier, cb ] = []

    beforeEach () =>
      requiredMessages = 2
      identifier = "identifier"
      cb = jasmine.createSpy()

    it "should not execute callback on subscription", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      expect(cb.callCount).toEqual(0)



    it "should not execute callback on the first confirmation", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(0)



    it "should execute callback if all required confirmations were received", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(1)



    it "should be able to receive confirmations again and again", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(1)

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(2)

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(3)



  describe "3 required confirmations", () =>
    [ requiredMessages, identifier, cb ] = []

    beforeEach () =>
      requiredMessages = 3
      identifier = "identifier"
      cb = jasmine.createSpy()

    it "should not execute callback on subscription", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      expect(cb.callCount).toEqual(0)



    it "should not execute callback on the first confirmation", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(0)



    it "should not execute callback on the second confirmation", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(0)



    it "should execute callback if all required confirmations were received", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(1)



    it "should be able to receive confirmations again and again", () =>
      clustr.master.onConfirm requiredMessages, identifier, cb
      [ [ channel, subCb ] ] = clustr.master.subscriber.on.argsForCall

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(1)

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(2)

      subCb("confirm", identifier)
      subCb("confirm", identifier)
      subCb("confirm", identifier)
      expect(cb.callCount).toEqual(3)
