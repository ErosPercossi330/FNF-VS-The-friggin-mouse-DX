package jaxe;

import haxe.macro.Context;
import haxe.macro.Expr;

class ProxyMacro {
    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();
        var className = localClass.name;
        
        // Array to hold our newly generated _original_ methods
        var newFields:Array<Field> = [];

        for (field in fields) {
            switch (field.kind) {
                case FFun(f):
                    // Skip constructors because Haxe requires super() to be in very specific 
                    // places during instantiation. Proxying 'new' is usually a bad idea anyway.
                    if (f.expr == null || field.name == "new") continue;

                    var isVoid = false;
                    if (f.ret != null) {
                        switch (f.ret) {
                            case TPath(p) if (p.name == "Void"): isVoid = true;
                            default:
                        }
                    }

                    var funcName = field.name;
                    var originalFuncName = "_original_" + funcName;

                    // 1. Create a hidden copy of the original function
                    newFields.push({
                        name: originalFuncName,
                        access: [APrivate], // Drop 'override' or 'public', just make it private
                        kind: FFun({
                            args: f.args,
                            ret: f.ret,
                            expr: f.expr // The original AST, including any super() calls!
                        }),
                        pos: field.pos,
                        meta: [{name: ":noCompletion", pos: field.pos}] // Hide from code completion
                    });

                    // 2. Map the original arguments
                    var argExprs = f.args.map(function(arg) return macro $i{arg.name});

                    // 3. Rewrite the main function to pass `this` and the original function closure
                    if (isVoid) {
                        f.expr = macro {
                            if (ProxyManager.hasProxy($v{className}, $v{funcName})) {
                                ProxyManager.callProxy(this, $v{className}, $v{funcName}, [$a{argExprs}], this.$originalFuncName);
                                return;
                            }
                            this.$originalFuncName($a{argExprs});
                        };
                    } else {
                        f.expr = macro {
                            if (ProxyManager.hasProxy($v{className}, $v{funcName})) {
                                return ProxyManager.callProxy(this, $v{className}, $v{funcName}, [$a{argExprs}], this.$originalFuncName);
                            }
                            return this.$originalFuncName($a{argExprs});
                        };
                    }
                default:
            }
        }
        
        // Append our newly generated original functions to the class
        for (nf in newFields) fields.push(nf);
        return fields;
    }
}
