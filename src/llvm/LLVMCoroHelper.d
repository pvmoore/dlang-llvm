module llvm.LLVMCoroHelper;

import llvm.all;
/**
 *  Helper class for creating coroutines.
 *
 *  See examples here:
 *  http://llvm.org/docs/Coroutines.html
 */

final class LLVMCoroHelper {
private:
    LLVMBuilder builder;
    LLVMModule mod;
    LLVMValueRef func;
public:
    LLVMBasicBlockRef suspendBB, cleanupBB;

    this(LLVMBuilder builder) {
        this.builder = builder;
    }
    auto setMod(LLVMModule mod) {
        this.mod = mod;
        setFunc(null);
        return this;
    }
    auto setFunc(LLVMValueRef func) {
        assert(mod);
        this.func      = func;
        this.suspendBB = null;
        this.cleanupBB = null;
        return this;
    }
    /** 
     *  Builds standard coro function entry.
     *  Assumes entry block has been created and builder is positioned after it.
     *  Returns the coro hdl
     */
    LLVMValueRef buildFrame(LLVMValueRef promise = null) {
        assert(mod);
        assert(func);

        auto entryBB      = func.getEntryBasicBlock(); assert(entryBB);
        auto coroAllocBB  = func.appendBasicBlock("coro.alloc");
        auto coroBeginBB  = func.appendBasicBlock("coro.begin");
        auto coroReadyBB = func.appendBasicBlock("func.start");

        cleanupBB = func.appendBasicBlock("coro.cleanup");
        auto coroFreeBB   = func.appendBasicBlock("coro.free");
        suspendBB = func.appendBasicBlock("coro.suspend");

        if(promise is null) {
            promise = constNullPointer(bytePointerType());
        } else {
            assert(promise.getType.isPointer);
            if(!promise.getType.getElementType.isI8Type) {
                promise = builder.bitcast(promise, bytePointerType(), "promise");
            }
        }

        auto id = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.id"), [
            constI32(0), promise, 
            constNullPointer(bytePointerType()), constNullPointer(bytePointerType())], "id");

        auto needAlloc = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.alloc"), [id], "need.alloc");
        builder.condBr(needAlloc, coroAllocBB, coroBeginBB);

    // coro.alloc:
        builder.positionAtEndOf(coroAllocBB);
        auto size  = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.size.i32"), [], "size");
        auto alloc = builder.mallocArray(i8Type(), size, "alloc");
        builder.br(coroBeginBB);

    // coro.begin:
        builder.positionAtEndOf(coroBeginBB);
        auto phi1 = builder.phi(bytePointerType());
        addIncoming(phi1, [constNullPointer(bytePointerType()), alloc], [entryBB, coroAllocBB]);
        auto hdl = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.begin"), [id, phi1], "hdl");
        builder.br(coroReadyBB);

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

    // coro.after.setup:    
        builder.positionAtEndOf(coroReadyBB);

        return hdl;
    }
    /**
     *  Builds a suspend point.
     */
    void buildSuspend(bool isLast, LLVMValueRef save = null) {
        assert(suspendBB);
        assert(cleanupBB);

        auto resumeBB = func.appendBasicBlock("resume");

        if(save is null) {
            save = constTokenNone();
        }

        /**
        *	return values: -1 = suspend
        *					0 = resume
        *					1 = destroy
        *
        *   2nd arg = true if this is the final suspend.
        */
        auto sus = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.suspend"),  [save, constI1(isLast ? 1 : 0)], "sus");
        auto sw = builder.switch_(sus, suspendBB, 2);
        addCase(sw, constI8(0), resumeBB);
        addCase(sw, constI8(1), cleanupBB);

        builder.positionAtEndOf(resumeBB);
    }
    LLVMValueRef buildSave(LLVMValueRef hdl) {
        return builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.save"), [hdl]);
    }
    void buildResume(LLVMValueRef hdl) {
        builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.resume"), [hdl]);
    }
    void buildDestroy(LLVMValueRef hdl) {
        builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.destroy"), [hdl]);
    }
    /**
     *  Returns (i1 true) if last suspend point for coro hdl has been reached.
     */
    LLVMValueRef buildIsDone(LLVMValueRef hdl) {
        return builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.done"), [hdl], "done");
    }
    /** 
     *  Loads the promise value for coro hdl.
     *  eg. auto p = buildLoadPromise(hdl, i32Type(), 4);
     */
    LLVMValueRef buildLoadPromise(LLVMValueRef hdl, LLVMTypeRef type, uint align_) {
        auto p  = builder.ccall(mod.getOrAddIntrinsicFunction("llvm.coro.promise"), [hdl, constI32(align_), constI1(0)], "p");
        auto p2 = builder.bitcast(p, pointerType(type), "p2");
        auto p3 = builder.load(p2, "promise.value");
        return p3;
    }
}