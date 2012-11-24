_        = require("underscore")
Redis    = require("redis")
Optimist = require("optimist")

class exports.Workers
  constructor: (config) ->
    return if not @isWorker()

    @config     = Optimist.argv
    @publisher  = config.workers[@config.id].publisher or Redis.createClient()
    @subscriber = config.workers[@config.id].subscriber or Redis.createClient()



  @create: (config) =>
    new Workers(config)



  setup: () =>
    @subscribe()



  isWorker: () =>
    @config ?= Optimist.argv
    @config.mode? is true and @config.mode is "worker"



  do: () =>
    return if not @isWorker()

    args = _.toArray(arguments)

    if args.length is 1
      [cb] = args
      return cb(@)

    if args.length is 2
      [name, cb] = args
      return cb(@) if @config.name is name



  publish: (channel, message) =>
    @publisher.publish(channel, message)



  # workers specific



  subscribe: () =>
    @subscriber.subscribe("workers")



  onMessage: (cb) =>
    @subscriber.on "message", (channel, message) =>
      cb(message) if channel is "workers"
