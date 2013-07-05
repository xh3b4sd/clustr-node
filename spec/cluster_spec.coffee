_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "cluster", () =>
  [ worker, event, subCb, channel, message, cb ] = []



  beforeEach () =>
    Mock.process()



  describe "master", () =>
    beforeEach () =>
      worker = Clustr.Master.create
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()



    describe "close", () =>
      it "should close publisher connection", () =>
        worker.close()
        expect(worker.publisher.quit).toHaveBeenCalled()



      it "should close subscriber connection", () =>
        worker.close()
        expect(worker.subscriber.quit).toHaveBeenCalled()



      it "should remove all process listener", () =>
        worker.close()
        expect(process.removeAllListeners).toHaveBeenCalled()



      it "should exit the process", () =>
        worker.close()
        expect(process.exit).toHaveBeenCalled()



    describe "registration", () =>
      beforeEach () =>
        [ [], [], [ event, subCb ] ] = worker.subscriber.on.argsForCall



      it "should listen on 'message' events", () =>
        expect(event).toEqual("message")



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



      it "should listen on 'message' events", () =>
        expect(event).toEqual("message")



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
      describe "on 'SIGHUP'", () =>
        it "should 'exit' master process", () =>
          # first call is for SIGHUP, second call is for SIGTERM
          [ [], [ event, onCb ] ] = process.on.argsForCall
          onCb()
          expect(process.exit).toHaveBeenCalledWith(15)



      describe "on 'exit'", () =>
        [ args1, args2, args3, args4, args5 ] = []

        beforeEach () =>
          worker.clusterInfo =
            web:   [ "pid1", "pid2" ]
            cache: [ "pid3", "pid4" ]

          spyOn(worker, "emitKill")
          [ [], [], [ event, exitCb ] ] = process.on.argsForCall

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



    describe "cluster info", () =>
      beforeEach () =>
        worker.clusterInfo =
          web:   [ "pid1", "pid2" ]
          cache: [ "pid3", "pid4" ]

        [ [], [ event, subCb ] ] = worker.subscriber.on.argsForCall



      it "should listen on 'message' events", () =>
        expect(event).toEqual("message")



      it "should send to correct worker that requested cluster info", () =>
        subCb("clusterInfo:#{process.pid}", JSON.stringify({ meta: { pid: "pid", group: "worker" }, data: "clusterInfo" }))
        [ [ channel, message ] ] = worker.publisher.publish.argsForCall

        expect(channel).toEqual("clusterInfo:pid")



      it "should send correct cluster info", () =>
        subCb("clusterInfo:#{process.pid}", JSON.stringify({ meta: { pid: "pid", group: "worker" }, data: "clusterInfo" }))
        [ [ channel, message ] ] = worker.publisher.publish.argsForCall

        expect(message).toEqual JSON.stringify
          meta: { pid: process.pid, group: "master" },
          data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }



      it "should not send on wrong channels", () =>
        subCb("clusterInfo", JSON.stringify({ meta: { pid: "pid", group: "worker" }, data: "clusterInfo" }))
        subCb(process.pid,   JSON.stringify({ meta: { pid: "pid", group: "worker" }, data: "clusterInfo" }))
        subCb("public",      JSON.stringify({ meta: { pid: "pid", group: "worker" }, data: "clusterInfo" }))
        subCb("private:foo", JSON.stringify({ meta: { pid: "pid", group: "worker" }, data: "clusterInfo" }))

        expect(worker.publisher.publish.argsForCall).toEqual([])



  describe "worker", () =>
    beforeEach () =>
      Mock.childProcess()
      Mock.optimist({ "cluster-master-pid": "masterPid" })

      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()



    describe "close", () =>
      it "should deregister worker", () =>
        spyOn(worker, "emitDeregistration")
        worker.close()
        expect(worker.emitDeregistration).toHaveBeenCalled()



      it "should close publisher connection", () =>
        worker.close()
        expect(worker.publisher.quit).toHaveBeenCalled()



      it "should close subscriber connection", () =>
        worker.close()
        expect(worker.subscriber.quit).toHaveBeenCalled()



      it "should remove all process listener", () =>
        worker.close()
        expect(process.removeAllListeners).toHaveBeenCalled()



      it "should exit the process", () =>
        worker.close()
        expect(process.exit).toHaveBeenCalled()



    describe "registration", () =>
      beforeEach () =>
        [ [ channel, message ] ] = worker.publisher.publish.argsForCall



      it "should register on creation on correct channel", () =>
        expect(channel).toEqual("registration:masterPid")



      it "should register on creation with correct message", () =>
        expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: "registration" }))



    describe "deregistration", () =>
      beforeEach () =>
        [ [ event, subCb ] ] = worker.subscriber.on.argsForCall
        subCb("kill:#{process.pid}", JSON.stringify({ meta: { pid: "mocked-uuid", group: "worker" }, data: 0 }))
        # first call is for registration
        [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



      it "should listen on 'message' events", () =>
        expect(event).toEqual("message")



      it "should deregister on exit on correct channel", () =>
        expect(channel).toEqual("deregistration:masterPid")



      it "should deregister on exit with correct message", () =>
        expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: "deregistration" }))



    describe "cluster info", () =>
      describe "request", () =>
        beforeEach () =>
          worker.emitClusterInfo()
          # first call is for cluster registration
          [ [], [ channel, message ] ] = worker.publisher.publish.argsForCall



        it "should publish to master", () =>
          expect(channel).toEqual("clusterInfo:masterPid")



        it "should publish correct data", () =>
          expect(message).toEqual(JSON.stringify({ meta: { pid: process.pid, group: "worker" }, data: "clusterInfo" }))



      describe "from master", () =>
        beforeEach () =>
          cb = jasmine.createSpy()

          worker.emitClusterInfo(cb)
          # first call is for onKill
          [ [], [ event, subCb ] ] = worker.subscriber.on.argsForCall



        it "should listen on 'message' events", () =>
          expect(event).toEqual("message")



        it "should provide cluster info data to given callback", () =>
          subCb "clusterInfo:#{process.pid}", JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          [ [ clusterInfo ] ] = cb.argsForCall
          expect(clusterInfo).toEqual
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }



        it "should not fire callback on wrong channels", () =>
          subCb "clusterInfo", JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          subCb process.pid, JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          subCb "infoo", JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          expect(cb).not.toHaveBeenCalled()



        it "should deregister event listener when callback was fired", () =>
          subCb "clusterInfo:#{process.pid}", JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          subCb "clusterInfo:#{process.pid}", JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          subCb "clusterInfo:#{process.pid}", JSON.stringify
            meta: { pid: process.pid, group: "master" },
            data: { web: [ "pid1", "pid2" ], cache: [ "pid3", "pid4" ] }

          expect(worker.subscriber.on.callCount).toEqual(2)
