_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "killing", () =>
  [ worker ] = []

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()



  describe "publication", () =>
    it "should publish on kill channel", () =>
      worker.killWorker("workerId")

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(channel).toEqual("kill:workerId")



    it "should publish default exit code 0", () =>
      worker.killWorker("workerId")

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(message).toEqual('{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":0}')



    it "should publish given exit code", () =>
      worker.killWorker("workerId", 1)

      [ [ channel, message ] ] = worker.publisher.publish.argsForCall
      expect(message).toEqual('{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":1}')



  describe "subscription", () =>
    [ channel, subCb ] = []

    beforeEach () =>
      spyOn(process, "exit")

      [ [ channel, subCb ] ] = worker.subscriber.on.argsForCall



    it "should kill process on kill channel", () =>
      subCb("kill:mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":0}')
      expect(process.exit.callCount).toEqual(1)



    it "should not kill process on other channels", () =>
      subCb("mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":0}')
      subCb("kill-uuid",   '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":1}')
      subCb("public",      '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":2}')
      subCb("private",     '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":3}')
      subCb("master",      '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":4}')

      expect(process.exit.callCount).toEqual(0)



    it "should kill process with exit code 0", () =>
      subCb("kill:mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":0}')
      expect(process.exit).toHaveBeenCalledWith(0)



    it "should kill process with exit code 1", () =>
      subCb("kill:mocked-uuid", '{"meta":{"workerId":"mocked-uuid","group":"worker"},"data":1}')
      expect(process.exit).toHaveBeenCalledWith(1)
