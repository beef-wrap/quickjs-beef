/*
* QuickJS Javascript Engine
*
* Copyright (c) 2017-2024 Fabrice Bellard
* Copyright (c) 2017-2024 Charlie Gordon
* Copyright (c) 2023-2025 Ben Noordhuis
* Copyright (c) 2023-2025 Saúl Ibarra Corretgé
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

using System;
using System.Interop;

namespace quickjs_Beef;

public static class quickjs
{
	typealias FILE = void*;
	typealias char = char8;
	typealias size_t = uint;

	typealias uint8_t = uint8;
	typealias uint16_t = uint16;
	typealias uint32_t = uint32;
	typealias uint64_t = uint64;
	typealias uintptr_t = uint64;

	typealias int8_t = int8;
	typealias int16_t = int16;
	typealias int32_t = int32;
	typealias int64_t = int64;

	public struct JSRuntime;
	public struct JSContext;
	public struct JSObject;
	public struct JSClass;
	typealias JSClassID = uint32_t;
	typealias JSAtom = uint32_t;

	/* Unless documented otherwise, C string pointers (`char* ` or `char* `) are assumed to verify these constraints:
	- unless a length is passed separately, the string has a null terminator
	- string contents is either pure ASCII or is UTF-8 encoded.
	 */

	[AllowDuplicates]
	public enum js_tag : c_int
	{
		/* all tags with a reference count are negative */
		JS_TAG_FIRST       = -9, /* first negative tag */
		JS_TAG_BIG_INT     = -9,
		JS_TAG_SYMBOL      = -8,
		JS_TAG_STRING      = -7,
		JS_TAG_MODULE      = -3, /* used internally */
		JS_TAG_FUNCTION_BYTECODE = -2, /* used internally */
		JS_TAG_OBJECT      = -1,

		JS_TAG_INT         = 0,
		JS_TAG_BOOL        = 1,
		JS_TAG_NULL        = 2,
		JS_TAG_UNDEFINED   = 3,
		JS_TAG_UNINITIALIZED = 4,
		JS_TAG_CATCH_OFFSET = 5,
		JS_TAG_EXCEPTION   = 6,
		JS_TAG_FLOAT64     = 7,
		/* any larger tag is FLOAT64 if JS_NAN_BOXING */
	}

	// #define JSValueConst JSValue /* For backwards compatibility. */

	// #if defined(JS_NAN_BOXING) && JS_NAN_BOXING

	//typealias JSValue = uint64_t;

	// #define JS_VALUE_GET_TAG(v) (c_int)((v) >> 32)
	// #define JS_VALUE_GET_INT(v) (c_int)(v)
	// #define JS_VALUE_GET_BOOL(v) (c_int)(v)
	// #define JS_VALUE_GET_PTR(v) (void* )(intptr_t)(v)

	// #define JS_MKVAL(tag, val) (((uint64_t)(tag) << 32) | (uint32_t)(val))
	// #define JS_MKPTR(tag, ptr) (((uint64_t)(tag) << 32) | (uintptr_t)(ptr))

	// #define JS_FLOAT64_TAG_ADDEND (0x7ff80000 - JS_TAG_FIRST + 1) /* quiet NaN encoding */

	[CRepr, Union] public struct JSValueUnion
	{
		public int32_t int32;
		public double float64;
		public void* ptr;
	}

	[CRepr] public struct JSValue
	{
		public JSValueUnion u;
		public int64_t tag;
	}

	/*

	#define JS_VALUE_IS_BOTH_INT(v1, v2) ((JS_VALUE_GET_TAG(v1) | JS_VALUE_GET_TAG(v2)) == 0)
	#define JS_VALUE_IS_BOTH_FLOAT(v1, v2) (JS_TAG_IS_FLOAT64(JS_VALUE_GET_TAG(v1)) && JS_TAG_IS_FLOAT64(JS_VALUE_GET_TAG(v2)))

	#define JS_VALUE_GET_OBJ(v) ((JSObject* )JS_VALUE_GET_PTR(v))
	#define JS_VALUE_HAS_REF_COUNT(v) ((unsigned)JS_VALUE_GET_TAG(v) >= unsigned)JS_TAG_FIRST)

	/* special values */
	#define JS_NULL      JS_MKVAL(JS_TAG_NULL, 0)
	#define JS_UNDEFINED JS_MKVAL(JS_TAG_UNDEFINED, 0)
	#define JS_FALSE     JS_MKVAL(JS_TAG_BOOL, 0)
	#define JS_TRUE      JS_MKVAL(JS_TAG_BOOL, 1)
	#define JS_EXCEPTION JS_MKVAL(JS_TAG_EXCEPTION, 0)
	#define JS_UNINITIALIZED JS_MKVAL(JS_TAG_UNINITIALIZED, 0)

	*/

	/* flags for object properties */
	const c_int JS_PROP_CONFIGURABLE  = 1 << 0;
	const c_int JS_PROP_WRITABLE      = 1 << 1;
	const c_int JS_PROP_ENUMERABLE    = 1 << 2;
	const c_int JS_PROP_C_W_E         = JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE | JS_PROP_ENUMERABLE;
	const c_int JS_PROP_LENGTH        = 1 << 3; /* used internally in Arrays */
	const c_int JS_PROP_TMASK         = 3 << 4; /* mask for NORMAL, GETSET, VARREF, AUTOINIT */
	const c_int JS_PROP_NORMAL         = 0 << 4;
	const c_int JS_PROP_GETSET         = 1 << 4;
	const c_int JS_PROP_VARREF         = 2 << 4; /* used internally */
	const c_int JS_PROP_AUTOINIT       = 3 << 4; /* used internally */

	/* flags for JS_DefineProperty */
	const c_int JS_PROP_HAS_SHIFT       =  8;
	const c_int JS_PROP_HAS_CONFIGURABLE = 1 << 8;
	const c_int JS_PROP_HAS_WRITABLE     = 1 << 9;
	const c_int JS_PROP_HAS_ENUMERABLE   = 1 << 10;
	const c_int JS_PROP_HAS_GET          = 1 << 11;
	const c_int JS_PROP_HAS_SET          = 1 << 12;
	const c_int JS_PROP_HAS_VALUE        = 1 << 13;

	/* throw an exception if false would be returned
	(JS_DefineProperty/JS_SetProperty) */
	const c_int JS_PROP_THROW            = 1 << 14;

	/* throw an exception if false would be returned in strict mode
	(JS_SetProperty) */
	const c_int JS_PROP_THROW_STRICT     = 1 << 15;

	const c_int JS_PROP_NO_ADD           = 1 << 16; /* internal use */
	const c_int JS_PROP_NO_EXOTIC        = 1 << 17; /* internal use */
	const c_int JS_PROP_DEFINE_PROPERTY  = 1 << 18; /* internal use */
	const c_int JS_PROP_REFLECT_DEFINE_PROPERTY = 1 << 19; /* internal use */

#if !JS_DEFAULT_STACK_SIZE
	const c_int JS_DEFAULT_STACK_SIZE = 1024 *  1024;
#endif

	/* JS_Eval() flags */
	const c_int JS_EVAL_TYPE_GLOBAL   = 0 << 0; /* global code (default) */;
	const c_int JS_EVAL_TYPE_MODULE   = 1 << 0; /* module code */;
	const c_int JS_EVAL_TYPE_DIRECT   = 2 << 0; /* direct call (internal use) */;
	const c_int JS_EVAL_TYPE_INDIRECT = 3 << 0; /* indirect call (internal use) */;
	const c_int JS_EVAL_TYPE_MASK     = 3 << 0;

	const c_int JS_EVAL_FLAG_STRICT   = 1 << 3; /* force 'strict' mode */;
	const c_int JS_EVAL_FLAG_UNUSED   = 1 << 4; /* unused */;

	/* compile but do not run. The result is an object with a
	JS_TAG_FUNCTION_BYTECODE or JS_TAG_MODULE tag. It can be executed
	with JS_EvalFunction(). */
	const c_int JS_EVAL_FLAG_COMPILE_ONLY = 1 << 5;

	/* don't include the stack frames before this eval in the Error() backtraces */
	const c_int JS_EVAL_FLAG_BACKTRACE_BARRIER = 1 << 6;

	/* allow top-level await in normal script. JS_Eval() returns a
	promise. Only allowed with JS_EVAL_TYPE_GLOBAL */
	const c_int JS_EVAL_FLAG_ASYNC = 1 << 7;

	public function JSValue JSCFunction(JSContext* ctx, JSValue this_val, c_int argc, JSValue* argv);
	public function JSValue JSCFunctionMagic(JSContext* ctx, JSValue this_val, c_int argc, JSValue* argv, c_int magic);
	public function JSValue JSCFunctionData(JSContext* ctx, JSValue this_val, c_int argc, JSValue* argv, c_int magic, JSValue* func_data);

	struct JSMallocFunctions
	{
		function void*(void* opaque, size_t count, size_t size) js_calloc;
		function void*(void* opaque, size_t size) js_malloc;
		function void(void* opaque, void* ptr) js_free;
		function void*(void* opaque, void* ptr, size_t size) js_realloc;
		function size_t(void* ptr) js_malloc_usable_size;
	}

	// Debug trace system: the debug output will be produced to the dump stream (currently
	// stdout) if dumps are enabled and JS_SetDumpFlags is invoked with the corresponding
	// bit set.
	const c_int JS_DUMP_BYTECODE_FINAL   = 0x01; /* dump pass 3 final byte code */
	const c_int JS_DUMP_BYTECODE_PASS2   = 0x02; /* dump pass 2 code */
	const c_int JS_DUMP_BYTECODE_PASS1   = 0x04; /* dump pass 1 code */
	const c_int JS_DUMP_BYTECODE_HEX     = 0x10; /* dump bytecode in hex */
	const c_int JS_DUMP_BYTECODE_PC2LINE = 0x20; /* dump line number table */
	const c_int JS_DUMP_BYTECODE_STACK   = 0x40; /* dump compute_stack_size */
	const c_int JS_DUMP_BYTECODE_STEP    = 0x80; /* dump executed bytecode */
	const c_int JS_DUMP_READ_OBJECT     = 0x100; /* dump the marshalled objects at load time */
	const c_int JS_DUMP_FREE            = 0x200; /* dump every object free */
	const c_int JS_DUMP_GC              = 0x400; /* dump the occurrence of the automatic GC */
	const c_int JS_DUMP_GC_FREE         = 0x800; /* dump objects freed by the GC */
	const c_int JS_DUMP_MODULE_RESOLVE = 0x1000; /* dump module resolution steps */
	const c_int JS_DUMP_PROMISE        = 0x2000; /* dump promise steps */
	const c_int JS_DUMP_LEAKS          = 0x4000; /* dump leaked objects and strings in JS_FreeRuntime */
	const c_int JS_DUMP_ATOM_LEAKS     = 0x8000; /* dump leaked atoms in JS_FreeRuntime */
	const c_int JS_DUMP_MEM           = 0x10000; /* dump memory usage in JS_FreeRuntime */
	const c_int JS_DUMP_OBJECTS       = 0x20000; /* dump objects in JS_FreeRuntime */
	const c_int JS_DUMP_ATOMS         = 0x40000; /* dump atoms in JS_FreeRuntime */
	const c_int JS_DUMP_SHAPES        = 0x80000; /* dump shapes in JS_FreeRuntime */

	// Finalizers run in LIFO order at the very end of JS_FreeRuntime.
	// Intended for cleanup of associated resources; the runtime itself
	// is no longer usable.
	public function void JSRuntimeFinalizer(JSRuntime* rt, void* arg);

	struct JSGCObjectHeader;

	[CLink] public static extern JSRuntime* JS_NewRuntime();
	/* info lifetime must exceed that of rt */
	[CLink] public static extern void JS_SetRuntimeInfo(JSRuntime* rt, char* info);
	/* use 0 to disable memory limit */
	[CLink] public static extern void JS_SetMemoryLimit(JSRuntime* rt, size_t limit);
	[CLink] public static extern void JS_SetDumpFlags(JSRuntime* rt, uint64_t flags);
	[CLink] public static extern uint64_t JS_GetDumpFlags(JSRuntime* rt);
	[CLink] public static extern size_t JS_GetGCThreshold(JSRuntime* rt);
	[CLink] public static extern void JS_SetGCThreshold(JSRuntime* rt, size_t gc_threshold);
	/* use 0 to disable maximum stack size check */
	[CLink] public static extern void JS_SetMaxStackSize(JSRuntime* rt, size_t stack_size);
	/* should be called when changing thread to update the stack top value
	used to check stack overflow. */
	[CLink] public static extern void JS_UpdateStackTop(JSRuntime* rt);
	[CLink] public static extern JSRuntime* JS_NewRuntime2(JSMallocFunctions* mf, void* opaque);
	[CLink] public static extern void JS_FreeRuntime(JSRuntime* rt);
	[CLink] public static extern void* JS_GetRuntimeOpaque(JSRuntime* rt);
	[CLink] public static extern void JS_SetRuntimeOpaque(JSRuntime* rt, void* opaque);
	[CLink] public static extern c_int JS_AddRuntimeFinalizer(JSRuntime* rt, JSRuntimeFinalizer* finalizer, void* arg);

	public function void JS_MarkFunc(JSRuntime* rt, JSGCObjectHeader* gp);

	[CLink] public static extern void JS_MarkValue(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func);
	[CLink] public static extern void JS_RunGC(JSRuntime* rt);
	[CLink] public static extern bool JS_IsLiveObject(JSRuntime* rt, JSValue obj);

	[CLink] public static extern JSContext* JS_NewContext(JSRuntime* rt);
	[CLink] public static extern void JS_FreeContext(JSContext* s);
	[CLink] public static extern JSContext* JS_DupContext(JSContext* ctx);
	[CLink] public static extern void* JS_GetContextOpaque(JSContext* ctx);
	[CLink] public static extern void JS_SetContextOpaque(JSContext* ctx, void* opaque);
	[CLink] public static extern JSRuntime* JS_GetRuntime(JSContext* ctx);
	[CLink] public static extern void JS_SetClassProto(JSContext* ctx, JSClassID class_id, JSValue obj);
	[CLink] public static extern JSValue JS_GetClassProto(JSContext* ctx, JSClassID class_id);
	[CLink] public static extern JSValue JS_GetFunctionProto(JSContext* ctx);

	/* the following functions are used to select the intrinsic object to
	save memory */
	[CLink] public static extern JSContext* JS_NewContextRaw(JSRuntime* rt);
	[CLink] public static extern void JS_AddIntrinsicBaseObjects(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicDate(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicEval(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicRegExpCompiler(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicRegExp(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicJSON(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicProxy(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicMapSet(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicTypedArrays(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicPromise(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicBigInt(JSContext* ctx);
	[CLink] public static extern void JS_AddIntrinsicWeakRef(JSContext* ctx);
	[CLink] public static extern void JS_AddPerformance(JSContext* ctx);

	/* for equality comparisons and sameness */
	[CLink] public static extern c_int JS_IsEqual(JSContext* ctx, JSValue op1, JSValue op2);
	[CLink] public static extern bool JS_IsStrictEqual(JSContext* ctx, JSValue op1, JSValue op2);
	[CLink] public static extern bool JS_IsSameValue(JSContext* ctx, JSValue op1, JSValue op2);
	/* Similar to same-value equality, but +0 and -0 are considered equal. */
	[CLink] public static extern bool JS_IsSameValueZero(JSContext* ctx, JSValue op1, JSValue op2);

	/* Only used for running 262 tests. TODO(saghul) add build time flag. */
	[CLink] public static extern JSValue js_string_codePointRange(JSContext* ctx, JSValue this_val, c_int argc, JSValue* argv);

	[CLink] public static extern void* js_calloc_rt(JSRuntime* rt, size_t count, size_t size);
	[CLink] public static extern void* js_malloc_rt(JSRuntime* rt, size_t size);
	[CLink] public static extern void js_free_rt(JSRuntime* rt, void* ptr);
	[CLink] public static extern void* js_realloc_rt(JSRuntime* rt, void* ptr, size_t size);
	[CLink] public static extern size_t js_malloc_usable_size_rt(JSRuntime* rt, void* ptr);
	[CLink] public static extern void* js_mallocz_rt(JSRuntime* rt, size_t size);

	[CLink] public static extern void* js_calloc(JSContext* ctx, size_t count, size_t size);
	[CLink] public static extern void* js_malloc(JSContext* ctx, size_t size);
	[CLink] public static extern void js_free(JSContext* ctx, void* ptr);
	[CLink] public static extern void* js_realloc(JSContext* ctx, void* ptr, size_t size);
	[CLink] public static extern size_t js_malloc_usable_size(JSContext* ctx, void* ptr);
	[CLink] public static extern void* js_realloc2(JSContext* ctx, void* ptr, size_t size, size_t* pslack);
	[CLink] public static extern void* js_mallocz(JSContext* ctx, size_t size);
	[CLink] public static extern char* js_strdup(JSContext* ctx, char* str);
	[CLink] public static extern char* js_strndup(JSContext* ctx, char* s, size_t n);

	struct JSMemoryUsage
	{
		int64_t malloc_size, malloc_limit, memory_used_size;
		int64_t malloc_count;
		int64_t memory_used_count;
		int64_t atom_count, atom_size;
		int64_t str_count, str_size;
		int64_t obj_count, obj_size;
		int64_t prop_count, prop_size;
		int64_t shape_count, shape_size;
		int64_t js_func_count, js_func_size, js_func_code_size;
		int64_t js_func_pc2line_count, js_func_pc2line_size;
		int64_t c_func_count, array_count;
		int64_t fast_array_count, fast_array_elements;
		int64_t binary_object_count, binary_object_size;
	}

	[CLink] public static extern void JS_ComputeMemoryUsage(JSRuntime* rt, JSMemoryUsage* s);
	[CLink] public static extern void JS_DumpMemoryUsage(FILE* fp, JSMemoryUsage* s, JSRuntime* rt);

	/* atom support */
	const c_int JS_ATOM_NULL = 0;

	[CLink] public static extern JSAtom JS_NewAtomLen(JSContext* ctx, char* str, size_t len);
	[CLink] public static extern JSAtom JS_NewAtom(JSContext* ctx, char* str);
	[CLink] public static extern JSAtom JS_NewAtomUInt32(JSContext* ctx, uint32_t n);
	[CLink] public static extern JSAtom JS_DupAtom(JSContext* ctx, JSAtom v);
	[CLink] public static extern void JS_FreeAtom(JSContext* ctx, JSAtom v);
	[CLink] public static extern void JS_FreeAtomRT(JSRuntime* rt, JSAtom v);
	[CLink] public static extern JSValue JS_AtomToValue(JSContext* ctx, JSAtom atom);
	[CLink] public static extern JSValue JS_AtomToString(JSContext* ctx, JSAtom atom);
	[CLink] public static extern char* JS_AtomToCString(JSContext* ctx, JSAtom atom);
	[CLink] public static extern JSAtom JS_ValueToAtom(JSContext* ctx, JSValue val);

	/* object class support */

	struct JSPropertyEnum
	{
		bool is_enumerable;
		JSAtom atom;
	}

	struct JSPropertyDescriptor
	{
		c_int flags;
		JSValue value;
		JSValue getter;
		JSValue setter;
	}

	struct JSClassExoticMethods
	{
		/* Return -1 if exception (can only happen in case of Proxy object), false if the property does not exists, true if it exists. If 1 is returned, the property descriptor 'desc' is filled if != NULL. */
		function c_int(JSContext* ctx, JSPropertyDescriptor* desc, JSValue obj, JSAtom prop) get_own_property;
		/* '*ptab' should hold the '*plen' property keys. Return 0 if OK, -1 if exception. The 'is_enumerable' field is ignored. */
		function c_int(JSContext* ctx, JSPropertyEnum** ptab, uint32_t* plen, JSValue obj) get_own_property_names;
		/* return < 0 if exception, or true/false */
		function c_int(JSContext* ctx, JSValue obj, JSAtom prop) delete_property;
		/* return < 0 if exception or true/false */
		function c_int(JSContext* ctx, JSValue this_obj, JSAtom prop, JSValue val, JSValue getter, JSValue setter, c_int flags) define_own_property;
		/* The following methods can be emulated with the previous ones, so they are usually not needed */
		/* return < 0 if exception or true/false */
		function c_int(JSContext* ctx, JSValue obj, JSAtom atom) has_property;
		function JSValue(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) get_property;
		/* return < 0 if exception or true/false */
		function c_int(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, c_int flags) set_property;
	}

	function void JSClassFinalizer(JSRuntime* rt, JSValue val);
	function void JSClassGCMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func);
	const c_int JS_CALL_FLAG_CONSTRUCTOR = 1 << 0;
	function JSValue JSClassCall(JSContext* ctx, JSValue func_obj, JSValue this_val, c_int argc, JSValue* argv, c_int flags);

	struct JSClassDef
	{
		char* class_name; /* pure ASCII only! */
		JSClassFinalizer* finalizer;
		JSClassGCMark* gc_mark;
		/* if call != NULL, the object is a function. If (flags &
		JS_CALL_FLAG_CONSTRUCTOR) != 0, the function is called as a
		constructor. In this case, 'this_val' is new.target. A
		constructor call only happens if the object constructor bit is
		set (see JS_SetConstructorBit()). */
		JSClassCall* call;
		/* XXX: suppress this indirection ? It is here only to save memory
		because only a few classes need these methods */
		JSClassExoticMethods* exotic;
	}

	const c_int JS_EVAL_OPTIONS_VERSION = 1;

	struct JSEvalOptions
	{
		c_int version;
		c_int eval_flags;
		char* filename;
		c_int line_num;
		// can add new fields in ABI-compatible manner by incrementing JS_EVAL_OPTIONS_VERSION
	}

	const c_int JS_INVALID_CLASS_ID = 0;

	[CLink] public static extern JSClassID JS_NewClassID(JSRuntime* rt, JSClassID* pclass_id);
	/* Returns the class ID if `v` is an object, otherwise returns JS_INVALID_CLASS_ID. */
	[CLink] public static extern JSClassID JS_GetClassID(JSValue v);
	[CLink] public static extern c_int JS_NewClass(JSRuntime* rt, JSClassID class_id, JSClassDef* class_def);
	[CLink] public static extern bool JS_IsRegisteredClass(JSRuntime* rt, JSClassID class_id);

	[CLink] public static extern JSValue JS_NewNumber(JSContext* ctx, double d);
	[CLink] public static extern JSValue JS_NewBigInt64(JSContext* ctx, int64_t v);
	[CLink] public static extern JSValue JS_NewBigUint64(JSContext* ctx, uint64_t v);

	[CLink] public static extern JSValue JS_Throw(JSContext* ctx, JSValue obj);
	[CLink] public static extern JSValue JS_GetException(JSContext* ctx);
	[CLink] public static extern bool JS_HasException(JSContext* ctx);
	[CLink] public static extern bool JS_IsError(JSContext* ctx, JSValue val);
	[CLink] public static extern bool JS_IsUncatchableError(JSContext* ctx, JSValue val);
	[CLink] public static extern void JS_SetUncatchableError(JSContext* ctx, JSValue val);
	[CLink] public static extern void JS_ClearUncatchableError(JSContext* ctx, JSValue val);
	// Shorthand for:
	//  JSValue exc = JS_GetException(ctx);
	//  JS_ClearUncatchableError(ctx, exc);
	//  JS_Throw(ctx, exc);
	[CLink] public static extern void JS_ResetUncatchableError(JSContext* ctx);
	[CLink] public static extern JSValue JS_NewError(JSContext* ctx);
	/*[CLink] public static extern JSValue JS_PRINTF_FORMAT_ATTR(2, 3) JS_ThrowPlainError(JSContext* ctx, JS_PRINTF_FORMAT char* fmt, ...);
	[CLink] public static extern JSValue JS_PRINTF_FORMAT_ATTR(2, 3) JS_ThrowSyntaxError(JSContext* ctx, JS_PRINTF_FORMAT char* fmt, ...);
	[CLink] public static extern JSValue JS_PRINTF_FORMAT_ATTR(2, 3) JS_ThrowTypeError(JSContext* ctx, JS_PRINTF_FORMAT char* fmt, ...);
	[CLink] public static extern JSValue JS_PRINTF_FORMAT_ATTR(2, 3) JS_ThrowReferenceError(JSContext* ctx, JS_PRINTF_FORMAT char* fmt, ...);
	[CLink] public static extern JSValue JS_PRINTF_FORMAT_ATTR(2, 3) JS_ThrowRangeError(JSContext* ctx, JS_PRINTF_FORMAT char* fmt, ...);
	[CLink] public static extern JSValue JS_PRINTF_FORMAT_ATTR(2, 3) JS_ThrowInternalError(JSContext* ctx, JS_PRINTF_FORMAT char* fmt, ...);*/
	[CLink] public static extern JSValue JS_ThrowOutOfMemory(JSContext* ctx);
	[CLink] public static extern void JS_FreeValue(JSContext* ctx, JSValue v);
	[CLink] public static extern void JS_FreeValueRT(JSRuntime* rt, JSValue v);
	[CLink] public static extern JSValue JS_DupValue(JSContext* ctx, JSValue v);
	[CLink] public static extern JSValue JS_DupValueRT(JSRuntime* rt, JSValue v);
	[CLink] public static extern c_int JS_ToBool(JSContext* ctx, JSValue val); /* return -1 for JS_EXCEPTION */

	[CLink] public static extern JSValue JS_ToNumber(JSContext* ctx, JSValue val);
	[CLink] public static extern c_int JS_ToInt32(JSContext* ctx, int32_t* pres, JSValue val);

	[CLink] public static extern c_int JS_ToInt64(JSContext* ctx, int64_t* pres, JSValue val);
	[CLink] public static extern c_int JS_ToIndex(JSContext* ctx, uint64_t* plen, JSValue val);
	[CLink] public static extern c_int JS_ToFloat64(JSContext* ctx, double* pres, JSValue val);
	/* return an exception if 'val' is a Number */
	[CLink] public static extern c_int JS_ToBigInt64(JSContext* ctx, int64_t* pres, JSValue val);
	[CLink] public static extern c_int JS_ToBigUint64(JSContext* ctx, uint64_t* pres, JSValue val);
	/* same as JS_ToInt64() but allow BigInt */
	[CLink] public static extern c_int JS_ToInt64Ext(JSContext* ctx, int64_t* pres, JSValue val);

	[CLink] public static extern JSValue JS_NewStringLen(JSContext* ctx, char* str1, size_t len1);

	[CLink] public static extern JSValue JS_NewAtomString(JSContext* ctx, char* str);
	[CLink] public static extern JSValue JS_ToString(JSContext* ctx, JSValue val);
	[CLink] public static extern JSValue JS_ToPropertyKey(JSContext* ctx, JSValue val);
	[CLink] public static extern char* JS_ToCStringLen2(JSContext* ctx, size_t* plen, JSValue val1, bool cesu8);
	[Inline] public static char* JS_ToCString(JSContext* ctx, JSValue val1)
	{
		return JS_ToCStringLen2(ctx, null, val1, false);
	}

	[CLink] public static extern void JS_FreeCString(JSContext* ctx, char* ptr);

	[CLink] public static extern JSValue JS_NewObjectProtoClass(JSContext* ctx, JSValue proto, JSClassID class_id);
	[CLink] public static extern JSValue JS_NewObjectClass(JSContext* ctx, c_int class_id);
	[CLink] public static extern JSValue JS_NewObjectProto(JSContext* ctx, JSValue proto);
	[CLink] public static extern JSValue JS_NewObject(JSContext* ctx);
	[CLink] public static extern JSValue JS_NewObjectFrom(JSContext* ctx, c_int count, JSAtom* props, JSValue* values);
	[CLink] public static extern JSValue JS_NewObjectFromStr(JSContext* ctx, c_int count, char** props, JSValue* values);
	[CLink] public static extern JSValue JS_ToObject(JSContext* ctx, JSValue val);
	[CLink] public static extern JSValue JS_ToObjectString(JSContext* ctx, JSValue val);

	[CLink] public static extern bool JS_IsFunction(JSContext* ctx, JSValue val);
	[CLink] public static extern bool JS_IsConstructor(JSContext* ctx, JSValue val);
	[CLink] public static extern bool JS_SetConstructorBit(JSContext* ctx, JSValue func_obj, bool val);

	[CLink] public static extern bool JS_IsRegExp(JSValue val);
	[CLink] public static extern bool JS_IsMap(JSValue val);

	[CLink] public static extern JSValue JS_NewArray(JSContext* ctx);
	// takes ownership of the values
	[CLink] public static extern JSValue JS_NewArrayFrom(JSContext* ctx, c_int count, JSValue* values);
	[CLink] public static extern c_int JS_IsArray(JSContext* ctx, JSValue val);

	[CLink] public static extern JSValue JS_NewDate(JSContext* ctx, double epoch_ms);
	[CLink] public static extern bool JS_IsDate(JSValue v);

	[CLink] public static extern JSValue JS_GetProperty(JSContext* ctx, JSValue this_obj, JSAtom prop);
	[CLink] public static extern JSValue JS_GetPropertyUint32(JSContext* ctx, JSValue this_obj, uint32_t idx);
	[CLink] public static extern JSValue JS_GetPropertyInt64(JSContext* ctx, JSValue this_obj, int64_t idx);
	[CLink] public static extern JSValue JS_GetPropertyStr(JSContext* ctx, JSValue this_obj, char* prop);

	[CLink] public static extern c_int JS_SetProperty(JSContext* ctx, JSValue this_obj, JSAtom prop, JSValue val);
	[CLink] public static extern c_int JS_SetPropertyUint32(JSContext* ctx, JSValue this_obj, uint32_t idx, JSValue val);
	[CLink] public static extern c_int JS_SetPropertyInt64(JSContext* ctx, JSValue this_obj, int64_t idx, JSValue val);
	[CLink] public static extern c_int JS_SetPropertyStr(JSContext* ctx, JSValue this_obj, char* prop, JSValue val);
	[CLink] public static extern c_int JS_HasProperty(JSContext* ctx, JSValue this_obj, JSAtom prop);
	[CLink] public static extern c_int JS_IsExtensible(JSContext* ctx, JSValue obj);
	[CLink] public static extern c_int JS_PreventExtensions(JSContext* ctx, JSValue obj);
	[CLink] public static extern c_int JS_DeleteProperty(JSContext* ctx, JSValue obj, JSAtom prop, c_int flags);
	[CLink] public static extern c_int JS_SetPrototype(JSContext* ctx, JSValue obj, JSValue proto_val);
	[CLink] public static extern JSValue JS_GetPrototype(JSContext* ctx, JSValue val);
	[CLink] public static extern c_int JS_GetLength(JSContext* ctx, JSValue obj, int64_t* pres);
	[CLink] public static extern c_int JS_SetLength(JSContext* ctx, JSValue obj, int64_t len);
	[CLink] public static extern c_int JS_SealObject(JSContext* ctx, JSValue obj);
	[CLink] public static extern c_int JS_FreezeObject(JSContext* ctx, JSValue obj);

	const c_int JS_GPN_STRING_MASK  = 1 << 0;
	const c_int JS_GPN_SYMBOL_MASK  = 1 << 1;
	const c_int JS_GPN_PRIVATE_MASK = 1 << 2;
	/* only include the enumerable properties */
	const c_int JS_GPN_ENUM_ONLY    = 1 << 4;
	/* set theJSPropertyEnum.is_enumerable field */
	const c_int JS_GPN_SET_ENUM     = 1 << 5;

	[CLink] public static extern c_int JS_GetOwnPropertyNames(JSContext* ctx, JSPropertyEnum** ptab, uint32_t* plen, JSValue obj, c_int flags);
	[CLink] public static extern c_int JS_GetOwnProperty(JSContext* ctx, JSPropertyDescriptor* desc, JSValue obj, JSAtom prop);
	[CLink] public static extern void JS_FreePropertyEnum(JSContext* ctx, JSPropertyEnum* tab, uint32_t len);

	[CLink] public static extern JSValue JS_Call(JSContext* ctx, JSValue func_obj, JSValue this_obj, c_int argc, JSValue* argv);
	[CLink] public static extern JSValue JS_Invoke(JSContext* ctx, JSValue this_val, JSAtom atom, c_int argc, JSValue* argv);
	[CLink] public static extern JSValue JS_CallConstructor(JSContext* ctx, JSValue func_obj, c_int argc, JSValue* argv);
	[CLink] public static extern JSValue JS_CallConstructor2(JSContext* ctx, JSValue func_obj, JSValue new_target, c_int argc, JSValue* argv);
	/* Try to detect if the input is a module. Returns true if parsing the input
	*  as a module produces no syntax errors. It's a naive approach that is not
	*  wholly infallible: non-strict classic scripts may _parse_ okay as a module
	*  but not _execute_ as one (different runtime semantics.) Use with caution.
	*  |input| can be either ASCII or UTF-8 encoded source code.
	*/
	[CLink] public static extern bool JS_DetectModule(char* input, size_t input_len);
	/* 'input' must be zero terminated i.e. input[input_len] = '\0'. */
	[CLink] public static extern JSValue JS_Eval(JSContext* ctx, char* input, size_t input_len, char* filename, c_int eval_flags);
	[CLink] public static extern JSValue JS_Eval2(JSContext* ctx, char* input, size_t input_len, JSEvalOptions* options);
	[CLink] public static extern JSValue JS_EvalThis(JSContext* ctx, JSValue this_obj, char* input, size_t input_len, char* filename, c_int eval_flags);
	[CLink] public static extern JSValue JS_EvalThis2(JSContext* ctx, JSValue this_obj, char* input, size_t input_len, JSEvalOptions* options);
	[CLink] public static extern JSValue JS_GetGlobalObject(JSContext* ctx);
	[CLink] public static extern c_int JS_IsInstanceOf(JSContext* ctx, JSValue val, JSValue obj);
	[CLink] public static extern c_int JS_DefineProperty(JSContext* ctx, JSValue this_obj, JSAtom prop, JSValue val, JSValue getter, JSValue setter, c_int flags);
	[CLink] public static extern c_int JS_DefinePropertyValue(JSContext* ctx, JSValue this_obj, JSAtom prop, JSValue val, c_int flags);
	[CLink] public static extern c_int JS_DefinePropertyValueUint32(JSContext* ctx, JSValue this_obj, uint32_t idx, JSValue val, c_int flags);
	[CLink] public static extern c_int JS_DefinePropertyValueStr(JSContext* ctx, JSValue this_obj, char* prop, JSValue val, c_int flags);
	[CLink] public static extern c_int JS_DefinePropertyGetSet(JSContext* ctx, JSValue this_obj, JSAtom prop, JSValue getter, JSValue setter, c_int flags);
	/* Only supported for custom classes, returns 0 on success < 0 otherwise. */
	[CLink] public static extern c_int JS_SetOpaque(JSValue obj, void* opaque);
	[CLink] public static extern void* JS_GetOpaque(JSValue obj, JSClassID class_id);
	[CLink] public static extern void* JS_GetOpaque2(JSContext* ctx, JSValue obj, JSClassID class_id);
	[CLink] public static extern void* JS_GetAnyOpaque(JSValue obj, JSClassID* class_id);

	/* 'buf' must be zero terminated i.e. buf[buf_len] = '\0'. */
	[CLink] public static extern JSValue JS_ParseJSON(JSContext* ctx, char* buf, size_t buf_len, char* filename);
	[CLink] public static extern JSValue JS_JSONStringify(JSContext* ctx, JSValue obj, JSValue replacer, JSValue space0);

	public function void JSFreeArrayBufferDataFunc(JSRuntime* rt, void* opaque, void* ptr);

	[CLink] public static extern JSValue JS_NewArrayBuffer(JSContext* ctx, uint8_t* buf, size_t len, JSFreeArrayBufferDataFunc* free_func, void* opaque, bool is_shared);
	[CLink] public static extern JSValue JS_NewArrayBufferCopy(JSContext* ctx, uint8_t* buf, size_t len);
	[CLink] public static extern void JS_DetachArrayBuffer(JSContext* ctx, JSValue obj);
	[CLink] public static extern uint8_t* JS_GetArrayBuffer(JSContext* ctx, size_t* psize, JSValue obj);
	[CLink] public static extern bool JS_IsArrayBuffer(JSValue obj);
	[CLink] public static extern uint8_t* JS_GetUint8Array(JSContext* ctx, size_t* psize, JSValue obj);

	public enum JSTypedArrayEnum : c_int
	{
		JS_TYPED_ARRAY_UINT8C = 0,
		JS_TYPED_ARRAY_INT8,
		JS_TYPED_ARRAY_UINT8,
		JS_TYPED_ARRAY_INT16,
		JS_TYPED_ARRAY_UINT16,
		JS_TYPED_ARRAY_INT32,
		JS_TYPED_ARRAY_UINT32,
		JS_TYPED_ARRAY_BIG_INT64,
		JS_TYPED_ARRAY_BIG_UINT64,
		JS_TYPED_ARRAY_FLOAT16,
		JS_TYPED_ARRAY_FLOAT32,
		JS_TYPED_ARRAY_FLOAT64,
	}

	[CLink] public static extern JSValue JS_NewTypedArray(JSContext* ctx, c_int argc, JSValue* argv, JSTypedArrayEnum array_type);
	[CLink] public static extern JSValue JS_GetTypedArrayBuffer(JSContext* ctx, JSValue obj, size_t* pbyte_offset, size_t* pbyte_length, size_t* pbytes_per_element);
	[CLink] public static extern JSValue JS_NewUint8Array(JSContext* ctx, uint8_t* buf, size_t len, JSFreeArrayBufferDataFunc* free_func, void* opaque, bool is_shared);
	/* returns -1 if not a typed array otherwise return a JSTypedArrayEnum value */
	[CLink] public static extern c_int JS_GetTypedArrayType(JSValue obj);
	[CLink] public static extern JSValue JS_NewUint8ArrayCopy(JSContext* ctx, uint8_t* buf, size_t len);

	[CRepr] struct JSSharedArrayBufferFunctions
	{
		function void*(void* opaque, size_t size) sab_alloc;
		function void(void* opaque, void* ptr) sab_free;
		function void(void* opaque, void* ptr) sab_dup;
		void* sab_opaque;
	}

	[CLink] public static extern void JS_SetSharedArrayBufferFunctions(JSRuntime* rt, JSSharedArrayBufferFunctions* sf);

	[CRepr] public enum JSPromiseStateEnum : c_int
	{
		JS_PROMISE_PENDING,
		JS_PROMISE_FULFILLED,
		JS_PROMISE_REJECTED,
	}

	[CLink] public static extern JSValue JS_NewPromiseCapability(JSContext* ctx, JSValue* resolving_funcs);
	[CLink] public static extern JSPromiseStateEnum JS_PromiseState(JSContext* ctx, JSValue promise);
	[CLink] public static extern JSValue JS_PromiseResult(JSContext* ctx, JSValue promise);
	[CLink] public static extern bool JS_IsPromise(JSValue val);

	[CLink] public static extern JSValue JS_NewSymbol(JSContext* ctx, char* description, bool is_global);

	/* is_handled = true means that the rejection is handled */
	public function void JSHostPromiseRejectionTracker(JSContext* ctx, JSValue promise, JSValue reason, bool is_handled, void* opaque);

	[CLink] public static extern void JS_SetHostPromiseRejectionTracker(JSRuntime* rt, JSHostPromiseRejectionTracker* cb, void* opaque);

	/* return != 0 if the JS code needs to be interrupted */
	public function c_int JSInterruptHandler(JSRuntime* rt, void* opaque);

	[CLink] public static extern void JS_SetInterruptHandler(JSRuntime* rt, JSInterruptHandler* cb, void* opaque);
	/* if can_block is true, Atomics.wait() can be used */
	[CLink] public static extern void JS_SetCanBlock(JSRuntime* rt, bool can_block);
	/* set the [IsHTMLDDA] internal slot */
	[CLink] public static extern void JS_SetIsHTMLDDA(JSContext* ctx, JSValue obj);

	public struct JSModuleDef;

	/* return the module specifier (allocated with js_malloc()) or NULL if
	exception */
	public function char* JSModuleNormalizeFunc(JSContext* ctx, char* module_base_name, char* module_name, void* opaque);
	public function JSModuleDef* JSModuleLoaderFunc(JSContext* ctx, char* module_name, void* opaque);

	/* module_normalize = NULL is allowed and invokes the default module
	filename normalizer */
	[CLink] public static extern void JS_SetModuleLoaderFunc(JSRuntime* rt, JSModuleNormalizeFunc* module_normalize, JSModuleLoaderFunc* module_loader, void* opaque);
	/* return the import.meta object of a module */
	[CLink] public static extern JSValue JS_GetImportMeta(JSContext* ctx, JSModuleDef* m);
	[CLink] public static extern JSAtom JS_GetModuleName(JSContext* ctx, JSModuleDef* m);
	[CLink] public static extern JSValue JS_GetModuleNamespace(JSContext* ctx, JSModuleDef* m);

	/* JS Job support */

	public function JSValue JSJobFunc(JSContext* ctx, c_int argc, JSValue* argv);
	[CLink] public static extern c_int JS_EnqueueJob(JSContext* ctx, JSJobFunc* job_func, c_int argc, JSValue* argv);

	[CLink] public static extern bool JS_IsJobPending(JSRuntime* rt);
	[CLink] public static extern c_int JS_ExecutePendingJob(JSRuntime* rt, JSContext** pctx);

	/* Structure to retrieve (de)serialized SharedArrayBuffer objects. */
	struct JSSABTab
	{
		uint8_t** tab;
		size_t len;
	}

	/* Object Writer/Reader (currently only used to handle precompiled code) */
	const c_int JS_WRITE_OBJ_BYTECODE  = 1 << 0; /* allow function/module */
	const c_int JS_WRITE_OBJ_BSWAP     = 0; /* byte swapped output (obsolete, handled transparently); */
	const c_int JS_WRITE_OBJ_SAB       = 1 << 2; /* allow SharedArrayBuffer */
	const c_int JS_WRITE_OBJ_REFERENCE = 1 << 3; /* allow object references to encode arbitrary object graph */
	const c_int JS_WRITE_OBJ_STRIP_SOURCE  = 1 << 4; /* do not write source code information */
	const c_int JS_WRITE_OBJ_STRIP_DEBUG   = 1 << 5; /* do not write debug information */

	[CLink] public static extern uint8_t* JS_WriteObject(JSContext* ctx, size_t* psize, JSValue obj, c_int flags);
	[CLink] public static extern uint8_t* JS_WriteObject2(JSContext* ctx, size_t* psize, JSValue obj, c_int flags, JSSABTab* psab_tab);

	const c_int JS_READ_OBJ_BYTECODE  = 1 << 0; /* allow function/module */
	const c_int JS_READ_OBJ_ROM_DATA  = 0; /* avoid duplicating 'buf' data (obsolete, broken by ICs) */
	const c_int JS_READ_OBJ_SAB       = 1 << 2; /* allow SharedArrayBuffer */
	const c_int JS_READ_OBJ_REFERENCE = 1 << 3; /* allow object references */

	[CLink] public static extern JSValue JS_ReadObject(JSContext* ctx, uint8_t* buf, size_t buf_len, c_int flags);
	[CLink] public static extern JSValue JS_ReadObject2(JSContext* ctx, uint8_t* buf, size_t buf_len, c_int flags, JSSABTab* psab_tab);
	/* instantiate and evaluate a bytecode function. Only used when
	reading a script or module with JS_ReadObject() */
	[CLink] public static extern JSValue JS_EvalFunction(JSContext* ctx, JSValue fun_obj);
	/* load the dependencies of the module 'obj'. Useful when JS_ReadObject()
	returns a module. */
	[CLink] public static extern c_int JS_ResolveModule(JSContext* ctx, JSValue obj);

	/* only exported for os.Worker() */
	[CLink] public static extern JSAtom JS_GetScriptOrModuleName(JSContext* ctx, c_int n_stack_levels);
	/* only exported for os.Worker() */
	[CLink] public static extern JSValue JS_LoadModule(JSContext* ctx, char* basename, char* filename);

	/* C function definition */
	public enum JSCFunctionEnum : c_int
	{ /* XXX: should rename for namespace isolation */
		JS_CFUNC_generic,
		JS_CFUNC_generic_magic,
		JS_CFUNC_constructor,
		JS_CFUNC_constructor_magic,
		JS_CFUNC_constructor_or_func,
		JS_CFUNC_constructor_or_func_magic,
		JS_CFUNC_f_f,
		JS_CFUNC_f_f_f,
		JS_CFUNC_getter,
		JS_CFUNC_setter,
		JS_CFUNC_getter_magic,
		JS_CFUNC_setter_magic,
		JS_CFUNC_iterator_next,
	}

	[Union] struct JSCFunctionType
	{
		JSCFunction* generic;
		function JSValue(JSContext* ctx, JSValue this_val, c_int argc, JSValue* argv, c_int magic) generic_magic;
		JSCFunction* constructor;
		function JSValue(JSContext* ctx, JSValue new_target, c_int argc, JSValue* argv, c_int magic) constructor_magic;
		JSCFunction* constructor_or_func;
		function double(double) f_f;
		function double(double, double) f_f_f;
		function JSValue(JSContext* ctx, JSValue this_val) getter;
		function JSValue(JSContext* ctx, JSValue this_val, JSValue val) setter;
		function JSValue(JSContext* ctx, JSValue this_val, c_int magic) getter_magic;
		function JSValue(JSContext* ctx, JSValue this_val, JSValue val, c_int magic) setter_magic;
		function JSValue(JSContext* ctx, JSValue this_val, c_int argc, JSValue* argv, c_int* pdone, c_int magic) iterator_next;
	}

	[CLink] public static extern JSValue JS_NewCFunction2(JSContext* ctx, JSCFunction func, char* name, c_int length, JSCFunctionEnum cproto, c_int magic);
	[CLink] public static extern JSValue JS_NewCFunction3(JSContext* ctx, JSCFunction func, char* name, c_int length, JSCFunctionEnum cproto, c_int magic, JSValue proto_val);
	[CLink] public static extern JSValue JS_NewCFunctionData(JSContext* ctx, JSCFunctionData func, c_int length, c_int magic, c_int data_len, JSValue* data);

	[Inline] public static JSValue JS_NewCFunction(JSContext* ctx, JSCFunction func, char* name, c_int length)
	{
		return JS_NewCFunction2(ctx, func, name, length, .JS_CFUNC_generic, 0);
	}

	[CLink] public static extern void JS_SetConstructor(JSContext* ctx, JSValue func_obj, JSValue proto);

	/* C property definition */

	struct JSCFunctionListEntry
	{
		char* name; /* pure ASCII or UTF-8 encoded */
		uint8_t prop_flags;
		uint8_t def_type;
		int16_t magic;

		/**/ [Union] struct
		{
			struct
			{
				uint8_t length; /* XXX: should move outside union */
				uint8_t cproto; /* XXX: should move outside union */
				JSCFunctionType cfunc;
			} func;
			struct
			{
				JSCFunctionType get;
				JSCFunctionType set;
			} getset;
			struct
			{
				char* name;
				c_int base_;
			} alias;
			struct
			{
				JSCFunctionListEntry* tab;
				c_int len;
			} prop_list;
			char* str; /* pure ASCII or UTF-8 encoded */
			int32_t i32;
			int64_t i64;
			uint64_t u64;
			double f64;
		} u;
	}

	const c_int JS_DEF_CFUNC          = 0;
	const c_int JS_DEF_CGETSET        = 1;
	const c_int JS_DEF_CGETSET_MAGIC  = 2;
	const c_int JS_DEF_PROP_STRING    = 3;
	const c_int JS_DEF_PROP_INT32     = 4;
	const c_int JS_DEF_PROP_INT64     = 5;
	const c_int JS_DEF_PROP_DOUBLE    = 6;
	const c_int JS_DEF_PROP_UNDEFINED = 7;
	const c_int JS_DEF_OBJECT         = 8;
	const c_int JS_DEF_ALIAS          = 9;

	/* Note: c++ does not like nested designators */
	// #define JS_CFUNC_DEF(name, length, func1) { name, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE, JS_DEF_CFUNC, 0, { .func = { length, JS_CFUNC_generic, { .generic = func1 } } } }
	// #define JS_CFUNC_DEF2(name, length, func1, prop_flags) { name, prop_flags, JS_DEF_CFUNC, 0, { .func = { length, JS_CFUNC_generic, { .generic = func1 } } } }
	// #define JS_CFUNC_MAGIC_DEF(name, length, func1, magic) { name, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE, JS_DEF_CFUNC, magic, { .func = { length, JS_CFUNC_generic_magic, { .generic_magic = func1 } } } }
	// #define JS_CFUNC_SPECIAL_DEF(name, length, cproto, func1) { name, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE, JS_DEF_CFUNC, 0, { .func = { length, JS_CFUNC_ ## cproto, { .cproto = func1 } } } }
	// #define JS_ITERATOR_NEXT_DEF(name, length, func1, magic) { name, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE, JS_DEF_CFUNC, magic, { .func = { length, JS_CFUNC_iterator_next, { .iterator_next = func1 } } } }
	// #define JS_CGETSET_DEF(name, fgetter, fsetter) { name, JS_PROP_CONFIGURABLE, JS_DEF_CGETSET, 0, { .getset = { .get = { .getter = fgetter }, .set = { .setter = fsetter } } } }
	// #define JS_CGETSET_DEF2(name, fgetter, fsetter, prop_flags) { name, prop_flags, JS_DEF_CGETSET, 0, { .getset = { .get = { .getter = fgetter }, .set = { .setter = fsetter } } } }
	// #define JS_CGETSET_MAGIC_DEF(name, fgetter, fsetter, magic) { name, JS_PROP_CONFIGURABLE, JS_DEF_CGETSET_MAGIC, magic, { .getset = { .get = { .getter_magic = fgetter }, .set = { .setter_magic = fsetter } } } }
	// #define JS_PROP_STRING_DEF(name, cstr, prop_flags) { name, prop_flags, JS_DEF_PROP_STRING, 0, { .str = cstr } }
	// #define JS_PROP_INT32_DEF(name, val, prop_flags) { name, prop_flags, JS_DEF_PROP_INT32, 0, { .i32 = val } }
	// #define JS_PROP_INT64_DEF(name, val, prop_flags) { name, prop_flags, JS_DEF_PROP_INT64, 0, { .i64 = val } }
	// #define JS_PROP_DOUBLE_DEF(name, val, prop_flags) { name, prop_flags, JS_DEF_PROP_DOUBLE, 0, { .f64 = val } }
	// #define JS_PROP_U2D_DEF(name, val, prop_flags) { name, prop_flags, JS_DEF_PROP_DOUBLE, 0, { .u64 = val } }
	// #define JS_PROP_UNDEFINED_DEF(name, prop_flags) { name, prop_flags, JS_DEF_PROP_UNDEFINED, 0, { .i32 = 0 } }
	// #define JS_OBJECT_DEF(name, tab, len, prop_flags) { name, prop_flags, JS_DEF_OBJECT, 0, { .prop_list = { tab, len } } }
	// #define JS_ALIAS_DEF(name, from) { name, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE, JS_DEF_ALIAS, 0, { .alias = { from, -1 } } }
	// #define JS_ALIAS_BASE_DEF(name, from, base) { name, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE, JS_DEF_ALIAS, 0, { .alias = { from, base } } }

	[CLink] public static extern void JS_SetPropertyFunctionList(JSContext* ctx, JSValue obj, JSCFunctionListEntry* tab, c_int len);

	public function c_int JSModuleInitFunc(JSContext* ctx, JSModuleDef* m);

	[CLink] public static extern JSModuleDef* JS_NewCModule(JSContext* ctx, char* name_str, JSModuleInitFunc* func);

	/* can only be called before the module is instantiated */
	[CLink] public static extern c_int JS_AddModuleExport(JSContext* ctx, JSModuleDef* m, char* name_str);
	[CLink] public static extern c_int JS_AddModuleExportList(JSContext* ctx, JSModuleDef* m, JSCFunctionListEntry* tab, c_int len);

	/* can only be called after the module is instantiated */
	[CLink] public static extern c_int JS_SetModuleExport(JSContext* ctx, JSModuleDef* m, char* export_name, JSValue val);
	[CLink] public static extern c_int JS_SetModuleExportList(JSContext* ctx, JSModuleDef* m, JSCFunctionListEntry* tab, c_int len);

	/* Version */

	const c_int QJS_VERSION_MAJOR = 0;
	const c_int QJS_VERSION_MINOR = 8;
	const c_int QJS_VERSION_PATCH = 0;
	const char8* QJS_VERSION_SUFFIX = "";

	[CLink] public static extern char* JS_GetVersion();

	/* Integration point for quickjs-libc.c, not for public use. */
	[CLink] public static extern uintptr_t js_std_cmd(c_int cmd, ...);
}