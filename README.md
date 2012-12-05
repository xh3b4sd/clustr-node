[![Build Status](https://travis-ci.org/zyndiecate/clustr-node.png)](https://travis-ci.org/zyndiecate/clustr-node)



# clustr-node



## facts

- each worker register to the cluster on process start
- each worker deregister from the cluster on process end
- each worker is able to spawn new processes
- each worker is able to talk with each cluster member
- each worker is able to kill workers
- each worker is able to fetch cluster info
- each worker has a stats object containing event statistics of its own process
- each worker knows the `pid` of the master process
- cluster dies when master receives `SIGHUP` (exit code 1)
- cluster dies when master receives signal from `emitKill`



## install

```bash
npm install clustr-node
```



## dependencies

- `clustr` uses [pubsub](http://redis.io/topics/pubsub) for ipc, so you have to run a `redis` server on your machine.
- `clustr` uses [taskset](http://www.unix.com/man-page/Linux/1/taskset/) for cpu affinity, so `clustr` should be used on `unix` systems.



## usage

### require

To require the module, just do.
```coffeescript
Clustr = require("clustr-node")
```



### create

Create a master process.
```coffeescript
master = Clustr.Master.create()
```



Create a worker process.
```coffeescript
worker = Clustr.Worker.create
  group: "worker"
```



### groups

Workers can be in every possible group you can imagine. There is just one
special group. The `master` group. Also there may should be only one worker
in the `master` group.



### onPublic

Public messages are send to each living process. To make a worker listen to
messages from the `public` channel do.
```coffeescript
worker.onPublic (message) =>
  # do something with public message when it was received
```



### onPrivate

Private messages are for a specific worker only that is identified by its
`pid` property. To make a worker listen to private messages do.
```coffeescript
worker.onPrivate (message) =>
  # do something with private message when it was received
```



### onGroup

Group messages are for a specific group only that is defined by its `group`
property. To make a worker listen to group messages do.
```coffeescript
worker.onGroup (message) =>
  # do something with group message when it was received
```



### onKill

Before a worker dies, it is possible to do something before. Here it is
necessary to execute the `cb` given to the `onKill` method. If the callback is
not fired, the process will __not__ die. To let a worker do his last action
befor death do.
```coffeescript
worker.onKill (cb) =>
  # process last actions befor death
  cb()
```



### onConfirmation

Worker are able to receive confirmations. To listen to a confirmation just do
the following. As described, the callback is executed when the message
"identifier" was received 2 times. Also, `messages` provided by the callback
contains meta data of all confirmed workers.
```coffeescript
worker.onConfirmation 2, "identifier", (messages) =>
  # do something when messages "identifier" was received 2 times
```



### emitPublic

To make a worker publish a public message do.
```coffeescript
worker.emitPublic("message")
```



### emitPrivate

To make a worker publish a private message do.
```coffeescript
worker.emitPrivate("pid", "message")
```



### emitGroup

To make a worker publish a group message do.
```coffeescript
worker.emitGroup("group", "message")
```



### emitKill

Each process is able to kill another. For that action you need to know the
unique `pid` of the worker you want to kill. `pid` here __is__
the systems `pid`. Each valid `exitCode`, a process respects, can be send
(0, 1, etc.). `exitCode` defaults to 0. Killing a worker will terminate its
children too. So be careful by sending a kill signal to the master process.
That will terminate the whole cluster. To send an exit code to an worker do.
```coffeescript
worker.emitKill("pid", 0)
```



### emitConfirmation

To make a worker publish a confirmation message do.
```coffeescript
worker.emitConfirmation("message")
```



### emitClusterInfo

Workers are able to receive cluster infos like that. See also the
[clusterInfo](https://github.com/zyndiecate/clustr-node#clusterinfo) section.
```coffeescript
webWorkerChild.emitClusterInfo (message) =>
  # do something with cluster info when it was received
```



### spawn

Each process is able to spawn workers.

required:
- `file` defines the file a worker should execute.

optional:
- `cpu` set cpu affinity using the `taskset` command, which only works under unix systems.
- `command` defines the command that executes `file`. By default `file` will be executed using the parents execution command.
- `respawn` by default is set to `true`. To prevent respawning a worker set `respawn` to `false`.
- `args` an object of command line args that will be given to a process.

To make a worker spawn workers, do something like that.
```coffeescript
worker.spawn [
  { file: "./web_worker.coffee",   cpu: 0 }
  { file: "./web_worker.coffee",   cpu: 1, args: { "cluster-option": "foo", private: "option" } }
  { file: "./cache_worker.coffee", cpu: 2, respawn: false }
  { file: "./cache_worker.coffee", cpu: 3, respawn: false }
  { file: "./bashscript", command: "bash" }
]
```



### masterPid

The master process id is available for each worker. It will be bubbled through
the cluster. So all workers are always able to talk with the master like that.
```coffeescript
worker.emitPrivate(worker.masterPid, "message")
```



### messages

If a process receives a message it looks something like that. Each meta item
should be a string. The data you send can be whatever is stringifyable. So you
will be able to receive what you send. Note that confirmation messages should
only be simple strings.
```coffeescript
message =
  meta:
    pid:   PROCESS_ID
    group: GROUP
  data:    YOUR_MESSAGE
```



### stats

Each worker has a stats object containing event statistics with the following
properties.
- `emitPublic`
- `emitPrivate`
- `emitGroup`
- `emitKill`
- `emitConfirmation`
- `onMessage`
- `onPublic`
- `onGroup`
- `onPrivate`
- `spawnChildProcess`
- `respawnChildProcess`
- `receivedConfirmations`
- `successfulConfirmations`



### clusterInfo

The `clusterInfo` object could look something like that. It contains lists of
cluster process ids grouped by the current cluster group names.
```coffeescript
clusterInfo =
  webWorker:   [ 5182, 5184 ]
  cacheWorker: [ 5186, 5188 ]
```



### argv

Command line argument parsing is realized using the
[optimist](https://github.com/substack/node-optimist) library. Arguments by
default are used by the given process. To bubble arguments through each process
of the cluster, prefix command line options with `cluster-`. See the
[examples](https://github.com/zyndiecate/clustr-node#examples) section, where
`--cluster-verbose` is given to each spawned child process, to enable logging
for the whole cluster. So, if you start the cluster just using `--verbose`,
only the master is able to log. Also, if you set a cluster option to a spawned
worker definition using the `args` property, each children of that worker will
receive that option too.



### logging

By default the cluster do not log any information. To make the master log its
own output, add `--verbose` to the execution command. To enable logging for the
whole cluster, add `--cluster-verbose` to the execution command.



### examples

For examples take a look into the `examples/` directory and play around.
```coffeescript
coffee examples/master.coffee --cluster-verbose
```



### tests

Tests are located in `spec/` directory. To run it just do.
```bash
npm test
```
