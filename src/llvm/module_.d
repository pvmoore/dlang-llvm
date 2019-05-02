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
	///	eg.
	///	f = getOrAddIntrinsicFunction("expect", i32Type());
	///
	///	Will match function name "@llvm.expect.i32"
	///
	LLVMValueRef getOrAddIntrinsicFunction(string name, LLVMTypeRef type) {

		void expect(bool b) {
			if(!b) throw new Error("type %s not supported".format(type.toString));
		}
		string getName(LLVMTypeRef t) {
			if(t.isInteger) {
				return "i%s".format(t.getNumBits);
			} else if(t.isF16Type) {
				return "f16";
			} else if(t.isF32Type) {
				return "f32";
			} else if(t.isF64Type) {
				return "f64";
			}
			expect(false);
			assert(false);
		}

		string typeName;

		if(type.isInteger || type.isReal) {
			typeName = getName(type);
		} else if(type.isVector) {
			auto eleType = type.getElementType();
			typeName = "v%s%s".format(type.vectorLength, getName(eleType));
		} else {
			expect(false);
		}

		string fullName = "llvm." ~ name ~ "." ~ typeName;

		auto f = getFunction(fullName);
		if(f) return f;

		switch(name) {
			case "bitreverse":
				// i16 @llvm.bitreverse.i16(i16)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type]);
			case "bswap":
				// i16 @llvm.bswap.i16(i16)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type]);
			case "ceil":
				// float @llvm.ceil.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "copysign":
				// float @llvm.copysign.f32(float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type, type]);
			case "cos":
				// float @llvm.cos.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "ctlz":
				// i8 @llvm.ctlz.i8(i8,i1)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type]);
			case "ctpop":
				// i8 @llvm.ctpop.i8(i8,i1)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type]);
			case "cttz":
				// i8 @llvm.cttz.i8(i8,i1)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type]);
			case "exp":
				// float @llvm.exp.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "exp2":
				// float @llvm.exp2.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "expect":
				expect(type.isInteger);
				return addCFunction(fullName, type, [type, type]);
			case "fabs":
				// float @llvm.fabs.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "floor":
				// float @llvm.floor.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "fma":
				// float @llvm.fma.f32(float,float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,type,type]);
			case "fshl":
				// i8 @llvm.fshl.i8(i8,i8,i8)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type,type,type]);
			case "fshr":
				// i8 @llvm.fshr.i8(i8,i8,i8)
				expect(type.isInteger || type.isIntegerVector);
				return addCFunction(fullName, type, [type,type,type]);
			case "log":
				// float @llvm.log.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "log10":
				// float @llvm.log10.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "log2":
				// float @llvm.log2.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "pow":
				// float @llvm.pow.f32(float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,type]);
			case "powi":
				// float @llvm.pow.f32(float,i32)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,i32Type()]);
			case "sin":
				// float @llvm.sin.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "sqrt":
				// float @llvm.sqrt.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "maximum":
				// float @llvm.maximum.f32(float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,type]);
			case "maxnum":
				// float @llvm.maxnum.f32(float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,type]);
			case "minimum":
				// float @llvm.minimum.f32(float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,type]);
			case "minnum":
				// float @llvm.minnum.f32(float,float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type,type]);
			case "nearbyint":
				// float @llvm.nearbyint.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "rint":
				// float @llvm.rint.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "round":
				// float @llvm.round.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);
			case "trunc":
				// float @llvm.trunc.f32(float)
				expect(type.isReal|| type.isRealVector);
				return addCFunction(fullName, type, [type]);

			default:
				throw new Error("Intrinsic %s not implemented".format(fullName));
		}

		assert(false);
	}
	LLVMValueRef getOrAddIntrinsicFunction(string name) {
		auto f = getFunction(name);
		if(f) return f; 

		switch(name) {

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

			case "llvm.memcpy.p0i8.p0i8.i32" : // void @llvm.memcpy.p0i8.p0i8.i32(i8*,i8*,i32,i1)
				return addCFunction("llvm.memcpy.p0i8.p0i8.i32",voidType(),[bytePointerType(), bytePointerType(), i32Type(), i1Type()]);

			case "llvm.memmove.p0i8.p0i8.i32" : // void @llvm.memmove.p0i8.p0i8.i32(i8*,i8*,i32,i1)
				return addCFunction("llvm.memmove.p0i8.p0i8.i32",voidType(),[bytePointerType(), bytePointerType(), i32Type(), i1Type()]);

			case "llvm.memset.p0i8.i32" : // void @llvm.memset.p0i8.i32(i8*,i8,i32,i1)
				return addCFunction("llvm.memset.p0i8.i32",voidType(),[bytePointerType(), i8Type(), i32Type(), i1Type()]);

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
