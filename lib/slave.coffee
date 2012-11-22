Send = require("./send").Send

class exports.Slave
  ###
  # Optains contains the process arguments.
  ###
  constructor: (@options) ->
    @send = Send.create()



  @create: (options) ->
    new Slave(options)



  do: (name, cb) ->
    return cb(@) if @isSlave() and @options.name is name
    cb(@) if @isSlave()



  isSlave: () ->
    @options.mode is "slave"
