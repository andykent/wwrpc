class WWRPC.Protocol
  constructor: (@template) ->

  workerCode: (context) ->
    data = JSON.stringify(@process(@template, context))
    """
      #{WWRPC.bridgeCode('__bridge__')}
      __bridge__.unpack(#{data}, self);
      __bridge__.init();
    """

  processLeaf: (leaf, context, tree=[]) ->
    o = {}
    o[key] = @process(value, context, tree.concat([key])) for key, value of leaf
    console.log o
    o

  process: (value, context, tree=[]) ->
    return value.resultForContext(context) if value.constructor is WWRPC.PassFunction
    return value.toRpcString(tree) if value.constructor is WWRPC.RemoteFunction
    return value.toRpcString(tree) if value.constructor is WWRPC.LocalFunction
    return @processLeaf(value, context, tree) if typeof value is 'object'
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


class WWRPC.PassFunction
  constructor: (@fn) -> null
  resultForContext: (context) -> @fn.apply(context, context)


