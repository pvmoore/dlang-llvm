module llvm.c.builder;

import llvm.c.all;

extern(C) {
	alias LLVMBuilderRef = LLVMOpaqueBuilder*;
	struct LLVMOpaqueBuilder {}

	LLVMBuilderRef LLVMCreateBuilder();
	void LLVMDisposeBuilder(LLVMBuilderRef Builder);

	void LLVMPositionBuilder(LLVMBuilderRef Builder, LLVMBasicBlockRef Block,
							 LLVMValueRef Instr);
	void LLVMPositionBuilderBefore(LLVMBuilderRef Builder, LLVMValueRef Instr);
	void LLVMPositionBuilderAtEnd(LLVMBuilderRef Builder, LLVMBasicBlockRef Block);
	
	LLVMBasicBlockRef LLVMGetInsertBlock(LLVMBuilderRef Builder);
	void LLVMClearInsertionPosition(LLVMBuilderRef Builder);
	void LLVMInsertIntoBuilder(LLVMBuilderRef Builder, LLVMValueRef Instr);
	void LLVMInsertIntoBuilderWithName(LLVMBuilderRef Builder, LLVMValueRef Instr,
									   immutable(char)* Name);


	LLVMValueRef LLVMBuildGlobalString(LLVMBuilderRef B, 
									   immutable(char)* Str,
									   immutable(char)* Name);
	LLVMValueRef LLVMBuildGlobalStringPtr(LLVMBuilderRef B, 
										  immutable(char)* Str,
										  immutable(char)* Name);

	LLVMValueRef LLVMBuildCall(LLVMBuilderRef, 
							   LLVMValueRef Fn,
							   LLVMValueRef *Args, 
							   uint NumArgs,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildSelect(LLVMBuilderRef, LLVMValueRef If,
								 LLVMValueRef Then, LLVMValueRef Else,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildRetVoid(LLVMBuilderRef);
	LLVMValueRef LLVMBuildRet(LLVMBuilderRef B, LLVMValueRef V);
	LLVMValueRef LLVMBuildSwitch(LLVMBuilderRef B, LLVMValueRef V,
								 LLVMBasicBlockRef Else, uint NumCases);
	LLVMValueRef LLVMBuildBr(LLVMBuilderRef B, LLVMBasicBlockRef Dest);
	LLVMValueRef LLVMBuildPhi(LLVMBuilderRef, LLVMTypeRef Ty, immutable(char)* Name);
	LLVMValueRef LLVMBuildInvoke(LLVMBuilderRef, LLVMValueRef Fn,
								 LLVMValueRef *Args, uint NumArgs,
								 LLVMBasicBlockRef Then, LLVMBasicBlockRef Catch,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildCondBr(LLVMBuilderRef, LLVMValueRef If,
								 LLVMBasicBlockRef Then, LLVMBasicBlockRef Else);
	LLVMValueRef LLVMBuildIndirectBr(LLVMBuilderRef B, LLVMValueRef Addr, uint NumDests);
	LLVMValueRef LLVMBuildLandingPad(LLVMBuilderRef B, LLVMTypeRef Ty,
									 LLVMValueRef PersFn, uint NumClauses,
									 immutable(char)* Name);
	LLVMValueRef LLVMBuildResume(LLVMBuilderRef B, LLVMValueRef Exn);
	LLVMValueRef LLVMBuildUnreachable(LLVMBuilderRef);
	void LLVMAddDestination(LLVMValueRef IndirectBr, LLVMBasicBlockRef Dest);
	void LLVMAddClause(LLVMValueRef LandingPad, LLVMValueRef ClauseVal);
	void LLVMSetCleanup(LLVMValueRef LandingPad, LLVMBool Val);

	// arithmetic
	LLVMValueRef LLVMBuildAdd(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildNSWAdd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildNUWAdd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildFAdd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildSub(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildNSWSub(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildNUWSub(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildFSub(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildMul(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildNSWMul(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildNUWMul(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildFMul(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildUDiv(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildSDiv(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildExactSDiv(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
									immutable(char)* Name);
	LLVMValueRef LLVMBuildFDiv(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildURem(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildSRem(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildFRem(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildShl(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildLShr(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildAShr(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildAnd(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildOr(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							 immutable(char)* Name);
	LLVMValueRef LLVMBuildXor(LLVMBuilderRef, LLVMValueRef LHS, LLVMValueRef RHS,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildBinOp(LLVMBuilderRef B, LLVMOpcode Op,
								LLVMValueRef LHS, LLVMValueRef RHS,
								immutable(char)* Name);

	LLVMValueRef LLVMBuildNeg(LLVMBuilderRef, LLVMValueRef V, immutable(char)* Name);
	LLVMValueRef LLVMBuildNSWNeg(LLVMBuilderRef B, LLVMValueRef V, immutable(char)* Name);
	LLVMValueRef LLVMBuildNUWNeg(LLVMBuilderRef B, LLVMValueRef V, immutable(char)* Name);
	LLVMValueRef LLVMBuildFNeg(LLVMBuilderRef, LLVMValueRef V, immutable(char)* Name);
	LLVMValueRef LLVMBuildNot(LLVMBuilderRef, LLVMValueRef V, immutable(char)* Name);

	// memory
	LLVMValueRef LLVMBuildMalloc(LLVMBuilderRef, LLVMTypeRef Ty, immutable(char)* Name);
	LLVMValueRef LLVMBuildArrayMalloc(LLVMBuilderRef, LLVMTypeRef Ty,
									  LLVMValueRef Val, immutable(char)* Name);
	LLVMValueRef LLVMBuildAlloca(LLVMBuilderRef, LLVMTypeRef Ty, immutable(char)* Name);
	LLVMValueRef LLVMBuildArrayAlloca(LLVMBuilderRef, LLVMTypeRef Ty,
									  LLVMValueRef Val, immutable(char)* Name);
	LLVMValueRef LLVMBuildFree(LLVMBuilderRef, LLVMValueRef PointerVal);


	LLVMValueRef LLVMBuildMemSet(LLVMBuilderRef B, LLVMValueRef Ptr, LLVMValueRef Val, LLVMValueRef Len, uint Align);
	LLVMValueRef LLVMBuildMemCpy(LLVMBuilderRef B, LLVMValueRef Dst, uint DstAlign, LLVMValueRef Src, uint SrcAlign, LLVMValueRef Size);
	LLVMValueRef LLVMBuildMemMove(LLVMBuilderRef B, LLVMValueRef Dst, uint DstAlign, LLVMValueRef Src, uint SrcAlign, LLVMValueRef Size);


	LLVMValueRef LLVMBuildLoad(LLVMBuilderRef, LLVMValueRef PointerVal,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildStore(LLVMBuilderRef, LLVMValueRef Val, LLVMValueRef Ptr);
	LLVMValueRef LLVMBuildGEP(LLVMBuilderRef B, LLVMValueRef Pointer,
							  LLVMValueRef *Indices, uint NumIndices,
							  immutable(char)* Name);
	LLVMValueRef LLVMBuildInBoundsGEP(LLVMBuilderRef B, LLVMValueRef Pointer,
									  LLVMValueRef *Indices, uint NumIndices,
									  immutable(char)* Name);
	LLVMValueRef LLVMBuildStructGEP(LLVMBuilderRef B, LLVMValueRef Pointer,
									uint Idx, immutable(char)* Name);

	// Casts 
	LLVMValueRef LLVMBuildTrunc(LLVMBuilderRef, LLVMValueRef Val,
								LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildZExt(LLVMBuilderRef, LLVMValueRef Val,
							   LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildSExt(LLVMBuilderRef, LLVMValueRef Val,
							   LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildFPToUI(LLVMBuilderRef, LLVMValueRef Val,
								 LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildFPToSI(LLVMBuilderRef, LLVMValueRef Val,
								 LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildUIToFP(LLVMBuilderRef, LLVMValueRef Val,
								 LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildSIToFP(LLVMBuilderRef, LLVMValueRef Val,
								 LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildFPTrunc(LLVMBuilderRef, LLVMValueRef Val,
								  LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildFPExt(LLVMBuilderRef, LLVMValueRef Val,
								LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildPtrToInt(LLVMBuilderRef, LLVMValueRef Val,
								   LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildIntToPtr(LLVMBuilderRef, LLVMValueRef Val,
								   LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildBitCast(LLVMBuilderRef, LLVMValueRef Val,
								  LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildAddrSpaceCast(LLVMBuilderRef, LLVMValueRef Val,
										LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildZExtOrBitCast(LLVMBuilderRef, LLVMValueRef Val,
										LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildSExtOrBitCast(LLVMBuilderRef, LLVMValueRef Val,
										LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildTruncOrBitCast(LLVMBuilderRef, LLVMValueRef Val,
										 LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildCast(LLVMBuilderRef B, LLVMOpcode Op, LLVMValueRef Val,
							   LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildPointerCast(LLVMBuilderRef, LLVMValueRef Val,
									  LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildIntCast(LLVMBuilderRef, LLVMValueRef Val, /*Signed cast!*/
								  LLVMTypeRef DestTy, immutable(char)* Name);
	LLVMValueRef LLVMBuildFPCast(LLVMBuilderRef, LLVMValueRef Val,
								 LLVMTypeRef DestTy, immutable(char)* Name);

	// Comparisons 
	LLVMValueRef LLVMBuildICmp(LLVMBuilderRef, LLVMIntPredicate Op,
							   LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);
	LLVMValueRef LLVMBuildFCmp(LLVMBuilderRef, LLVMRealPredicate Op,
							   LLVMValueRef LHS, LLVMValueRef RHS,
							   immutable(char)* Name);

	// misc
	LLVMValueRef LLVMBuildVAArg(LLVMBuilderRef, LLVMValueRef List, LLVMTypeRef Ty,
								immutable(char)* Name);
	LLVMValueRef LLVMBuildExtractElement(LLVMBuilderRef, LLVMValueRef VecVal,
										 LLVMValueRef Index, 
										 immutable(char)* Name);
	LLVMValueRef LLVMBuildInsertElement(LLVMBuilderRef, LLVMValueRef VecVal,
										LLVMValueRef EltVal, LLVMValueRef Index,
										immutable(char)* Name);
	LLVMValueRef LLVMBuildShuffleVector(LLVMBuilderRef, LLVMValueRef V1,
										LLVMValueRef V2, LLVMValueRef Mask,
										immutable(char)* Name);
	LLVMValueRef LLVMBuildExtractValue(LLVMBuilderRef, LLVMValueRef AggVal,
									   uint Index, immutable(char)* Name);
	LLVMValueRef LLVMBuildInsertValue(LLVMBuilderRef, LLVMValueRef AggVal,
									  LLVMValueRef EltVal, uint Index,
									  immutable(char)* Name);
	LLVMValueRef LLVMBuildIsNull(LLVMBuilderRef, LLVMValueRef Val,
								 immutable(char)* Name);
	LLVMValueRef LLVMBuildIsNotNull(LLVMBuilderRef, LLVMValueRef Val,
									immutable(char)* Name);
	LLVMValueRef LLVMBuildPtrDiff(LLVMBuilderRef, LLVMValueRef LHS,
								  LLVMValueRef RHS, immutable(char)* Name);

	// atomics
	LLVMValueRef LLVMBuildFence(LLVMBuilderRef B, LLVMAtomicOrdering ordering,
								LLVMBool singleThread, immutable(char)* Name);
	LLVMValueRef LLVMBuildAtomicRMW(LLVMBuilderRef B, LLVMAtomicRMWBinOp op,
									LLVMValueRef PTR, LLVMValueRef Val,
									LLVMAtomicOrdering ordering,
									LLVMBool singleThread);
	LLVMValueRef LLVMBuildAtomicCmpXchg(LLVMBuilderRef B, LLVMValueRef Ptr,	
										LLVMValueRef Cmp, LLVMValueRef New,
										LLVMAtomicOrdering SuccessOrdering,
										LLVMAtomicOrdering FailureOrdering,
										LLVMBool singleThread);
	

	// const
	LLVMValueRef LLVMConstAdd(LLVMValueRef LHSConstant, LLVMValueRef RHSConstant);									
}