package jaxe;

import haxe.macro.Context;
import haxe.macro.Expr;

class JaxeProxyMacro {
    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var newFields:Array<Field> = [];

        for (field in fields) {
            switch (field.kind) {
                case FFun(f):
                    // Skip empty functions, constructors, and already generated original functions
                    if (f.expr == null || field.name == "new" || StringTools.startsWith(field.name, "_original_")) continue;

                    var isVoid = false;
                    if (f.ret != null) {
                        switch (f.ret) {
                            case TPath(p) if (p.name == "Void"): isVoid = true;
                            default:
                        }
                    }

                    var funcName = field.name;
                    var originalFuncName = "_original_" + funcName;

                    // 1. Create a hidden copy of the original function (contains super calls)
                    newFields.push({
                        name: originalFuncName,
                        access: [APrivate],
                        kind: FFun({
                            args: f.args,
                            ret: f.ret,
                            expr: f.expr 
                        }),
                        pos: field.pos,
                        meta: [{name: ":noCompletion", pos: field.pos}, {name: ":dox", params: [macro hide], pos: field.pos}]
                    });

                    // 2. Map the original arguments
                    var argExprs = f.args.map(function(arg) return macro $i{arg.name});

                    // 3. Rewrite the compiled function to ask JaxeProxyManager first
                    if (isVoid) {
                        f.expr = macro {
                            if (jaxe.JaxeProxyManager.hasProxy(this, $v{funcName})) {
                                jaxe.JaxeProxyManager.callProxy(this, $v{funcName}, [$a{argExprs}]);
                                return;
                            }
                            this.$originalFuncName($a{argExprs});
                        };
                    } else {
                        f.expr = macro {
                            if (jaxe.JaxeProxyManager.hasProxy(this, $v{funcName})) {
                                return jaxe.JaxeProxyManager.callProxy(this, $v{funcName}, [$a{argExprs}]);
                            }
                            return this.$originalFuncName($a{argExprs});
                        };
                    }
                default:
            }
        }
        
        for (nf in newFields) fields.push(nf);
        return fields;
    }
}
  
