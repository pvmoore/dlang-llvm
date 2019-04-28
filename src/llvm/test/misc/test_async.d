module llvm.test.misc.test_async;

import llvm.all;
import llvm.test.test_common;

/**
 * Todo: Combine this with coroutines, make await a suspend point and use a work-stealing thread pool.
 */
final class TestAsyncAwait {
private:
    Tester tester;
    LLVMWrapper wrapper;
    LLVMBuilder builder;

    // win32 functions
    LLVMValueRef CloseHandle;
    LLVMValueRef CreateSemaphoreW;
    LLVMValueRef CreateThread;
    LLVMValueRef GetCurrentThreadId;
    LLVMValueRef ReleaseSemaphore;
    LLVMValueRef Sleep;
    LLVMValueRef WaitForSingleObject;

    // Internal functions
    LLVMValueRef calcValueFunc;
    LLVMValueRef FutureGet;
    LLVMValueRef FutureDestroy;
    LLVMValueRef threadStartFunc;

    // Globals
    LLVMValueRef threadHandle;

    // Types
    LLVMTypeRef futureStructType;       
    LLVMTypeRef securityAttributesType;
    LLVMTypeRef threadStartType;
public:
    this(Tester tester) {
        this.tester  = tester;
        this.wrapper = tester.getWrapper();
        this.builder = wrapper.builder;
    }
    void test() {
        writefln("============================================================="); 
        writefln("TestAsyncAwait - Async await ...");
        writefln("=============================================================");

        auto mod = wrapper.createModule("TestAsyncAwait");

        createGlobals(mod);
        createWindowsFunctions(mod);
        createFutureStruct(mod);

        createCalcValue(mod);
        createThreadStartFunc(mod);
        auto asyncWrap  = createAsyncWrapper(mod, calcValueFunc);
        auto main       = createMain(mod, asyncWrap); 


        //writefln("main = %s", main.toString);
        //writefln("asyncThing = %s", asyncThing.toString);
        //writefln("async wrap = %s", asyncWrap.toString);
        
        if(tester.verify(mod)) {
            tester.optimise(mod);
            tester.verify(mod);

            mod.dumpToConsole();

            tester.runOnJIT(mod, main);
        }

        //mod.dumpToConsole();
    }
private:
    /**
        int main() {
            Future* f = __async_calcValue();

            int value = f.get();

            f.destroy();  
            return 0;
        }
    */
    LLVMValueRef createMain(LLVMModule mod, LLVMValueRef asyncWrap) {
        auto main  = mod.addCFunction("main", i32Type(), []);

        auto entry = main.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] main: Calling __async_calcValue\n");
        auto future = builder.ccall(asyncWrap, []);

        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] main: Calling f.get()\n");
        auto value = builder.ccall(FutureGet, [future], "value"); 

        //auto wait = builder.ccall(WaitForSingleObject, [builder.load(threadHandle), constI32(2000)]);
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] main: Got value", value, "\n");

        builder.ccall(FutureDestroy, [future]);

        builder.ccall(mod.getOrAddIntrinsicFunction("CloseHandle"), [builder.load(threadHandle)]);

        builder.ret(constI32(0));
        return main;
    }
    void createGlobals(LLVMModule mod) {
        threadHandle = mod.addGlobal(bytePointerType(), "threadHandle");
        threadHandle.setInitialiser(constNullPointer(bytePointerType()));
    }
    void createFutureStruct(LLVMModule mod) {
        /*
        // assume T is int
        struct Future <T> { // futureStructType
            void* semaphoreHandle;
            T value;
            bool isValueReady;
        }
        */
        futureStructType = struct_("Future");
        futureStructType.setTypes([bytePointerType(), i32Type(), i8Type()], false);

        /*
        T Future.get(Future* this) {  // FutureGet
            if(this.isValueReady) return this.value;
            WaitForSingleObject(this.semaphoreHandle);
            return this.value;
        }
        */
        {
            FutureGet = mod.addCFunction("Future.Get", i32Type(), [pointerType(futureStructType)]);
            auto entry = FutureGet.appendBasicBlock("entry");
            auto else_ = FutureGet.appendBasicBlock("wait");
            auto then  = FutureGet.appendBasicBlock("return");
            builder.positionAtEndOf(entry);

            auto ptr = FutureGet.getFunctionParam(0);

            auto cond = builder.getStructProperty(ptr, 2);
            cond.setAlignment(4);
            cond.setAtomicOrdering(LLVMAtomicOrdering.LLVMAtomicOrderingMonotonic);
            auto if_  = builder.icmp(LLVMIntPredicate.LLVMIntEQ, cond, constI8(1));
            builder.condBr(if_, then, else_);

        // wait
            builder.positionAtEndOf(else_);

            tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] Future.get: Waiting on semaphore ...\n");
            builder.ccall(WaitForSingleObject, [builder.getStructProperty(ptr, 0), constI32(2000)]);
            builder.br(then);
        // return
            builder.positionAtEndOf(then);
            auto value = builder.getStructProperty(ptr, 1);
            value.setAlignment(4);
            value.setAtomicOrdering(LLVMAtomicOrdering.LLVMAtomicOrderingMonotonic);
            builder.ret(value);
        }
        /*
        void destroy(Future* this) {    // FutureDestroy
            CloseHandle(this.semaphoreHandle);
        }
        */
        {
            FutureDestroy = mod.addCFunction("Future.Destroy", voidType(), [pointerType(futureStructType)]);
            auto entry = FutureDestroy.appendBasicBlock("entry");
            builder.positionAtEndOf(entry);

            auto ptr = FutureDestroy.getFunctionParam(0);
            builder.ccall(CloseHandle, [builder.getStructProperty(ptr, 0)]);
            builder.retVoid();
        }
    }
    /**
     int calcValue() {
         Sleep(1000);
         return 99;
     } 
     */
    void createCalcValue(LLVMModule mod) {
        calcValueFunc = mod.addCFunction("calcValue", i32Type(), []);

        auto entry = calcValueFunc.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        // calculate a value here
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] calcValue: Calculating value (takes 1 second)...\n");
        builder.ccall(Sleep, [constI32(1000)]);
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] calcValue: Value calculated\n");

        builder.ret(constI32(99));
    }
    
    
    void createWindowsFunctions(LLVMModule mod) {
        /** 
        struct SECURITY_ATTRIBUTES {
            uint  nLength;
            void* lpSecurityDescriptor;
            BOOL  bInheritHandle;
        }
        HANDLE CreateSemaphoreW(
            SECURITY_ATTRIBUTES* lpSemaphoreAttributes,
            long                 lInitialCount,
            long                 lMaximumCount,
            wchar*               lpName
        )
        */
        securityAttributesType = struct_("SECURITY_ATTRIBUTES");
        securityAttributesType.setTypes([i32Type(), bytePointerType(), i32Type()], false);

        CreateSemaphoreW = mod.addCFunction("CreateSemaphoreW", bytePointerType(), [
            pointerType(securityAttributesType),
            i32Type(),
            i32Type(),
            i16PointerType()
        ]);

        threadStartType = pointerType(function_(i32Type(), [bytePointerType()]));

        CreateThread = mod.addCFunction("CreateThread", bytePointerType(), [
            pointerType(securityAttributesType),
            i64Type(),          // stack size (0=default)
            threadStartType,    // (void* argsPtr)->DWORD
            bytePointerType(),  // args*
            i32Type(),          // 0 = start immediately
            i32PointerType()    // threadId out    
        ]);

        CloseHandle = mod.addCFunction("CloseHandle", i32Type(), [bytePointerType()]);

        GetCurrentThreadId = mod.addCFunction("GetCurrentThreadId", i32Type(), []);

        ReleaseSemaphore = mod.addCFunction("ReleaseSemaphore", i32Type(), [bytePointerType(), i32Type(), i32PointerType()]);

        Sleep = mod.addCFunction("Sleep", voidType(), [i32Type()]);

        WaitForSingleObject = mod.addCFunction("WaitForSingleObject", i32Type(), [bytePointerType(), i32Type()]);
    }
    void createThreadStartFunc(LLVMModule mod) {
        threadStartFunc = mod.addCFunction("__threadStartFunc", i32Type(), [bytePointerType()]);

        auto entry = threadStartFunc.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        auto futurePtr = builder.pointerCast(threadStartFunc.getFunctionParam(0), pointerType(futureStructType), "futurePtr");

        // call calcValueFunc
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] __threadStartFunc: calling calcValue()\n");
        auto result = builder.ccall(calcValueFunc, [], "result");
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] __threadStartFunc: calcValue() returned", result, "\n");

        // call future.setValue(value)
        //builder.ccall(futureSetValue, [futurePtr, result]);

        // atomically set future value
        auto store1 = builder.setStructProperty(futurePtr, 1, result);
        store1.setAlignment(4);
        store1.setAtomicOrdering(LLVMAtomicOrdering.LLVMAtomicOrderingMonotonic);

        // atomically set future isValueReady
        auto store2 = builder.setStructProperty(futurePtr, 2, constI8(1));
        store2.setAlignment(4);
        store2.setAtomicOrdering(LLVMAtomicOrdering.LLVMAtomicOrderingMonotonic); 

        // signal semaphore here
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] __threadStartFunc: Signalling semaphore\n");
        auto handlePtr = builder.getElementPointer_struct(futurePtr, 0);
        auto semaphoreHandle = builder.load(handlePtr, "semaphoreHandle");

        builder.ccall(ReleaseSemaphore, [semaphoreHandle, constI32(1), constNullPointer(i32PointerType())]);

        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] __threadStartFunc: Finishing\n");

        builder.ret(constI32(0));
    }
    LLVMValueRef createAsyncWrapper(LLVMModule mod, LLVMValueRef calcValue) {
        auto wrap = mod.addCFunction("__async", pointerType(futureStructType), []);

        auto entry = wrap.appendBasicBlock("entry");
        builder.positionAtEndOf(entry);

        // Malloc the Future struct and zero initialise it
        auto futurePtr = builder.malloc(futureStructType, "future");
        builder.store(constAllZeroes(futureStructType), futurePtr);

        // Create semaphore and store it
        auto semaphoreHandle = builder.ccall(CreateSemaphoreW, [
            constNullPointer(pointerType(securityAttributesType)), 
            constI32(0), 
            constI32(1), 
            constNullPointer(i16PointerType())], "semaphoreHandle");

        builder.setStructProperty(futurePtr, 0, semaphoreHandle);

        // Create thread and launch it
        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] __async: Launching __threadStartFunc function\n");
        
        auto threadIdPtr = builder.alloca(i32Type(), "threadId");
        auto t = builder.ccall(mod.getOrAddIntrinsicFunction("CreateThread"), [
            constNullPointer(pointerType(securityAttributesType)),
            constI64(0),
            builder.pointerCast(threadStartFunc,  threadStartType),
            builder.bitcast(futurePtr, bytePointerType()),
            constI32(0),
            threadIdPtr
        ]);
        // Save the thread handle so we can destroy it later
        builder.store(t, threadHandle);

        tester.print(mod, "[", builder.ccall(GetCurrentThreadId, []), "] __async: Thread id = ", builder.load(threadIdPtr),"\n");
        
        // Return Future* back to main

        builder.ret(futurePtr);
        return wrap;
    }
}
