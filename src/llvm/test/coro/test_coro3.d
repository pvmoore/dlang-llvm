module llvm.test.coro.test_coro3;

import llvm.all;
import llvm.test.test_common;
import llvm.LLVMCoroHelper;

/**
    Use a promise to store/retrieve the current value produced by a coroutine.

    void* primes() {
        value = 1
        <suspend>
        value = 2
        <suspend>
        value = 3
        <suspend>
        value = 5
        <suspend>
        value = 7
    }
    int main() {
        hdl = primes(); 
        <getpromise>    // 1
        <resume>        
        <getpromise>    // 2
        <resume>        
        <getpromise>    // 3
        <resume>        
        <getpromise>    // 5
        <resume>        
        <getpromise>    // 7
        <destroy>
    }
 */
final class TestCoro3 {
private:
    Tester tester;
    LLVMWrapper wrapper;
    LLVMBuilder builder;
    LLVMCoroHelper coro;
public:
    this(Tester tester) {
        this.tester  = tester;
        this.wrapper = tester.getWrapper();
        this.builder = wrapper.builder;
        this.coro    = new LLVMCoroHelper(builder);
    }
    void testPromise() {
        writefln("=============================================================");
        writefln("TestCoro3 - Coroutine with promise ...");
        writefln("=============================================================");

        // Should produce 12357

        auto mod  = wrapper.createModule("CoroTest3");
        coro.setMod(mod);

        auto primes = createPrimes(mod);
        auto main = createMain(mod, primes);

        //writefln("main = %s", main.toString);
        //writefln("primes = %s", primes.toString);

        tester.optimise(mod);
        tester.verify(mod);

        //mod.dumpToConsole();

        //writefln("main = %s", main.toString);

        tester.runOnJIT(mod, main);
    }
private:
    /**
        define i32 @main() {
        entry:
            %hdl = call i8* @primes()               // 1
            call void @llvm.coro.resume(i8* %hdl)   // 2
            call void @llvm.coro.resume(i8* %hdl)   // 3
            call void @llvm.coro.resume(i8* %hdl)   // 5
            call void @llvm.coro.resume(i8* %hdl)   // 7
            call void @llvm.coro.destroy(i8* %hdl)
            ret i32 0
        }
    */
    LLVMValueRef createMain(LLVMModule mod, LLVMValueRef primes) {
        auto main  = mod.addCFunction("main", i32Type(), []);

        auto entry = main.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        auto hdl = builder.ccall(primes, [], "hdl");

        void getPromiseAndPutchar() {
            auto p  = coro.buildLoadPromise(hdl, i32Type(), 4);
            auto p2 = builder.add(p, constI32('0'), "p");
            builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [p2]);
        }
        getPromiseAndPutchar();

        coro.buildResume(hdl);
        getPromiseAndPutchar();

        coro.buildResume(hdl);
        getPromiseAndPutchar();
        
        coro.buildResume(hdl);
        getPromiseAndPutchar();

        coro.buildResume(hdl);
        getPromiseAndPutchar();

        coro.buildDestroy(hdl);

        builder.ret(constI32(0));
        return main;
    }
    LLVMValueRef createPrimes(LLVMModule mod) {
        LLVMValueRef primes = mod.addCFunction("primes", bytePointerType(), []);

        coro.setFunc(primes);

        auto entryBB   = primes.appendBasicBlock("entry");

    // entry:
        builder.positionAtEndOf(entryBB);

        auto promise = builder.alloca(i32Type(), "promise");

        coro.buildFrame(promise);

    // func.start:
        builder.store(constI32(1), promise);    
        coro.buildSuspend(false);    // yield 1

    // resume1:
        builder.store(constI32(2), promise);     
        coro.buildSuspend(false);    // yield 2

    // resume2:
        builder.store(constI32(3), promise);    
        coro.buildSuspend(false);    // yield 3  

    // resume3:
        builder.store(constI32(5), promise);    
        coro.buildSuspend(false);    // yield 5 

    // resume4:
        builder.store(constI32(7), promise);    
        coro.buildSuspend(true);    // yield 7 and set done=true

    // resume5:
        builder.br(coro.suspendBB);

        return primes;
    }
}