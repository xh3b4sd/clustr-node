_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "process channels", () =>
  [ process, channels ] = []

  beforeEach () =>
    process = Clustr.Process.create
      group:        "process"
      uuid:         Mock.uuid()
      publisher:    Mock.pub()
      subscriber:   Mock.sub()
      childProcess: Mock.chiPro()

    channels = _.flatten(process.subscriber.subscribe.argsForCall)



  it "should provide list of channels", () =>
    expect(process.channels).toEqual [
      "confirmation"
      "public"
      "private:mocked-uuid"
      "group:process"
      "kill:mocked-uuid"
    ]



  it "should subscribe to confirmation channel", () =>
    expect(channels).toContain("confirmation")



  it "should subscribe to public channel", () =>
    expect(channels).toContain("public")



  it "should subscribe to private channel", () =>
    expect(channels).toContain("private:mocked-uuid")



  it "should subscribe to group channel", () =>
    expect(channels).toContain("group:process")



  it "should subscribe to kill channel", () =>
    expect(channels).toContain("kill:mocked-uuid")



  it "should only subscribe to 5 channels", () =>
    expect(channels.length).toEqual(5)
