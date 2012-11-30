Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "confirmation", () =>
  [ master, requiredMessages, identifier, cb, subCb ] = []

  beforeEach () =>
    master = Clustr.Master.create
      name: "master"
      publisher: Mock.pub()
      subscriber: Mock.sub()
      childProcess: Mock.chiPro()



  describe "channel", () =>
    beforeEach () =>
      requiredMessages = 1
      identifier = "identifier"
      cb = jasmine.createSpy()

      master.onConfirmation(requiredMessages, identifier, cb)
      [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



    it "should not execute callback on subscription", () =>
      expect(cb.callCount).toEqual(0)



    it "should not execute callback on wrong channel", () =>
      subCb("private", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
      subCb("public",  '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
      subCb("master",  '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(0)



    it "should execute callback on 'confirmation' channel", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(1)



  describe "identifier", () =>
    beforeEach () =>
      requiredMessages = 1
      identifier = "identifier"
      cb = jasmine.createSpy()

      master.onConfirmation(requiredMessages, identifier, cb)
      [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



    it "should not execute callback on subscription", () =>
      expect(cb.callCount).toEqual(0)



    it "should not execute callback on wrong identifier", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"web"}')
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"identifiers"}')
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"id"}')

      expect(cb.callCount).toEqual(0)



    it "should execute callback on correct identifier", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(1)



  describe "2 required confirmations", () =>
    beforeEach () =>
      requiredMessages = 2
      identifier = "identifier"
      cb = jasmine.createSpy()

      master.onConfirmation(requiredMessages, identifier, cb)
      [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



    it "should not execute callback on subscription", () =>
      expect(cb.callCount).toEqual(0)



    it "should not execute callback on the first confirmation", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(0)



    it "should execute callback if all required confirmations were received", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(1)



    describe "repetition", () =>
      beforeEach () =>
        master.onConfirmation(requiredMessages, identifier, cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should be able to receive confirmations 1 time", () =>
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

        expect(cb.callCount).toEqual(1)

      it "should be able to receive confirmations 2 time", () =>
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

        expect(cb.callCount).toEqual(2)

      it "should be able to receive confirmations 3 time", () =>
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

        expect(cb.callCount).toEqual(3)



  describe "3 required confirmations", () =>
    beforeEach () =>
      requiredMessages = 3
      identifier = "identifier"
      cb = jasmine.createSpy()

      master.onConfirmation(requiredMessages, identifier, cb)
      [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



    it "should not execute callback on subscription", () =>
      expect(cb.callCount).toEqual(0)



    it "should not execute callback on the first confirmation", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(0)



    it "should not execute callback on the second confirmation", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(0)



    it "should execute callback if all required confirmations were received", () =>
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
      subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

      expect(cb.callCount).toEqual(1)



    describe "repetition", () =>
      beforeEach () =>
        master.onConfirmation(requiredMessages, identifier, cb)
        [ [ channel, subCb ] ] = master.subscriber.on.argsForCall



      it "should be able to receive confirmations 1 time", () =>
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

        expect(cb.callCount).toEqual(1)

      it "should be able to receive confirmations 2 time", () =>
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

        expect(cb.callCount).toEqual(2)

      it "should be able to receive confirmations 3 time", () =>
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')
        subCb("confirmation", '{"meta":{"workerId":"mocked-uuid","group":"webWorker"},"data":"' + identifier + '"}')

        expect(cb.callCount).toEqual(3)
