module test_coroutines;

import llvm.all;

void testCoroutines(LLVMWrapper wrapper) {
    LLVMBuilder builder	 = wrapper.builder;
	auto passManager = wrapper.passManager;
	auto target		 = wrapper.x86Target;

	LLVMLinkInMCJIT();

	writefln("Coroutines ... ");

	LLVMModule mod = wrapper.createModule("CoroTest");

	LLVMValueRef createF() {
		/**
		*  define i8* @f() {
		*	entry:
		*		%id = call token @llvm.coro.id(i32 0, i8* null, i8* null, i8* null)
		*
		*
		*		ret i8* null
		* 	}
		*/
		auto f 	   	   = mod.addCFunction("f", bytePointerType(), []);
		auto entry 	   = f.appendBasicBlock("coro_frame");
		auto begin	   = f.appendBasicBlock("after_frame");
		auto resume	   = f.appendBasicBlock("resume");
		auto cleanup   = f.appendBasicBlock("cleanup");
		auto suspendBB = f.appendBasicBlock("suspend");
		builder.positionAtEndOf(entry);

		// setup coro frame
		auto promise = constPointerToNull(bytePointerType());

		auto id = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.id"), [
				constI32(0), promise, constPointerToNull(bytePointerType()), constPointerToNull(bytePointerType())
			], "id");

		auto size = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.size.i32"), [], "size");
		
		auto alloc = builder.ccall(mod.getOrAddIntrinsicFunction("malloc"), [size], "alloc");

		auto hdl = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.begin"), [
				id, alloc 
			], "hdl");

		// main block
		builder.br(begin);
		builder.positionAtEndOf(begin);

		builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [constI32('1')]);

		/**
		 *	return values: -1 = suspend
		 *					0 = resume
		 *					1 = destroy
		 */
		auto suspend = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.suspend"), [constTokenNone(), constI1(0)], "suspend");

		auto sw = builder.switch_(suspend, suspendBB, 2);
		addCase(sw, constI8(0), resume);
		addCase(sw, constI8(1), cleanup);

		// resume
		builder.positionAtEndOf(resume);

		builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [constI32('2')]);
		builder.br(cleanup);

		// cleanup
		
		//builder.br(cleanup);
		builder.positionAtEndOf(cleanup);

		auto mem = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.free"), [
			id, hdl	
			], "mem");

		builder.ccall(mod.getOrAddIntrinsicFunction("free"), [mem]);

		// suspend
		
		builder.br(suspendBB);
		builder.positionAtEndOf(suspendBB);

		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.end"), [hdl, constI1(0)], "end");

		builder.ret(hdl);
		return f;
	}
	auto f = createF();

	LLVMValueRef createMain() {
		/**
		*	define void @main() {
		*	entry:
		*		%hdl = call i8* @f()
		*		call void @llvm.coro.resume(i8* %hdl)
		*
		*		ret void 
		*	}
		*/
		auto main  = mod.addCFunction("main", voidType(), []);
		auto entry = main.appendBasicBlock("entry");
		builder.positionAtEndOf(entry);

		auto hdl = builder.ccall(f, [], "hdl");

		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.resume"), [hdl]);

		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.destroy"), [hdl]);

		builder.retVoid();

		return main;
	}
	auto main = createMain();

	mod.dumpToConsole();

	writefln("#############################################################");
	writefln("Optimising module ..."); 
	
	passManager.runOnModule(mod); 

	mod.dumpToConsole();

	if(!mod.verify()) {
		writefln("Verify FAILED");
		return;
	} 	 
	writefln("Verify PASSED");

	void run() {
		char* error;
		LLVMExecutionEngineRef engine;
		LLVMMCJITCompilerOptions options;
		options.OptLevel = 3;
		LLVMInitializeMCJITCompilerOptions(&options, 1);

		if(LLVMCreateMCJITCompilerForModule(&engine, mod.ref_, &options, 1, &error)) {
			writefln("Error creating JIT %s", error.fromStringz);
			LLVMDisposeMessage(error);
		} 

		writefln("Running main...");
		auto execResult = LLVMRunFunction(engine, main, 0, null);
		auto intVal     = LLVMGenericValueToInt(execResult, true);

		writefln("\nr=%s", intVal);

		//LLVMDisposeExecutionEngine(engine);
	}

	//run();

	mod.writeToFileBC("test.bc");

	//auto asm_ = target.writeToStringASM(mod);
	//writefln("asm = %s", asm_);


	writefln("Finished coroutines test");
}