_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "cluster", () =>
  [ worker, subCb, channel, message ] = []

  describe "master", () =>
    beforeEach () =>
      spyOn(process, "on")
      spyOn(process, "exit")

      worker = Clustr.Master.create
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()
        childProcess: Mock.childProcess()



    describe "registration", () =>
      beforeEach () =>
        [ [], [], [ event, subCb ] ] = worker.subscriber.on.argsForCall



      it "should not register on creation", () =>
        expect(worker.publisher.publish.argsForCall).toEqual([])



      it "should provide empty cluster info object", () =>
        expect(worker.clusterInfo).toEqual({})



      it "should register worker in unknown group", () =>
        subCb("registration:#{process.pid}", JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "registration" }))
        expect(worker.clusterInfo).toEqual( web: [ "pid1" ] )



      it "should register worker in known group", () =>
        worker.clusterInfo = web: [ "pid1" ]
        subCb("registration:#{process.pid}", JSON.stringify({ meta: { pid: "pid2", group: "cache" }, data: "registration" }))
        expect(worker.clusterInfo).toEqual
          web:   [ "pid1" ]
          cache: [ "pid2" ]



      it "should register another worker in known group", () =>
        worker.clusterInfo = web: [ "pid1" ]
        subCb("registration:#{process.pid}", JSON.stringify({ meta: { pid: "pid2", group: "web" }, data: "registration" }))
        expect(worker.clusterInfo).toEqual
          web:   [ "pid1", "pid2" ]



      it "should not register worker on wrong channel", () =>
        subCb("registration", JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "registration" }))
        subCb(process.pid,    JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "registration" }))
        subCb("public",       JSON.stringify({ meta: { pid: "pid1", group: "web" }, data: "registration" }))

        expect(worker.clusterInfo).toEqual({})






    describe "deregistration", () =>
      beforeEach () =>
        [ [], [], [], [ event, subCb ] ] = worker.subscriber.on.argsForCall

        worker.clusterInfo =
          web:   [ "pid1", "pid2" ]
          cache: [ "pid3", "pid4" ]



      it "should not deregister on exit", () =>
        [ [ event, subCb ] ] = worker.subscriber.on.argsForCall
        subCb("kill:#{process.pid}", JSON.stringify({ meta: { pid: process.pid, group: "master" }, data: 0 }))

        expect(worker.publisher.publish.argsForCall).toEqual([])



      it "should deregister worker on correct channel", () =>
        subCb("deregistration:#{process.pid}", JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "registration" }))
        expect(worker.clusterInfo).toEqual
          web:   [ "pid1", "pid2" ]
          cache: [         "pid4" ]



      it "should not deregister worker on unknown pid", () =>
        subCb("deregistration:#{process.pid}", JSON.stringify({ meta: { pid: "pid5", group: "cache" }, data: "registration" }))
        expect(worker.clusterInfo).toEqual
          web:   [ "pid1", "pid2" ]
          cache: [ "pid3", "pid4" ]



      it "should not deregister worker on unknown group", () =>
        subCb("deregistration:#{process.pid}", JSON.stringify({ meta: { pid: "pid3", group: "foo" }, data: "registration" }))
        expect(worker.clusterInfo).toEqual
          web:   [ "pid1", "pid2" ]
          cache: [ "pid3", "pid4" ]



      it "should not deregister worker on wrong channel", () =>
        subCb("deregistration", JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "registration" }))
        subCb(process.pid,      JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "registration" }))
        subCb("public",         JSON.stringify({ meta: { pid: "pid3", group: "cache" }, data: "registration" }))

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



  describe "worker", () =>
    beforeEach () =>
      worker = Clustr.Worker.create
        group:        "worker"
        optimist:     Mock.optimist({ "cluster-master-pid": "masterPid" })
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()
        childProcess: Mock.childProcess()



    describe "registration", () =>
      beforeEach () =>
        [ [ channel, message ] ] = worker.publisher.publish.argsForCall



      it "should register on creation on correct channel", () =>
        expect(channel).toEqual("registration:masterPid")



      it "should register on creation with correct message", () =>
        expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: "registration" }))



    describe "deregistration", () =>
      beforeEach () =>
        spyOn(process, "exit")

        [ [ event, subCb ] ] = worker.subscriber.on.argsForCall
        subCb("kill:#{process.pid}", JSON.stringify({ meta: { pid: "mocked-uuid", group: "worker" }, data: 0 }))
        # first call is for registration
        [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



      it "should deregister on exit on correct channel", () =>
        expect(channel).toEqual("deregistration:masterPid")



      it "should deregister on exit with correct message", () =>
        expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: "deregistration" }))
