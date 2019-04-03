module llvm.test.test_misc;

import llvm.all;
import llvm.test.test_common;

void testMisc(Tester tester) {

	auto wrapper     = tester.getWrapper();
	auto builder	 = wrapper.builder;
	//auto passManager = wrapper.passManager;

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
}