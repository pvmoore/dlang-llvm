module llvm.c.pass;

import llvm.c.all;
/*
	CFG  - Control flow graph
	CSE  - Common subexpression elimination
	DCE  - Dead code elimination
	GVN  - Global value numbering
	LICM - Loop invariant code motion
	SCCP - Sparse conditional constant propagation
*/
extern(C) {
	alias LLVMPassManagerRef = LLVMOpaquePassManager*;
	struct LLVMOpaquePassManager {}

	LLVMPassManagerRef LLVMCreatePassManager();
	void LLVMDisposePassManager(LLVMPassManagerRef PM);

	LLVMBool LLVMRunPassManager(LLVMPassManagerRef PM, LLVMModuleRef M);
	void LLVMAddTargetData(LLVMTargetDataRef TD, LLVMPassManagerRef PM);

	// analysis
	void LLVMAddBasicAliasAnalysisPass(LLVMPassManagerRef PM);
	void LLVMAddTypeBasedAliasAnalysisPass(LLVMPassManagerRef PM);
	void LLVMAddScopedNoAliasAAPass(LLVMPassManagerRef PM);
	void LLVMAddVerifierPass(LLVMPassManagerRef PM);

	////=====--------------------------- interesting ones here
	//void LLVMAddConstantPropagationPass(LLVMPassManagerRef PM);
	void LLVMAddDCEPass(LLVMPassManagerRef PM);
	void LLVMAddAggressiveDCEPass(LLVMPassManagerRef PM);
	void LLVMAddDeadStoreEliminationPass(LLVMPassManagerRef PM);

	// eliminates trivially redundant instructions
	void LLVMAddEarlyCSEPass(LLVMPassManagerRef PM);
	void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM);
	void LLVMAddCFGSimplificationPass(LLVMPassManagerRef PM);
	void LLVMAddGVNPass(LLVMPassManagerRef PM);
	void LLVMAddPartiallyInlineLibCallsPass(LLVMPassManagerRef PM);

	void LLVMAddBitTrackingDCEPass(LLVMPassManagerRef PM);

	void LLVMAddInstructionSimplifyPass(LLVMPassManagerRef PM);

	void LLVMAddMergedLoadStoreMotionPass(LLVMPassManagerRef PM);
	void LLVMAddIndVarSimplifyPass(LLVMPassManagerRef PM);

	// loop invariant code motion and memory promotion
	void LLVMAddLICMPass(LLVMPassManagerRef PM);
	void LLVMAddLoopDeletionPass(LLVMPassManagerRef PM);
	void LLVMAddLoopIdiomPass(LLVMPassManagerRef PM);
	void LLVMAddLoopRotatePass(LLVMPassManagerRef PM);
	void LLVMAddLoopRerollPass(LLVMPassManagerRef PM);
	void LLVMAddLoopUnrollPass(LLVMPassManagerRef PM);
	void LLVMAddLoopUnswitchPass(LLVMPassManagerRef PM);
	void LLVMAddLoopFlattenPass(LLVMPassManagerRef PM);
	void LLVMAddLoopUnrollAndJamPass(LLVMPassManagerRef PM);

	void LLVMAddMemCpyOptPass(LLVMPassManagerRef PM);

	void LLVMAddLowerSwitchPass(LLVMPassManagerRef PM);

	// This pass reassociates commutative expressions in an order that is designed
	// to promote better constant propagation
	void LLVMAddReassociatePass(LLVMPassManagerRef PM);

	void LLVMAddScalarReplAggregatesPass(LLVMPassManagerRef PM);
	void LLVMAddScalarReplAggregatesPassSSA(LLVMPassManagerRef PM);
	void LLVMAddScalarReplAggregatesPassWithThreshold(LLVMPassManagerRef PM, int Threshold);

	void LLVMAddUnifyFunctionExitNodesPass(LLVMPassManagerRef PM);

	void LLVMAddTailCallEliminationPass(LLVMPassManagerRef PM);

	// Sparse conditional constant propagation
	void LLVMAddSCCPPass(LLVMPassManagerRef PM);

	void LLVMAddLowerConstantIntrinsicsPass(LLVMPassManagerRef PM);


	// demote register to memory
	void LLVMAddDemoteMemoryToRegisterPass(LLVMPassManagerRef PM);
	void LLVMAddPromoteMemoryToRegisterPass(LLVMPassManagerRef PM);

	// ValuePropagation - Propagate CFG-derived value information
	void LLVMAddCorrelatedValuePropagationPass(LLVMPassManagerRef PM);

	//=====------------------------------- weird ones below here
	void LLVMAddJumpThreadingPass(LLVMPassManagerRef PM);
	void LLVMAddScalarizerPass(LLVMPassManagerRef PM);
	// lowers the 'expect' intrinsic to LLVM metadata
	void LLVMAddLowerExpectIntrinsicPass(LLVMPassManagerRef PM);
	// Use assume intrinsics to set load/store alignments.
	void LLVMAddAlignmentFromAssumptionsPass(LLVMPassManagerRef PM);

	// from IPO.cpp
	void LLVMAddArgumentPromotionPass(LLVMPassManagerRef PM);
	void LLVMAddConstantMergePass(LLVMPassManagerRef PM);
	void LLVMAddDeadArgEliminationPass(LLVMPassManagerRef PM);
	void LLVMAddFunctionAttrsPass(LLVMPassManagerRef PM);
	void LLVMAddFunctionInliningPass(LLVMPassManagerRef PM);
	void LLVMAddAlwaysInlinerPass(LLVMPassManagerRef PM);
	void LLVMAddGlobalDCEPass(LLVMPassManagerRef PM);
	void LLVMAddGlobalOptimizerPass(LLVMPassManagerRef PM);
	//void LLVMAddIPConstantPropagationPass(LLVMPassManagerRef PM);
	void LLVMAddPruneEHPass(LLVMPassManagerRef PM);
	void LLVMAddIPSCCPPass(LLVMPassManagerRef PM);
	void LLVMAddInternalizePass(LLVMPassManagerRef PM, uint AllButMain);
	void LLVMAddStripDeadPrototypesPass(LLVMPassManagerRef PM);
	void LLVMAddStripSymbolsPass(LLVMPassManagerRef PM);

	// from Vectorize.cpp
	void LLVMAddLoopVectorizePass(LLVMPassManagerRef PM);
	void LLVMAddSLPVectorizePass(LLVMPassManagerRef PM);

	// Coroutines passes
	void LLVMAddCoroEarlyPass(LLVMPassManagerRef PM);
	void LLVMAddCoroSplitPass(LLVMPassManagerRef PM);
	void LLVMAddCoroElidePass(LLVMPassManagerRef PM);
	void LLVMAddCoroCleanupPass(LLVMPassManagerRef PM);


	void LLVMAddCalledValuePropagationPass(LLVMPassManagerRef PM);
	void LLVMAddLoopSimplifyCFGPass(LLVMPassManagerRef PM);
	void LLVMAddNewGVNPass(LLVMPassManagerRef PM);
	void LLVMAddLoopUnrollAndJamPass(LLVMPassManagerRef PM);
	void LLVMAddLowerAtomicPass(LLVMPassManagerRef PM);
	void LLVMAddGVNHoistLegacyPass(LLVMPassManagerRef PM);
	void LLVMAddAggressiveInstCombinerPass(LLVMPassManagerRef PM);
	void LLVMAddEarlyCSEMemSSAPass(LLVMPassManagerRef PM);
	void LLVMAddLoopSinkPass(LLVMPassManagerRef PM);
}