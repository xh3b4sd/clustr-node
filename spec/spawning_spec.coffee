Path    = require("path")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")
ChildProcess = require("child_process")

describe "spawning", () =>
  [ worker, callOne, callTwo, callThree, callFour, callFive ] = []

  beforeEach () =>
    Mock.optimist()
    Mock.childProcess()



  describe "worker", () =>
    beforeEach () =>
      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      worker.spawn [
        { file: "./web_worker.js", args: { "cluster-option5": true, "private-option5": "option" } }
        { file: "./web_worker.js", cpu: 1 }
        { file: "./cache_worker.coffee", command: "node", respawn: false }
        { file: "./cache_worker.coffee", cpu: 2, command: "node" }
      ]

      [ callOne, callTwo, callThree, callFour, callFive, callSix ] = ChildProcess.spawn.argsForCall



    it "should provide 'masterProcessId'", () =>
      Mock.optimist({ "cluster-master-pid": "masterPid" })

      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      expect(worker.masterPid).toEqual("masterPid")



    it "should spawn first worker correctly", () =>
      expect(callOne).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./web_worker.js")
          "--cluster-option5"
          "--private-option5=option"
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should spawn second worker correctly", () =>
      expect(callTwo).toEqual [
        "taskset"
        [
          "-c"
          1
          "node"
          Path.resolve(process.argv[1], "../", "./web_worker.js")
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should spawn third worker correctly", () =>
      expect(callThree).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./node_modules/coffee-script/bin/coffee")
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should spawn fourth worker correctly", () =>
      expect(callFour).toEqual [
        "taskset"
        [
          "-c"
          2
          "node"
          Path.resolve(process.argv[1], "../", "./node_modules/coffee-script/bin/coffee")
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should not spawn fifth worker", () =>
      expect(callFive).toBeUndefined()



    describe "respawning enabled by default", () =>
      [ workerChild, eventNameTwo, eventCbTwo ] = []

      beforeEach () =>
        # cause 5. spawn()
        workerChild = ChildProcess.spawn()
        [ [], [ eventNameTwo, eventCbTwo ] ] = workerChild.on.argsForCall



      describe "exit code 0", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should not respawn worker", () =>
          # send exit code 0 to 2. worker and cause 6. spawn()
          eventCbTwo(0)
          [ [], [], [], [], [], argsSixth ] = ChildProcess.spawn.argsForCall

          # 6. spawn() should not cause respawning of 2. worker
          expect(argsSixth).toBeUndefined()



      describe "exit code 1", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should respawn worker", () =>
          # send exit code 1 to 2. worker and cause 6. spawn()
          eventCbTwo(1)
          [ [], argsTwo, [], [], [], argsSixth ] = ChildProcess.spawn.argsForCall

          # 6. spawn() should cause respawning of 2. worker
          expect(argsTwo).toEqual(argsSixth)



    describe "respawning disabled", () =>
      [ workerChild, eventNameTwo, eventCbTwo ] = []

      beforeEach () =>
        # cause 5. spawn()
        workerChild = ChildProcess.spawn()
        [ [], [], [ eventNameTwo, eventCbTwo ] ] = workerChild.on.argsForCall



      describe "exit code 1", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should not respawn worker", () =>
          # send exit code 0 to 3. worker and cause 6. spawn()
          eventCbTwo(0)
          [ [], [], [], [], [], argsSixth ] = ChildProcess.spawn.argsForCall

          # 6. spawn() should not cause respawning of 3. worker
          expect(argsSixth).toBeUndefined()



      describe "exit code 9", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should not respawn worker", () =>
          # send exit code 0 to 3. worker and cause 6. spawn()
          eventCbTwo(9)
          [ [], [], [], [], [], argsSixth ] = ChildProcess.spawn.argsForCall

          # 6. spawn() should not cause respawning of 3. worker
          expect(argsSixth).toBeUndefined()



  describe "master", () =>
    beforeEach () =>
      worker = Clustr.Worker.create
        group:        "master"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      worker.spawn [
        { file: "./web_worker.js", args: { "cluster-option5": true, "private-option5": "option" } }
        { file: "./web_worker.js", cpu: 1 }
        { file: "./cache_worker.coffee", command: "node", respawn: false }
        { file: "./cache_worker.coffee", cpu: 2, command: "node" }
      ]

      [ callOne, callTwo, callThree, callFour, callFive, callSix ] = ChildProcess.spawn.argsForCall



    it "should not provide 'masterProcessId' for master", () =>
      expect(worker.masterProcessId).toBeUndefined()



    it "should spawn first worker correctly", () =>
      expect(callOne).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./web_worker.js")
          "--cluster-option5"
          "--private-option5=option"
          "--cluster-master-pid=#{process.pid}"
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should spawn second worker correctly", () =>
      expect(callTwo).toEqual [
        "taskset"
        [
          "-c"
          1
          "node"
          Path.resolve(process.argv[1], "../", "./web_worker.js")
          "--cluster-master-pid=#{process.pid}"
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should spawn third worker correctly", () =>
      expect(callThree).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./node_modules/coffee-script/bin/coffee")
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
          "--cluster-master-pid=#{process.pid}"
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should spawn fourth worker correctly", () =>
      expect(callFour).toEqual [
        "taskset"
        [
          "-c"
          2
          "node"
          Path.resolve(process.argv[1], "../", "./node_modules/coffee-script/bin/coffee")
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
          "--cluster-master-pid=#{process.pid}"
          "--cluster-option1=cluster-command-line-option"
          "--cluster-option2"
          "--cluster-option4=5"
        ]
      ]



    it "should not spawn fifth worker", () =>
      expect(callFive).toBeUndefined()
