_    = require("underscore")
Send = require("./send").Send

class exports.Slave
  ###
  # Optains contains the process arguments.
  ###
  constructor: (@options) ->
    @send = Send.create()



  @create: (options) =>
    new Slave(options)



  do: () =>
    return if not @isSlave()

    args = _.toArray(arguments)

    if args.length is 1
      [cb] = args
      return cb(@)

    if args.length is 2
      [name, cb] = args
      return cb(@) if @options.name is name



  isSlave: () =>
    @options.mode is "slave"
