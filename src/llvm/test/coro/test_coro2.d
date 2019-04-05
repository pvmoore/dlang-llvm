module llvm.test.coro.test_coro2;

import llvm.all;
import llvm.test.test_common;

/**
    void *f(int n) {
        for(;;) {
            putchar(n+'0');
            <suspend>
            
            print(n+4);
            <suspend>
            n++;
        }
    }
    int main() {
        hdl = f(4);
        <resume>
        <resume>
        <resume>
        <destroy>
    }
 */
final class TestCoro2 {
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
    void testMultipleSuspendPoints() {
        writefln("=============================================================");
        writefln("TestCoro2 - Coroutine with multiple suspend points ...");
        writefln("=============================================================");

        // Should produce 4859

        auto mod  = wrapper.createModule("CoroTest2");
        auto f    = createF(mod);
        auto main = createMain(mod, f);

        //mod.dumpToConsole();

        tester.optimise(mod);
        tester.verify(mod);

	    //writefln("main = %s", main.toString);

        tester.runOnJIT(mod, main);

    }
private:
    /**
        define i32 @main() {
        entry:
            %hdl = call i8* @f(i32 4)               // print 4
            call void @llvm.coro.resume(i8* %hdl)   // print 8
            call void @llvm.coro.resume(i8* %hdl)   // print 5
            call void @llvm.coro.resume(i8* %hdl)   // print 9
            call void @llvm.coro.destroy(i8* %hdl)
            ret i32 0
        }
    */
    LLVMValueRef createMain(LLVMModule mod, LLVMValueRef f) {
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
    /**
    void *f(int n) {
        for(;;) {
            putchar(n+'0');
            <suspend>
            print(n+4);
            <suspend>
            n++;
        }
    }

    define i8* @f(i32 %n) {
	entry:
		%id = call token @llvm.coro.id(i32 0, i8* null, i8* null, i8* null)
		%need.alloc = call i1 @llvm.coro.alloc(token %id)
		br i1 %need.alloc, label %coro.alloc, label %coro.begin
	coro.alloc:	
		%size = call i32 @llvm.coro.size.i32()
		%alloc = call i8* @malloc(i32 %size)
		br label %coro.begin
	coro.begin:
		%hdl = call noalias i8* @llvm.coro.begin(token %id, i8* %alloc)
		br label %loop
		; 
	loop:
		%n.val = phi i32 [ %n, %entry ], [ %inc, %resume ]
		%inc = add nsw i32 %n.val, 1
		call void @print(i32 %n.val)

		; suspend [1]
		%0 = call i8 @llvm.coro.suspend(token none, i1 false)
		switch i8 %0, label %suspend [i8 0, label %resume
									  i8 1, label %cleanup]

    resume:
        %n2 = add i32 4, %n.val 
        call void @print(i32 %n2)

        ; suspend [2]
        %1 = call i8 @llvm.coro.suspend(token none, i1 false)
		switch i8 %1, label %suspend [i8 0, label %loop
									  i8 1, label %cleanup]

	cleanup:
		%mem = call i8* @llvm.coro.free(token %id, i8* %hdl)
		%need.free = br icmp ne i8* %mem, null
		br i1 %need.free, label %coro.free, label %suspend

	coro.free:	
		call void @free(i8* %mem)
		br label %suspend
	suspend:
		%unused = call i1 @llvm.coro.end(i8* %hdl, i1 false)
		ret i8* %hdl
	}
    */
    LLVMValueRef createF(LLVMModule mod) {
        LLVMValueRef f = mod.addCFunction("f", bytePointerType(), [i32Type()]);

        auto entryBB   	  = f.appendBasicBlock("entry");
        auto coroAllocBB  = f.appendBasicBlock("coro.alloc");
        auto coroBeginBB  = f.appendBasicBlock("coro.begin");
        auto loopBB	      = f.appendBasicBlock("loop");
        auto resumeBB	  = f.appendBasicBlock("resume");
        auto cleanupBB    = f.appendBasicBlock("cleanup");
        auto coroFreeBB   = f.appendBasicBlock("coro.free");
        auto suspendBB    = f.appendBasicBlock("suspend");

    // entry
        builder.positionAtEndOf(entryBB);

        auto id = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.id"), [
                constI32(0), 
                constNullPointer(bytePointerType()), 
                constNullPointer(bytePointerType()), 
                constNullPointer(bytePointerType())
            ], "id");

        auto needAlloc = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.alloc"), [id], "need.alloc");
        builder.condBr(needAlloc,coroAllocBB , coroBeginBB);

    // coro.alloc
        builder.positionAtEndOf(coroAllocBB);		
        auto size  = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.size.i32"), [], "size");
        auto alloc = builder.mallocArray(i8Type(), size, "alloc");
        builder.br(coroBeginBB);

    // coro.begin
        builder.positionAtEndOf(coroBeginBB);
        auto phi1 = builder.phi(bytePointerType());
        addIncoming(phi1, [constNullPointer(bytePointerType()), alloc], [entryBB, coroAllocBB]);
        auto hdl = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.begin"), [id, phi1], "hdl");
        builder.br(loopBB);

    // loop
        builder.positionAtEndOf(loopBB);
        auto phi = builder.phi(i32Type(), "n.val");
        auto inc = builder.add(phi, constI32(1), "inc");
        addIncoming(phi, [f.getFunctionParam(0), inc], [coroBeginBB, resumeBB]);

        auto p = builder.add(phi, constI32('0'), "p");
        builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [p]);
        /**
            *	return values: -1 = suspend
            *					0 = resume
            *					1 = destroy
            */
        auto sus = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.suspend"),  [constTokenNone(), constI1(0)], "sw");
        auto sw = builder.switch_(sus, suspendBB, 2);
        addCase(sw, constI8(0), resumeBB);
        addCase(sw, constI8(1), cleanupBB);

    // resume
        builder.positionAtEndOf(resumeBB);
        auto p2 = builder.add(p, constI32(4), "p2");
        builder.ccall(mod.getOrAddIntrinsicFunction("putchar"), [p2]);

        auto sus2 = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.suspend"),  [constTokenNone(), constI1(0)], "sw2");
        auto sw2 = builder.switch_(sus2, suspendBB, 2);
        addCase(sw2, constI8(0), loopBB);
        addCase(sw2, constI8(1), cleanupBB);

    // cleanup
        builder.positionAtEndOf(cleanupBB);
        auto mem = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.free"), [id, hdl], "mem");
        auto needFree = builder.icmp(LLVMIntPredicate.LLVMIntNE, mem, constNullPointer(bytePointerType()), "need.free");
        builder.condBr(needFree, coroFreeBB, suspendBB);

    // coroFreeBB
        builder.positionAtEndOf(coroFreeBB);
        builder.free(mem);
        builder.br(suspendBB);

    // suspend
        builder.positionAtEndOf(suspendBB);

        builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.end"), [hdl, constI1(0)]);

        builder.ret(hdl);  
        return f;
    }
}