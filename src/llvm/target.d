module llvm.target;

import llvm.all;

final class LLVMX86Target {
	LLVMTargetRef target;
	LLVMTargetMachineRef targetMachine;
	const string targetTriple = "x86_64-pc-windows-msvc"; // "x86_64-pc-win32"
	/**
	 *	e           little-endian
	 *  p:64:64:64  pointer size
     *  i1:8:8      i1 alignment
     *  i8:8:8      i8 alignment
     *  i16:16:16
     *  i32:32:32
     *  i64:64:64
     *  f32:32:32
     *  f64:64:64
     *  v128:128:128    vector type alignment
     *
     *
	 */
	const string dataLayout   =
        "e-"~               // little-endian
        "p:64:64:64-"~      // pointer size
        "i1:8:8-"~          // i1 alignment
        "i8:8:8-"~          // i8 alignment
        "i16:16:16-"~
        "i32:32:32-"~
        "i64:64:64-"~
        "f32:32:32-"~
        "f64:64:64-"~
        "v64:64:64-"~
        "v128:128:128-"~    // vector alignment
        "v256:256:256-"~
        "a0:0:64-"~         // struct alignment
        "S0:64:64-"~        // stack alignment
        "f80:128:128";
	const string cpu	  = "haswell";
	const string features = "+avx"; // +feature,-feature syntax

	this() {
		InitializeX86Target();
		char* error;
		LLVMGetTargetFromTriple(targetTriple.toStringz, &target, &error);
		targetMachine = LLVMCreateTargetMachine(
			target, 
			targetTriple.toStringz, 
			cpu.toStringz, 
			features.toStringz,
			LLVMCodeGenOptLevel.LLVMCodeGenLevelAggressive,
			LLVMRelocMode.LLVMRelocDefault,
			LLVMCodeModel.LLVMCodeModelDefault
		);
	}
	/// return true if the write succeeded
	bool writeToFileASM(LLVMModule mod, string filename) {
		mod.setTargetTriple(targetTriple);
		mod.setDataLayout(dataLayout);

		char* error;
		LLVMBool res = LLVMTargetMachineEmitToFile(
			targetMachine, 
			mod.ref_, 
			filename.toStringz,
			LLVMCodeGenFileType.LLVMAssemblyFile,
			&error);
		//writefln("error=%s", error.fromStringz);
		return 0==res;
	}
	/// return true if the write succeeded
	bool writeToFileOBJ(LLVMModule mod, string filename) {
		mod.setTargetTriple(targetTriple);
		mod.setDataLayout(dataLayout);

		char* error;
		LLVMBool res = LLVMTargetMachineEmitToFile(
			targetMachine, 
			mod.ref_, 
			filename.toStringz,
			LLVMCodeGenFileType.LLVMObjectFile,
			&error);
		//writefln("error=%s", error.fromStringz);
		return 0==res;
	}
private:
	void InitializeX86Target() {
		LLVMInitializeX86TargetInfo();
		LLVMInitializeX86Target();
		LLVMInitializeX86TargetMC();
		LLVMInitializeX86AsmPrinter();
		//LLVMInitializeX86AsmParser();
		//LLVMInitializeX86Disassembler();
	}
}