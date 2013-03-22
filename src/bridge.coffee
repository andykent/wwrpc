WWRPC.BRIDGE = ->
  WAITING_CALLBACKS: []

  unpack: (obj, binding={}) ->
    for key, value of obj
      if typeof value is 'object'
        binding[key] = @unpack(value)
      else if typeof value is 'string' and value.search(/^function/) is 0
        binding[key] = eval("(" + value + ")")
      else
        binding[key] = value
    binding

  init: ->
    addEventListener 'message', (e) => @process(e.data)

  process: (data) ->
    switch data.action
      when 'wwrpc:run'
        eval("(" + data.code + ")()")
      when 'wwrpc:callback'
        @runCallback(data.callbackId, data.args)

  runCallback: (id, args) ->
    @WAITING_CALLBACKS[id].apply(args, args)

  queueCallback: (fn) ->
    @WAITING_CALLBACKS.push(fn)
    @WAITING_CALLBACKS.length - 1

  call: (name, args=[]) ->
    callbackId = null
    if args.length > 0 and typeof args[args.length-1] is 'function'
      callbackId = @queueCallback(args.pop())
    postMessage(action:"wwrpc:call", name:name, args:args, callbackId:callbackId)