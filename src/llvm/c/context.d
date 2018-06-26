module llvm.c.context;

import llvm.c.all;


extern(C) {
	alias LLVMContextRef = LLVMOpaqueContext*;
	struct LLVMOpaqueContext {}

	LLVMContextRef LLVMContextCreate();
	void LLVMContextDispose(LLVMContextRef C);
	LLVMContextRef LLVMGetGlobalContext();

	//LLVMBasicBlockRef LLVMAppendBasicBlockInContext(LLVMContextRef C,
	//												LLVMValueRef Fn,
	//												immutable(char)* Name);
}
