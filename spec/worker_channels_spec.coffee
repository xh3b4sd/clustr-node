_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "worker channels", () =>
  [ worker, channels ] = []

  beforeEach () =>
    worker = Clustr.Process.create
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



  it "should subscribe to confirmation channel", () =>
    expect(channels).toContain("confirmation")



  it "should subscribe to public channel", () =>
    expect(channels).toContain("public")



  it "should subscribe to private channel", () =>
    expect(channels).toContain("private:mocked-uuid")



  it "should subscribe to group channel", () =>
    expect(channels).toContain("group:worker")



  it "should subscribe to kill channel", () =>
    expect(channels).toContain("kill:mocked-uuid")



  it "should only subscribe to 5 channels", () =>
    expect(channels.length).toEqual(5)
