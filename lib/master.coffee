Send = require("./send").Send

class exports.Master
  ###
  # Options contains the process arguments.
  ###
  constructor: (@options) ->
    @send = Send.create()



  @create: (options) ->
    new Master(options)



  do: (cb) ->
    cb(@) if @isMaster()



  isMaster: () ->
    @options.mode is undefined or @options.mode is not "slave"
