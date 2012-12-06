Optimist     = require("optimist")
ChildProcess = require("child_process")

module.exports =
  logger: jasmine.createSpy



  optimist: (custom) =>
    Optimist.argv =
        "_":               "foo"
        "$0":              "bar"
        "cluster-option1": "cluster-command-line-option"
        "cluster-option2": true
        "cluster-option3": false
        "cluster-option4": 5
        "private-option1": "private-command-line-option"
        "private-option2": true
        "private-option3": false
        "private-option4": 5

    Optimist.argv[key] = val for key, val of custom when custom?



  publisher: () =>
    publish: jasmine.createSpy()
    quit:    jasmine.createSpy()



  subscriber: () =>
    on:             jasmine.createSpy()
    subscribe:      jasmine.createSpy()
    quit:           jasmine.createSpy()
    removeListener: jasmine.createSpy()



  childProcess: () =>
    spyOn(ChildProcess, "spawn").andReturn
      stdout:
        on: jasmine.createSpy()
      stderr:
        on: jasmine.createSpy()
      on: jasmine.createSpy()



  process: () =>
    spyOn(process, "on")
    spyOn(process, "exit")
    spyOn(process, "removeAllListeners")
