_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "channels", () =>
  [ worker, channels ] = []

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()

    channels = _.flatten(worker.subscriber.subscribe.argsForCall)



  it "should provide list of channels", () =>
    expect(worker.channels).toEqual [
      "confirmation"
      "public"
      "private:mocked-uuid"
      "group:worker"
      "kill:mocked-uuid"
    ]



  it "should subscribe to channels", () =>
    expect(channels).toEqual [
      "confirmation"
      "public"
      "private:mocked-uuid"
      "group:worker"
      "kill:mocked-uuid"
    ]
