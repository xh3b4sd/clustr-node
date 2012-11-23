_        = require("underscore")
Redis    = require("redis")

class exports.Workers
  constructor: (@options) ->
    @publisher  = Redis.createClient()
    @subscriber = Redis.createClient()



  @create: (options) =>
    new Workers(options)



  setup: () =>
    @deamon()
    @subscribe()



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  subscribe: () =>
    @subscriber.subscribe("workers")



  onMessage: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "workers"



  isWorker: () =>
    @options.mode? is true and @options.mode is "worker"



  deamon: () =>
    if @options.deamon is true
      anonym = () ->
      setInterval(anonym, 60000)



  do: () =>
    return if not @isWorker()

    args = _.toArray(arguments)

    if args.length is 1
      [cb] = args
      return cb(@)

    if args.length is 2
      [name, cb] = args
      return cb(@) if @options.name is name
