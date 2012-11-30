Path    = require("path")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "spawning", () =>
  [ callOne, callTwo, callThree, callFour, callFive ] = []



  describe "master", () =>
    [ master ] = []

    beforeEach () =>
      master = Clustr.Master.create
        publisher: Mock.pub()
        subscriber: Mock.sub()
        childProcess: Mock.chiPro()

      master.spawn [
        { file: "./web_worker.js" }
        { file: "./web_worker.js",       cpu: 1 }
        { file: "./cache_worker.coffee",         command: "coffee" }
        { file: "./cache_worker.coffee", cpu: 2, command: "coffee" }
      ]

      [ callOne, callTwo, callThree, callFour, callFive, callSix ] = master.childProcess.spawn.argsForCall



    it "should spawn first worker correctly", () =>
      expect(callOne).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./web_worker.js")
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
        ]
      ]



    it "should spawn third worker correctly", () =>
      expect(callThree).toEqual [
        "coffee"
        [
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
        ]
      ]



    it "should spawn fourth worker correctly", () =>
      expect(callFour).toEqual [
        "taskset"
        [
          "-c"
          2
          "coffee"
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
        ]
      ]



    it "should not spawn fifth worker", () =>
      expect(callFive).toBeUndefined()



    describe "respawning", () =>
      [ worker, eventNameTwo, eventCbTwo ] = []

      beforeEach () =>
        # cause 5. spawn()
        worker = master.childProcess.spawn()
        [ [], [ eventNameTwo, eventCbTwo ] ] = worker.on.argsForCall



      describe "exit code 0", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should not respawn worker", () =>
          # send exit code 0 to 2. worker and cause 6. spawn()
          eventCbTwo(0)
          [ [], [], [], [], [], argsSixth ] = master.childProcess.spawn.argsForCall

          # 6. spawn() should not cause respawning of 2. worker
          expect(argsSixth).toBeUndefined()



      describe "exit code 1", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should respawn worker", () =>
          # send exit code 1 to 2. worker and cause 6. spawn()
          eventCbTwo(1)
          [ [], argsTwo, [], [], [], argsSixth ] = master.childProcess.spawn.argsForCall

          # 6. spawn() should cause respawning of 2. worker
          expect(argsTwo).toEqual(argsSixth)



  describe "worker", () =>
    [ worker ] = []

    beforeEach () =>
      worker = Clustr.Worker.create
        group: "worker"
        publisher: Mock.pub()
        subscriber: Mock.sub()
        childProcess: Mock.chiPro()

      worker.spawn [
        { file: "./web_worker.coffee" }
        { file: "./web_worker.coffee",   cpu: 1 }
        { file: "./cache_worker.coffee" }
        { file: "./cache_worker.coffee", cpu: 2 }
      ]

      [ callOne, callTwo, callThree, callFour, callFive, callSix ] = worker.childProcess.spawn.argsForCall



    it "should spawn first worker correctly", () =>
      expect(callOne).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./web_worker.coffee")
        ]
      ]



    it "should spawn second worker correctly", () =>
      expect(callTwo).toEqual [
        "taskset"
        [
          "-c"
          1
          "node"
          Path.resolve(process.argv[1], "../", "./web_worker.coffee")
        ]
      ]



    it "should spawn third worker correctly", () =>
      expect(callThree).toEqual [
        "node"
        [
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
        ]
      ]



    it "should spawn fourth worker correctly", () =>
      expect(callFour).toEqual [
        "taskset"
        [
          "-c"
          2
          "node"
          Path.resolve(process.argv[1], "../", "./cache_worker.coffee")
        ]
      ]



    it "should not spawn fifth worker", () =>
      expect(callFive).toBeUndefined()



    describe "respawning", () =>
      [ eventNameTwo, eventCbTwo ] = []

      beforeEach () =>
        # cause 5. spawn()
        workerChild = worker.childProcess.spawn()
        [ [], [ eventNameTwo, eventCbTwo ] ] = workerChild.on.argsForCall



      describe "exit code 0", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should not respawn worker", () =>
          # send exit code 0 to 2. worker and cause 6. spawn()
          eventCbTwo(0)
          [ [], [], [], [], [], argsSixth ] = worker.childProcess.spawn.argsForCall

          # 6. spawn() should not cause respawning of 2. worker
          expect(argsSixth).toBeUndefined()



      describe "exit code 1", () =>
        it "should use correct event name", () =>
          expect(eventNameTwo).toEqual("exit")



        it "should respawn worker", () =>
          # send exit code 1 to 2. worker and cause 6. spawn()
          eventCbTwo(1)
          [ [], argsTwo, [], [], [], argsSixth ] = worker.childProcess.spawn.argsForCall

          # 6. spawn() should cause respawning of 2. worker
          expect(argsTwo).toEqual(argsSixth)
