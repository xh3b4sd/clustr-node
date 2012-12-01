Process = require("./process").Process

class exports.Master extends Process
  constructor: (@config = {}) ->

    @setup()



  @create: (config) =>
    new Master(config)



  #
  # listener
  #
