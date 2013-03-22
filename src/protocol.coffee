class WWRPC.Protocol
  constructor: (@template) ->

  workerCode: ->
    data = JSON.stringify(@process(@template))
    """
      #{WWRPC.bridgeCode('__bridge__')}
      __bridge__.unpack(#{data}, self);
      __bridge__.init();
    """

  processLeaf: (leaf, context=[]) ->
    o = {}
    o[key] = @process(value, context.concat([key])) for key, value of leaf
    o

  process: (value, context=[]) ->
    return value.toRpcString(context) if value.constructor is WWRPC.RemoteFunction
    return value.toRpcString(context) if value.constructor is WWRPC.LocalFunction
    return @processLeaf(value, context) if typeof value is 'object'
    value

  call: (name, context, args, callback=null) ->
    fn = @findFn(name)
    throw new Error("Undefined RPC function #{name} called.") unless fn
    fn.run(context, args, callback)

  findFn: (name) ->
    parts = name.split('.')
    scope = @template
    scope = scope[part] for part in parts when scope isnt undefined
    scope

class WWRPC.RemoteFunction
  constructor: (@fn) -> null
  run: (context, args, callback) ->
    args.push(callback) unless callback is null
    @fn.apply(context, args)
  toRpcString: (context) ->
    """function() { __bridge__.call('#{context.join('.')}', Array.prototype.slice.apply(arguments)); }"""


class WWRPC.LocalFunction
  constructor: (@fn) -> null
  toRpcString: (context) -> @fn.toString()


