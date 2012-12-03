class exports.Listener
  onPublic: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++
      return if channel isnt "public"

      cb(JSON.parse(payload))
      @stats.onPublic++



  onPrivate: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++
      return if channel isnt "private:#{@processId}"

      cb(JSON.parse(payload))
      @stats.onPrivate++



  onGroup: (cb) =>
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++
      return if channel isnt "group:#{@config.group}"

      cb(JSON.parse(payload))
      @stats.onGroup++



  onConfirmation: (requiredMessages, identifier, cb) =>
    received = 0
    @subscriber.on "message", (channel, payload) =>
      @stats.onMessage++

      message = JSON.parse(payload)
      return if channel      isnt "confirmation"
      return if message.data isnt identifier

      @stats.receivedConfirmations++

      return if ++received < requiredMessages

      received = 0
      cb(message)
      @stats.successfulConfirmations++



  onKill: (cb) =>
    @onKillCb = cb



  onKillCb: (cb) =>
    cb()
