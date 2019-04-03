module llvm.test.test_fib;

import llvm.all;
import llvm.test.test_common;

/**
    int fib(int n) {
        
    }
    int main() {
        fib(6);
    }
 */
final class TestFib {
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
        writefln("Fibonacci ...");
        writefln("=============================================================");

        // Should produce 8

        auto mod  = wrapper.createModule("FibTest");
        auto fib  = createFib(mod);
        auto main = createMain(mod, fib);

        //writefln("main = %s", main.toString);
        //writefln("fib = %s", fib.toString);
        //writefln("asm = %s", wrapper.x86Target.writeToStringASM(mod));

        tester.optimise(mod);
        tester.verify(mod);

        mod.dumpToConsole();

        tester.runOnJIT(mod, main);
    }
private:
    /**
        define i32 @main() {
        entry:
            %f = call fastcc i32 @fib(i32 6)
            %ch = add i32 %f, 48
            %0 = i32 @putchar(i32 %ch)
            ret i32 0
        }
    */
    LLVMValueRef createMain(LLVMModule mod, LLVMValueRef fib) {
        auto main  = mod.addCFunction("main", i32Type(), []);

        auto entry = main.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        auto f = builder.fastcall(fib, [constI32(6)], "f");
        auto ch = builder.add(f, constI32('0'), "ch"); 
        builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [ch]);

        builder.ret(constI32(0));
        return main;
    }
    /**
    int fib(int n) {
        return n<2 ? n : fib(n-1) + fib(n-2);
    }

    declare i32 @fib(i32 %0) {
    entry:
        switch i8 %0, label %case_default [i32 0, label %case0
                                           i32 1, label %case1]
    case0:
        br label %end
    case1:
        br label %end
    case_default:
        %a = sub i32 %0, 1
        %c1 = call i32 @fib(i32 %a)
        %b = sub i32 %0, 2
        %c2 = call i32 @fib(i32 %b)
        %r = add i32 %c1, %c2
        br label %end
    end:
        %res = phi i32 [ i32 0, %case0 ], [ i32 1, %case1 ], [ %r, %case_default]
        ret i32 %res    
    }
     */
    LLVMValueRef createFib(LLVMModule mod) {
        auto fib = mod.addFastcallFunction("fib", i32Type(),  [i32Type()]);

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
        auto a = builder.sub(n, constI32(1), "a");
        auto c1 = builder.fastcall(fib, [a], "c1");

        auto b = builder.sub(n, constI32(2), "b");
        auto c2 = builder.fastcall(fib, [b], "c2");

        auto r = builder.add(c1, c2, "r");
        builder.br(endBB);

        builder.positionAtEndOf(endBB);
        auto res = builder.phi(i32Type(), "res");
        auto phi_vals = [ constI32(0), constI32(1), r ];
        auto phi_blocks = [ case0BB, case1BB, defaultBB ];
        res.addIncoming(phi_vals, phi_blocks);
        builder.ret(res);

        return fib;
    }
}