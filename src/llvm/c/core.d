module llvm.c.core;

import llvm.c.all;

extern(C) {
	alias LLVMBool = int;

	alias LLVMUseRef = LLVMOpaqueUse*;
	struct LLVMOpaqueUse {}

	//alias LLVMMCJITMemoryManagerRef = LLVMOpaqueMCJITMemoryManager*;
	//struct LLVMOpaqueMCJITMemoryManager {}

	alias LLVMTargetDataRef = LLVMOpaqueTargetData*;
	struct LLVMOpaqueTargetData {}

	alias LLVMTargetRef = LLVMTarget*;
	struct LLVMTarget {}

	alias LLVMTargetMachineRef = LLVMOpaqueTargetMachine*;
	struct LLVMOpaqueTargetMachine {}

	alias LLVMPassRegistryRef = LLVMOpaquePassRegistry*;
    struct LLVMOpaquePassRegistry {}



	void LLVMInitializeCore(LLVMPassRegistryRef R);
	void LLVMShutdown();
	
	LLVMPassRegistryRef LLVMGetGlobalPassRegistry();
	void LLVMInitializeScalarOpts(LLVMPassRegistryRef R);
	void LLVMInitializeAnalysis(LLVMPassRegistryRef R);
	void LLVMInitializeCodeGen(LLVMPassRegistryRef R);
	void LLVMInitializeInstCombine(LLVMPassRegistryRef R);
	void LLVMInitializeInstrumentation(LLVMPassRegistryRef R);
	void LLVMInitializeObjCARCOpts(LLVMPassRegistryRef R);
	void LLVMInitializeTarget(LLVMPassRegistryRef R);
	void LLVMInitializeTransformUtils(LLVMPassRegistryRef R);
	void LLVMInitializeVectorization(LLVMPassRegistryRef R);
	void LLVMInitializeIPO(LLVMPassRegistryRef R);
	void LLVMInitializeIPA(LLVMPassRegistryRef R);

	void LLVMAddAnalysisPasses(LLVMTargetMachineRef T, LLVMPassManagerRef PM);

	char *LLVMGetDefaultTargetTriple();
	LLVMBool LLVMGetTargetFromTriple(immutable(char)* TripleStr, LLVMTargetRef *T,
									 char **ErrorMessage);
	char* LLVMGetTargetName(LLVMTargetRef T);
	char * LLVMGetTargetDescription(LLVMTargetRef T);

	LLVMTargetMachineRef LLVMCreateTargetMachine(LLVMTargetRef T,
												 immutable(char)* Triple, 
												 immutable(char)* CPU, 
												 immutable(char)* Features,
												 LLVMCodeGenOptLevel Level, 
												 LLVMRelocMode Reloc,
												 LLVMCodeModel CodeModel);
	char* LLVMGetTargetMachineCPU(LLVMTargetMachineRef T);
	char* LLVMGetTargetMachineFeatureString(LLVMTargetMachineRef T);
	LLVMBool LLVMTargetHasAsmBackend(LLVMTargetRef T);
	LLVMBool LLVMTargetMachineEmitToFile(LLVMTargetMachineRef T, 
										 LLVMModuleRef M,
										 immutable(char)* Filename, 
										 LLVMCodeGenFileType codegen, 
										 char** ErrorMessage);
	void LLVMDisposeMessage(char* Message);
	void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);

	LLVMTargetDataRef LLVMCreateTargetData(immutable(char)* StringRep);

	
	
	/*struct LLVMMCJITCompilerOptions {
		uint OptLevel;
		LLVMCodeModel CodeModel;
		LLVMBool NoFramePointerElim;
		LLVMBool EnableFastISel;
		LLVMMCJITMemoryManagerRef MCJMM;
	}
	//void LLVMLinkInInterpreter();
	//void LLVMLinkInMCJIT();
	//void LLVMLinkInOrcMCJITReplacement(); // On Request Compilation
	//LLVMBool LLVMTargetHasJIT(LLVMTargetRef T);
	//void LLVMInitializeMCJITCompilerOptions(LLVMMCJITCompilerOptions *PassedOptions,
	//											size_t SizeOfPassedOptions);
	//LLVMBool LLVMCreateMCJITCompilerForModule(LLVMExecutionEngineRef *OutJIT, LLVMModuleRef M,
	//										  LLVMMCJITCompilerOptions *PassedOptions, size_t SizeOfPassedOptions,
	//										  char **OutError);
	*/
	//===--------------------------------------------- All targets
	void LLVMInitializeAllTargetInfos();
	void LLVMInitializeAllTargets();
	void LLVMInitializeAllTargetMCs();
	void LLVMInitializeAllAsmPrinters();
	void LLVMInitializeAllAsmParsers();
	void LLVMInitializeAllDisassemblers();
	//===--------------------------------------------- X86 target
	void LLVMInitializeX86TargetInfo();
	void LLVMInitializeX86Target();
	void LLVMInitializeX86TargetMC();
	void LLVMInitializeX86AsmParser();
	void LLVMInitializeX86AsmPrinter();
	void LLVMInitializeX86Disassembler();
}
