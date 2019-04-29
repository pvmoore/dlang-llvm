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

	alias LLVMMemoryBufferRef = LLVMOpaqueMemoryBuffer*;
	struct LLVMOpaqueMemoryBuffer {}



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
	void LLVMInitializeAggressiveInstCombiner(LLVMPassRegistryRef R);

	void LLVMInitializeCoroutines(LLVMPassRegistryRef R);

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

	LLVMBool LLVMTargetMachineEmitToFile(
		LLVMTargetMachineRef T,
	    LLVMModuleRef M,
	    immutable(char)* Filename,
	    LLVMCodeGenFileType codegen,
	    char** ErrorMessage);

	LLVMBool LLVMTargetMachineEmitToMemoryBuffer(
		LLVMTargetMachineRef T,
		LLVMModuleRef M,
		LLVMCodeGenFileType codegen,
		char** ErrorMessage,
		LLVMMemoryBufferRef* OutMemBuf
	);


	void LLVMDisposeMessage(char* Message);
	void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);

	LLVMTargetDataRef LLVMCreateTargetData(immutable(char)* StringRep);

	//============================================== Memory Buffer stuff
	char* LLVMGetBufferStart(LLVMMemoryBufferRef MemBuf);
	size_t LLVMGetBufferSize(LLVMMemoryBufferRef MemBuf);
	void LLVMDisposeMemoryBuffer(LLVMMemoryBufferRef MemBuf);
	
	
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
