_       = require("underscore")
Jasmine = require("jasmine-node")
Mock    = require("./lib/mock")
Clustr  = require("../index")

describe "logging", () =>
  [ worker ] = []

  describe "verbose", () =>
    it "should log using 'console.log' by default", () =>
      Mock.optimist({ "verbose": true })
      spyOn(console, "log")

      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      worker.log("test message")
      expect(console.log).toHaveBeenCalledWith("test message")



    it "should log using custom logger if given", () =>
      Mock.optimist({ "verbose": true })

      worker = Clustr.Worker.create
        group:        "worker"
        logger:       Mock.logger()
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      worker.log("test message")
      expect(worker.logger).toHaveBeenCalledWith("test message")



  describe "cluster-verbose", () =>
    it "should log using 'console.log' by default", () =>
      Mock.optimist({ "cluster-verbose": true })
      spyOn(console, "log")

      worker = Clustr.Worker.create
        group:        "worker"
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      worker.log("test message")
      expect(console.log).toHaveBeenCalledWith("test message")



    it "should log using custom logger if given", () =>
      Mock.optimist({ "cluster-verbose": true })

      worker = Clustr.Worker.create
        group:        "worker"
        logger:       Mock.logger()
        publisher:    Mock.publisher()
        subscriber:   Mock.subscriber()

      worker.log("test message")
      expect(worker.logger).toHaveBeenCalledWith("test message")
