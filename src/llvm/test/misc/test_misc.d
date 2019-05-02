module llvm.test.misc.test_misc;

import llvm.all;
import llvm.test.test_common;

final class TestMisc {
private:
    Tester tester;
	LLVMWrapper wrapper;
	LLVMBuilder builder;
public:
	this(Tester tester) {
		this.tester  = tester;
		this.wrapper = tester.getWrapper();
		this.builder = wrapper.builder;
	}
    void test() {
		writefln("=============================================================");
		writefln("Miscellaneous ...");
		writefln("=============================================================");

		LLVMModule mod1 = wrapper.createModule("test");
		LLVMModule mod2 = wrapper.createModule("test2");
		LLVMModule mod3 = wrapper.createModule("test3");

		makeModule1(mod1, [testExpect(mod1)]);
		makeModule2(mod2);
		makeModule3(mod3);

		/// Link all modules into mod1
		wrapper.linkModules(mod1, mod2, mod3);

		mod1.dumpToConsole();



	}
private:
	LLVMValueRef testExpect(LLVMModule mod) {
		auto f = mod.addCFunction("testExpect", voidType(), []);

		auto entry = f.appendBasicBlock("entry");
		builder.positionAtEndOf(entry);

		auto b = builder.alloca(i32Type(), "a");

		builder.store(
			builder.ccall(mod.getOrAddIntrinsicFunction("expect", i32Type()), [constI32(7),constI32(7)]),
			b
		);

		builder.retVoid();

		writefln("||| testExpect ===>\n%s", f.toString());

		return f;
	}
	void makeModule1(LLVMModule mod, LLVMValueRef[] callFuncs) {

		auto main 		 = mod.addCFunction("main", voidType(), []);
		auto externFunc  = mod.addCFunction("myfunc", voidType(), []);
		auto externFunc2 = mod.addCFunction("myfunc2", voidType(), []);

		/// inline function
		auto inlineFunc = mod.addFastcallFunction("myInlineFunc", i32Type(), [f32Type(), i8Type()]);

		/// add some function attributes
		auto inline   = LLVMAttribute.AlwaysInline;
		auto nounwind = LLVMAttribute.NoUnwind;
		auto readonly = LLVMAttribute.ReadOnly;
		auto nonnull  = LLVMAttribute.NonNull;

		inlineFunc.addFunctionAttribute(inline);
		inlineFunc.addFunctionAttribute(nounwind);
		/// remove a function attribute
		//inlineFunc.removeFunctionAttribute(inline);

		/// return value attribute
		inlineFunc.addFunctionArgAttribute(0, readonly);
		/// parameter attributes
		inlineFunc.addFunctionArgAttribute(1, nonnull);
		inlineFunc.addFunctionArgAttribute(1, readonly);
		inlineFunc.addFunctionArgAttribute(2, readonly);

		auto inlineEntry = inlineFunc.appendBasicBlock("entry");
		builder.positionAtEndOf(inlineEntry);
		builder.ret(constI32(10));
		auto entry = main.appendBasicBlock("entry");
		builder.positionAtEndOf(entry);
		builder.ccall(externFunc, []);
		builder.ccall(externFunc2, []);

		foreach(f; callFuncs) {
			builder.ccall(f, []);
		}

		builder.retVoid();
	}
	void makeModule2(LLVMModule mod) {

		auto myfunc = mod.addCFunction("myfunc", voidType(), []);
		auto entry  = myfunc.appendBasicBlock("entry");
		builder.positionAtEndOf(entry);

		// metadata
		auto m1 = builder.alloca(i32Type());
		auto m2 = builder.store(constI32(7), m1);
		auto m3 = builder.load(m1);
		auto rangeMD = createMetaDataNode([constI32(0), constI32(10)]);
		m1.setMetadata(LLVMMetadata.RANGE, rangeMD);

		builder.retVoid();
	}
	void makeModule3(LLVMModule mod) {

		auto myfunc2 = mod.addCFunction("myfunc2", voidType(), []);
		auto entry   = myfunc2.appendBasicBlock("entry");
		builder.positionAtEndOf(entry);
		builder.retVoid();

		auto myfunc3  = mod.addCFunction("myfunc3", voidType(), []);
		auto entry2 = myfunc3.appendBasicBlock("entry");
		builder.positionAtEndOf(entry2);
		builder.retVoid();
	}
}
