module llvm.metadata;

import llvm.all;

enum LLVMMetadata : string {
    // must point to a node of 2 values [min, max)
    // use on load, call and invoke of integer types only
    RANGE = "range"
}

void setMetadata(LLVMValueRef dest, LLVMMetadata mtype, LLVMValueRef metadataNode) {
    LLVMSetMetadata(dest, getKindID(mtype), metadataNode);
}

LLVMValueRef createMetaDataNode(LLVMValueRef[] values) {
    return LLVMMDNode(values.ptr, cast(int)values.length);
}

//====================================================================================
private uint getKindID(LLVMMetadata m) {
    string s = cast(string)m;
    return LLVMGetMDKindID(s.ptr, cast(int)s.length);
}



