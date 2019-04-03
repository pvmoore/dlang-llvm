module llvm.test.test_common;

import llvm.all;

final class Tester {
private:
    LLVMWrapper wrapper;
public:
    this(LLVMWrapper wrapper) {
        this.wrapper = wrapper;	

	    wrapper.passManager.addPasses8();

        LLVMLinkInMCJIT();
    }
    auto getWrapper() { return wrapper; }

    void optimise(LLVMModule mod) {
        wrapper.passManager.runOnModule(mod);   
    }
    void verify(LLVMModule mod) {
        if(!mod.verify()) {
            writefln("Verify FAILED");
        } else {	 
            writefln("Verify PASSED");
        }
    }
    void runOnJIT(LLVMModule mod, LLVMValueRef main) {
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

        char* errors;
        LLVMModuleRef o;
        LLVMRemoveModule(engine, mod.ref_, &o, &errors);

		LLVMDisposeExecutionEngine(engine);
	}
}
