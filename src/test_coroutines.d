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
		define i8* @f(i32 %n) {
		entry:
			%id = call token @llvm.coro.id(i32 0, i8* null, i8* null, i8* null)
			%size = call i32 @llvm.coro.size.i32()
			%alloc = call i8* @malloc(i32 %size)
			%hdl = call noalias i8* @llvm.coro.begin(token %id, i8* %alloc)
			br label %loop
		loop:
			%n.val = phi i32 [ %n, %entry ], [ %inc, %loop ]
			%inc = add nsw i32 %n.val, 1
			call void @print(i32 %n.val)
			%0 = call i8 @llvm.coro.suspend(token none, i1 false)
			switch i8 %0, label %suspend [i8 0, label %loop
										  i8 1, label %cleanup]
		cleanup:
			%mem = call i8* @llvm.coro.free(token %id, i8* %hdl)
			call void @free(i8* %mem)
			br label %suspend
		suspend:
			%unused = call i1 @llvm.coro.end(i8* %hdl, i1 false)
			ret i8* %hdl
		}
		*/
		auto f 	   	   = mod.addCFunction("f", bytePointerType(), [i32Type()]);
		auto entryBB   = f.appendBasicBlock("entry");
		auto loopBB	   = f.appendBasicBlock("loop");
		auto cleanupBB = f.appendBasicBlock("cleanup");
		auto suspendBB = f.appendBasicBlock("suspend");

		// entry
		builder.positionAtEndOf(entryBB);

		auto id = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.id"), [
				constI32(0), 
				constPointerToNull(bytePointerType()), 
				constPointerToNull(bytePointerType()), 
				constPointerToNull(bytePointerType())
			], "id");

		auto size  = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.size.i32"), [], "size");
		auto alloc = builder.ccall(mod.getOrAddIntrinsicFunction("malloc"), [size], "alloc");
		auto hdl   = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.begin"), [id, alloc], "hdl");
		builder.br(loopBB);

		//loop
		builder.positionAtEndOf(loopBB);
		auto phi = builder.phi(i32Type(), "n.val");
		auto inc = builder.add(phi, constI32(1), "inc");
		addIncoming(phi, [f.getFunctionParam(0), inc], [entryBB, loopBB]);

		auto p = builder.add(phi, constI32('0'), "p");

		builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [p]);
		/**
		 *	return values: -1 = suspend
		 *					0 = resume
		 *					1 = destroy
		 */
		auto sus = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.suspend"),  [constTokenNone(), constI1(0)], "sw");
		auto sw = builder.switch_(sus, suspendBB, 2);
		addCase(sw, constI8(0), loopBB);
		addCase(sw, constI8(1), cleanupBB);

		// cleanup
		builder.positionAtEndOf(cleanupBB);
		auto mem = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.free"), [id, hdl], "mem");
		builder.ccall(mod.getOrAddIntrinsicFunction("free"), [mem]);
		builder.br(suspendBB);

		// suspend
		builder.positionAtEndOf(suspendBB);

		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.end"), [hdl, constI1(0)]);

		builder.ret(hdl);
		return f;
	}
	auto f = createF();

	LLVMValueRef createMain() {
		/**
		define i32 @main() {
		entry:
			%hdl = call i8* @f(i32 4)
			call void @llvm.coro.resume(i8* %hdl)
			call void @llvm.coro.resume(i8* %hdl)
			call void @llvm.coro.destroy(i8* %hdl)
			ret i32 0
		}
		*/
		auto main  = mod.addCFunction("main", i32Type(), []);
		auto entry = main.appendBasicBlock("entry");
		builder.positionAtEndOf(entry);

		auto hdl = builder.ccall(f, [constI32(4)], "hdl");

		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.resume"), [hdl]);
		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.resume"), [hdl]);
		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.resume"), [hdl]);
		builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.destroy"), [hdl]);

		builder.ret(constI32(0));

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

		writefln("Running main.......\n");
		auto execResult = LLVMRunFunction(engine, main, 0, null);
		auto intVal     = LLVMGenericValueToInt(execResult, true);

		writefln("\n\n....main returned %s\n", intVal);

		//LLVMDisposeExecutionEngine(engine);
	}

	run();

	mod.writeToFileBC("test.bc");

	//auto asm_ = target.writeToStringASM(mod);
	//writefln("asm = %s", asm_);


	writefln("Finished coroutines test");
}