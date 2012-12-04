_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "cluster", () =>
  [ worker, subCb ] = []

  beforeEach () =>
    spyOn(process, "on")
    spyOn(process, "exit")

    worker = Clustr.Master.create
      publisher:    Mock.publisher()
      subscriber:   Mock.subscriber()
      childProcess: Mock.childProcess()



  afterEach () =>
    worker.close()



  describe "registration", () =>
    beforeEach () =>
      [ [], [ event, subCb ] ] = worker.subscriber.on.argsForCall



    it "should provide empty cluster info object", () =>
      expect(worker.clusterInfo).toEqual({})



    it "should register worker in unknown group", () =>
      subCb("registration:#{process.pid}", JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "register" }))
      expect(worker.clusterInfo).toEqual( web: [ "pid1" ] )



    it "should register worker in known group", () =>
      worker.clusterInfo = web: [ "pid1" ]
      subCb("registration:#{process.pid}", JSON.stringify({ meta: { pid: "pid2", group: "cache" }, data: "register" }))
      expect(worker.clusterInfo).toEqual
        web:   [ "pid1" ]
        cache: [ "pid2" ]



    it "should register another worker in known group", () =>
      worker.clusterInfo = web: [ "pid1" ]
      subCb("registration:#{process.pid}", JSON.stringify({ meta: { pid: "pid2", group: "web" }, data: "register" }))
      expect(worker.clusterInfo).toEqual
        web:   [ "pid1", "pid2" ]



    it "should not register worker on wrong channel", () =>
      subCb("registration", JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "register" }))
      subCb(process.pid,    JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "register" }))
      subCb("public",       JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "register" }))

      expect(worker.clusterInfo).toEqual({})






  describe "deregistration", () =>
    beforeEach () =>
      [ [], [], [ event, subCb ] ] = worker.subscriber.on.argsForCall

      worker.clusterInfo =
        web:   [ "pid1", "pid2" ]
        cache: [ "pid3", "pid4" ]



    it "should deregister worker on correct channel", () =>
      subCb("deregistration:#{process.pid}", JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "register" }))
      expect(worker.clusterInfo).toEqual
        web:   [ "pid1", "pid2" ]
        cache: [         "pid4" ]



    it "should not deregister worker on unknown pid", () =>
      subCb("deregistration:#{process.pid}", JSON.stringify({ meta: { pid: "pid5", group: "cache" }, data: "register" }))
      expect(worker.clusterInfo).toEqual
        web:   [ "pid1", "pid2" ]
        cache: [ "pid3", "pid4" ]



    it "should not deregister worker on unknown group", () =>
      subCb("deregistration:#{process.pid}", JSON.stringify({ meta: { pid: "pid3", group: "foo" }, data: "register" }))
      expect(worker.clusterInfo).toEqual
        web:   [ "pid1", "pid2" ]
        cache: [ "pid3", "pid4" ]



    it "should not deregister worker on wrong channel", () =>
      subCb("deregistration", JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "register" }))
      subCb(process.pid,      JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "register" }))
      subCb("public",         JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "register" }))

      expect(worker.clusterInfo).toEqual
        web:   [ "pid1", "pid2" ]
        cache: [ "pid3", "pid4" ]



  describe "termination", () =>
    describe "on 'SIGHUB'", () =>
      it "should 'exit' master process", () =>
        [ [ event, onCb ] ] = process.on.argsForCall
        onCb()
        expect(process.exit).toHaveBeenCalledWith(1)



    describe "on 'exit'", () =>
      [ args1, args2, args3, args4, args5 ] = []

      beforeEach () =>
        worker.clusterInfo =
          web:   [ "pid1", "pid2" ]
          cache: [ "pid3", "pid4" ]

        spyOn(worker, "emitKill")
        [ [], [ event, exitCb ] ] = process.on.argsForCall

        exitCb(1)

        [ args1, args2, args3, args4, args5 ] = worker.emitKill.argsForCall



      it "should kill first worker", () =>
        expect(args1).toEqual([ "pid1", 1 ])



      it "should kill second worker", () =>
        expect(args2).toEqual([ "pid2", 1 ])



      it "should kill third worker", () =>
        expect(args3).toEqual([ "pid3", 1 ])



      it "should kill fourth worker", () =>
        expect(args4).toEqual([ "pid4", 1 ])



      it "should not kill other workers", () =>
        expect(args5).toBeUndefined()
