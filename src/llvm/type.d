module llvm.type;

import llvm.all;

//====--------------------------------------------------------- misc
LLVMTypeRef voidType() { return LLVMVoidType(); }
LLVMTypeRef labelType() { return LLVMLabelType(); }
LLVMTypeRef mmxType() { return LLVMX86MMXType(); }
LLVMTypeRef i1Type() { return LLVMInt1Type(); }
LLVMTypeRef i8Type() { return LLVMInt8Type(); }
LLVMTypeRef i16Type() { return LLVMInt16Type(); }
LLVMTypeRef i32Type() { return LLVMInt32Type(); }
LLVMTypeRef i64Type() { return LLVMInt64Type(); }
LLVMTypeRef f16Type() { return LLVMHalfType(); }
LLVMTypeRef f32Type() { return LLVMFloatType(); }
LLVMTypeRef f64Type() { return LLVMDoubleType(); }
LLVMTypeRef f80Type() { return LLVMX86FP80Type(); }

LLVMTypeRef tokenType(LLVMContextRef context=LLVMGetGlobalContext()) {
	return LLVMTokenTypeInContext(context);
}

//LLVMTypeRef clone(LLVMTypeRef type) {
//	assert(!type.isPointer);
//
//	if(type.isInteger) {
//		return LLVMIntType(type.getNumBits);
//	} else if(type.isF16Type()) {
//		return f16Type();
//	} else if(type.isF32Type()) {
//		return f32Type();
//	} else if(type.isF64Type()) {
//		return f64Type();
//	} else throw new Error("Only works on basic integer or real types");
//	assert(false);
//}

//void dump(LLVMTypeRef t) {
//	LLVMDumpType(t);
//}
string toString(LLVMTypeRef t) {
	return cast(string)LLVMPrintTypeToString(t).fromStringz;
}
LLVMTypeKind getTypeEnum(LLVMTypeRef t) {
	return LLVMGetTypeKind(t);
}
uint getNumBits(LLVMTypeRef t) {
	assert(t.isInteger);
	return LLVMGetIntTypeWidth(t);
}
bool isI1Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMIntegerTypeKind && t.getNumBits == 1;
}
bool isI8Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMIntegerTypeKind && t.getNumBits == 8;
}
bool isI16Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMIntegerTypeKind && t.getNumBits == 16;
}
bool isI32Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMIntegerTypeKind && t.getNumBits == 32;
}
bool isI64Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMIntegerTypeKind && t.getNumBits == 64;
}
bool isF16Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMHalfTypeKind;
}
bool isF32Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMFloatTypeKind;
}
bool isF64Type(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMDoubleTypeKind;
}
bool isReal(LLVMTypeRef t) {
	LLVMTypeKind kind = t.getTypeEnum();
	return kind==LLVMTypeKind.LLVMHalfTypeKind ||
		   kind==LLVMTypeKind.LLVMFloatTypeKind ||
		   kind==LLVMTypeKind.LLVMDoubleTypeKind;
}
bool isInteger(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMIntegerTypeKind;
}
bool isPointer(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMPointerTypeKind;
}
bool isStruct(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMVectorTypeKind;
}
bool isArray(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMArrayTypeKind;
}
bool isFunction(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMFunctionTypeKind;
}
bool isVector(LLVMTypeRef t) {
	return t.getTypeEnum()==LLVMTypeKind.LLVMVectorTypeKind;
}
bool isIntegerVector(LLVMTypeRef t) {
	return t.isVector && t.getElementType().isInteger;
}
bool isRealVector(LLVMTypeRef t) {
	return t.isVector && t.getElementType().isReal;
}
/// works on array, vector and pointer types
LLVMTypeRef getElementType(LLVMTypeRef ty) {
	return LLVMGetElementType(ty);
}
LLVMValueRef alignof(LLVMTypeRef t) {
	return LLVMAlignOf(t);
}
LLVMValueRef sizeof(LLVMTypeRef t) {
	return LLVMSizeOf(t);
}
//====------------------------------------------------- pointer types
LLVMTypeRef pointerType(LLVMTypeRef ElementType, uint AddressSpace=0) {
	return LLVMPointerType(ElementType, AddressSpace);
}
LLVMTypeRef voidPointerType() {
	return pointerType(voidType());
}
LLVMTypeRef bytePointerType() {
	return pointerType(i8Type());
}
LLVMTypeRef i16PointerType() {
	return pointerType(i16Type());
}
LLVMTypeRef i32PointerType() {
	return pointerType(i32Type());
}
LLVMTypeRef i64PointerType() {
	return pointerType(i64Type());
}
LLVMTypeRef f32PointerType() {
	return pointerType(f32Type());
}
LLVMTypeRef f64PointerType() {
	return pointerType(f64Type());
}
//====------------------------------------------------- array types
LLVMTypeRef arrayType(LLVMTypeRef elementType, uint numElements) {
	return LLVMArrayType(elementType, numElements);
}
uint arrayLength(LLVMTypeRef arr) {
	return LLVMGetArrayLength(arr);
}
//====------------------------------------------------- vector types
LLVMTypeRef vector(LLVMTypeRef ElementType, uint ElementCount) {
	return LLVMVectorType(ElementType, ElementCount);
}
uint vectorLength(LLVMTypeRef Vector) {
	return LLVMGetVectorSize(Vector);
}
//====----------------------------------------------- function types
LLVMTypeRef function_(LLVMTypeRef retType, 
					  LLVMTypeRef[] params, 
					  bool isVararg=false) 
{
	return LLVMFunctionType(retType,
                            params.ptr, 
							cast(uint)params.length,
                            isVararg.toLLVMBool);
}
uint countParams(LLVMTypeRef func) {
	return LLVMCountParamTypes(func);
}
LLVMTypeRef getReturnType(LLVMTypeRef func) {
	return LLVMGetReturnType(func);
}
//====------------------------------------------------------ structs
LLVMTypeRef struct_(LLVMTypeRef[] ElementTypes, bool Packed) {
	return LLVMStructType(ElementTypes.ptr, 
						  cast(uint)ElementTypes.length,
						  Packed.toLLVMBool);
}
LLVMTypeRef struct_(string name, LLVMContextRef context=LLVMGetGlobalContext()) {
	return LLVMStructCreateNamed(context, name.toStringz);
}
void setTypes(LLVMTypeRef Struct, LLVMTypeRef[] types, bool packed) {
	LLVMStructSetBody(Struct, types.ptr,
                      cast(uint)types.length, packed.toLLVMBool);
}
string getName(LLVMTypeRef st) {
	return cast(string)LLVMGetStructName(st).fromStringz;
}
@property uint countTypes(LLVMTypeRef Struct) {
	return LLVMCountStructElementTypes(Struct);
}
LLVMTypeRef[] getTypes(LLVMTypeRef Struct) {
	LLVMTypeRef[] ele = new LLVMTypeRef[Struct.countTypes];
	LLVMGetStructElementTypes(Struct, ele.ptr);
	return ele;
}
LLVMTypeRef getTypeAtIndex(LLVMTypeRef Struct, uint index) {
	return LLVMStructGetTypeAtIndex(Struct, index);
}
bool isPackedStruct(LLVMTypeRef st) {
	return LLVMIsPackedStruct(st)!=0;
}
bool isOpaqueStruct(LLVMTypeRef st) {
	return LLVMIsOpaqueStruct(st)!=0;
}
//====--------------------------------------------------------
