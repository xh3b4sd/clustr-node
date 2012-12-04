_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "listener", () =>
  [ worker, requiredMessages, identifier, cb, subCb ] = []

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
          subCb("private:#{process.pid}", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb.callCount).toEqual(1)



        it "should receive correct messages", () =>
          subCb("private:#{process.pid}", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          expect(cb).toHaveBeenCalledWith(               { meta: { processId: "processId", group: "worker" }, data: expectedMessage })



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
          expect(cb).toHaveBeenCalledWith(     { meta: { processId: "processId", group: "worker" }, data: expectedMessage })



        it "should not receive messages on other channels", () =>
          subCb("all",          JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("public",       JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: expectedMessage }))

          expect(cb.callCount).toEqual(0)



  describe "confirmation listener", () =>
    describe "channel", () =>
      beforeEach () =>
        requiredMessages = 1
        identifier = "identifier"
        cb = jasmine.createSpy()

        worker.onConfirmation(requiredMessages, identifier, cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should not execute callback on wrong channel", () =>
        subCb("private", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        subCb("public",  JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        subCb("worker",  JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

        expect(cb.callCount).toEqual(0)



      it "should execute callback on 'confirmation' channel", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        expect(cb.callCount).toEqual(1)



    describe "identifier", () =>
      beforeEach () =>
        requiredMessages = 1
        identifier = "identifier"
        cb = jasmine.createSpy()

        worker.onConfirmation(requiredMessages, identifier, cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should not execute callback on wrong identifier", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: "web" }))
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: 5 }))
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: [ "foo" ] }))

        expect(cb.callCount).toEqual(0)



      it "should execute callback on correct identifier", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        expect(cb.callCount).toEqual(1)



    describe "2 required confirmations", () =>
      beforeEach () =>
        requiredMessages = 2
        identifier = "identifier"
        cb = jasmine.createSpy()

        worker.onConfirmation(requiredMessages, identifier, cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should not execute callback on the first confirmation", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        expect(cb.callCount).toEqual(0)



      it "should execute callback if all required confirmations were received", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

        expect(cb.callCount).toEqual(1)



      describe "repetition", () =>
        beforeEach () =>
          worker.onConfirmation(requiredMessages, identifier, cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should be able to receive confirmations 1 time", () =>
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

          expect(cb.callCount).toEqual(1)

        it "should be able to receive confirmations 2 time", () =>
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

          expect(cb.callCount).toEqual(2)

        it "should be able to receive confirmations 3 time", () =>
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

          expect(cb.callCount).toEqual(3)



    describe "3 required confirmations", () =>
      beforeEach () =>
        requiredMessages = 3
        identifier = "identifier"
        cb = jasmine.createSpy()

        worker.onConfirmation(requiredMessages, identifier, cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not execute callback on subscription", () =>
        expect(cb.callCount).toEqual(0)



      it "should not execute callback on the first confirmation", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        expect(cb.callCount).toEqual(0)



      it "should not execute callback on the second confirmation", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

        expect(cb.callCount).toEqual(0)



      it "should execute callback if all required confirmations were received", () =>
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
        subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

        expect(cb.callCount).toEqual(1)



      describe "repetition", () =>
        beforeEach () =>
          worker.onConfirmation(requiredMessages, identifier, cb)
          # the first subscription is caused by the kill listener
          [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



        it "should be able to receive confirmations 1 time", () =>
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

          expect(cb.callCount).toEqual(1)

        it "should be able to receive confirmations 2 time", () =>
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

          expect(cb.callCount).toEqual(2)

        it "should be able to receive confirmations 3 time", () =>
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))
          subCb("confirmation", JSON.stringify({ meta: { processId: "processId", group: "worker" }, data: identifier }))

          expect(cb.callCount).toEqual(3)



  describe "kill listener", () =>
    [ channel, subCb ] = []

    beforeEach () =>
      spyOn(process, "exit")

      # the first subscription is caused by the kill listener
      [ [ channel, subCb ] ] = worker.subscriber.on.argsForCall



    it "should kill worker on kill channel", () =>
      subCb("kill:#{process.pid}", JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 0 }))
      expect(process.exit.callCount).toEqual(1)



    it "should not kill worker on other channels", () =>
      subCb("mocked-uuid", JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 0 }))
      subCb("kill-uuid",   JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 1 }))
      subCb("public",      JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 2 }))
      subCb("private",     JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 3 }))
      subCb("worker",      JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 4 }))

      expect(process.exit.callCount).toEqual(0)



    it "should not kill worker if onKillCb is not fired", () =>
      worker.onKill (cb) => # cb not called
      subCb("kill:#{process.pid}", JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 0 }))
      expect(process.exit.callCount).toEqual(0)



    it "should kill worker if onKillCb is fired", () =>
      worker.onKill (cb) => cb()
      subCb("kill:#{process.pid}", JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 0 }))
      expect(process.exit.callCount).toEqual(1)



    it "should kill worker with exit code 0", () =>
      subCb("kill:#{process.pid}", JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 0 }))
      expect(process.exit).toHaveBeenCalledWith(0)



    it "should kill worker with exit code 1", () =>
      subCb("kill:#{process.pid}", JSON.stringify({ meta: { processId: "mocked-uuid", group: "worker" }, data: 1 }))
      expect(process.exit).toHaveBeenCalledWith(1)
