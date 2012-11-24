module.exports =
  pub: () =>
    publish: jasmine.createSpy()



  sub: () =>
    on:        jasmine.createSpy()
    subscribe: jasmine.createSpy()



  chiPro: () =>
    spawn: jasmine.createSpy().andReturn
      stdout:
        on: jasmine.createSpy()
      stderr:
        on: jasmine.createSpy()
      on: jasmine.createSpy()
