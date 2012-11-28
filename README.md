[![Build Status](https://travis-ci.org/zyndiecate/clustr-node.png)](https://travis-ci.org/zyndiecate/clustr-node)



# clustr-node

### That project is new and currently under development.

CoffeeScript cluster module to manage multi process cluster in NodeJs. Clustr is
responseable for worker spawning and messaging between all processes.



## install

```
npm install clustr-node
```



## usage

### require

To require the module, just do.
```coffeescript
Clustr = require("clustr-node")
```



### master

Create the master process.
```coffeescript
master = Clustr.Master.create
  name: "master"
```



The master is a normal process like all other workers. The only special thing
is that the master is able to receive confirmations. To listen to a confirmation
just do the following. As described, the callback is executed when the message
"identifier" was received 2 times.
```coffeescript
master.onConfirmation 2, "identifier", () =>
  # do something when message "identifier" was received 2 times
```

For more information see the next section `worker`.



### worker

Create a worker process.
```coffeescript
worker = Clustr.Worker.create
  name: "worker"
```



Public messages are send to each living process. To make a worker listen to
messages from the `public` channel do.
```coffeescript
worker.onPublic (message) =>
  # do something with public message when it was received
```



Private messages are for a specific role only that is defined by its `name`
property. To make a worker listen to private messages do.
```coffeescript
worker.onPrivate (message) =>
  # do something with private message when it was received
```



To make a worker publish a message to a channel do.
```coffeescript
worker.publish("channel", "message")
```



To make a worker publish a confirmation message do.
```coffeescript
worker.publish("confirmation", "message")
```



Each process is able to spawn workers, both, the `master` and `workers`.

- Spawning a worker __requires__ a `file` the worker should execute.
- __Optionally__ workers can be cpu bound. To do so, set `cpu` to one of your
cores (0, 1, 2, 3, etc.). Cpu affinity is set using the `taskset` command,
which only works under unix systems.
- __Optionally__ a process can be executed using a special `command`. Otherwise
the new process will be executed using the parents execution command.

To make a worker spawn workers, do
something like that.
```coffeescript
worker.spawn [
  { file: "./web_worker.coffee",   cpu: 1          }
  { file: "./web_worker.coffee",   cpu: 1          }
  { file: "./cache_worker.coffee", cpu: 2          }
  { file: "./cache_worker.coffee", cpu: 2          }
  { file: "./bashscript",          command: "bash" }
]
```



### examples

For examples take a look into the `examples/` directory and play around.



### tests

Tests are located in `spec/` directory. To run it just do.
```
npm test
```
