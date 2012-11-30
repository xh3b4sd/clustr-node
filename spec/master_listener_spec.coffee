_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "master listener", () =>
  [ master, requiredMessages, identifier, cb, subCb ] = []

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



  describe "public listener", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ cb, subCb ] = []

        beforeEach () =>
          cb = jasmine.createSpy()

          master.onPublic(cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("public", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("public",  JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith({ meta: { processId: "processId", group: "master" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          subCb("private",      JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)



  describe "private listener", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ cb, subCb ] = []

        beforeEach () =>
          cb = jasmine.createSpy()

          master.onPrivate(cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("private:mocked-uuid", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("private:mocked-uuid", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith(            { meta: { processId: "processId", group: "master" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          subCb("public",       JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)



  describe "group listener", () =>
    _.each dataTypes, (expectedMessage, dataTypeTestCase) =>
      describe dataTypeTestCase, () =>
        [ cb, subCb ] = []

        beforeEach () =>
          cb = jasmine.createSpy()

          master.onGroup(cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



        it "should not execute callback on subscription", () =>
          expect(cb.callCount).toEqual(0)



        it "should receive 1 messages", () =>
          subCb("group:master", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("group:master", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith(            { meta: { processId: "processId", group: "master" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          subCb("public",       JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "master" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)



  describe "confirmation listener", () =>
    describe "channel", () =>
      beforeEach () =>
        requiredMessages = 1
        identifier = "identifier"
        cb = jasmine.createSpy()

        master.onConfirmation(requiredMessages, identifier, cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



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
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



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
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



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
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



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
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



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
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = master.subscriber.on.argsForCall



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
