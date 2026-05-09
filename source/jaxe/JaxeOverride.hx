package jaxe;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import jaxe.JaxeConfig;

using Lambda;
using StringTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;

class JaxeOverride
{
	public static macro function build():Array<Field>
	{
		var cls:ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();
		
		var pack = cls.pack.join(".");
		var fullClassName = (pack.length > 0 ? pack + "." : "") + cls.name;

		for (ignored in JaxeConfig.DISALLOW_OVERRIDE_CLASSES) {
			if (fullClassName.startsWith(ignored) || cls.name.startsWith(ignored)) return fields;
		}

		if (cls.meta.has(':jaxeProcessed')) return fields;
		cls.meta.add(":jaxeProcessed", [], cls.pos);

		var utils = buildJaxeUtils(cls);
		fields = fields.concat(utils);

		fields = buildJaxeOverrides(cls, fields);

		return fields;
	}

	static function buildJaxeUtils(cls:ClassType):Array<Field>
	{
		return [{
			name: '_jaxeFunctions',
			access: [APublic],
			kind: FVar(macro :Map<String, haxe.Constraints.Function>, macro new Map<String, haxe.Constraints.Function>()),
			pos: cls.pos
		}];
	}

	static function parentHasField(cls:ClassType, fieldName:String):Bool {
		var cl = cls.superClass;
		while (cl != null) {
			var t = cl.t.get();
			for (f in t.fields.get()) {
				if (f.name == fieldName) return true;
			}
			cl = t.superClass;
		}
		return false;
	}

	static function buildJaxeOverrides(cls:ClassType, fields:Array<Field>):Array<Field>
	{
		var fieldDone:Array<String> = [for (f in fields) f.name];
		var fieldArray:Array<Field> = [];
		var targetClass:ClassType = cls;
		var mappedParams:Map<String, Type> = new Map<String, Type>();

		while (targetClass != null)
		{
			for (field in targetClass.fields.get())
			{
				if (field.name == 'new') continue;
				if (fieldDone.contains(field.name)) continue;

				var results = overrideField(cls, field, mappedParams);
				for (result in results) {
					fieldArray.push(result);
					fieldDone.push(result.name);
				}
			}
			
			if (targetClass.superClass != null)
			{
				var targetParams = targetClass.superClass.params;
				targetClass = targetClass.superClass.t.get();
				for (i in 0...targetClass.params.length)
				{
					mappedParams.set('${targetClass.pack.join('.')}.${targetClass.name}.${targetClass.params[i].name}', targetParams[i]);
				}
			}
			else
			{
				targetClass = null;
			}
		}

		return fields.concat(fieldArray);
	}

	static function overrideField(localClass:ClassType, field:ClassField, params:Map<String, Type>):Array<Field>
	{
		var type = Context.follow(field.type);
		switch (type)
		{
			case TLazy(lt):
				return [];
			case TFun(args, ret):
				if (field.isFinal || field.name.startsWith("__")) return [];
				
				for (arg in args) {
					switch (arg.t) {
						case TInst(ty, pa):
							var typ = ty.get();
							if (typ != null && typ.isPrivate) return [];
						default:
					}
				}

				switch (field.kind) {
					case FMethod(k):
						if (k == MethInline) return [];
					default:
				}

				for (m in field.meta.get()) if (m.name == ":generic") return [];

				var func_access = [field.isPublic ? APublic : APrivate];
				if (parentHasField(localClass, field.name)) func_access.push(AOverride);

				var func_inputArgs:Array<FunctionArg> = [
					for (arg in args) {
						name: arg.name,
						opt: arg.opt,
						type: Context.toComplexType(deparameterizeType(arg.t, params))
					}
				];

				var callArgs:Array<Expr> = [for (arg in args) macro $i{arg.name}];
				var isVoid = ret.toString() == "Void";
				var func_ret = isVoid ? (macro :Void) : Context.toComplexType(deparameterizeType(ret, params));
				var name = field.name;
				var superName = 'super_' + name;

				var superAccess = [APublic];
				if (parentHasField(localClass, superName)) superAccess.push(AOverride);

				var superCallExpr = isVoid ? macro super.$name($a{callArgs}) : macro return super.$name($a{callArgs});
				var superCall:Field = {
					name: superName,
					access: superAccess,
					meta: [{name: ":keep", pos: field.pos}],
					kind: FFun({
						args: func_inputArgs,
						ret: func_ret,
						expr: superCallExpr
					}),
					pos: field.pos
				};

				var fallbackExpr = isVoid ? macro $i{superName}($a{callArgs}) : macro return $i{superName}($a{callArgs});
				var jaxeExpr = isVoid ? macro Reflect.callMethod(this, func, [$a{callArgs}]) : macro return Reflect.callMethod(this, func, [$a{callArgs}]);

				var over:Field = {
					name: name,
					access: func_access,
					meta: [{name: ":keep", pos: field.pos}],
					kind: FFun({
						args: func_inputArgs,
						ret: func_ret,
						expr: macro {
							if (_jaxeFunctions.exists($v{name})) {
								var func = _jaxeFunctions.get($v{name});
								$jaxeExpr;
							} else {
								$fallbackExpr;
							}
						}
					}),
					pos: field.pos
				};

				return [superCall, over];
			default:
				return [];
		}
	}

	static function deparameterizeType(targetType:Type, targetParams:Map<String, Type>):Type
	{
		var resultType = targetType;
		switch (targetType)
		{
			case TFun(args, ret):
				var retType = deparameterizeType(ret, targetParams);
				var argTypes = args.map(function(arg) return {
					name: arg.name, opt: arg.opt, t: deparameterizeType(arg.t, targetParams)
				});
				resultType = TFun(argTypes, retType);
			case TAbstract(ty, params):
				var typeName = ty.toString();
				if (targetParams.exists(typeName)) {
					resultType = targetParams.get(typeName);
				} else if (params.length != 0) {
					var oldParams:Array<Type> = [];
					var newParams:Array<Type> = [];
					for (param in params) {
						var baseTypes = scanBaseTypes(param);
						for (baseType in baseTypes) {
							var newParam = deparameterizeType(baseType, targetParams);
							if (newParam.toString() != "Void") {
								oldParams.push(baseType);
								newParams.push(newParam);
							}
						}
					}
					var baseParams = getBaseParamsOfType(resultType, oldParams);
					newParams = newParams.slice(0, baseParams.length);
					if (newParams.length > 0) resultType = resultType.applyTypeParameters(baseParams, newParams);
				}
			case TInst(ty, params):
				var typeName = ty.toString();
				if (targetParams.exists(typeName)) {
					resultType = targetParams.get(typeName);
				} else if (params.length != 0) {
					var oldParams:Array<Type> = [];
					var newParams:Array<Type> = [];
					for (param in params) {
						var baseTypes = scanBaseTypes(param);
						for (baseType in baseTypes) {
							var newParam = deparameterizeType(baseType, targetParams);
							if (newParam.toString() != "Void") {
								oldParams.push(baseType);
								newParams.push(newParam);
							}
						}
					}
					var baseParams = getBaseParamsOfType(resultType, oldParams);
					newParams = newParams.slice(0, baseParams.length);
					if (newParams.length > 0) resultType = resultType.applyTypeParameters(baseParams, newParams);
				}
			default:
		}
		return resultType;
	}

	static function getBaseParamsOfType(parentType:Type, paramTypes:Array<Type>):Array<haxe.macro.Type.TypeParameter>
	{
		var parentParams:Array<haxe.macro.Type.TypeParameter> = [];
		switch (parentType) {
			case TMono(t): return getBaseParamsOfType(t.get(), paramTypes);
			case TInst(t, params): parentParams = t.get().params;
			case TType(t, params): return getBaseParamsOfType(t.get().type, paramTypes);
			case TDynamic(t): return getBaseParamsOfType(t, paramTypes);
			case TLazy(f): return getBaseParamsOfType(f(), paramTypes);
			case TAbstract(t, _params): parentParams = t.get().params;
			default: return [];
		}

		var result:Array<haxe.macro.Type.TypeParameter> = [];
		for (i => parentParam in parentParams) {
			result.push({ name: parentParam.name, t: paramTypes[i] });
		}
		return result;
	}

	static function scanBaseTypes(targetType:Type):Array<Type>
	{
		switch (targetType) {
			case TFun(args, ret):
				var results:Array<Type> = [];
				for (result in scanBaseTypes(ret)) results.push(result);
				for (arg in args) for (result in scanBaseTypes(arg.t)) results.push(result);
				return results;
			case TAbstract(ty, params):
				if (params.length == 0) return [targetType];
				var results:Array<Type> = [];
				for (param in params) for (result in scanBaseTypes(param)) results.push(result);
				return results;
			default: return [targetType];
		}
	}
}
