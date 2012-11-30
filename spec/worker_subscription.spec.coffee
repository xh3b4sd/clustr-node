_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "worker subscription", () =>
  [ worker, channels ] = []

  beforeEach () =>
    worker = Clustr.Worker.create
      group:        "worker"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()

    channels = _.flatten(worker.subscriber.subscribe.argsForCall)



  it "should subscribe to public channel", () =>
    expect(channels).toContain("public")



  it "should subscribe to group channel", () =>
    expect(channels).toContain("worker")



  it "should subscribe to private channel", () =>
    expect(channels).toContain("mocked-uuid")



  it "should subscribe to kill channel", () =>
    expect(channels).toContain("kill:mocked-uuid")



  it "should only subscribe to 4 channels", () =>
    expect(channels.length).toEqual(4)
