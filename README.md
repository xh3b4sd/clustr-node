[![Build Status](https://travis-ci.org/zyndiecate/clustr-node.png)](https://travis-ci.org/zyndiecate/clustr-node)



# clustr-node



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
  group: "worker"
```


__onPublic__

Public messages are send to each living process. To make a worker listen to
messages from the `public` channel do.
```coffeescript
worker.onPublic (message) =>
  # do something with public message when it was received
```



__onPrivate__

Private messages are for a specific worker only that is identified by its
`processId` property. To make a worker listen to private messages do.
```coffeescript
worker.onPrivate (message) =>
  # do something with private message when it was received
```



__onGroup__

Group messages are for a specific group only that is defined by its `group`
property. To make a worker listen to group messages do. Note that the master
is not able to receive group messages.
```coffeescript
worker.onGroup (message) =>
  # do something with group message when it was received
```



__onKill__

Before a worker dies, it is possible to do something before. Here it is
necessary to execute the `cb` given to the `onKill` method. If the callback is
not fired, the process will __not__ die. To let a worker do his last action
befor death do.
```coffeescript
worker.onKill (cb) =>
  # process last actions befor death
  cb()
```



__emitPublic__

To make a worker publish a public message do.
```coffeescript
worker.emitPublic("message")
```



__emitPrivate__

To make a worker publish a private message do.
```coffeescript
worker.emitPrivate("processId", "message")
```



__emitGroup__

To make a worker publish a group message do.
```coffeescript
worker.emitGroup("group", "message")
```



__emitConfirmation__

To make a worker publish a confirmation message do.
```coffeescript
worker.emitConfirmation("message")
```



__emitKill__

Each process is able to kill another. For that action you need to know the
unique `processId` of the worker you want to kill. `processId` here is __not__
the systems `pid`. Each valid `exitCode`, a process respects, can be send
(0, 1, etc.). `exitCode` defaults to 0. Killing a worker will terminate its
children too. So be careful by sending a kill signal to the master process.
That will terminate the whole cluster. To send an exit code to an worker do.
```coffeescript
worker.emitKill("processId", 0)
```



__spawn__

Each process is able to spawn workers, both, `master` and `worker`.

required:
- `file` defines the file a worker should execute.

optional:
- `cpu` set cpu affinity using the `taskset` command, which only works under unix systems.
- `command` defines the command that executes `file`. By default `file` will be executed using the parents execution command.
- `respawn` by default is set to `true`. To prevent respawning a worker set `respawn` to `false`.

To make a worker spawn workers, do something like that.
```coffeescript
worker.spawn [
  { file: "./web_worker.coffee",   cpu: 0                          }
  { file: "./web_worker.coffee",   cpu: 1                          }
  { file: "./cache_worker.coffee", cpu: 2,          respawn: false }
  { file: "./cache_worker.coffee", cpu: 3,          respawn: false }
  { file: "./bashscript",          command: "bash"                 }
]
```



### messages

If a process receives a message it looks something like that.
```coffeescript
message =
  meta:
    processId: PROCESS_ID
    group:     GROUP
  data:        YOUR_MESSAGE
```

Each meta item should be a string. The `processId` should not be provided if
the message was sent by the master. The data you send to a channel, using the
`publish` method, can be whatever is stringifyable. So you will be able to
receive what you send. Note that confirmation messages should only be simple
strings.



### examples

For examples take a look into the `examples/` directory and play around.



### tests

Tests are located in `spec/` directory. To run it just do.
```
npm test
```
