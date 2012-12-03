_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "stats", () =>
  [ worker, channels ] = []

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.publisher()
      subscriber:   Mock.subscriber()
      childProcess: Mock.childProcess()



  it "should provide initialized stats object", () =>
    expect(worker.stats).toEqual
      emitPublic:              0
      emitPrivate:             0
      emitGroup:               0
      emitKill:                0
      emitConfirmation:        0
      onMessage:               0
      onPublic:                0
      onGroup:                 0
      onPrivate:               0
      spawnChildProcess:       0
      respawnChildProcess:     0
      receivedConfirmations:   0
      successfulConfirmations: 0



  describe "emitter", () =>
    it "should count public message events", () =>
      worker.emitPublic("message")
      expect(worker.stats).toEqual
        emitPublic:              1
        emitPrivate:             0
        emitGroup:               0
        emitKill:                0
        emitConfirmation:        0
        onMessage:               0
        onPublic:                0
        onGroup:                 0
        onPrivate:               0
        spawnChildProcess:       0
        respawnChildProcess:     0
        receivedConfirmations:   0
        successfulConfirmations: 0



    it "should count private message events", () =>
      worker.emitPrivate("message")
      expect(worker.stats).toEqual
        emitPublic:              0
        emitPrivate:             1
        emitGroup:               0
        emitKill:                0
        emitConfirmation:        0
        onMessage:               0
        onPublic:                0
        onGroup:                 0
        onPrivate:               0
        spawnChildProcess:       0
        respawnChildProcess:     0
        receivedConfirmations:   0
        successfulConfirmations: 0



    it "should count group message events", () =>
      worker.emitGroup("message")
      expect(worker.stats).toEqual
        emitPublic:              0
        emitPrivate:             0
        emitGroup:               1
        emitKill:                0
        emitConfirmation:        0
        onMessage:               0
        onPublic:                0
        onGroup:                 0
        onPrivate:               0
        spawnChildProcess:       0
        respawnChildProcess:     0
        receivedConfirmations:   0
        successfulConfirmations: 0



    it "should count kill message events", () =>
      worker.emitKill("message")
      expect(worker.stats).toEqual
        emitPublic:              0
        emitPrivate:             0
        emitGroup:               0
        emitKill:                1
        emitConfirmation:        0
        onMessage:               0
        onPublic:                0
        onGroup:                 0
        onPrivate:               0
        spawnChildProcess:       0
        respawnChildProcess:     0
        receivedConfirmations:   0
        successfulConfirmations: 0



    it "should count confirmation message events", () =>
      worker.emitConfirmation("message")
      expect(worker.stats).toEqual
        emitPublic:              0
        emitPrivate:             0
        emitGroup:               0
        emitKill:                0
        emitConfirmation:        1
        onMessage:               0
        onPublic:                0
        onGroup:                 0
        onPrivate:               0
        spawnChildProcess:       0
        respawnChildProcess:     0
        receivedConfirmations:   0
        successfulConfirmations: 0

  describe "listener", () =>
    [ subCb ] = []

    describe "public", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPublic(cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should count each message event", () =>
        subCb("wrongChannel", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



      it "should also count each public message event", () =>
        subCb("public", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                1
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



    describe "private", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onPrivate(cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should count each message event", () =>
        subCb("wrongChannel", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



      it "should also count each private message event", () =>
        subCb("private:mocked-uuid", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 0
          onPrivate:               1
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



    describe "group", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onGroup(cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should count each message event", () =>
        subCb("wrongChannel", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



      it "should also count each private message event", () =>
        subCb("group:worker", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 1
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



    describe "confirmation", () =>
      beforeEach () =>
        cb = jasmine.createSpy()

        worker.onConfirmation(2, "identifier", cb)
        # the first subscription is caused by the kill listener
        [ [], [ channel, subCb ] ] = worker.subscriber.on.argsForCall



      it "should count each message event", () =>
        subCb("wrongChannel", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "message" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



      it "should also count received confirmations", () =>
        subCb("confirmation", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "identifier" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               1
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   1
          successfulConfirmations: 0



      it "should also count matching confirmations", () =>
        subCb("confirmation", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "identifier" }))
        subCb("confirmation", JSON.stringify({ meta: { workerId: "workerId", group: "worker" }, data: "identifier" }))
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               2
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       0
          respawnChildProcess:     0
          receivedConfirmations:   2
          successfulConfirmations: 1


    describe "spawning", () =>
      beforeEach () =>
        worker.spawn([ file: "./web_worker.js" ])


      it "should count spawn event", () =>
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               0
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       1
          respawnChildProcess:     0
          receivedConfirmations:   0
          successfulConfirmations: 0



    describe "respawning", () =>
      [ exitCb ] = []

      beforeEach () =>
        worker.spawn([ file: "./web_worker.js" ])
        workerChild = worker.childProcess.spawn()
        [ [ eventName, exitCb ] ] = workerChild.on.argsForCall



      it "should count respawning event", () =>
        exitCb(1)
        expect(worker.stats).toEqual
          emitPublic:              0
          emitPrivate:             0
          emitGroup:               0
          emitKill:                0
          emitConfirmation:        0
          onMessage:               0
          onPublic:                0
          onGroup:                 0
          onPrivate:               0
          spawnChildProcess:       2
          respawnChildProcess:     1
          receivedConfirmations:   0
          successfulConfirmations: 0
