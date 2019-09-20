module llvm.test.test_common;

import llvm.all;

final class Tester {
private:
    LLVMWrapper wrapper;
public:
    this(LLVMWrapper wrapper) {
        this.wrapper = wrapper;

	    //wrapper.passManager.addPassesO3();
        wrapper.passManager.addPassesO0();

        LLVMLinkInMCJIT();
    }
    auto getWrapper() { return wrapper; }

    void optimise(LLVMModule mod) {
        wrapper.passManager.runOnModule(mod);
    }
    bool verify(LLVMModule mod) {
        if(!mod.verify()) {
            throw new Error("\n!!!!!!! Verify FAILED !!!!!!!!\n");
        }
        writefln("Verify PASSED");
        return true;
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

        if(intVal != 0) {
            throw new Error("\n!!!!  Status code %s !!!!\n".format(intVal));
        }
	}
    /**
     *  Builds a call to printf which will print all args in order.
     *  Also handles creation of global strings.
     */
    void print(Args...)(LLVMModule mod, Args argList) {
        LLVMBuilder b = wrapper.builder;

        auto fmt            = "";
        LLVMValueRef[] args = [];

        static foreach(arg; argList) {
            static if(is(typeof(arg)==string)) {
                args ~= b.globalString(arg);
                fmt  ~= "%s";
                if(arg[$-1] != '\n') fmt ~= " ";
            } else static if(is(typeof(arg)==long)) {
                args ~= constI64(arg);
                fmt  ~= "%lld ";
            } else static if(is(typeof(arg)==int)) {
                args ~= constI32(arg);
                fmt  ~= "%d ";
            } else static if(is(typeof(arg)==float) || is(typeof(arg)==double) || is(typeof(arg)==real)) {
                // printf assumes floats are passed as doubles
                args ~= constF64(arg);
                fmt  ~= "%.4f ";
            } else static if(is(typeof(arg)==bool)) {
                args ~= constI32(arg ? 1 : 0);
                fmt  ~= "%d ";
            } else static if(is(typeof(arg)==LLVMValueRef)) {
                args ~= arg;
                if(arg.getType.isInteger()) fmt ~= "%d ";
                else if(arg.getType.isReal()) fmt = ".4f ";
                else if(arg.getType.isPointer()) fmt = "%lld ";
                else assert(false, "LLVMTypeRef %s not handled".format(arg.getType.toString));
            } else {
                pragma(msg, "ERROR: Unsupported type passed to printf: %s".format(typeof(arg).stringof));
                assert(false);
            }
        }

        auto str = b.globalString(fmt, "fmt");
        args = [constPointerCast(str, bytePointerType())] ~ args;

        b.ccall(mod.getOrAddCRTFunction("printf"), args);
    }
}
