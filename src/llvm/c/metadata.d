module llvm.c.metadata;

import llvm.all;

extern(C) {
    uint LLVMGetMDKindIDInContext(LLVMContextRef C, immutable(char)* Name, uint SLen);
    uint LLVMGetMDKindID(immutable(char)* Name, uint SLen);

    LLVMValueRef LLVMMDNodeInContext(LLVMContextRef C, LLVMValueRef* Vals, uint Count);
    LLVMValueRef LLVMMDNode(LLVMValueRef* Vals, uint Count);

    LLVMValueRef LLVMMDStringInContext(LLVMContextRef C, immutable(char)* Str, uint SLen);
    LLVMValueRef LLVMMDString(immutable(char)* Str, uint SLen);

    void LLVMSetMetadata(LLVMValueRef Val, uint KindID, LLVMValueRef Node);
    int LLVMHasMetadata(LLVMValueRef Inst);
    LLVMValueRef LLVMGetMetadata(LLVMValueRef Inst, uint KindID);

    void LLVMAddNamedMetadataOperand(LLVMModuleRef M, immutable(char)* name, LLVMValueRef Val);
    uint LLVMGetNamedMetadataNumOperands(LLVMModuleRef M, immutable(char)* name);
    void LLVMGetNamedMetadataOperands(LLVMModuleRef M, immutable(char)* name, LLVMValueRef *Dest);
}

