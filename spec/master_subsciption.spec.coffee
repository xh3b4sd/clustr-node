_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "master subscription", () =>
  [ master, channels ] = []

  beforeEach () =>
    master = Clustr.Master.create
      publisher: Mock.pub()
      subscriber: Mock.sub()
      childProcess: Mock.chiPro()

    channels = _.flatten(master.subscriber.subscribe.argsForCall)



  it "should subscribe to public channel", () =>
    expect(channels).toContain("public")



  it "should subscribe to confirmation channel", () =>
    expect(channels).toContain("confirmation")



  it "should subscribe to private channel", () =>
    expect(channels).toContain("master")



  it "should only subscribe to 3 channels", () =>
    expect(channels.length).toEqual(3)
