_        = require("underscore")
Redis    = require("redis")

class exports.Worker
  constructor: (@options) ->
    @publisher  = Redis.createClient()
    @subscriber = Redis.createClient()



  @create: (options) =>
    new Worker(options)



  setup: () =>
    @subscribe()



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  subscribe: () =>
    @subscriber.subscribe("public")
    @subscriber.subscribe(@options.name)



  onPublic: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "public"



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is @options.name



  isWorker: () =>
    @options.mode? is true and @options.mode is "worker"



  do: () =>
    return if not @isWorker()

    args = _.toArray(arguments)

    if args.length is 1
      [cb] = args
      return cb(@)

    if args.length is 2
      [name, cb] = args
      return cb(@) if @options.name is name
