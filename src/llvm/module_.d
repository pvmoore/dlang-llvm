module llvm.module_;

import llvm.all;

final class LLVMModule {
	LLVMModuleRef ref_;
	string name;

	LLVMValueRef[string] coroFuncs; 

	this(string name) {
		this.name = name;
		this.ref_ = LLVMModuleCreateWithName(name.toStringz);
	}
	void destroy() {
		LLVMDisposeModule(ref_);
	}
	void setTargetTriple(string triple) {
		LLVMSetTarget(ref_, triple.toStringz);
	}
	void setDataLayout(string layout) {
		LLVMSetDataLayout(ref_, layout.toStringz);
	}
	LLVMValueRef addGlobal(LLVMTypeRef type, string name=null) {
		return LLVMAddGlobal(ref_, type, name.toStringz);
	}
	LLVMValueRef addAlias(LLVMTypeRef type, LLVMValueRef aliasee, string name) {
		return LLVMAddAlias(ref_, type, aliasee, name.toStringz);
	}
	void setInlineAsm(string asmStr) {
		LLVMSetModuleInlineAsm(ref_, asmStr.toStringz);
	}
	LLVMTypeRef getType(string name) {
		return LLVMGetTypeByName(ref_, name.toStringz);
	}
	LLVMValueRef getFunction(string name) {
		return LLVMGetNamedFunction(ref_, name.toStringz);
	}
	LLVMValueRef getGlobal(string name) {
		return LLVMGetNamedGlobal(ref_, name.toStringz);
	}
	void deleteGlobal(LLVMValueRef g) {
		LLVMDeleteGlobal(g);
	}
	bool verify() {
		char* messages;
		LLVMBool isBroken = LLVMVerifyModule(
			ref_, 
			LLVMVerifierFailureAction.LLVMPrintMessageAction, 
			&messages
		);
		LLVMDisposeMessage(messages);
		return 0==isBroken;
	}
	void dump() {
		LLVMDumpModule(ref_);
	}
	string dumpToString() {
        return cast(string)LLVMPrintModuleToString(ref_).fromStringz;
	}
	void dumpToConsole() {
	    writeln(dumpToString());
	}
	bool writeToFileLL(string filename) {
		char* error;
		return 0==LLVMPrintModuleToFile(ref_, filename.toStringz, &error);
	}
	bool writeToFileBC(string filename) {
		return 0==LLVMWriteBitcodeToFile(ref_, filename.toStringz);
	}
	LLVMValueRef addFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, LLVMCallConv cc, bool vararg=false) {
		auto functionType = LLVMFunctionType(retType, 
											 params.ptr, 
											 cast(int)params.length, 
											 cast(LLVMBool)vararg);
		auto func = LLVMAddFunction(ref_, name.toStringz, functionType);
		LLVMSetFunctionCallConv(func, cc);
		return func;
	}
	LLVMValueRef addCFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, bool vararg=false) {
		return addFunction(name, retType, params, LLVMCallConv.LLVMCCallConv, vararg);
	}
	LLVMValueRef addFastcallFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, bool vararg=false) {
		return addFunction(name, retType, params, LLVMCallConv.LLVMFastCallConv, vararg);
	}
	LLVMValueRef getOrAddIntrinsicFunction(string name) {
		auto f = getFunction(name);
		if(f) return f; 

		switch(name) {

			case "llvm.bitreverse.i16" : // i16 @llvm.bitreverse.i16(i16)
				return addCFunction("llvm.bitreverse.i16", i16Type(), [i16Type()]);
			case "llvm.bitreverse.i32" : // i32 @llvm.bitreverse.i32(i32)
				return addCFunction("llvm.bitreverse.i32", i32Type(), [i32Type()]);
			case "llvm.bitreverse.i64" : // i64 @llvm.bitreverse.i64(i64)
				return addCFunction("llvm.bitreverse.i64", i64Type(), [i64Type()]);
			case "llvm.bitreverse.v4i32" : // <4xi32> @llvm.bitreverse.v4i32(<4xi32>)
				return addCFunction("llvm.bitreverse.v4i32", vector(i32Type(),4), [vector(i32Type(),4)]);

			case "llvm.bswap.i16" : // i16 @llvm.bswap.i16(i16)
				return addCFunction("llvm.bswap.i16", i16Type(), [i16Type()]);
			case "llvm.bswap.i32" : // i32 @llvm.bswap.i32(i32)
				return addCFunction("llvm.bswap.i32", i32Type(), [i32Type()]);
			case "llvm.bswap.i64" : // i64 @llvm.bswap.i64(i64)
				return addCFunction("llvm.bswap.i64", i64Type(), [i64Type()]);
			case "llvm.bswap.v4i32" : // <4xi32> @llvm.bswap.v4i32(<4xi32>)
				return addCFunction("llvm.bswap.v4i32", vector(i32Type(),4), [vector(i32Type(),4)]);

			case "llvm.ceil.f32" : // float @llvm.ceil.f32(float)
				return addCFunction("llvm.ceil.f32", f32Type(), [f32Type()]);
			case "llvm.ceil.f64" : // double @llvm.ceil.f64(double)
				return addCFunction("llvm.ceil.f64", f64Type(), [f64Type()]);

			case "llvm.copysign.f32" : // float @llvm.copysign.f32(float,float)
				return addCFunction("llvm.copysign.f32", f32Type(), [f32Type(),f32Type()]);
			case "llvm.copysign.f64" : // double @llvm.copysign.f64(double,double)
				return addCFunction("llvm.copysign.f64", f64Type(), [f64Type(),f64Type()]);

			case "llvm.coro.alloc" : // i1 @llvm.coro.alloc(token <id>)
				return addCFunction("llvm.coro.alloc", i1Type(), [tokenType()]);
			case "llvm.coro.begin" : // i8* @llvm.coro.begin(token <id>, i8* <mem>)
				return addCFunction("llvm.coro.begin", bytePointerType(), [tokenType(), bytePointerType()]);
			case "llvm.coro.destroy" : // void @llvm.coro.destroy(i8* <handle>)
				return addCFunction("llvm.coro.destroy", voidType(), [bytePointerType()]);
			case "llvm.coro.done" : // i1 @llvm.coro.done(i8* <handle>)
				return addCFunction("llvm.coro.done", i1Type(), [bytePointerType()]);
			case "llvm.coro.end" : // i1 @llvm.coro.end(i8* <handle>, i1 <unwind>)
				return addCFunction("llvm.coro.end", i1Type(), [bytePointerType(), i1Type()]);
			case "llvm.coro.frame" : // i8* @llvm.coro.frame()
				return addCFunction("llvm.coro.frame", bytePointerType(), []);
			case "llvm.coro.free" : // i8* @llvm.coro.free(token %id, i8* <frame>)
				return addCFunction("llvm.coro.free", bytePointerType(), [tokenType(), bytePointerType()]);
			case "llvm.coro.id" : // token @llvm.coro.id(i32 <align>, i8* <promise>, i8* <coroaddr>, i8* <fnaddrs>)
				return addCFunction("llvm.coro.id", tokenType(), [i32Type(),bytePointerType(),bytePointerType(),bytePointerType()]);
			case "llvm.coro.noop" : // i8* @llvm.coro.noop()
				return addCFunction("llvm.coro.noop", bytePointerType(), []);
			case "llvm.coro.param" : // i1 @llvm.coro.param(i8* <original>, i8* <copy>)
				return addCFunction("llvm.coro.param", i1Type(), [bytePointerType(), bytePointerType()]);
			case "llvm.coro.promise" : // i8* @llvm.coro.promise(i8* <ptr>, i32 <alignment>, i1 <from>)
				return addCFunction("llvm.coro.promise", bytePointerType(), [bytePointerType(), i32Type(), i1Type()]);
			case "llvm.coro.resume" : // void @llvm.coro.resume(i8* <handle>)
				return addCFunction("llvm.coro.resume", voidType(), [bytePointerType()]);
			case "llvm.coro.save" : // token @llvm.coro.save(i8* <handle>)
				return addCFunction("llvm.coro.save", tokenType(), [bytePointerType()]);
			case "llvm.coro.size.i32" : // i32 @llvm.coro.size.i32()
				return addCFunction("llvm.coro.size.i32", i32Type(), []);
			case "llvm.coro.suspend" : // i8 @llvm.coro.suspend(token <save>, i1 <final>)
				return addCFunction("llvm.coro.suspend", i8Type(), [tokenType(), i1Type()]);

			case "llvm.cos.f32" : // float @llvm.cos.f32(float)
				return addCFunction("llvm.cos.f32", f32Type(), [f32Type()]);
			case "llvm.cos.f64" : // double @llvm.cos.f64(double)
				return addCFunction("llvm.cos.f64", f64Type(), [f64Type()]);

			case "llvm.ctlz.i8" : // i8 @llvm.ctlz.i8(i8,i1)
				return addCFunction("llvm.ctlz.i8", i8Type(), [i8Type(),i1Type()]);
			case "llvm.ctlz.i16" : // i16 @llvm.ctlz.i16(i16,i1)
				return addCFunction("llvm.ctlz.i16", i16Type(), [i16Type(),i1Type()]);
			case "llvm.ctlz.i32" : // i32 @llvm.ctlz.i32(i32,i1)
				return addCFunction("llvm.ctlz.i32", i32Type(), [i32Type(),i1Type()]);
			case "llvm.ctlz.i64" : // i64 @llvm.ctlz.i64(i64,i1)
				return addCFunction("llvm.ctlz.i64", i64Type(), [i64Type(),i1Type()]);
			case "llvm.ctlz.v2i32" : // <2xi32> @llvm.ctlz.v2i32(<2xi32>,i1)
				return addCFunction("llvm.ctlz.v2i32", vector(i32Type(),2), [vector(i32Type(),2),i1Type()]);

			case "llvm.ctpop.i8" : // i8 @llvm.ctpop.i8(i8)
				return addCFunction("llvm.ctpop.i8", i8Type(), [i8Type()]);
			case "llvm.ctpop.i16" : // i16 @llvm.ctpop.i16(i16)
				return addCFunction("llvm.ctpop.i16", i16Type(), [i16Type()]);
			case "llvm.ctpop.i32" : // i32 @llvm.ctpop.i32(i32)
				return addCFunction("llvm.ctpop.i32", i32Type(), [i32Type()]);
			case "llvm.ctpop.i64" : // i64 @llvm.ctpop.i64(i64)
				return addCFunction("llvm.ctpop.i64", i64Type(), [i64Type()]);
			case "llvm.ctpop.v2i32" : // <2xi32> @llvm.ctpop.v2i32(<2xi32>)
				return addCFunction("llvm.ctpop.v2i32", vector(i32Type(),2), [vector(i32Type(),2)]);

			case "llvm.cttz.i8" : // i8 @llvm.cttz.i8(i8,i1)
				return addCFunction("llvm.cttz.i8", i8Type(), [i8Type(),i1Type()]);
			case "llvm.cttz.i16" : // i16 @llvm.cttz.i16(i16,i1)
				return addCFunction("llvm.cttz.i16", i16Type(), [i16Type(),i1Type()]);
			case "llvm.cttz.i32" : // i32 @llvm.cttz.i32(i32,i1)
				return addCFunction("llvm.cttz.i32", i32Type(), [i32Type(),i1Type()]);
			case "llvm.cttz.i64" : // i64 @llvm.cttz.i64(i64,i1)
				return addCFunction("llvm.cttz.i64", i64Type(), [i64Type(),i1Type()]);
			case "llvm.cttz.v2i32" : // <2xi32> @llvm.cttz.v2i32(<2xi32>,i1)
				return addCFunction("llvm.cttz.v2i32", vector(i32Type(),2), [vector(i32Type(),2),i1Type()]);

			case "llvm.exp.f32" : // float @llvm.exp.f32(float)
				return addCFunction("llvm.exp.f32", f32Type(), [f32Type()]);
			case "llvm.exp.f64" : // double @llvm.exp.f64(double)
				return addCFunction("llvm.exp.f64", f64Type(), [f64Type()]);

			case "llvm.expect.i1" : // i1 @llvm.expect.i1(i1,i1)
				return addCFunction("llvm.expect.i1",i1Type(),[i1Type(), i1Type()]);

			case "llvm.exp2.f32" : // float @llvm.exp2.f32(float)
				return addCFunction("llvm.exp2.f32", f32Type(), [f32Type()]);
			case "llvm.exp2.f64" : // double @llvm.exp2.f64(double)
				return addCFunction("llvm.exp2.f64", f64Type(), [f64Type()]);

			case "llvm.fabs.f32" : // float @llvm.fabs.f32(float)
				return addCFunction("llvm.fabs.f32", f32Type(), [f32Type()]);
			case "llvm.fabs.f64" : // double @llvm.fabs.f64(double)
				return addCFunction("llvm.fabs.f64", f64Type(), [f64Type()]);

			case "llvm.floor.f32" : // float @llvm.floor.f32(float)
				return addCFunction("llvm.floor.f32", f32Type(), [f32Type()]);
			case "llvm.floor.f64" : // double @llvm.floor.f64(double)
				return addCFunction("llvm.floor.f64", f64Type(), [f64Type()]);

			case "llvm.fma.f32" : // float @llvm.fma.f32(float, float, float)
				return addCFunction("llvm.fma.f32", f32Type(), [f32Type(),f32Type(),f32Type()]);
			case "llvm.fma.f64" : // double @llvm.fma.f64(double, double, double)
				return addCFunction("llvm.fma.f64", f64Type(), [f64Type(),f64Type(),f64Type()]);

			case "llvm.fshl.i8" : // i8 @llvm.fshl.i8(i8,i8,i8)
				return addCFunction("llvm.fshl.i8", i8Type(), [i8Type(),i8Type(),i8Type()]);
			case "llvm.fshl.i16" : // i16 @llvm.fshl.i16(i16,i16,i16)
				return addCFunction("llvm.fshl.i16", i16Type(), [i16Type(),i16Type(),i16Type()]);
			case "llvm.fshl.i32" : // i16 @llvm.fshl.i32(i32,i32,i32)
				return addCFunction("llvm.fshl.i32", i32Type(), [i32Type(),i32Type(),i32Type()]);
			case "llvm.fshl.i64" : // i16 @llvm.fshl.i64(i64,i64,i64)
				return addCFunction("llvm.fshl.i64", i64Type(), [i64Type(),i64Type(),i64Type()]);

			case "llvm.fshr.i8" : // i8 @llvm.fshr.i8(i8,i8,i8)
				return addCFunction("llvm.fshr.i8", i8Type(), [i8Type(),i8Type(),i8Type()]);
			case "llvm.fshr.i16" : // i16 @llvm.fshr.i16(i16,i16,i16)
				return addCFunction("llvm.fshr.i16", i16Type(), [i16Type(),i16Type(),i16Type()]);
			case "llvm.fshr.i32" : // i16 @llvm.fshr.i32(i32,i32,i32)
				return addCFunction("llvm.fshr.i32", i32Type(), [i32Type(),i32Type(),i32Type()]);
			case "llvm.fshr.i64" : // i16 @llvm.fshr.i64(i64,i64,i64)
				return addCFunction("llvm.fshr.i64", i64Type(), [i64Type(),i64Type(),i64Type()]);

			case "llvm.log.f32" : // float @llvm.log.f32(float)
				return addCFunction("llvm.log.f32", f32Type(), [f32Type()]);
			case "llvm.log.f64" : // double @llvm.log.f64(double)
				return addCFunction("llvm.log.f64", f64Type(), [f64Type()]);

			case "llvm.log10.f32" : // float @llvm.log10.f32(float)
				return addCFunction("llvm.log10.f32", f32Type(), [f32Type()]);
			case "llvm.log10.f64" : // double @llvm.log10.f64(double)
				return addCFunction("llvm.log10.f64", f64Type(), [f64Type()]);

			case "llvm.log2.f32" : // float @llvm.log2.f32(float)
				return addCFunction("llvm.log2.f32", f32Type(), [f32Type()]);
			case "llvm.log2.f64" : // double @llvm.log2.f64(double)
				return addCFunction("llvm.log2.f64", f64Type(), [f64Type()]);

			case "llvm.pow.f32" : // float @llvm.pow.f32(float,float)
				return addCFunction("llvm.pow.f32", f32Type(), [f32Type(), f32Type()]);
			case "llvm.pow.f64" : // double @llvm.pow.f64(double,double)
				return addCFunction("llvm.pow.f64", f64Type(), [f64Type(), f64Type()]);

			case "llvm.powi.f32" : // float @llvm.powi.f32(float,i32)
				return addCFunction("llvm.powi.f32", f32Type(), [f32Type(), i32Type()]);
			case "llvm.powi.f64" : // double @llvm.powi.f64(double,i32)
				return addCFunction("llvm.powi.f64", f64Type(), [f64Type(), i32Type()]);

			case "llvm.sin.f32" : // float @llvm.sin.f32(float)
				return addCFunction("llvm.sin.f32", f32Type(), [f32Type()]);
			case "llvm.sin.f64" : // double @llvm.sin.f64(double)
				return addCFunction("llvm.sin.f64", f64Type(), [f64Type()]);

			case "llvm.sqrt.f32" : // float @llvm.sqrt.f32(float)
				return addCFunction("llvm.sqrt.f32", f32Type(), [f32Type()]);
			case "llvm.sqrt.f64" : // double @llvm.sqrt.f64(double)
				return addCFunction("llvm.sqrt.f64", f64Type(), [f64Type()]);

			case "llvm.memcpy.p0i8.p0i8.i32" : // void @llvm.memcpy.p0i8.p0i8.i32(i8*,i8*,i32,i1)
				return addCFunction("llvm.memcpy.p0i8.p0i8.i32",voidType(),[bytePointerType(), bytePointerType(), i32Type(), i1Type()]);

			case "llvm.memmove.p0i8.p0i8.i32" : // void @llvm.memmove.p0i8.p0i8.i32(i8*,i8*,i32,i1)
				return addCFunction("llvm.memmove.p0i8.p0i8.i32",voidType(),[bytePointerType(), bytePointerType(), i32Type(), i1Type()]);

			case "llvm.memset.p0i8.i32" : // void @llvm.memset.p0i8.i32(i8*,i8,i32,i1)
				return addCFunction("llvm.memset.p0i8.i32",voidType(),[bytePointerType(), i8Type(), i32Type(), i1Type()]);

			case "llvm.maximum.f32" : // float @llvm.maximum.f32(float,float)
				return addCFunction("llvm.maximum.f32", f32Type(), [f32Type(),f32Type()]);
			case "llvm.maximum.f64" : // double @llvm.maximum.f64(double,double)
				return addCFunction("llvm.maximum.f64", f64Type(), [f64Type(),f64Type()]);

			case "llvm.maxnum.f32" : // float @llvm.maxnum.f32(float,float)
				return addCFunction("llvm.maxnum.f32", f32Type(), [f32Type(),f32Type()]);
			case "llvm.maxnum.f64" : // double @llvm.maxnum.f64(double,double)
				return addCFunction("llvm.maxnum.f64", f64Type(), [f64Type(),f64Type()]);

			case "llvm.minimum.f32" : // float @llvm.minimum.f32(float,float)
				return addCFunction("llvm.minimum.f32", f32Type(), [f32Type(),f32Type()]);
			case "llvm.minimum.f64" : // double @llvm.minimum.f64(double,double)
				return addCFunction("llvm.minimum.f64", f64Type(), [f64Type(),f64Type()]);

			case "llvm.minnum.f32" : // float @llvm.minnum.f32(float,float)
				return addCFunction("llvm.minnum.f32", f32Type(), [f32Type(),f32Type()]);
			case "llvm.minnum.f64" : // double @llvm.minnum.f64(double,double)
				return addCFunction("llvm.minnum.f64", f64Type(), [f64Type(),f64Type()]);

			case "llvm.nearbyint.f32" : // float @llvm.nearbyint.f32(float)
				return addCFunction("llvm.nearbyint.f32", f32Type(), [f32Type()]);
			case "llvm.nearbyint.f64" : // double @llvm.nearbyint.f64(double)
				return addCFunction("llvm.nearbyint.f64", f64Type(), [f64Type()]);

			case "llvm.rint.f32" : // float @llvm.rint.f32(float)
				return addCFunction("llvm.rint.f32", f32Type(), [f32Type()]);
			case "llvm.rint.f64" : // double @llvm.rint.f64(double)
				return addCFunction("llvm.rint.f64", f64Type(), [f64Type()]);

			case "llvm.round.f32" : // float @llvm.round.f32(float)
				return addCFunction("llvm.round.f32", f32Type(), [f32Type()]);
			case "llvm.round.f64" : // double @llvm.round.f64(double)
				return addCFunction("llvm.round.f64", f64Type(), [f64Type()]);

			case "llvm.trunc.f32" : // float @llvm.trunc.f32(float)
				return addCFunction("llvm.trunc.f32", f32Type(), [f32Type()]);
			case "llvm.trunc.f64" : // double @llvm.trunc.f64(double)
				return addCFunction("llvm.trunc.f64", f64Type(), [f64Type()]);

			case "llvm.va_copy" : // void @llvm.va_copy(i8*,i8*)
				return addCFunction("llvm.va_copy", voidType(), [bytePointerType(),bytePointerType()]);
			case "llvm.va_end" : // void @llvm.va_end(i8*)
				return addCFunction("llvm.va_end", voidType(), [bytePointerType()]);
			case "llvm.va_start" : // void @llvm.va_start(i8*)
				return addCFunction("llvm.va_start", voidType(), [bytePointerType()]);

			default : throw new Error("Intrinsic %s not implemented".format(name));
		}
		assert(false);
	}
	LLVMValueRef getOrAddCRTFunction(string name) {
		auto f = getFunction(name);
		if(f) return f;

		switch (name) {
			case "free" : // void @free(i8*)
				return addCFunction("free", voidType(), [bytePointerType()]);

			case "malloc" : // i8* @malloc(i64)
				return addCFunction("malloc", bytePointerType(), [i64Type()]);

			case "memcmp" : // i32 @memcmp(i8*,i8*,i64)
				return addCFunction("memcmp", i32Type(), [bytePointerType(), bytePointerType(), i64Type()]);

			case "printf" : // i32 @printf(i8*, ...)
				return addCFunction("printf", i32Type(), [bytePointerType()], true);
			case "putchar" : // i32 @putchar(i32)
				return addCFunction("putchar", i32Type(), [i32Type()]);

			default : throw new Error("Function %s not implemented".format(name));
		}
		assert(false);
	}
}
