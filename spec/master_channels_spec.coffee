_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "master channels", () =>
  [ master, channels ] = []

  beforeEach () =>
    master = Clustr.Master.create
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()

    channels = _.flatten(master.subscriber.subscribe.argsForCall)



  it "should subscribe to confirmation channel", () =>
    expect(channels).toContain("confirmation")



  it "should subscribe to public channel", () =>
    expect(channels).toContain("public")



  it "should subscribe to private channel", () =>
    expect(channels).toContain("private:mocked-uuid")



  it "should subscribe to group channel", () =>
    expect(channels).toContain("group:master")



  it "should subscribe to kill channel", () =>
    expect(channels).toContain("kill:mocked-uuid")



  it "should only subscribe to 5 channels", () =>
    expect(channels.length).toEqual(5)
