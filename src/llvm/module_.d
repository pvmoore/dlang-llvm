module llvm.module_;

import llvm.all;

final class LLVMModule {
	LLVMModuleRef ref_;
	string name;

	this(string name) {
		this.name = name;
		this.ref_ = LLVMModuleCreateWithName(name.toStringz);
	}
	void destroy() {
		LLVMDisposeModule(ref_);
	}
	void setTargetTriple(string triple) {
		LLVMSetTarget(ref_, triple.toStringz);
	}
	void setDataLayout(string layout) {
		LLVMSetDataLayout(ref_, layout.toStringz);
	}
	LLVMValueRef addFunction(string name, 
							 LLVMTypeRef retType, 
							 LLVMTypeRef[] params, 
							 LLVMCallConv cc,
							 bool vararg=false) 
	{
		auto functionType = LLVMFunctionType(retType, 
											 params.ptr, 
											 cast(int)params.length, 
											 cast(LLVMBool)vararg);
		auto func = LLVMAddFunction(ref_, name.toStringz, functionType);
		LLVMSetFunctionCallConv(func, cc);
		return func;
	}
	LLVMValueRef addCFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, bool vararg=false) 
	{
		return addFunction(name, retType, params, LLVMCallConv.LLVMCCallConv, vararg);
	}
	LLVMValueRef addFastcallFunction(string name, LLVMTypeRef retType, LLVMTypeRef[] params, bool vararg=false) 
	{
		return addFunction(name, retType, params, LLVMCallConv.LLVMFastCallConv, vararg);
	}
	LLVMValueRef addGlobal(LLVMTypeRef type, string name=null) {
		return LLVMAddGlobal(ref_, type, name.toStringz);
	}
	LLVMValueRef addAlias(LLVMTypeRef type, LLVMValueRef aliasee, string name) {
		return LLVMAddAlias(ref_, type, aliasee, name.toStringz);
	}
	void setInlineAsm(string asmStr) {
		LLVMSetModuleInlineAsm(ref_, asmStr.toStringz);
	}
	LLVMTypeRef getType(string name) {
		return LLVMGetTypeByName(ref_, name.toStringz);
	}
	LLVMValueRef getFunction(string name) {
		return LLVMGetNamedFunction(ref_, name.toStringz);
	}
	LLVMValueRef getGlobal(string name) {
		return LLVMGetNamedGlobal(ref_, name.toStringz);
	}
	void deleteGlobal(LLVMValueRef g) {
		LLVMDeleteGlobal(g);
	}
	bool verify() {
		char* messages;
		LLVMBool isBroken = LLVMVerifyModule(
			ref_, 
			LLVMVerifierFailureAction.LLVMPrintMessageAction, 
			&messages
		);
		LLVMDisposeMessage(messages);
		return 0==isBroken;
	}
	void dump() {
		LLVMDumpModule(ref_);
	}
	string dumpToString() {
        return cast(string)LLVMPrintModuleToString(ref_).fromStringz;
	}
	void dumpToConsole() {
	    writeln(dumpToString());
	}
	bool writeToFileLL(string filename) {
		char* error;
		return 0==LLVMPrintModuleToFile(ref_, filename.toStringz, &error);
	}
	bool writeToFileBC(string filename) {
		return 0==LLVMWriteBitcodeToFile(ref_, filename.toStringz);
	}
}
