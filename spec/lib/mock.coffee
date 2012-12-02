module.exports =
  optimist: () =>
    argv:
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

  uuid: () =>
    v4: jasmine.createSpy().andReturn("mocked-uuid")



  pub: () =>
    publish: jasmine.createSpy()
    quit:    jasmine.createSpy()



  sub: () =>
    on:        jasmine.createSpy()
    subscribe: jasmine.createSpy()
    quit:      jasmine.createSpy()



  chiPro: () =>
    spawn: jasmine.createSpy().andReturn
      stdout:
        on: jasmine.createSpy()
      stderr:
        on: jasmine.createSpy()
      on: jasmine.createSpy()
