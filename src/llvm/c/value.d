module llvm.c.value;

import llvm.c.all;

extern(C) {
	alias LLVMValueRef = LLVMOpaqueValue*;
	struct LLVMOpaqueValue {}

	// function
	LLVMValueRef LLVMGetParam(LLVMValueRef FnRef, uint index);
	void LLVMGetParams(LLVMValueRef FnRef, LLVMValueRef *ParamRefs);
	uint LLVMCountParams(LLVMValueRef Fn);
	void LLVMSetFunctionCallConv(LLVMValueRef Fn, LLVMCallConv CC);
	LLVMCallConv LLVMGetFunctionCallConv(LLVMValueRef Fn);
	void LLVMDeleteFunction(LLVMValueRef Fn);

	void LLVMSetParamAlignment(LLVMValueRef Arg, uint align_);

	// misc
	LLVMValueRef LLVMInstructionClone(LLVMValueRef Inst);
	void LLVMSetInstructionCallConv(LLVMValueRef Instr, LLVMCallConv CC);
	void LLVMSetTailCall(LLVMValueRef CallInst, LLVMBool IsTailCall);
	void LLVMAddCase(LLVMValueRef Switch, 
					 LLVMValueRef OnVal,
					 LLVMBasicBlockRef Dest);

	// phi
	void LLVMAddIncoming(LLVMValueRef PhiNode, LLVMValueRef *IncomingValues,
						 LLVMBasicBlockRef *IncomingBlocks, uint Count);

	// const values
	LLVMValueRef LLVMConstNull(LLVMTypeRef Ty); /* all zeroes */
	LLVMValueRef LLVMConstAllOnes(LLVMTypeRef Ty);
	LLVMValueRef LLVMConstPointerNull(LLVMTypeRef Ty);
	LLVMValueRef LLVMConstInt(LLVMTypeRef IntTy, ulong N,
							  LLVMBool SignExtend);
	LLVMValueRef LLVMConstIntOfArbitraryPrecision(LLVMTypeRef IntTy,
												  uint NumWords,
												  ulong* Words);
	LLVMValueRef LLVMConstIntOfString(LLVMTypeRef IntTy, immutable(char)* Text,
									  ubyte Radix);

	LLVMValueRef LLVMConstIntOfStringAndSize(LLVMTypeRef IntTy, immutable(char)* Text,
											 uint SLen, ubyte Radix);
	LLVMValueRef LLVMConstReal(LLVMTypeRef RealTy, double N);
	LLVMValueRef LLVMConstRealOfString(LLVMTypeRef RealTy, char *Text);
	LLVMValueRef LLVMConstRealOfStringAndSize(LLVMTypeRef RealTy, immutable(char)* Text, uint SLen);
	
	LLVMValueRef LLVMConstString(immutable(char)* Str, uint Length,
								 LLVMBool DontNullTerminate);
	LLVMValueRef LLVMConstStruct(LLVMValueRef *ConstantVals, uint Count,
								 LLVMBool Packed);
	LLVMValueRef LLVMConstArray(LLVMTypeRef ElementTy,
								LLVMValueRef *ConstantVals, uint Length);
	LLVMValueRef LLVMConstNamedStruct(LLVMTypeRef StructTy,
									  LLVMValueRef *ConstantVals,
									  uint Count);
	LLVMValueRef LLVMGetElementAsConstant(LLVMValueRef c, uint idx);
	LLVMValueRef LLVMConstVector(LLVMValueRef *ScalarConstantVals, uint Size);


	LLVMTypeRef LLVMTypeOf(LLVMValueRef Val);
	char *LLVMGetValueName(LLVMValueRef Val);
	void LLVMSetValueName(LLVMValueRef Val, immutable(char)* Name);
	void LLVMDumpValue(LLVMValueRef Val);
	char *LLVMPrintValueToString(LLVMValueRef Val);
	void LLVMReplaceAllUsesWith(LLVMValueRef OldVal, LLVMValueRef NewVal);
	LLVMBool LLVMIsConstant(LLVMValueRef Val);
	LLVMBool LLVMIsUndef(LLVMValueRef Val);
	LLVMValueRef LLVMIsAMDNode(LLVMValueRef Val);
	LLVMValueRef LLVMIsAMDString(LLVMValueRef Val);
	LLVMUseRef LLVMGetFirstUse(LLVMValueRef Val);
	LLVMUseRef LLVMGetNextUse(LLVMUseRef U);
	LLVMValueRef LLVMGetUser(LLVMUseRef U);
	LLVMValueRef LLVMGetUsedValue(LLVMUseRef U);
	LLVMValueRef LLVMGetOperand(LLVMValueRef Val, uint Index);
	LLVMUseRef LLVMGetOperandUse(LLVMValueRef Val, uint Index);
	void LLVMSetOperand(LLVMValueRef User, uint Index, LLVMValueRef Val);
	int LLVMGetNumOperands(LLVMValueRef Val);
	LLVMValueRef LLVMGetUndef(LLVMTypeRef Ty);
	LLVMBool LLVMIsNull(LLVMValueRef Val);

	ulong LLVMConstIntGetZExtValue(LLVMValueRef ConstantVal);
	long LLVMConstIntGetSExtValue(LLVMValueRef ConstantVal);
	double LLVMConstRealGetDouble(LLVMValueRef ConstantVal, LLVMBool *losesInfo);
	
	LLVMBool LLVMIsConstantString(LLVMValueRef c);
	immutable(char)* LLVMGetAsString(LLVMValueRef c, size_t* out_);


    void LLVMSetAlignment(LLVMValueRef V, uint Bytes);
	void LLVMSetInitializer(LLVMValueRef GlobalVar, LLVMValueRef ConstantVal);
	void LLVMSetThreadLocal(LLVMValueRef GlobalVar, LLVMBool IsThreadLocal);
	void LLVMSetThreadLocalMode(LLVMValueRef GlobalVar, LLVMThreadLocalMode Mode);
	void LLVMSetGlobalConstant(LLVMValueRef GlobalVar, LLVMBool IsConstant);
	void LLVMSetExternallyInitialized(LLVMValueRef GlobalVar, LLVMBool IsExtInit);
    void LLVMSetVisibility(LLVMValueRef Global, LLVMVisibility Viz);


    uint LLVMGetAlignment(LLVMValueRef V);
    LLVMValueRef LLVMGetInitializer(LLVMValueRef GlobalVar);
    LLVMVisibility LLVMGetVisibility(LLVMValueRef Global);


	LLVMValueRef LLVMConstAdd(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant);

	LLVMLinkage LLVMGetLinkage(LLVMValueRef Global);
	void LLVMSetLinkage(LLVMValueRef Global, LLVMLinkage Linkage);

	LLVMOpcode LLVMGetConstOpcode(LLVMValueRef ConstantVal);
	LLVMOpcode LLVMGetInstructionOpcode(LLVMValueRef Inst);

} 