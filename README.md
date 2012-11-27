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



Public messages are send to each living process. To make the master listen to
public messages do.
```coffeescript
master.onPublic (message) =>
  # do something with public message when it was received
```



Private messages are for a specific role only that is defined by its name. To
make the master listen to private messages do.
```coffeescript
master.onPrivate (message) =>
  # do something with private message when it was received
```



The master is able to receive for confirmations. To listen to a confirmation
just do the following. As described, the callback is executed when the message
"identifier" was received 2 times.
```coffeescript
master.onConfirmation 2, "identifier", () =>
  # do something when message "identifier" was received 2 times
```



To make the master publish a message to a channel do.
```coffeescript
master.publish("channel", "message")
```



Each process is able to spawn workers. Spawning a worker requires a file the
worker should execute. Optionally workers can be cpu bound. Cpu affinity is set
using the `taskset` command, which only works under unix systems. To make the
master spawn workers, do something like that.
```coffeescript
master.spawn [
  { file: "./web_worker.coffee",   cpu: 1 }
  { file: "./web_worker.coffee",          }
  { file: "./cache_worker.coffee", cpu: 2 }
  { file: "./cache_worker.coffee",        }
]
```



### worker

Create a worker process.
```coffeescript
worker = Clustr.Worker.create
  name: "worker"
```



Public messages are send to each living process. To make a worker listen to
public messages do.
```coffeescript
worker.onPublic (message) =>
  # do something with public message when it was received
```



Private messages are for a specific role only that is defined by its name. To
make a worker listen to private messages do.
```coffeescript
worker.onPrivate (message) =>
  # do something with private message when it was received
```



To make a worker publish a message to a channel do.
```coffeescript
worker.publish("channel", "message")
```



Each process is able to spawn workers. Spawning a worker requires a file the
worker should execute. Optionally workers can be cpu bound. Cpu affinity is set
using the `taskset` command, which only works under unix systems. To make a
worker spawn workers, do something like that.
```coffeescript
worker.spawn [
  { file: "./web_worker_child.coffee",   cpu: 1 }
  { file: "./web_worker_child.coffee",          }
  { file: "./cache_worker_child.coffee", cpu: 2 }
  { file: "./cache_worker_child.coffee",        }
]
```



### examples

For examples take a look into the `examples/` directory and play around.



### tests

Tests are located in `spec/` directory. To run it just do.
```
npm test
```
