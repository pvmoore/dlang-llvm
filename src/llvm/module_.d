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
	LLVMValueRef addFunction(string name, 
							 LLVMTypeRef retType, 
							 LLVMTypeRef[] params, 
							 LLVMCallConv cc,
							 bool vararg=false) 
	{
		auto functionType = LLVMFunctionType(retType, 
											 params.ptr, 
											 cast(int)params.length, 
											 cast(LLVMBool)vararg);
		auto func = LLVMAddFunction(ref_, name.toStringz, functionType);
		LLVMSetFunctionCallConv(func, cc);
		return func;
	}
	LLVMValueRef addCFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, bool vararg=false) 
	{
		return addFunction(name, retType, params, LLVMCallConv.LLVMCCallConv, vararg);
	}
	LLVMValueRef addFastcallFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, bool vararg=false) 
	{
		return addFunction(name, retType, params, LLVMCallConv.LLVMFastCallConv, vararg);
	}
	LLVMValueRef getOrAddIntrinsicFunction(string name) {
		auto f = getFunction(name);
		if(f) return f; 

		switch(name) {
			case "free" : // void @free(i8*)
				return addCFunction("free", voidType(), [bytePointerType()]);
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

			case "llvm.expect.i1" : // i1 @llvm.expect.i1(i1,i1)
				return addCFunction("llvm.expect.i1",i1Type(),[i1Type(), i1Type()]);

			//case "llvm.memset.p0i8.i32" : // void @llvm.memset.p0i8.i32(i8*,i8,i32,i1)
			//	return addCFunction("llvm.memset.p0i8.i32",voidType(),[bytePointerType(), i8Type(), i32Type(), i1Type()]);

			//case "malloc" : // i8* @malloc(i32)
			//	return addCFunction("malloc", bytePointerType(), [i32Type()]);
			case "memcmp" : // i32 @memcmp(i8*,i8*,i64)
				return addCFunction("memcmp", i32Type(), [bytePointerType(), bytePointerType(), i64Type()]);
			//case "llvm.memmove.p0i8.p0i8.i32" : // void @llvm.memmove.p0i8.p0i8.i32(i8*,i8*,i32,i1)
			//	return addCFunction("llvm.memmove.p0i8.p0i8.i32",voidType(),[bytePointerType(), bytePointerType(), i32Type(), i1Type()]);

			case "putchar" : // i32 @putchar(i32)
				return addCFunction("putchar", i32Type(), [i32Type()]);

			default : throw new Error("Intrinsic %s not implemented".format(name));
		}
		assert(false);
	}
}
