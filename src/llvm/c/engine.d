module llvm.c.engine;

import llvm.c.all;
/*
extern(C) {
	alias LLVMExecutionEngineRef = LLVMOpaqueExecutionEngine*;
	alias LLVMGenericValueRef = LLVMOpaqueGenericValue*;
	struct LLVMOpaqueExecutionEngine {}
	struct LLVMOpaqueGenericValue {}

	LLVMBool LLVMCreateExecutionEngineForModule(LLVMExecutionEngineRef *OutEE,
												LLVMModuleRef M,
												char** OutError);
	LLVMBool LLVMCreateJITCompilerForModule(LLVMExecutionEngineRef *OutJIT,
											LLVMModuleRef M,
											uint OptLevel,
											char **OutError);

	void LLVMDisposeExecutionEngine(LLVMExecutionEngineRef EE);
	void LLVMDisposeGenericValue(LLVMGenericValueRef GenVal);
	LLVMBool LLVMRemoveModule(LLVMExecutionEngineRef EE, LLVMModuleRef M,
							  LLVMModuleRef *OutMod, char** OutError);
	LLVMGenericValueRef LLVMRunFunction(LLVMExecutionEngineRef EE, LLVMValueRef F,
										uint NumArgs,
										LLVMGenericValueRef *Args);
	uint LLVMGenericValueIntWidth(LLVMGenericValueRef GenValRef);
	LLVMGenericValueRef LLVMCreateGenericValueOfFloat(LLVMTypeRef TyRef, double N);
	LLVMGenericValueRef LLVMCreateGenericValueOfInt(LLVMTypeRef Ty,
													ulong N,
													LLVMBool IsSigned);
	double LLVMGenericValueToFloat(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal);
	ulong LLVMGenericValueToInt(LLVMGenericValueRef GenValRef,
								LLVMBool IsSigned);
	LLVMTargetDataRef LLVMGetExecutionEngineTargetData(LLVMExecutionEngineRef EE);


    void LLVMLinkInOrcMCJITReplacement();
}
*/