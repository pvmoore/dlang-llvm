module llvm.c.type;

import llvm.c.all;

extern(C) {
	alias LLVMTypeRef = LLVMOpaqueType*;
	struct LLVMOpaqueType {};

	LLVMTypeKind LLVMGetTypeKind(LLVMTypeRef Ty);
	LLVMBool LLVMTypeIsSized(LLVMTypeRef Ty);

	//void LLVMDumpType(LLVMTypeRef Val);
	char *LLVMPrintTypeToString(LLVMTypeRef Val);

	LLVMTypeRef LLVMInt1Type();
	LLVMTypeRef LLVMInt8Type();
	LLVMTypeRef LLVMInt16Type();
	LLVMTypeRef LLVMInt32Type();
	LLVMTypeRef LLVMInt64Type();
	LLVMTypeRef LLVMIntType(uint NumBits);
	uint LLVMGetIntTypeWidth(LLVMTypeRef IntegerTy);

	LLVMTypeRef LLVMHalfType();
	LLVMTypeRef LLVMFloatType();
	LLVMTypeRef LLVMDoubleType();
	LLVMTypeRef LLVMX86FP80Type();
	LLVMTypeRef LLVMFP128Type();
	LLVMTypeRef LLVMPPCFP128Type();

	LLVMTypeRef LLVMTokenTypeInContext(LLVMContextRef c);

	LLVMTypeRef LLVMFunctionType(LLVMTypeRef ReturnType,
								 LLVMTypeRef *ParamTypes, uint ParamCount,
								 LLVMBool IsVarArg);
	LLVMBool LLVMIsFunctionVarArg(LLVMTypeRef FunctionTy);
	LLVMTypeRef LLVMGetReturnType(LLVMTypeRef FunctionTy);
	uint LLVMCountParamTypes(LLVMTypeRef FunctionTy);
	void LLVMGetParamTypes(LLVMTypeRef FunctionTy, LLVMTypeRef *Dest);
	LLVMTypeRef LLVMStructType(LLVMTypeRef *ElementTypes, uint ElementCount,
							   LLVMBool Packed);
	LLVMTypeRef LLVMStructCreateNamed(LLVMContextRef C, const char *Name);
	char *LLVMGetStructName(LLVMTypeRef Ty);
	void LLVMStructSetBody(LLVMTypeRef StructTy, LLVMTypeRef *ElementTypes,
						   uint ElementCount, LLVMBool Packed);
	uint LLVMCountStructElementTypes(LLVMTypeRef StructTy);
	void LLVMGetStructElementTypes(LLVMTypeRef StructTy, LLVMTypeRef *Dest);
	LLVMTypeRef LLVMStructGetTypeAtIndex(LLVMTypeRef StructTy, uint i);
	LLVMBool LLVMIsPackedStruct(LLVMTypeRef StructTy);
	LLVMBool LLVMIsOpaqueStruct(LLVMTypeRef StructTy);
	LLVMTypeRef LLVMGetElementType(LLVMTypeRef Ty);
	LLVMTypeRef LLVMArrayType(LLVMTypeRef ElementType, uint ElementCount);
	uint LLVMGetArrayLength(LLVMTypeRef ArrayTy);
	LLVMTypeRef LLVMPointerType(LLVMTypeRef ElementType, uint AddressSpace);
	uint LLVMGetPointerAddressSpace(LLVMTypeRef PointerTy);
	LLVMTypeRef LLVMVectorType(LLVMTypeRef ElementType, uint ElementCount);
	uint LLVMGetVectorSize(LLVMTypeRef VectorTy);
	//LLVMTypeRef LLVMVoidTypeInContext(LLVMContextRef C);
	//LLVMTypeRef LLVMLabelTypeInContext(LLVMContextRef C);
	//LLVMTypeRef LLVMX86MMXTypeInContext(LLVMContextRef C);
	LLVMTypeRef LLVMVoidType();
	LLVMTypeRef LLVMLabelType();
	LLVMTypeRef LLVMX86MMXType();

	LLVMValueRef LLVMAlignOf(LLVMTypeRef Ty);
	LLVMValueRef LLVMSizeOf(LLVMTypeRef Ty);
	
}
