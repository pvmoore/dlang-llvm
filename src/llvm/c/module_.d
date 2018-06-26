module llvm.c.module_;

import llvm.c.all;

extern(C) {
	alias LLVMModuleRef = LLVMOpaqueModule*;
	struct LLVMOpaqueModule {};

	LLVMModuleRef LLVMModuleCreateWithName(immutable(char)* ModuleID);
	LLVMModuleRef LLVMCloneModule(LLVMModuleRef M);
	void LLVMDisposeModule(LLVMModuleRef M);

	char* LLVMGetTarget(LLVMModuleRef M);
	void LLVMSetTarget(LLVMModuleRef M, immutable(char)* Triple);

	char *LLVMGetDataLayout(LLVMModuleRef M);
	void LLVMSetDataLayout(LLVMModuleRef M, immutable(char)* Triple);

	LLVMBool LLVMVerifyModule(LLVMModuleRef M, LLVMVerifierFailureAction Action,
							  char** OutMessages);

	LLVMValueRef LLVMAddFunction(LLVMModuleRef M, immutable(char)* Name,
								 LLVMTypeRef FunctionTy);

	LLVMValueRef LLVMGetNamedFunction(LLVMModuleRef M, immutable(char)* Name);
	LLVMTypeRef LLVMGetTypeByName(LLVMModuleRef M, immutable(char)* Name);

	LLVMValueRef LLVMGetFirstFunction(LLVMModuleRef M);
	LLVMValueRef LLVMGetNextFunction(LLVMValueRef Fn);
	LLVMValueRef LLVMGetPreviousFunction(LLVMValueRef Fn);
	LLVMValueRef LLVMGetLastFunction(LLVMModuleRef M);
	void LLVMSetModuleInlineAsm(LLVMModuleRef M, immutable(char)* Asm);

	void LLVMDumpModule(LLVMModuleRef M);
	LLVMBool LLVMPrintModuleToFile(
		LLVMModuleRef M, 
		immutable(char)* Filename,
		char **ErrorMessage
	);
	char* LLVMPrintModuleToString(LLVMModuleRef M);
	int LLVMWriteBitcodeToFile(LLVMModuleRef M, immutable(char)* Path);

	LLVMValueRef LLVMAddGlobal(LLVMModuleRef M, LLVMTypeRef Ty, immutable(char)* Name);
	LLVMValueRef LLVMGetNamedGlobal(LLVMModuleRef M, immutable(char)* Name);
	void LLVMDeleteGlobal(LLVMValueRef GlobalVar);
	LLVMValueRef LLVMAddAlias(LLVMModuleRef M, LLVMTypeRef Ty, LLVMValueRef Aliasee,
							  immutable(char)* Name);

	LLVMBool LLVMLinkModules2(LLVMModuleRef Dest, LLVMModuleRef Src);
}

