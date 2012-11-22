_        = require("underscore")
Redis    = require("redis")

class exports.Slaves
  constructor: (@options) ->
    @publisher  = Redis.createClient()
    @subscriber = Redis.createClient()



  @create: (options) =>
    new Slaves(options)



  setup: () =>
    @deamon()
    @subscribe()



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  subscribe: () =>
    @subscriber.subscribe("slaves")



  onMessage: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "slaves"



  isSlave: () =>
    @options.mode? is true and @options.mode is "slave"



  deamon: () =>
    if @options.deamon is true
      anonym = () ->
      setInterval(anonym, 60000)



  do: () =>
    return if not @isSlave()

    args = _.toArray(arguments)

    if args.length is 1
      [cb] = args
      return cb(@)

    if args.length is 2
      [name, cb] = args
      return cb(@) if @options.name is name
