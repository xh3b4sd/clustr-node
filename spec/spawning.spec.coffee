Jasmine = require("jasmine-node")
Clustr  = require("../index")
Mock    = require("./lib/mock")

describe "spawning", () =>
  [ clustr,  callOne, callTwo, callThree, callFour, callFive ] = []



  beforeEach () =>
    config =
      master:
        { name: "master", publisher: Mock.pub(), subscriber: Mock.sub(), childProcess: Mock.chiPro() }
      workers: [
        { name: "web",   cpu: 0,         publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "web",   respawn: true,  publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache", respawn: false, publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache",                 publisher: Mock.pub(), subscriber: Mock.sub() }
      ]

    clustr = Clustr.create(config)
    [ callOne, callTwo, callThree, callFour, callFive, callSix ] = clustr.master.childProcess.spawn.argsForCall


  describe "cpu binding", () =>
    it "should spawn first worker correctly", () =>
      expect(callOne).toEqual [
        "taskset"
        [
          "-c"
          0
          "node"
          process.argv[1]
          "--mode=worker"
          "--id=0"
          "--name=web"
          "--cpu=0"
          "--publisher=[object Object]"
          "--subscriber=[object Object]"
        ]
      ]



  it "should spawn second worker correctly", () =>
    expect(callTwo).toEqual [
      "node"
      [
        process.argv[1]
        "--mode=worker"
        "--id=1"
        "--name=web"
        "--respawn"
        "--publisher=[object Object]"
        "--subscriber=[object Object]"
      ]
    ]



  it "should spawn third worker correctly", () =>
    expect(callThree).toEqual [
      "node"
      [
        process.argv[1]
        "--mode=worker"
        "--id=2"
        "--name=cache"
        "--publisher=[object Object]"
        "--subscriber=[object Object]"
      ]
    ]



  it "should spawn fourth worker correctly", () =>
    expect(callFour).toEqual [
      "node"
      [
        process.argv[1]
        "--mode=worker"
        "--id=3"
        "--name=cache"
        "--publisher=[object Object]"
        "--subscriber=[object Object]"
      ]
    ]



  it "should not spawn fifth worker", () =>
    expect(callFive).toBeUndefined()



  describe "respawning", () =>
    describe "enabled", () =>
      it "should not respawn worker on exit code 0", () =>
        # cause 5. spawn()
        worker = clustr.master.childProcess.spawn()

        # send exit code 0 to 2. worker and cause 6. spawn()
        [ [], [ eventNameTwo, eventCbTwo ] ] = worker.on.argsForCall
        eventCbTwo(0)
        [ [], argsTwo, [], [], [], argsSixth ] = clustr.master.childProcess.spawn.argsForCall

        # 6. spawn() should not cause respawning of 2. worker
        expect(argsSixth).toBeUndefined()



      it "should respawn worker on exit code 1", () =>
        # cause 5. spawn()
        worker = clustr.master.childProcess.spawn()

        # send exit code 1 to 2. worker and cause 6. spawn()
        [ [], [ eventNameTwo, eventCbTwo ] ] = worker.on.argsForCall
        eventCbTwo(1)
        [ [], argsTwo, [], [], [], argsSixth ] = clustr.master.childProcess.spawn.argsForCall

        # 6. spawn() should cause respawning of 2. worker
        expect(argsTwo).toEqual(argsSixth)



    describe "disabled", () =>
      it "should not respawn worker on exit code 0", () =>
        # cause 5. spawn()
        worker = clustr.master.childProcess.spawn()

        # send exit code 1 to 3. worker and cause 6. spawn()
        [ [], [], [ eventNameThree, eventCbThree ] ] = worker.on.argsForCall
        eventCbThree(0)
        [ [], [], [], [], [], argsSixth ] = clustr.master.childProcess.spawn.argsForCall

        # 6. spawn() should not cause respawning of 3. worker
        expect(argsSixth).toBeUndefined()



      it "should not respawn worker on exit code 1", () =>
        # cause 5. spawn()
        worker = clustr.master.childProcess.spawn()

        # send exit code 1 to 3. worker and cause 6. spawn()
        [ [], [], [ eventNameThree, eventCbThree ] ] = worker.on.argsForCall
        eventCbThree(1)
        [ [], [], [], [], [], argsSixth ] = clustr.master.childProcess.spawn.argsForCall

        # 6. spawn() should not cause respawning of 3. worker
        expect(argsSixth).toBeUndefined()



    describe "not set", () =>
      it "should not respawn worker on exit code 0", () =>
        # cause 5. spawn()
        worker = clustr.master.childProcess.spawn()

        # send exit code 1 to 4. worker and cause 6. spawn()
        [ [], [], [], [ eventNameFour, eventCbFour ] ] = worker.on.argsForCall
        eventCbFour(0)
        [ [], [], [], [], [], argsSixth ] = clustr.master.childProcess.spawn.argsForCall

        # 6. spawn() should not cause respawning of 3. worker
        expect(argsSixth).toBeUndefined()



      it "should not respawn worker on exit code 1", () =>
        # cause 5. spawn()
        worker = clustr.master.childProcess.spawn()

        # send exit code 1 to 4. worker and cause 6. spawn()
        [ [], [], [], [ eventNameFour, eventCbFour ] ] = worker.on.argsForCall
        eventCbFour(1)
        [ [], [], [], [], [], argsSixth ] = clustr.master.childProcess.spawn.argsForCall

        # 6. spawn() should not cause respawning of 3. worker
        expect(argsSixth).toBeUndefined()
