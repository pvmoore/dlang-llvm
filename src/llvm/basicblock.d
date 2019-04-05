module llvm.basicblock;

import llvm.all;

LLVMBasicBlockRef getPrevious(LLVMBasicBlockRef block) {
    return LLVMGetPreviousBasicBlock(block);
}
LLVMBasicBlockRef getNext(LLVMBasicBlockRef block) {
    return LLVMGetNextBasicBlock(block);
}
