module llvm.c.llvm4;
/**
 *  New stuff introduced in LLVM 4.0.0
 */
import llvm.c.all;

extern(C) {
    alias LLVMAttributeIndex = uint;

    alias LLVMAttributeRef = LLVMOpaqueAttributeRef*;
    struct LLVMOpaqueAttributeRef {}

    LLVMAttributeRef LLVMCreateEnumAttribute(LLVMContextRef ctx, uint KindID, ulong Val);
    LLVMAttributeRef LLVMCreateStringAttribute(LLVMContextRef C,
                                               immutable(char)*K, uint KLength,
                                               immutable(char)*V, uint VLength);

    void LLVMAddAttributeAtIndex(LLVMValueRef F, LLVMAttributeIndex Idx,
                                 LLVMAttributeRef A);
    void LLVMAddTargetDependentFunctionAttr(LLVMValueRef Fn,
                                            immutable(char)* A,
                                            immutable(char)* V);


    void LLVMRemoveEnumAttributeAtIndex(LLVMValueRef func, LLVMAttributeIndex Idx,
                                        uint KindID);
    void LLVMRemoveStringAttributeAtIndex(LLVMValueRef func,
                                          LLVMAttributeIndex Idx,
                                          immutable(char)* K, uint KLen);


    uint LLVMGetAttributeCountAtIndex(LLVMValueRef func, LLVMAttributeIndex Idx);
    void LLVMGetAttributesAtIndex(LLVMValueRef func, LLVMAttributeIndex Idx,
                                  LLVMAttributeRef* Attrs);
    LLVMAttributeRef LLVMGetEnumAttributeAtIndex(LLVMValueRef F,
                                                 LLVMAttributeIndex Idx,
                                                 uint KindID);
    LLVMAttributeRef LLVMGetStringAttributeAtIndex(LLVMValueRef F,
                                                   LLVMAttributeIndex Idx,
                                                   immutable(char)* K, uint KLen);

    uint LLVMGetEnumAttributeKindForName(immutable(char)* attr_name, size_t attr_len);
    uint LLVMGetEnumAttributeKind(LLVMAttributeRef A);
    ulong LLVMGetEnumAttributeValue(LLVMAttributeRef A);

    immutable(char)* LLVMGetStringAttributeKind(LLVMAttributeRef A, uint* Length);
    immutable(char)* LLVMGetStringAttributeValue(LLVMAttributeRef A, uint* Length);
    LLVMBool LLVMIsEnumAttribute(LLVMAttributeRef A);
    LLVMBool LLVMIsStringAttribute(LLVMAttributeRef A);
}
