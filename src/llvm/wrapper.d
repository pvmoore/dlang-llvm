module llvm.wrapper;

import llvm.all;

final class LLVMWrapper {
	LLVMBuilder builder;
	LLVMPassManager passManager;
	LLVMX86Target x86Target;
	LLVMModule[string] modules;

	this() {
		LLVMPassRegistryRef passRegistry = LLVMGetGlobalPassRegistry();

		LLVMInitializeCore(passRegistry);
		LLVMInitializeInstrumentation(passRegistry);
		LLVMInitializeObjCARCOpts(passRegistry);
		LLVMInitializeTarget(passRegistry);
		LLVMInitializeTransformUtils(passRegistry);
		LLVMInitializeInstCombine(passRegistry);
		LLVMInitializeAggressiveInstCombiner(passRegistry);
		LLVMInitializeCodeGen(passRegistry);
		LLVMInitializeAnalysis(passRegistry);
		LLVMInitializeScalarOpts(passRegistry);
		LLVMInitializeVectorization(passRegistry);
		LLVMInitializeIPO(passRegistry);
		LLVMInitializeIPA(passRegistry);


		this.x86Target   = new LLVMX86Target();
		this.builder	 = new LLVMBuilder();
		this.passManager = new LLVMPassManager(x86Target);
	}
	void destroy() {
		foreach(m; modules.values) m.destroy();
		passManager.destroy();
		builder.destroy();
		LLVMShutdown();
	}
	LLVMModule createModule(string name) {
		auto m = new LLVMModule(name);
        m.setTargetTriple(x86Target.targetTriple);
        m.setDataLayout(x86Target.dataLayout);

		modules[name] = m;
		return m;
	}
	/// links module b into dest and destroys module b
	/// returns true on success
	bool linkModules(LLVMModule dest, LLVMModule[] others...) {
		foreach(LLVMModule o; others) {
			LLVMBool res = LLVMLinkModules2(dest.ref_, o.ref_);
			if(res!=0) return false;
			modules.remove(o.name);
		}
		return true;
	}
}