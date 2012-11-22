_    = require("underscore")
Send     = require("./send").Send
Optimist = require("optimist")

class exports.Master
  ###
  # options contains the master configuration
  ###
  constructor: (options) ->
    @options = _.extend({}, options, Optimist.argv)
    @send = Send.create()



  @create: (options) ->
    new Master(options)



  do: (cb) ->
    cb(@) if @isMaster()



  isMaster: () ->
    @options.mode is undefined or @options.mode is not "slave"
