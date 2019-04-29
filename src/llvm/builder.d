module llvm.builder;

import llvm.all;

final class LLVMBuilder {
	LLVMBuilderRef ref_;

	this(LLVMContextRef context = LLVMGetGlobalContext()) {
		this.ref_ = LLVMCreateBuilderInContext(context);
	}
	void destroy() {
		LLVMDisposeBuilder(ref_);
	}
	void positionBefore(LLVMValueRef instr) {
		LLVMPositionBuilderBefore(ref_, instr);
	}
	LLVMBasicBlockRef getInsertBlock() {
		return LLVMGetInsertBlock(ref_);
	}
	void positionAtEndOf(LLVMBasicBlockRef bb) {
		LLVMPositionBuilderAtEnd(ref_, bb);
	}

	void setFastMath(bool flag = true) {
		LLVMSetFastMath(ref_, flag);
	}

	LLVMValueRef globalString(string str, string name=null) {
		return LLVMBuildGlobalString(ref_, str.toStringz, name.toStringz);
	}
	LLVMValueRef globalStringPtr(string str, string name=null) {
		return LLVMBuildGlobalStringPtr(ref_, str.toStringz, name.toStringz);
	}
	LLVMValueRef retVoid() {
		return LLVMBuildRetVoid(ref_);
	}
	LLVMValueRef ret(LLVMValueRef val) {
		return LLVMBuildRet(ref_, val);
	}
	LLVMValueRef call(LLVMValueRef func, LLVMValueRef[] args, LLVMCallConv cc, string name=null) {
		auto call = LLVMBuildCall(ref_, func, args.ptr, cast(int)args.length, name.toStringz);
		LLVMSetInstructionCallConv(call, cc);
		return call;
	}
	LLVMValueRef ccall(LLVMValueRef func, LLVMValueRef[] args, string name=null) {
		return call(func, args, LLVMCallConv.LLVMCCallConv, name);
	}
	LLVMValueRef fastcall(LLVMValueRef func, LLVMValueRef[] args, string name=null) {
		return call(func, args, LLVMCallConv.LLVMFastCallConv, name);
	}
	LLVMValueRef switch_(LLVMValueRef value, LLVMBasicBlockRef defaultBB, uint numCases) {
		return LLVMBuildSwitch(ref_, value, defaultBB, numCases);
	}
	LLVMValueRef br(LLVMBasicBlockRef bb) {
		return LLVMBuildBr(ref_, bb);
	}
	LLVMValueRef condBr(LLVMValueRef if_,
						LLVMBasicBlockRef then,
						LLVMBasicBlockRef else_) {
		return LLVMBuildCondBr(ref_, if_, then, else_);
	}
	LLVMValueRef indirectBr(LLVMValueRef addr, uint numDests) {
		return LLVMBuildIndirectBr(ref_, addr, numDests);
	}
	LLVMValueRef invoke(LLVMValueRef fn, LLVMValueRef[] args,
						LLVMBasicBlockRef then, LLVMBasicBlockRef catch_,
						string name=null)
	{
		return LLVMBuildInvoke(ref_, fn, args.ptr, cast(uint)args.length,
							   then, catch_, name.toStringz);
	}
	LLVMValueRef phi(LLVMTypeRef type, string name=null) {
		return LLVMBuildPhi(ref_, type, name.toStringz);
	}
	LLVMValueRef landingPad(LLVMTypeRef Ty, LLVMValueRef PersFn,
							uint NumClauses, string name=null) {
		return LLVMBuildLandingPad(ref_, Ty, PersFn, NumClauses,
								   name.toStringz);
	}
	LLVMValueRef select(LLVMValueRef If, LLVMValueRef Then, LLVMValueRef Else, string name=null) {
		return LLVMBuildSelect(ref_, If, Then, Else, name.toStringz);
	}
	LLVMValueRef vaArg(LLVMValueRef List, LLVMTypeRef Ty, string name=null) {
		return LLVMBuildVAArg(ref_, List, Ty, name.toStringz);
	}
	LLVMValueRef resume(LLVMValueRef Exn) {
		return LLVMBuildResume(ref_, Exn);
	}
	LLVMValueRef unreachable() {
		return LLVMBuildUnreachable(ref_);
	}
	LLVMValueRef add(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildAdd(ref_, left, right, name.toStringz);
	}
	LLVMValueRef add_noSignedWrap(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildNSWAdd(ref_, left, right, name.toStringz);
	}
	LLVMValueRef add_noUnsignedWrap(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildNUWAdd(ref_, left, right, name.toStringz);
	}
	LLVMValueRef fadd(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildFAdd(ref_, left, right, name.toStringz);
	}
	LLVMValueRef sub(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildSub(ref_, left, right, name.toStringz);
	}
	LLVMValueRef sub_noSignedWrap(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildNSWSub(ref_, left, right, name.toStringz);
	}
	LLVMValueRef sub_noUnsignedWrap(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildNUWSub(ref_, left, right, name.toStringz);
	}
	LLVMValueRef fsub(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildFSub(ref_, left, right, name.toStringz);
	}
	LLVMValueRef mul(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildMul(ref_, left, right, name.toStringz);
	}
	LLVMValueRef mul_noSignedWrap(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildNSWMul(ref_, left, right, name.toStringz);
	}
	LLVMValueRef mul_noUnsignedWrap(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildNUWMul(ref_, left, right, name.toStringz);
	}
	LLVMValueRef fmul(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildFMul(ref_, left, right, name.toStringz);
	}
	LLVMValueRef udiv(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildUDiv(ref_, left, right, name.toStringz);
	}
	LLVMValueRef sdiv(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildSDiv(ref_, left, right, name.toStringz);
	}
	LLVMValueRef sdiv_exact(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildExactSDiv(ref_, left, right, name.toStringz);
	}
	LLVMValueRef fdiv(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildFDiv(ref_, left, right, name.toStringz);
	}
	LLVMValueRef urem(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildURem(ref_, left, right, name.toStringz);
	}
	LLVMValueRef srem(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildSRem(ref_, left, right, name.toStringz);
	}
	LLVMValueRef frem(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildFRem(ref_, left, right, name.toStringz);
	}
	LLVMValueRef shl(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildShl(ref_, left, right, name.toStringz);
	}
	LLVMValueRef shr_logical(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildLShr(ref_, left, right, name.toStringz);
	}
	LLVMValueRef shr_arithmetic(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildAShr(ref_, left, right, name.toStringz);
	}
	LLVMValueRef and(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildAnd(ref_, left, right, name.toStringz);
	}
	LLVMValueRef or(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildOr(ref_, left, right, name.toStringz);
	}
	LLVMValueRef xor(LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildXor(ref_, left, right, name.toStringz);
	}
	LLVMValueRef binop(LLVMOpcode op, LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildBinOp(ref_, op, left, right, name.toStringz);
	}
	LLVMValueRef neg(LLVMValueRef v, string name=null) {
		return LLVMBuildNeg(ref_, v, name.toStringz);
	}
	LLVMValueRef neg_noSignedWrap(LLVMValueRef v, string name=null) {
		return LLVMBuildNSWNeg(ref_, v, name.toStringz);
	}
	LLVMValueRef neg_noUnsigedWrap(LLVMValueRef v, string name=null) {
		return LLVMBuildNUWNeg(ref_, v, name.toStringz);
	}
	LLVMValueRef fneg(LLVMValueRef v, string name=null) {
		return LLVMBuildFNeg(ref_, v, name.toStringz);
	}
	LLVMValueRef not(LLVMValueRef v, string name=null) {
		return LLVMBuildNot(ref_, v, name.toStringz);
	}
	/// allocate memory on the heap for one type
	LLVMValueRef malloc(LLVMTypeRef Ty, string name=null) {
		return LLVMBuildMalloc(ref_, Ty, name.toStringz);
	}
	/// allocate memory on the heap for an array of types
	LLVMValueRef mallocArray(LLVMTypeRef type, LLVMValueRef len, string name=null) {
		return LLVMBuildArrayMalloc(ref_, type, len, name.toStringz);
	}
	/// free malloced memory
	LLVMValueRef free(LLVMValueRef PointerVal) {
		return LLVMBuildFree(ref_, PointerVal);
	}
	LLVMValueRef memset(LLVMValueRef Ptr, LLVMValueRef Val, LLVMValueRef Len, uint Align) {
		return LLVMBuildMemSet(ref_, Ptr, Val, Len, Align);
	}
	LLVMValueRef memcpy(LLVMValueRef Dst, uint DstAlign, LLVMValueRef Src, uint SrcAlign, LLVMValueRef Size) {
		return LLVMBuildMemCpy(ref_, Dst, DstAlign, Src, SrcAlign, Size);
	}
	LLVMValueRef memmove(LLVMValueRef Dst, uint DstAlign, LLVMValueRef Src, uint SrcAlign, LLVMValueRef Size) {
		return LLVMBuildMemMove(ref_, Dst, DstAlign, Src, SrcAlign, Size);
	}

	/// allocate memory on the stack for one type
	LLVMValueRef alloca(LLVMTypeRef Ty, string name=null) {
		return LLVMBuildAlloca(ref_, Ty, name.toStringz);
	}
	/// allocate memory on the stack for an array of types
	LLVMValueRef allocaArray(LLVMTypeRef Ty, LLVMValueRef len, string name=null) {
		return LLVMBuildArrayAlloca(ref_, Ty, len, name.toStringz);
	}
	LLVMValueRef load(LLVMValueRef PointerVal, string name=null) {
		return LLVMBuildLoad(ref_, PointerVal, name.toStringz);
	}
	LLVMValueRef store(LLVMValueRef Val, LLVMValueRef Ptr) {
		return LLVMBuildStore(ref_, Val, Ptr);
	}
	LLVMValueRef getElementPointer(LLVMValueRef Pointer, LLVMValueRef[] indices, string name=null) {
		return LLVMBuildGEP(ref_, Pointer, indices.ptr,
							cast(uint)indices.length, name.toStringz);
	}
	LLVMValueRef getElementPointer_inBounds(LLVMValueRef Pointer, LLVMValueRef[] indices, string name=null) {
		return LLVMBuildInBoundsGEP(ref_, Pointer, indices.ptr,
									cast(uint)indices.length, name.toStringz);
	}
	LLVMValueRef getElementPointer_struct(LLVMValueRef Pointer, uint index, string name=null) {
		return LLVMBuildStructGEP(ref_, Pointer, index, name.toStringz);
	}

	// casts
	LLVMValueRef trunc(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildTrunc(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef fptrunc(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildFPTrunc(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef zext(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildZExt(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef sext(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildSExt(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef fptoui(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildFPToUI(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef fptosi(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildFPToSI(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef uitofp(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildUIToFP(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef sitofp(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildSIToFP(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef fpext(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildFPExt(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef ptrToInt(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildPtrToInt(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef intToPtr(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildIntToPtr(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef bitcast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildBitCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef addressSpaceCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildAddrSpaceCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef zExtOrBitCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildZExtOrBitCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef sExtOrBitCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildSExtOrBitCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef truncOrBitCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildTruncOrBitCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef cast_(LLVMOpcode op, LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildCast(ref_, op, v, DestTy, name.toStringz);
	}
	LLVMValueRef pointerCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildPointerCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef intCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildIntCast(ref_, v, DestTy, name.toStringz);
	}
	LLVMValueRef fpCast(LLVMValueRef v, LLVMTypeRef DestTy, string name=null) {
		return LLVMBuildFPCast(ref_, v, DestTy, name.toStringz);
	}

	// comparisons
	LLVMValueRef icmp(LLVMIntPredicate Op, LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildICmp(ref_, Op, left, right, name.toStringz);
	}
	LLVMValueRef fcmp(LLVMRealPredicate Op, LLVMValueRef left, LLVMValueRef right, string name=null) {
		return LLVMBuildFCmp(ref_, Op, left, right, name.toStringz);
	}

	// misc
	LLVMValueRef extractElement(LLVMValueRef VecVal,LLVMValueRef Index, string name=null) {
		return LLVMBuildExtractElement(ref_, VecVal, Index, name.toStringz);
	}
	LLVMValueRef insertElement(LLVMValueRef VecVal, LLVMValueRef EltVal, LLVMValueRef Index, string name=null) {
		return LLVMBuildInsertElement(ref_, VecVal, EltVal, Index, name.toStringz);
	}
	LLVMValueRef shuffleVector(LLVMValueRef V1, LLVMValueRef V2, LLVMValueRef Mask, string name=null) {
		return LLVMBuildShuffleVector(ref_, V1, V2, Mask, name.toStringz);
	}
	LLVMValueRef extractValue(LLVMValueRef AggVal,uint Index, string name=null) {
		return 	LLVMBuildExtractValue(ref_, AggVal, Index, name.toStringz);
	}
	LLVMValueRef insertValue(LLVMValueRef aggVal, LLVMValueRef eleVal, uint index, string name=null) {
		return LLVMBuildInsertValue(ref_, aggVal, eleVal, index, name.toStringz);
	}
	LLVMValueRef isNull(LLVMValueRef Val, string name=null) {
		return LLVMBuildIsNull(ref_, Val, name.toStringz);
	}
	LLVMValueRef isNotNull(LLVMValueRef Val, string name=null) {
		return LLVMBuildIsNotNull(ref_, Val, name.toStringz);
	}
	LLVMValueRef ptrDiff(LLVMValueRef LHS, LLVMValueRef RHS, string name=null) {
		return LLVMBuildPtrDiff(ref_, LHS, RHS, name.toStringz);
	}

	// atomics
	LLVMValueRef fence(LLVMAtomicOrdering ordering, bool singleThread, string name=null) {
		return LLVMBuildFence(ref_, ordering, singleThread.toLLVMBool, name.toStringz);
	}
	LLVMValueRef atomicRMW(LLVMAtomicRMWBinOp op,
						   LLVMValueRef PTR,
						   LLVMValueRef Val,
						   LLVMAtomicOrdering ordering,
						   bool singleThread) {
		return LLVMBuildAtomicRMW(ref_, op, PTR, Val, ordering, singleThread.toLLVMBool);
	}
	LLVMValueRef atomicCmpXchg(LLVMValueRef Ptr,
							   LLVMValueRef Cmp,
							   LLVMValueRef New,
							   LLVMAtomicOrdering SuccessOrdering,
							   LLVMAtomicOrdering FailureOrdering,
							   LLVMBool singleThread)
	{
		return LLVMBuildAtomicCmpXchg(ref_, Ptr, Cmp, New, SuccessOrdering, FailureOrdering, singleThread);
	}

	// const
	LLVMValueRef constAdd(LLVMValueRef left, LLVMValueRef right) {
		assert(left.isConst);
		assert(right.isConst);
		return LLVMConstAdd(left, right);
	}

	// Useful higher level snippets
	/** 
	 *	Sets struct property and returns the store instruction.
	 */
	LLVMValueRef setStructProperty(LLVMValueRef structPtr, uint propertyIndex, LLVMValueRef value) {
        return store(value, getElementPointer_struct(structPtr, propertyIndex));
	}
	/**
	 *	Gets struct property value.
	 */
	LLVMValueRef getStructProperty(LLVMValueRef structPtr, uint propertyIndex) {
		return load(getElementPointer_struct(structPtr, propertyIndex));
	}
}
