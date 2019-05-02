module llvm.test.misc.test_fastmath;

import llvm.all;
import llvm.test.test_common;

import std.string : indexOf;

/**
    Test using the fast math flag on instructions:
        - fadd
        - fsub
        - fmul
        - fdiv
        - frem
        - fcmp
        - call (Fast-math flags are only valid for calls that return a floating-point scalar or vector type)
 */
final class TestFastMath {
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
        writefln("Fast math functions ...");
        writefln("=============================================================");

        auto mod  = wrapper.createModule("FastMathTest");
        auto main = createMain(mod);

        writefln("\nPre-optimise main = %s", main.toString);

        string mainStr = main.toString;

        assert(mainStr.indexOf("fadd fast")!=-1);
        assert(mainStr.indexOf("fsub fast")!=-1);
        assert(mainStr.indexOf("fmul fast")!=-1);
        assert(mainStr.indexOf("fdiv fast")!=-1);
        assert(mainStr.indexOf("frem fast")!=-1);
        assert(mainStr.indexOf("fcmp fast")!=-1);
        assert(mainStr.indexOf("call fast")!=-1);

        assert(mainStr.indexOf("fadd float 1.")!=-1);
        assert(mainStr.indexOf("fsub float 1.")!=-1);
        assert(mainStr.indexOf("fmul float 1.")!=-1);
        assert(mainStr.indexOf("fdiv float 1.")!=-1);
        assert(mainStr.indexOf("frem float 1.")!=-1);
        assert(mainStr.indexOf("fcmp oeq float 1.")!=-1);
        assert(mainStr.indexOf("call float")!=-1);


        if(tester.verify(mod)) {
            tester.optimise(mod);
            tester.verify(mod);

            writefln("\nOptimised main = %s", main.toString);

            tester.runOnJIT(mod, main);
        }
    }
private:
    LLVMValueRef createMain(LLVMModule mod) {
        auto main  = mod.addCFunction("main", i32Type(), []);

        auto entry = main.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        auto res = builder.alloca(f32Type());
        builder.store(constAllZeroes(f32Type()), res);

        auto aPtr = builder.alloca(f32Type());
        builder.store(constF32(3.1f), aPtr);

        auto a = builder.load(aPtr);

        builder.setFastMath(true);

        /// fadd
        auto add = builder.fadd(a, constF32(1.0f), "add");

        /// fsub
        auto sub = builder.fsub(a, constF32(1.0f), "sub");

        /// fmul
        auto mul = builder.fmul(a, constF32(1.0f), "mul");

        /// fdiv
        auto div = builder.fdiv(a, constF32(1.0f), "div");

        /// frem
        auto rem = builder.frem(a, constF32(1.0f), "rem");

        /// fcmp
        auto cmp = builder.fcmp(LLVMRealPredicate.LLVMRealOEQ, a, constF32(1.0f), "cmp");

        /// call
        auto call = builder.ccall(mod.getOrAddIntrinsicFunction("fabs", f32Type()), [a], "call");

        /// This should not have the 'fast' flag set
        builder.setFastMath(false);

        builder.fadd(constF32(1.0f), a);
        builder.fsub(constF32(1.0f), a);
        builder.fmul(constF32(1.0f), a);
        builder.fdiv(constF32(1.0f), a);
        builder.frem(constF32(1.0f), a);
        builder.fcmp(LLVMRealPredicate.LLVMRealOEQ, constF32(1.0f), a);
        builder.ccall(mod.getOrAddIntrinsicFunction("fabs", f32Type()), [a]);

        builder.ret(constI32(0));
        return main;
    }
}

