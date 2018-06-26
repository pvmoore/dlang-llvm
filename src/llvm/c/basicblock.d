module llvm.c.basicblock;

import llvm.c.all;

extern(C) {
	alias LLVMBasicBlockRef = LLVMOpaqueBasicBlock*;
	struct LLVMOpaqueBasicBlock {}

	LLVMBasicBlockRef LLVMAppendBasicBlock(LLVMValueRef FnRef, immutable(char)* Name);
}