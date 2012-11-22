_        = require("underscore")
Send     = require("./send").Send
Optimist = require("optimist")

class exports.Master
  constructor: (@options) ->
    @send = Send.create()



  @create: (options) ->
    new Master(options)



  do: (cb) ->
    cb(@) if @isMaster()



  isMaster: () ->
    Optimist.argv.mode? is false or Optimist.argv.mode is not "slave"
