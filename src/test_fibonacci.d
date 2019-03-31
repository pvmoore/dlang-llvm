module test_fibonacci;

import llvm.all;

void testFibonacci(LLVMWrapper wrapper) {

	auto builder	 = wrapper.builder;
	auto passManager = wrapper.passManager;
	auto target		 = wrapper.x86Target;

    LLVMModule mod1  = wrapper.createModule("test");
	auto main 		 = mod1.addCFunction("main", voidType(), []);
	auto externFunc  = mod1.addCFunction("myfunc", voidType(), []);
	auto externFunc2 = mod1.addCFunction("myfunc2", voidType(), []);

	// inline function
	auto inlineFunc = mod1.addFastcallFunction("myInlineFunc", i32Type(), [f32Type(), i8Type()]);

	// add some function attributes
    auto inline   = LLVMAttribute.AlwaysInline;
    auto nounwind = LLVMAttribute.NoUnwind;
    auto readonly = LLVMAttribute.ReadOnly;
    auto nonnull  = LLVMAttribute.NonNull;

    inlineFunc.addFunctionAttribute(inline);
    inlineFunc.addFunctionAttribute(nounwind);
    // remove a function attribute
    //inlineFunc.removeFunctionAttribute(inline);

    // return value attribute
    inlineFunc.addFunctionArgAttribute(0, readonly);
    // parameter attributes
    inlineFunc.addFunctionArgAttribute(1, nonnull);
    inlineFunc.addFunctionArgAttribute(1, readonly);
    inlineFunc.addFunctionArgAttribute(2, readonly);


    // remove attribute at parameter 1
    //inlineFunc.removeFunctionArgAttribute(1, readonly);

    //auto att = inlineFunc.getFunctionArgAttributes(1);
    //writefln("att=%s", att);

    //auto att2 = inlineFunc.getFunctionAttributes();
    //writefln("att2=%s", att2);

	auto inlineEntry = inlineFunc.appendBasicBlock("entry");
	builder.positionAtEndOf(inlineEntry);
	builder.ret(constI32(10));
	auto entry = main.appendBasicBlock("entry");
	builder.positionAtEndOf(entry);
	builder.ccall(externFunc, []);
	builder.ccall(externFunc2, []);
	builder.retVoid();
	writefln("================ test module ============="); 
	mod1.dumpToConsole();
	

	LLVMModule mod2 = wrapper.createModule("test2");
	auto main2 = mod2.addCFunction("myfunc", voidType(), []);
	auto entry2 = main2.appendBasicBlock("entry");
	builder.positionAtEndOf(entry2);

    // metadata
    auto m1 = builder.alloca(i32Type());
    auto m2 = builder.store(constI32(7), m1);
    auto m3 = builder.load(m1);
	auto rangeMD = createMetaDataNode([constI32(0), constI32(10)]);
    m1.setMetadata(LLVMMetadata.RANGE, rangeMD);

	builder.retVoid();
	writefln("================ test2 module ============="); 
	mod2.dumpToConsole();

	LLVMModule mod3 = wrapper.createModule("test3");
	auto main3 = mod3.addCFunction("myfunc2", voidType(), []);
	auto entry3 = main3.appendBasicBlock("entry");
	builder.positionAtEndOf(entry3);
	builder.retVoid();
	auto main4 = mod3.addCFunction("myfunc3", voidType(), []);
	auto entry4 = main4.appendBasicBlock("entry");
	builder.positionAtEndOf(entry4);
    builder.retVoid();
	writefln("================ test3 module ============="); 
	mod3.dumpToConsole();

	wrapper.linkModules(mod1, mod2, mod3);
	writefln("=============== after linking test+test2+test3 -> test ============");
	mod1.dumpToConsole();

	LLVMModule mod = wrapper.createModule("fibonacci");

	// fib function
	auto fib = mod.addFastcallFunction(
		"fib",
		i32Type(), 
		[i32Type()],
		false
	);

	auto entryBB	= fib.appendBasicBlock("entry");
	auto case0BB	= fib.appendBasicBlock("case0");
	auto case1BB	= fib.appendBasicBlock("case1");
	auto defaultBB	= fib.appendBasicBlock("case_default");
	auto endBB		= fib.appendBasicBlock("end");
	builder.positionAtEndOf(entryBB);

	auto n = fib.getFunctionParam(0);

	auto swtch = builder.switch_(n, defaultBB, 2);

	swtch.addCase(constI32(0), case0BB);
	swtch.addCase(constI32(1), case1BB);

	builder.positionAtEndOf(case0BB);
	builder.br(endBB);

	builder.positionAtEndOf(case1BB);
	builder.br(endBB);

	builder.positionAtEndOf(defaultBB);
	auto subResult = builder.sub(n, constI32(1));
	auto call1 = builder.fastcall(fib, [subResult]);

	auto subResult2 = builder.sub(n, constI32(2));
	auto call2 = builder.fastcall(fib, [subResult2]);

	auto res_default = builder.add(call1, call2);
	builder.br(endBB);

	builder.positionAtEndOf(endBB);
	auto res = builder.phi(i32Type(), "result");
	auto phi_vals = [ constI32(0), constI32(1), res_default ];
	auto phi_blocks = [ case0BB, case1BB, defaultBB ];
	res.addIncoming(phi_vals, phi_blocks);
	builder.ret(res);

	bool ok = true;

    writefln("=============== fibonacci ============");
	mod.dumpToConsole();

	if(!mod.verify()) {
	    ok = false;
		writefln("verification failed");
	} else {
		writefln("verification passed");
	}

	passManager.runOnModule(mod);

	if(!mod.verify()) {
	    ok = false;
		writefln("verification failed after opt");
	} else {
		writefln("verification passed after opt");
		writefln("=============== after optimisation ======================");
		mod.dumpToConsole();
	}

	if(!mod.writeToFileLL("temp.ll")) {
	    ok = false;
		writefln("failed to write LL");
	}
	if(!mod.writeToFileBC("temp.bc")) {
	    ok = false;
		writefln("failed to write BC");
	}
	if(!target.writeToFileASM(mod, "temp.asm")) {
	    ok = false;
		writefln("failed to write ASM");
	}
	if(!target.writeToFileOBJ(mod, "temp.obj")) {
	    ok = false;
		writefln("failed to write OBJ");
	}

	string assembly = target.writeToStringASM(mod);
	ok |= assembly.length > 0;

    if(ok)
	    writefln("-- All Good --");
    else
        writefln("-- FAILURE --");
}