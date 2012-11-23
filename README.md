# clustr

### That project is new and currently under development.

CoffeeScript cluster module to manage multi process cluster in NodeJs. Clustr is
responseable for worker spawning and messaging between all processes.

## install

    npm install clustr

## usage

### require

To require the module, just do.

    Clustr = require("clustr")


### options

Before creating a new cluster, we have to define some options for it. To make
the master spawn 4 workers, you need to define the options as follows. The
`name` property is required.

```coffeescript
    options =
      master:
        { name: "master" }
      worker: [
        { name: "web" }
        { name: "web" }
        { name: "cache" }
        { name: "cache" }
      ]
```

Optionally workers can have the following properties.

  - `cpu` binds the worker to the specified cpu core (0, 1, 2, 3, etc.)
  - `respawn` tries to respawn the worker if process exit unexpectedly (exit code 0 let the worker die)

So you could define your workers like that.

```javascript
    options =
      master:
        { name: "master" }
      slaves: [
        { name: "web", cpu: 1, respawn: true }
        { name: "web", cpu: 2, respawn: true }
        { name: "cache" }
        { name: "cache" }
      ]
```

### creation

Create a new cluster is pretty simple.

    clustr  = Clustr.create(options)

### master

To make only the master do something, do as described below.

    clustr.master.do (master) =>
      # do something with master

Public messages are send to each living process. To make the master listen to
public messages do.

    master.onPublic (message) =>
      # do something with public message when it was received

Private messages are for a specific role only. To make the master listen to
private messages do.

    master.onPrivate (message) =>
      # do something with private message when it was received

The master is able to waiting for confirmations. To listen to a confirmation
just do the following. As described, the callback is executed when the message
"cache" was received 2 times.

    master.onConfirm 2, "cache", () =>
      # do something when message "cache" was received 2 times

To make the master publish a message do.

    master.publish("channel", "message")

### worker

Each process has a name. The process name represents a role. To make only
`cache` workers do something, do as described below.

    clustr.worker.do "cache", (cacheWorker) =>
      # do something with cacheWorker

Public messages are send to each living process. To make a worker listen to
public messages do.

    cacheWorker.onPublic (message) =>
      # do something with public message when it was received

Private messages are for a specific role only. To make each worker of a role
listen to private messages do.

    cacheWorker.onPrivate (message) =>
      # do something with private message when it was received

To make each worker of a role publish a message do.

    cacheWorker.publish("channel", "message")

To make each worker of a role publish a confirmation message do.

    cacheWorker.publish("confirm", "cache")

### workers

To make each worker do something, regardless of its role, do as described below.

    clustr.workers.do (workers) =>
      # do sonething with workers

To make each worker listen to messages all workers receive, regardless of their
role, do as described below.

    worker.onMessage (message) =>
      # do something with message

To make each worker publish a message, regardless of their role, do as described
below.

    slaves.publish("channel", "message")

### examples

For examples take a look into the `examples/` directory and play around.

### tests

comming soon :)
