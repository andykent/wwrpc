class WWRPC.Worker
  constructor: (@protocol, @context={}) ->
    @blob = new Blob([@protocol.workerCode(@context)], { "type" : "text/javascript" })
    @start()

  process: (data) ->
    switch data.action
      when 'wwrpc:call'
        @protocol.call(data.name, @context, data.args, @buildCallback(data.callbackId))

  buildCallback: (id) ->
    return null if id is null
    =>
      return unless @worker
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
    @worker = new window.Worker(@blobURL())
    @worker.addEventListener('message', (e) => @process(e.data))

  loadCode: (code) ->
    @worker.postMessage(action:'wwrpc:run', code:code.toString())

  blobURL: ->
    if window.URL
      window.URL.createObjectURL(@blob)
    else
      window.webkitURL.createObjectURL(@blob)