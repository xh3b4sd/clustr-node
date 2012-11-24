Jasmine = require("jasmine-node")
Clustr  = require("../index")
Mock    = require("./lib/mock")

describe "execution", () =>
  [ clustr ] = []



  beforeEach () =>
    config =
      master:
        { name: "master", publisher: Mock.pub(), subscriber: Mock.sub(), childProcess: Mock.chiPro() }
      workers: [
        { name: "web",   publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "web",   publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache", publisher: Mock.pub(), subscriber: Mock.sub() }
        { name: "cache", publisher: Mock.pub(), subscriber: Mock.sub() }
      ]

    clustr = Clustr.create(config)
    spyOn(clustr.master,  "publish")
    spyOn(clustr.worker,  "publish")
    spyOn(clustr.workers, "publish")



  describe "master", () =>
    it "should execute only master is allowed to", () =>
      clustr.master.do (master) =>
        master.publish("channel", master.config.name)

        expect(master.publish).toHaveBeenCalledWith("channel", "master")



  describe "webWorker", () =>
    it "should execute only webWorker is allowed to", () =>
      clustr.worker.config =
        name: "web"
        mode: "worker"

      clustr.worker.do "web", (webWorker) =>
        webWorker.publish("channel", webWorker.config.name)

        expect(webWorker.publish).toHaveBeenCalledWith("channel", "web")



  describe "cacheWorker", () =>
    it "should execute only cacheWorker is allowed to", () =>
      clustr.worker.config =
        name: "cache"
        mode: "worker"

      clustr.worker.do "cache", (cacheWorker) =>
        cacheWorker.publish("channel", cacheWorker.config.name)

        expect(cacheWorker.publish).toHaveBeenCalledWith("channel", "cache")



  describe "workers", () =>
    it "should execute only workers are allowed to", () =>
      clustr.workers.config =
        name: "cache"
        mode: "worker"

      clustr.workers.do (workers) =>
        workers.publish("channel", workers.config.name)

        expect(workers.publish).toHaveBeenCalledWith("channel", "cache")
