# WWRPC

A WebWorker RPC bridge to allow easily spawning thread-like background processes or sandboxed code from within the browser.



## A Simple Example

In the following example we will create a protocol with a single function called `hello(name)` we will then spawn a new worker process with our protocol and then load some code into the worker process.

    var protocol = WWRPC.defineProtocol({
      hello: WWRPC.remote(function(name) {
        console.log("Hello "+name);
      })
    });

    var worker = WWRPC.spawnWorker(protocol);

    worker.loadCode(function() {
      hello('andy');
    });

It's important to note that WebWorkers don't actually support `console.log()`. This code only works because we have a bridge in place. This means that when you call `hello()` from within the worker you are actually calling a stub method which serialises your arguments and passes them back to the main process where th real hello method is called. Below is an alternaive version of the same thing that introduces the concept of Worker Local Functions.

    var protocol = WWRPC.defineProtocol({
      console: {
        log: WWRPC.remote(function(msg) { console.log(msg) })
      },
      hello: WWRPC.local(function(name) { console.log("Hello "+name) })
    });

    var worker = WWRPC.spawnWorker(protocol);

    worker.loadCode(function() {
      hello('andy');
    });

In the above example we defined a protocol comprised of 2 functions `console.log()` which is a remote function and `hello()` which is a Worker Local Function. when we call `hello()` in the Worker we are actually calling the real implementation of hello however this then calls `console.log()` which is a stub method and gets passed back to the main process for exection. Did you notice we just enabled `console.log()` calls from inside a WebWorker in a couple of lines?



## Remote Callbacks

Given the async nature of JavaScript often you need to fire a remote function that returns some data from the main process back to the worker. The RPC bridge transparently handles functions which take a final argument of a callback. The complexities are hidden away but here is a concrete example.

    var protocol = WWRPC.defineProtocol({
      getJSON: WWRPC.remote(function(url, done) {
        // assuming you have jquery required and available for this example...
        $.getJSON(url, done);
      })
    });

    var worker = WWRPC.spawnWorker(protocol);

    worker.loadCode(function() {
      getJSON('http://url.com', function(data) {
        console.log(data);
      });
    });