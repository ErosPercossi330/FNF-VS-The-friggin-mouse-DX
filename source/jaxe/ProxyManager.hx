package jaxe;

class ProxyManager {
    public static var proxies:Map<String, Map<String, Dynamic>> = new Map();

    public static function addProxy(className:String, funcName:String, func:Dynamic):Void {
        if (!proxies.exists(className)) proxies.set(className, new Map());
        proxies.get(className).set(funcName, func);
    }

    public static function hasProxy(className:String, funcName:String):Bool {
        return proxies.exists(className) && proxies.get(className).exists(funcName);
    }

    // Notice the new arguments: `instance` and `originalFunc`
    public static function callProxy(instance:Dynamic, className:String, funcName:String, args:Array<Dynamic>, originalFunc:Dynamic):Dynamic {
        var proxyFunc = proxies.get(className).get(funcName);
        
        // Prepend the instance and the original function to the arguments list.
        // Your scripts will now always receive `(instance, original, ...args)`
        var callArgs = [instance, originalFunc].concat(args);
        
        return Reflect.callMethod(null, proxyFunc, callArgs);
    }
}
