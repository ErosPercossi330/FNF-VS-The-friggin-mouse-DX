package jaxe;

import haxe.ds.ObjectMap;

class JaxeProxyManager {
    // Maps a specific object instance to a map of method names -> JaxeInterp
    public static var instanceProxies:ObjectMap<Dynamic, Map<String, JaxeInterp>> = new ObjectMap();

    /**
     * Called by JaxeInterp to register a script override for a specific object instance.
     */
    public static function addInstanceProxy(instance:Dynamic, methodName:String, interp:JaxeInterp):Void {
        var methodMap = instanceProxies.get(instance);
        if (methodMap == null) {
            methodMap = new Map<String, JaxeInterp>();
            instanceProxies.set(instance, methodMap);
        }
        methodMap.set(methodName, interp);
    }

    /**
     * Checked by the injected macro at the start of every compiled function.
     */
    public static function hasProxy(instance:Dynamic, methodName:String):Bool {
        var methodMap = instanceProxies.get(instance);
        return methodMap != null && methodMap.exists(methodName);
    }

    /**
     * Executes the script method via JaxeInterp.
     */
    public static function callProxy(instance:Dynamic, methodName:String, args:Array<Dynamic>):Dynamic {
        var methodMap = instanceProxies.get(instance);
        var interp = methodMap.get(methodName);

        // Temporarily ensure the interp's context is set to this specific instance
        var prevObj = interp.extendedObject;
        interp.extendedObject = instance;

        var result = interp.call(methodName, args);

        // Restore context
        interp.extendedObject = prevObj;
        return result;
    }
}
