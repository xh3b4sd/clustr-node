_        = require("underscore")
Redis    = require("redis")
Optimist = require("optimist")

class exports.Worker
  constructor: (config) ->
    return if not @isWorker()

    @config     = Optimist.argv
    @publisher  = config.workers[@config.id].publisher or Redis.createClient()
    @subscriber = config.workers[@config.id].subscriber or Redis.createClient()



  @create: (config) =>
    new Worker(config)



  setup: () =>
    @subscribe()



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  subscribe: () =>
    @subscriber.subscribe("public")
    @subscriber.subscribe(@config.name)



  onPublic: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "public"



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is @config.name



  isWorker: () =>
    Optimist.argv.mode? is true and Optimist.argv.mode is "worker"



  do: () =>
    return if not @isWorker()

    args = _.toArray(arguments)

    if args.length is 1
      [cb] = args
      return cb(@)

    if args.length is 2
      [name, cb] = args
      return cb(@) if @config.name is name
