using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using static quickjs_Beef.quickjs;

namespace example;

static class Program
{
	static int Main(params String[] args)
	{
		JSRuntime* rt = JS_NewRuntime();
		defer JS_FreeRuntime(rt);

		JSContext* ctx = JS_NewContext(rt);
		defer JS_FreeContext(ctx);

		JSValue global = JS_GetGlobalObject(ctx);
		defer JS_FreeValue(ctx, global);

		JSCFunction myCallback = (ctx, val, argc, argv) =>
			{
				Debug.WriteLine("my callback");
				return .() { u = .() { int32 = (.)js_tag.JS_TAG_UNDEFINED }, tag = 0 };
			};

		let fn = JS_NewCFunction(ctx, myCallback, "test", 1);

		let prop = JS_SetPropertyStr(ctx, global, "test", fn);

		let script = "test()";

		JS_Eval(ctx, script, (.)script.Length, null, 0);

		if (JS_HasException(ctx))
		{
			let exc = JS_GetException(ctx);
			defer JS_FreeValue(ctx, exc);

			Debug.WriteLine(StringView(JS_ToCString(ctx, exc)));
		}

		String js = "console.log(\"hello world\")";

		JSValue val = JS_Eval(ctx, js.Ptr, (.)js.Length, null, 0);
		defer JS_FreeValue(ctx, val);

		char8* strval = JS_ToCString(ctx, val);

		return 0;
	}
}