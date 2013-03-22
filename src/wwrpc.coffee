window.WWRPC = WWRPC = {}

WWRPC.defineProtocol = (p) -> new WWRPC.Protocol(p)
WWRPC.spawnWorker = (protocol) -> new WWRPC.Worker(protocol)

WWRPC.remote = (fn) -> new WWRPC.RemoteFunction(fn)
WWRPC.local = (fn) -> new WWRPC.LocalFunction(fn)

WWRPC.bridgeCode = (name) -> """var #{name} = (#{WWRPC.BRIDGE.toString()})();"""