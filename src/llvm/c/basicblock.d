module llvm.c.basicblock;

import llvm.c.all;

extern(C) {
	alias LLVMBasicBlockRef = LLVMOpaqueBasicBlock*;
	struct LLVMOpaqueBasicBlock {}

	LLVMBasicBlockRef LLVMAppendBasicBlock(LLVMValueRef Fn, immutable(char)* Name);
	LLVMBasicBlockRef LLVMGetEntryBasicBlock(LLVMValueRef Fn);

	LLVMBasicBlockRef LLVMGetPreviousBasicBlock(LLVMBasicBlockRef BB);
	LLVMBasicBlockRef LLVMGetNextBasicBlock(LLVMBasicBlockRef BB);

}