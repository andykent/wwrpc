class WWRPC.Worker
  constructor: (@protocol, @context=this) ->
    @blob = new Blob([@protocol.workerCode()], { "type" : "text/javascript" })
    @start()

  process: (data) ->
    console.log data
    switch data.action
      when 'wwrpc:call'
        @protocol.call(data.name, @context, data.args, @buildCallback(data.callbackId))

  buildCallback: (id) ->
    return null if id is null
    =>
      @worker.postMessage
        action: 'wwrpc:callback'
        callbackId: id
        args: Array.prototype.slice.apply(arguments)

  terminate: ->
    @worker.terminate()
    @worker = null

  on: (eventName, fn) ->

  trigger: (eventName) ->

  start: ->
    @worker = new window.Worker(window.URL.createObjectURL(@blob))
    @worker.addEventListener('message', (e) => @process(e.data))

  loadCode: (code) ->
    console.log "loading code", code.toString()
    @worker.postMessage(action:'wwrpc:run', code:code.toString())
