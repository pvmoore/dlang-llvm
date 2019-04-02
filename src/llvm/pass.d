module llvm.pass;

import llvm.all;

/// See http://llvm.org/docs/Passes.html

final class LLVMPassManager {
	LLVMPassManagerRef ref_;

	this(LLVMX86Target target) {
		this.ref_ = LLVMCreatePassManager();

		// this adds the TargetTransformInfoWrapperPass
		LLVMAddAnalysisPasses(target.targetMachine, ref_);
	}
	void destroy() {
		LLVMDisposePassManager(ref_);
	}
	// Scalar.cpp
	void addBasicAliasAnalysisPass() { LLVMAddBasicAliasAnalysisPass(ref_); }
	void addTypeBasedAliasAnalysisPass() { LLVMAddTypeBasedAliasAnalysisPass(ref_); }
	void addScopedNoAliasAAPass() { LLVMAddScopedNoAliasAAPass(ref_); }
	void addVerifierPass() { LLVMAddVerifierPass(ref_); }

	void addEarlyCSEPass() { LLVMAddEarlyCSEPass(ref_); }
	void addEarlyCSEMemSSAPass() { LLVMAddEarlyCSEMemSSAPass(ref_); }

	void addCorrelatedValuePropagationPass() { LLVMAddCorrelatedValuePropagationPass(ref_); }
	void addReassociatePass() { LLVMAddReassociatePass(ref_); }
	void addConstantPropagationPass() { LLVMAddConstantPropagationPass(ref_); }
	void addLowerExpectIntrinsicPass() { LLVMAddLowerExpectIntrinsicPass(ref_); }
	void addDemoteMemoryToRegisterPass() { LLVMAddDemoteMemoryToRegisterPass(ref_); }
	void addTailCallEliminationPass() { LLVMAddTailCallEliminationPass(ref_); }
	void addScalarReplAggregatesPassWithThreshold() { LLVMAddScalarReplAggregatesPassWithThreshold(ref_, -1); }
	void addScalarReplAggregatesPass() { LLVMAddScalarReplAggregatesPass(ref_); }
	void addScalarReplAggregatesPassSSA() { LLVMAddScalarReplAggregatesPassSSA(ref_); }
	void addSCCPPass() { LLVMAddSCCPPass(ref_); }
	void addPromoteMemoryToRegisterPass() { LLVMAddPromoteMemoryToRegisterPass(ref_); }
	void addLowerSwitchPass() { LLVMAddLowerSwitchPass(ref_); }	
	void addPartiallyInlineLibCallsPass() { LLVMAddPartiallyInlineLibCallsPass(ref_); }
	void addMemCpyOptPass() { LLVMAddMemCpyOptPass(ref_); }
	void addLoopUnswitchPass() { LLVMAddLoopUnswitchPass(ref_); } 
	void addLoopUnrollPass() { LLVMAddLoopUnrollPass(ref_); }
	void addLoopRerollPass() { LLVMAddLoopRerollPass(ref_); }
	void addLoopRotatePass() { LLVMAddLoopRotatePass(ref_); }
	void addLoopIdiomPass() { LLVMAddLoopIdiomPass(ref_); }
	void addLoopDeletionPass() { LLVMAddLoopDeletionPass(ref_); }
	//void addLoopSinkPass() { LLVMAddLoopSinkPass(ref_); }
	void addLICMPass() { LLVMAddLICMPass(ref_); }
	void addJumpThreadingPass() { LLVMAddJumpThreadingPass(ref_); }	
	void addInstructionCombiningPass() { LLVMAddInstructionCombiningPass(ref_); }
	void addIndVarSimplifyPass() { LLVMAddIndVarSimplifyPass(ref_); }
	void addMergedLoadStoreMotionPass() { LLVMAddMergedLoadStoreMotionPass(ref_); }
	void addGVNPass() { LLVMAddGVNPass(ref_); }
	void addScalarizerPass() { LLVMAddScalarizerPass(ref_); }
	void addDeadStoreEliminationPass() { LLVMAddDeadStoreEliminationPass(ref_); }
	void addCFGSimplificationPass() { LLVMAddCFGSimplificationPass(ref_); }
	void addAlignmentFromAssumptionsPass() { LLVMAddAlignmentFromAssumptionsPass(ref_); }
	void addBitTrackingDCEPass() { LLVMAddBitTrackingDCEPass(ref_); }
	void addAggressiveDCEPass() { LLVMAddAggressiveDCEPass(ref_); }

	void addUnifyFunctionExitNodesPass() { LLVMAddUnifyFunctionExitNodesPass(ref_); }
	void addCalledValuePropagationPass() { LLVMAddCalledValuePropagationPass(ref_); }

	// IPO.cpp
	void addArgumentPromotionPass() { LLVMAddArgumentPromotionPass(ref_); }
	void addConstantMergePass() { LLVMAddConstantMergePass(ref_); }
	void addDeadArgEliminationPass() { LLVMAddDeadArgEliminationPass(ref_); }
	void addFunctionAttrsPass() { LLVMAddFunctionAttrsPass(ref_); }
	void addFunctionInliningPass() { LLVMAddFunctionInliningPass(ref_); }
	void addAlwaysInlinerPass() { LLVMAddAlwaysInlinerPass(ref_); }
	void addGlobalDCEPass() { LLVMAddGlobalDCEPass(ref_); }
	void addGlobalOptimizerPass() { LLVMAddGlobalOptimizerPass(ref_); }
	void addIPConstantPropagationPass() { LLVMAddIPConstantPropagationPass(ref_); }
	void addPruneEHPass() { LLVMAddPruneEHPass(ref_); }
	void addIPSCCPPass() { LLVMAddIPSCCPPass(ref_); }
	void addInternalizePass(uint AllButMain) { LLVMAddInternalizePass(ref_, AllButMain); }
	void addStripDeadPrototypesPass() { LLVMAddStripDeadPrototypesPass(ref_); }
	void addStripSymbolsPass() { LLVMAddStripSymbolsPass(ref_); }
	void addAggressiveInstCombinerPass() { LLVMAddAggressiveInstCombinerPass(ref_); }

	// Vectorize.cpp
	void addLoopVectorizePass() { LLVMAddLoopVectorizePass(ref_); }
	void addSLPVectorizePass() { LLVMAddSLPVectorizePass(ref_); }

	// Coroutines
	void addCoroEarlyPass() { LLVMAddCoroEarlyPass(ref_); }
	void addCoroSplitPass() { LLVMAddCoroSplitPass(ref_); }
	void addCoroElidePass() { LLVMAddCoroElidePass(ref_); }
	void addCoroCleanupPass() { LLVMAddCoroCleanupPass(ref_); }

	void addPasses() {

		addVerifierPass();
		addCoroEarlyPass();

		addGlobalDCEPass();
		addTypeBasedAliasAnalysisPass();
		addScopedNoAliasAAPass();
		addIPSCCPPass();
		addCalledValuePropagationPass();
		addGlobalOptimizerPass();
		addPromoteMemoryToRegisterPass();
		addDeadArgEliminationPass();
		addInstructionCombiningPass();
		
		addCFGSimplificationPass();
		addPruneEHPass();
		addFunctionInliningPass();
		addFunctionAttrsPass();
		addUnifyFunctionExitNodesPass();
		addScalarReplAggregatesPass();
		addScalarReplAggregatesPassSSA();
		addScalarizerPass();
		addEarlyCSEPass();
		addJumpThreadingPass();
		addCorrelatedValuePropagationPass();

		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addTailCallEliminationPass();

		addCFGSimplificationPass();
		addReassociatePass();
		addLoopRotatePass();
		addLICMPass();
		addLoopUnswitchPass();

		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addIndVarSimplifyPass();
		addLoopIdiomPass();
		addLoopDeletionPass();
		addLoopUnrollPass();
		addMergedLoadStoreMotionPass();
		addGVNPass();
		addMemCpyOptPass();
		addSCCPPass();
		addBitTrackingDCEPass();
		addInstructionCombiningPass();
		addJumpThreadingPass();
		addCorrelatedValuePropagationPass();
		addDeadStoreEliminationPass();
		addLICMPass();
		addPartiallyInlineLibCallsPass();
		addAggressiveDCEPass();

		addCoroSplitPass();

		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addLoopRotatePass();
		addLoopVectorizePass();
		addInstructionCombiningPass();
		addSLPVectorizePass();

		addCoroElidePass();

		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addLoopUnrollPass();
		addInstructionCombiningPass();
		addLICMPass();
		addAlignmentFromAssumptionsPass();
		addStripDeadPrototypesPass();
		addGlobalDCEPass();
		addConstantMergePass();
		addLowerExpectIntrinsicPass();
		addGlobalOptimizerPass();
		
		addCFGSimplificationPass();
		addCoroCleanupPass();

		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addIndVarSimplifyPass();
		addLoopIdiomPass();
		addLoopDeletionPass();
		addLoopUnrollPass();
		addMergedLoadStoreMotionPass();
		addGVNPass();
		addMemCpyOptPass();
		addSCCPPass();
		addBitTrackingDCEPass();
		addInstructionCombiningPass();
		addJumpThreadingPass();
		addCorrelatedValuePropagationPass();
		addDeadStoreEliminationPass();
		addLICMPass();
		addAggressiveDCEPass();

		//addCFGSimplificationPass();

		//addStripSymbolsPass();
		addVerifierPass();
	}
	/**
	 *	Optimisation pass order copied from LLVM 8 opt.exe
	 */
	void addPasses8() {
		addVerifierPass();
 
		addCoroEarlyPass();

		addGlobalDCEPass();
		addTypeBasedAliasAnalysisPass();
		addScopedNoAliasAAPass();
		addIPSCCPPass();
		addCalledValuePropagationPass();
		addFunctionAttrsPass();
		addGlobalOptimizerPass();
		addPromoteMemoryToRegisterPass();
		addConstantMergePass();
		addDeadArgEliminationPass(); 
		addInstructionCombiningPass();
		addFunctionInliningPass();
		addPruneEHPass();
		addGlobalOptimizerPass();
		addGlobalDCEPass();
		addArgumentPromotionPass(); 
		addInstructionCombiningPass();
		addJumpThreadingPass();
		addScalarReplAggregatesPass();
		addFunctionAttrsPass();
		addLICMPass();
		addMergedLoadStoreMotionPass();
		addGVNPass();
		addMemCpyOptPass();
		addDeadStoreEliminationPass();
		addIndVarSimplifyPass();
		addLoopDeletionPass();
		addLoopUnrollPass();
		addLoopVectorizePass();
		addLoopUnrollPass();
		addInstructionCombiningPass();
		addCFGSimplificationPass();
		addIPSCCPPass();
		addInstructionCombiningPass();
		addBitTrackingDCEPass();
		addAlignmentFromAssumptionsPass();
		addInstructionCombiningPass();
		addJumpThreadingPass();
		addCFGSimplificationPass();
		addGlobalDCEPass();
		addTypeBasedAliasAnalysisPass();
		addScopedNoAliasAAPass();
		addIPSCCPPass();
		addCalledValuePropagationPass();
		addGlobalOptimizerPass();
		addPromoteMemoryToRegisterPass();
		addDeadArgEliminationPass();
		addInstructionCombiningPass();
		addCFGSimplificationPass();
		addPruneEHPass();
		addFunctionInliningPass();
		addFunctionAttrsPass();
		addArgumentPromotionPass();
		
		addCoroSplitPass();

		addScalarReplAggregatesPass();
		addEarlyCSEMemSSAPass();
		addJumpThreadingPass();
		addCorrelatedValuePropagationPass();
		addCFGSimplificationPass();
		addAggressiveInstCombinerPass();
		addInstructionCombiningPass();
		addTailCallEliminationPass();
		addCFGSimplificationPass();
		addReassociatePass();
		addLoopRotatePass();
		addLICMPass();
		addLoopUnswitchPass();
		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addIndVarSimplifyPass(); 
		addLoopIdiomPass();
		addLoopDeletionPass();
		addLoopUnrollPass();
		addMergedLoadStoreMotionPass();
		addGVNPass();
		addMemCpyOptPass();
		addBitTrackingDCEPass();
		addInstructionCombiningPass();
		addJumpThreadingPass();
		addCorrelatedValuePropagationPass();
		addDeadStoreEliminationPass();
		addLICMPass();

		addCoroElidePass();

		addAggressiveDCEPass();
		addCFGSimplificationPass();
		addInstructionCombiningPass();
		addGlobalOptimizerPass();
		addGlobalDCEPass();
		addLoopRotatePass();
		addLoopVectorizePass();
		addInstructionCombiningPass();
		addCFGSimplificationPass();
		addSLPVectorizePass();
		addInstructionCombiningPass();
		addLoopUnrollPass();
		addInstructionCombiningPass();
		addLICMPass();
		addAlignmentFromAssumptionsPass();
		addStripDeadPrototypesPass();
		addGlobalDCEPass();
		addConstantMergePass();
		addCFGSimplificationPass();
		
		addCoroCleanupPass();

		addVerifierPass();
	}
	bool runOnModule(LLVMModule mod) {
		//addTargetData(LLVMCreateTargetData(mod.getDataLayout().toStringz), pass);
		return 0!=LLVMRunPassManager(ref_, mod.ref_);
	}
}