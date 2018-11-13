module llvm.value;

import llvm.all;

string getName(LLVMValueRef v) {
	return cast(string)LLVMGetValueName(v).fromStringz;
}
void setName(LLVMValueRef v, string name) {
	LLVMSetValueName(v, name.toStringz);
}
LLVMTypeRef getType(LLVMValueRef Val) {
	return LLVMTypeOf(Val);
}
void setAlignment(LLVMValueRef v, uint bytes) {
	LLVMSetAlignment(v, bytes);
}
uint getAlignment(LLVMValueRef V) {
    return LLVMGetAlignment(V);
}
void dump(LLVMValueRef val) {
	LLVMDumpValue(val);
}
string toString(LLVMValueRef v) {
	return cast(string)LLVMPrintValueToString(v).fromStringz;
}
bool isVolatile(LLVMValueRef v) {
	return 1==LLVMGetVolatile(v);
}
void setVolatile(LLVMValueRef v, bool flag=true) {
	LLVMSetVolatile(v, flag.toLLVMBool);
}
LLVMOpcode getConstOpcode(LLVMValueRef constVal) {
	return LLVMGetConstOpcode(constVal);
}
LLVMOpcode getOpcode(LLVMValueRef v) {
	return LLVMGetInstructionOpcode(v);
}
//=====----------------------------------------------------- consts
LLVMValueRef constAllZeroes(LLVMTypeRef Ty) {
	return LLVMConstNull(Ty);
}
LLVMValueRef constAllOnes(LLVMTypeRef t) {
	return LLVMConstAllOnes(t);
}
LLVMValueRef undef(LLVMTypeRef ty) {
	return LLVMGetUndef(ty);
}
LLVMValueRef constPointerToNull(LLVMTypeRef ty) {
	return LLVMConstPointerNull(ty);
}
LLVMValueRef constI1(int value) { 
	return LLVMConstInt(LLVMInt1Type(), value, cast(LLVMBool)true);
}
LLVMValueRef constI8(int value) { 
	return LLVMConstInt(LLVMInt8Type(), value, cast(LLVMBool)true);
}
LLVMValueRef constI16(int value) { 
	return LLVMConstInt(LLVMInt16Type(), value, cast(LLVMBool)true);
}
LLVMValueRef constI32(long value) { 
	return LLVMConstInt(LLVMInt32Type(), value, cast(LLVMBool)true);
}
LLVMValueRef constI64(long value) { 
	return LLVMConstInt(LLVMInt64Type(), value, cast(LLVMBool)true);
}
LLVMValueRef constU32(uint value) { 
	return LLVMConstInt(LLVMInt32Type(), value, cast(LLVMBool)false);
}
LLVMValueRef constF16(float f) {
	return LLVMConstReal(f16Type(), f);
}
LLVMValueRef constF32(float f) {
	return LLVMConstReal(f32Type(), f);
}
LLVMValueRef constF64(double f) {
	return LLVMConstReal(f64Type(), f);
}
LLVMValueRef constNullPointer(LLVMTypeRef t) {
	return LLVMConstPointerNull(t);
}
LLVMValueRef constString(string s, bool nullTerminate=true) {
	return LLVMConstString(s.toStringz, cast(uint)s.length,
						   (!nullTerminate).toLLVMBool);
}
LLVMValueRef constStruct(LLVMValueRef[] values, bool packed) {
	return LLVMConstStruct(values.ptr, cast(uint)values.length, packed.toLLVMBool);
}
LLVMValueRef constNamedStruct(LLVMTypeRef StructTy, LLVMValueRef[] values) {
	return LLVMConstNamedStruct(StructTy, values.ptr, cast(uint)values.length);
}
LLVMValueRef constArray(LLVMTypeRef ElementTy, LLVMValueRef[] values) {
	return LLVMConstArray(ElementTy, values.ptr, cast(uint)values.length);
}
LLVMValueRef constVector(LLVMValueRef[] values) {
	return LLVMConstVector(values.ptr, cast(uint)values.length);
}
//=====--------------------------------------------------- functions
LLVMBasicBlockRef appendBasicBlock(LLVMValueRef func, string name) {
	return LLVMAppendBasicBlock(func, name.toStringz);
}
// param 0 is the first parameter
LLVMValueRef getFunctionParam(LLVMValueRef func, uint index) {
	return LLVMGetParam(func, index);
}
LLVMValueRef[] getFunctionParams(LLVMValueRef func) {
	auto args = new LLVMValueRef[countFunctionArgs(func)];
	LLVMGetParams(func, args.ptr);
	return args;
}
void setFunctionArgAlignment(LLVMValueRef arg, uint align_) {
	LLVMSetParamAlignment(arg, align_);
}
uint countFunctionArgs(LLVMValueRef func) {
	return LLVMCountParams(func);
}
void deleteFunction(LLVMValueRef func) {
	LLVMDeleteFunction(func);
}
void setFunctionCallConv(LLVMValueRef func, LLVMCallConv cc) {
	LLVMSetFunctionCallConv(func, cc);
}
LLVMCallConv getFunctionCallConv(LLVMValueRef func) {
	return LLVMGetFunctionCallConv(func);
}
//=====----------------------------------------------------- metadata
bool hasMetadata(LLVMValueRef instr) {
	return LLVMHasMetadata(instr) != 0;
}
LLVMValueRef getMetadata(LLVMValueRef instr, uint type) {
	return LLVMGetMetadata(instr, type);
}
void setMetadata(LLVMValueRef instr, uint kind, LLVMValueRef node) {
	LLVMSetMetadata(instr, kind, node);
}
//====---------------------------------------------------------- globals
void setInitialiser(LLVMValueRef global, LLVMValueRef constValue) {
	LLVMSetInitializer(global, constValue);
}
LLVMValueRef getInitialiser(LLVMValueRef GlobalVar) {
    return LLVMGetInitializer(GlobalVar);
}
void setThreadLocal(LLVMValueRef global, bool flag) {
	LLVMSetThreadLocal(global, flag.toLLVMBool);
}
void setThreadLocalMode(LLVMValueRef global, LLVMThreadLocalMode mode) {
	LLVMSetThreadLocalMode(global, mode);
}
void setConstant(LLVMValueRef global, bool isConst) {
	LLVMSetGlobalConstant(global, isConst.toLLVMBool);
}
void setExternallyInitialised(LLVMValueRef global, bool flag) {
	LLVMSetExternallyInitialized(global, flag.toLLVMBool);
}
void setVisibility(LLVMValueRef global, LLVMVisibility viz) {
	LLVMSetVisibility(global, viz);
}
LLVMVisibility getVisibility(LLVMValueRef Global) {
    return LLVMGetVisibility(Global);
}
LLVMLinkage getLinkage(LLVMValueRef global) {
    return LLVMGetLinkage(global);
}
void setLinkage(LLVMValueRef global, LLVMLinkage linkage) {
    LLVMSetLinkage(global, linkage);
}
//====----------------------------------------------------------
void setTailCall(LLVMValueRef call, bool flag) {
	LLVMSetTailCall(call, flag.toLLVMBool);
}
LLVMValueRef getElementAsConst(LLVMValueRef v, uint index) {
	return LLVMGetElementAsConstant(v, index);
}
LLVMValueRef clone(LLVMValueRef v) {
	return LLVMInstructionClone(v);
}
//=====--------------------------------------------------- switch
void addCase(LLVMValueRef swtch, 
			 LLVMValueRef value, 
			 LLVMBasicBlockRef toBlock) 
{
	LLVMAddCase(swtch, value, toBlock);
}
//=====--------------------------------------------------- phi
void addIncoming(LLVMValueRef PhiNode, LLVMValueRef[] IncomingValues, LLVMBasicBlockRef[] IncomingBlocks) {
    LLVMAddIncoming(PhiNode, IncomingValues.ptr, IncomingBlocks.ptr, cast(int)IncomingValues.length);
}

/// Add a destination to the indirectbr instruction
void addIndirectBrDestination(LLVMValueRef IndirectBr, LLVMBasicBlockRef Dest) {
	LLVMAddDestination(IndirectBr, Dest);
}
/// Add a catch or filter clause to the landingpad instruction
void addLandingPadClause(LLVMValueRef LandingPad, LLVMValueRef ClauseVal) {
	LLVMAddClause(LandingPad, ClauseVal);
}
/// Set the 'cleanup' flag in the landingpad instruction
void addLandingPadCleanup(LLVMValueRef LandingPad, LLVMBool Val) {
	LLVMSetCleanup(LandingPad, Val);
}


bool isNull(LLVMValueRef v) {
	return 0!=LLVMIsNull(v);
}
bool isConst(LLVMValueRef v) {
	return 0!=LLVMIsConstant(v);
}
bool isConstString(LLVMValueRef v) {
	return 0!=LLVMIsConstantString(v);
}
bool isUndef(LLVMValueRef v) {
	return 0!=LLVMIsUndef(v);
}

bool isI1(LLVMValueRef v) {
	return v.getType().isI1Type;
}
bool isI8(LLVMValueRef v) {
	return v.getType().isI8Type;
}

