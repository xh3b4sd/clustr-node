Jasmine = require("jasmine-node")
Clustr  = require("../index")
Mock    = require("./lib/mock")

describe "execution", () =>
  [ cb, config, clustr ] = []



  beforeEach () =>
    cb = jasmine.createSpy()

    config =
      master:
        { name: "master", publisher: Mock.pub(), subscriber: Mock.sub(), childProcess: Mock.chiPro() }
      workers: [
        { name: "web",    publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "web",    publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache",  publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache",  publisher: Mock.pub(), subscriber: Mock.sub() }
      ]

    clustr = Clustr.create(config)



  describe "master", () =>
    it "should execute callback only master is allowed to", () =>
      clustr.master.do(cb)
      expect(cb).toHaveBeenCalled()



    it "should provide master object to the callback", () =>
      clustr.master.do(cb)

      [ [ master ] ] = cb.argsForCall
      expect(master.config.name).toEqual("master")



  describe "webWorker", () =>
    it "should execute callback only webWorker is allowed to", () =>
      clustr.worker.config =
        name: "web"
        mode: "worker"

      clustr.worker.do("web", cb)
      expect(cb).toHaveBeenCalled()



    it "should provide webWorker object to the callback", () =>
      clustr.worker.config =
        name: "web"
        mode: "worker"

      clustr.worker.do("web", cb)

      [ [ webWorker ] ] = cb.argsForCall
      expect(webWorker.config.name).toEqual("web")



  describe "cacheWorker", () =>
    it "should execute callback only cacheWorker is allowed to", () =>
      clustr.worker.config =
        name: "cache"
        mode: "worker"

      clustr.worker.do("cache", cb)
      expect(cb).toHaveBeenCalled()



    it "should provide cacheWorker object to the callback", () =>
      clustr.worker.config =
        name: "cache"
        mode: "worker"

      clustr.worker.do("cache", cb)

      [ [ cacheWorker ] ] = cb.argsForCall
      expect(cacheWorker.config.name).toEqual("cache")



  describe "workers", () =>
    describe "webWorker", () =>
      it "should execute callback only workers is allowed to", () =>
        clustr.workers.config =
          name: "web"
          mode: "worker"

        clustr.workers.do(cb)
        expect(cb).toHaveBeenCalled()



      it "should provide worker object to the callback", () =>
        clustr.workers.config =
          name: "web"
          mode: "worker"

        clustr.workers.do(cb)

        [ [ webWorker ] ] = cb.argsForCall
        expect(webWorker.config.name).toEqual("web")


    describe "cacheWorker", () =>
      it "should execute callback only workers is allowed to", () =>
        clustr.workers.config =
          name: "cache"
          mode: "worker"

        clustr.workers.do(cb)
        expect(cb).toHaveBeenCalled()



      it "should provide worker object to the callback", () =>
        clustr.workers.config =
          name: "cache"
          mode: "worker"

        clustr.workers.do(cb)

        [ [ cacheWorker ] ] = cb.argsForCall
        expect(cacheWorker.config.name).toEqual("cache")
