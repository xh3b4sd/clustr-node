Uuid    = require("node-uuid")
Process = require("./process").Process

class exports.Worker extends Process
  constructor: (@config = {}) ->
    # check worker file
    return @missingGroupName() if not @config.group?

    @workerId = @config?.uuid?.v4() or Uuid.v4()
    @channels = [ @workerId, @config.group, "kill:#{@workerId}", "public" ]

    @setup()
    @onKill()



  @create: (config) =>
    new Worker(config)



  onKill: () =>
    @subscriber.on "message", (channel, payload) =>
      message = JSON.parse(payload)
      # console.log("#{message.meta.group} kill #{@config.group} - exit code: #{message.data}")
      process.exit(message.data) if channel is "kill:#{@workerId}"



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      cb(JSON.parse(payload)) if channel is @workerId



  onGroup: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      cb(JSON.parse(payload)) if channel is @config.group



  missingGroupName: () =>
    throw new Error("group name is missing")
