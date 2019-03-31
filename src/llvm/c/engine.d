module llvm.c.engine;

import llvm.c.all;

extern(C) {
	alias LLVMExecutionEngineRef = LLVMOpaqueExecutionEngine*;
	alias LLVMGenericValueRef = LLVMOpaqueGenericValue*;
	alias LLVMMCJITMemoryManagerRef = LLVMOpaqueMCJITMemoryManager*;
	struct LLVMOpaqueExecutionEngine {}
	struct LLVMOpaqueGenericValue {}

	struct LLVMOpaqueMCJITMemoryManager {} 

	/*	
	LLVMBool LLVMCreateExecutionEngineForModule(LLVMExecutionEngineRef *OutEE,
												LLVMModuleRef M,
												char** OutError);
	LLVMBool LLVMCreateJITCompilerForModule(LLVMExecutionEngineRef *OutJIT,
											LLVMModuleRef M,
											uint OptLevel,
											char **OutError);

	
	void LLVMDisposeGenericValue(LLVMGenericValueRef GenVal);
	
	
	uint LLVMGenericValueIntWidth(LLVMGenericValueRef GenValRef);
	
	LLVMTargetDataRef LLVMGetExecutionEngineTargetData(LLVMExecutionEngineRef EE);
	
	*/

	LLVMBool LLVMTargetHasJIT(LLVMTargetRef T);

	void LLVMInitializeMCJITCompilerOptions(LLVMMCJITCompilerOptions* PassedOptions, ulong SizeOfPassedOptions);
	LLVMBool LLVMCreateMCJITCompilerForModule(LLVMExecutionEngineRef* OutJIT, LLVMModuleRef M,
											  LLVMMCJITCompilerOptions* PassedOptions, ulong SizeOfPassedOptions,
											  char** OutError);

	void LLVMDisposeExecutionEngine(LLVMExecutionEngineRef EE);

	LLVMGenericValueRef LLVMCreateGenericValueOfInt(LLVMTypeRef Ty, ulong N, LLVMBool IsSigned);
	ulong LLVMGenericValueToInt(LLVMGenericValueRef GenValRef, LLVMBool IsSigned);

	LLVMGenericValueRef LLVMCreateGenericValueOfFloat(LLVMTypeRef TyRef, double N);
	double LLVMGenericValueToFloat(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal);

	LLVMGenericValueRef LLVMRunFunction(LLVMExecutionEngineRef EE, LLVMValueRef func,
										uint NumArgs, LLVMGenericValueRef* Args);
	int LLVMRunFunctionAsMain(LLVMExecutionEngineRef EE, LLVMValueRef F, uint ArgC, char** ArgV, char** EnvP);

	void LLVMAddModule(LLVMExecutionEngineRef EE, LLVMModuleRef M);
	LLVMBool LLVMRemoveModule(LLVMExecutionEngineRef EE, LLVMModuleRef M,
							  LLVMModuleRef *OutMod, char** OutError);

	struct LLVMMCJITCompilerOptions {
		uint OptLevel;
		LLVMCodeModel CodeModel;
		LLVMBool NoFramePointerElim;
		LLVMBool EnableFastISel;
		LLVMMCJITMemoryManagerRef MCJMM;
	}

	void LLVMLinkInInterpreter();
	void LLVMLinkInMCJIT();
    void LLVMLinkInOrcMCJITReplacement();
}
