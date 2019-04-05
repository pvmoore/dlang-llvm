module llvm.c.enums;

enum LLVMOpcode {
	/* Terminator Instructions */
	LLVMRet            = 1,
	LLVMBr             = 2,
	LLVMSwitch         = 3,
	LLVMIndirectBr     = 4,
	LLVMInvoke         = 5,
	/* removed 6 due to API changes */
	LLVMUnreachable    = 7,

	/* Standard Binary Operators */
	LLVMAdd            = 8,
	LLVMFAdd           = 9,
	LLVMSub            = 10,
	LLVMFSub           = 11,
	LLVMMul            = 12,
	LLVMFMul           = 13,
	LLVMUDiv           = 14,
	LLVMSDiv           = 15,
	LLVMFDiv           = 16,
	LLVMURem           = 17,
	LLVMSRem           = 18,
	LLVMFRem           = 19,

	/* Logical Operators */
	LLVMShl            = 20,
	LLVMLShr           = 21,
	LLVMAShr           = 22,
	LLVMAnd            = 23,
	LLVMOr             = 24,
	LLVMXor            = 25,

	/* Memory Operators */
	LLVMAlloca         = 26,
	LLVMLoad           = 27,
	LLVMStore          = 28,
	LLVMGetElementPtr  = 29,

	/* Cast Operators */
	LLVMTrunc          = 30,
	LLVMZExt           = 31,
	LLVMSExt           = 32,
	LLVMFPToUI         = 33,
	LLVMFPToSI         = 34,
	LLVMUIToFP         = 35,
	LLVMSIToFP         = 36,
	LLVMFPTrunc        = 37,
	LLVMFPExt          = 38,
	LLVMPtrToInt       = 39,
	LLVMIntToPtr       = 40,
	LLVMBitCast        = 41,
	LLVMAddrSpaceCast  = 60,

	/* Other Operators */
	LLVMICmp           = 42,
	LLVMFCmp           = 43,
	LLVMPHI            = 44,
	LLVMCall           = 45,
	LLVMSelect         = 46,
	LLVMUserOp1        = 47,
	LLVMUserOp2        = 48,
	LLVMVAArg          = 49,
	LLVMExtractElement = 50,
	LLVMInsertElement  = 51,
	LLVMShuffleVector  = 52,
	LLVMExtractValue   = 53,
	LLVMInsertValue    = 54,

	/* Atomic operators */
	LLVMFence          = 55,
	LLVMAtomicCmpXchg  = 56,
	LLVMAtomicRMW      = 57,

	/* Exception Handling Operators */
	LLVMResume         = 58,
	LLVMLandingPad     = 59,
	LLVMCleanupRet     = 61,
	LLVMCatchRet       = 62,
	LLVMCatchPad       = 63,
	LLVMCleanupPad     = 64,
	LLVMCatchSwitch    = 65
}  

enum LLVMTypeKind{
	LLVMVoidTypeKind,        /**< type with no size */
	LLVMHalfTypeKind,        /**< 16 bit floating point type */
	LLVMFloatTypeKind,       /**< 32 bit floating point type */
	LLVMDoubleTypeKind,      /**< 64 bit floating point type */
	LLVMX86_FP80TypeKind,    /**< 80 bit floating point type (X87) */
	LLVMFP128TypeKind,       /**< 128 bit floating point type (112-bit mantissa)*/
	LLVMPPC_FP128TypeKind,   /**< 128 bit floating point type (two 64-bits) */
	LLVMLabelTypeKind,       /**< Labels */
	LLVMIntegerTypeKind,     /**< Arbitrary bit width integers */
	LLVMFunctionTypeKind,    /**< Functions */
	LLVMStructTypeKind,      /**< Structures */
	LLVMArrayTypeKind,       /**< Arrays */
	LLVMPointerTypeKind,     /**< Pointers */
	LLVMVectorTypeKind,      /**< SIMD 'packed' format, or other vector type */
	LLVMMetadataTypeKind,    /**< Metadata */
	LLVMX86_MMXTypeKind,     /**< X86 MMX */
	LLVMTokenTypeKind        /**< Tokens */
} 

enum LLVMLinkage {
	LLVMExternalLinkage,    /**< Externally visible function */
	LLVMAvailableExternallyLinkage,
	LLVMLinkOnceAnyLinkage, /**< Keep one copy of function when linking (inline)*/
	LLVMLinkOnceODRLinkage, /**< Same, but only replaced by something equivalent. */
	LLVMLinkOnceODRAutoHideLinkage, /**< Obsolete */
	LLVMWeakAnyLinkage,     /**< Keep one copy of function when linking (weak) */
	LLVMWeakODRLinkage,     /**< Same, but only replaced by something equivalent. */
	LLVMAppendingLinkage,   /**< Special purpose, only applies to global arrays */
	LLVMInternalLinkage,    /**< Rename collisions when linking (static functions) */
	LLVMPrivateLinkage,     /**< Like Internal, but omit from symbol table */
	LLVMDLLImportLinkage,   /**< Obsolete */
	LLVMDLLExportLinkage,   /**< Obsolete */
	LLVMExternalWeakLinkage,/**< ExternalWeak linkage description */
	LLVMGhostLinkage,       /**< Obsolete */
	LLVMCommonLinkage,      /**< Tentative definitions */
	LLVMLinkerPrivateLinkage, /**< Like Private, but linker removes. */
	LLVMLinkerPrivateWeakLinkage /**< Like LinkerPrivate, but is weak. */
}

enum LLVMVisibility{
	LLVMDefaultVisibility,  /**< The GV is visible */
	LLVMHiddenVisibility,   /**< The GV is hidden */
	LLVMProtectedVisibility /**< The GV is protected */
} 

enum LLVMCallConv : uint {
	LLVMCCallConv           = 0,
	LLVMFastCallConv        = 8,
	LLVMColdCallConv        = 9,
	LLVMWebKitJSCallConv    = 12,
	LLVMAnyRegCallConv      = 13,
	LLVMX86StdcallCallConv  = 64,
	LLVMX86FastcallCallConv = 65
} 

enum LLVMIntPredicate {
	LLVMIntEQ = 32, /**< equal */
	LLVMIntNE,      /**< not equal */
	LLVMIntUGT,     /**< unsigned greater than */
	LLVMIntUGE,     /**< unsigned greater or equal */
	LLVMIntULT,     /**< unsigned less than */
	LLVMIntULE,     /**< unsigned less or equal */
	LLVMIntSGT,     /**< signed greater than */
	LLVMIntSGE,     /**< signed greater or equal */
	LLVMIntSLT,     /**< signed less than */
	LLVMIntSLE      /**< signed less or equal */
} 

enum LLVMRealPredicate {
	LLVMRealPredicateFalse, /**< Always false (always folded) */
	LLVMRealOEQ,            /**< True if ordered and equal */
	LLVMRealOGT,            /**< True if ordered and greater than */
	LLVMRealOGE,            /**< True if ordered and greater than or equal */
	LLVMRealOLT,            /**< True if ordered and less than */
	LLVMRealOLE,            /**< True if ordered and less than or equal */
	LLVMRealONE,            /**< True if ordered and operands are unequal */
	LLVMRealORD,            /**< True if ordered (no nans) */
	LLVMRealUNO,            /**< True if unordered: isnan(X) | isnan(Y) */
	LLVMRealUEQ,            /**< True if unordered or equal */
	LLVMRealUGT,            /**< True if unordered or greater than */
	LLVMRealUGE,            /**< True if unordered, greater than, or equal */
	LLVMRealULT,            /**< True if unordered or less than */
	LLVMRealULE,            /**< True if unordered, less than, or equal */
	LLVMRealUNE,            /**< True if unordered or not equal */
	LLVMRealPredicateTrue   /**< Always true (always folded) */
} 

enum LLVMThreadLocalMode {
	LLVMNotThreadLocal = 0,
	LLVMGeneralDynamicTLSModel,
	LLVMLocalDynamicTLSModel,
	LLVMInitialExecTLSModel,
	LLVMLocalExecTLSModel
} 

enum LLVMAtomicOrdering {
	LLVMAtomicOrderingNotAtomic = 0, /**< A load or store which is not atomic */
	
	LLVMAtomicOrderingUnordered = 1, /**< Lowest level of atomicity, guarantees
										somewhat sane results, lock free. */
	LLVMAtomicOrderingMonotonic = 2, /**< guarantees that if you take all the
										operations affecting a specific address,
										a consistent ordering exists */
	LLVMAtomicOrderingAcquire = 4, /**< Acquire provides a barrier of the sort
										necessary to acquire a lock to access other
										memory with normal loads and stores. */
	LLVMAtomicOrderingRelease = 5, /**< Release is similar to Acquire, but with
										a barrier of the sort necessary to release a lock. */
	LLVMAtomicOrderingAcquireRelease = 6, /**< provides both an Acquire and a
											Release barrier (for fences and
											operations which both read and write
											memory). */
	LLVMAtomicOrderingSequentiallyConsistent = 7 /**< provides Acquire semantics
													for loads and Release
													semantics for stores.
													Additionally, it guarantees
													that a total ordering exists
													between all
													SequentiallyConsistent
													operations. */
} 

enum LLVMAtomicRMWBinOp {
    LLVMAtomicRMWBinOpXchg, /**< Set the new value and return the one old */
	LLVMAtomicRMWBinOpAdd, 	/**< Add a value and return the old one */
	LLVMAtomicRMWBinOpSub, 	/**< Subtract a value and return the old one */
	LLVMAtomicRMWBinOpAnd, 	/**< And a value and return the old one */
	LLVMAtomicRMWBinOpNand, /**< Not-And a value and return the old one */
	LLVMAtomicRMWBinOpOr, 	/**< OR a value and return the old one */
	LLVMAtomicRMWBinOpXor, 	/**< Xor a value and return the old one */
	LLVMAtomicRMWBinOpMax, 	/**< Sets the value if it's greater than the
								original using a signed comparison and return the old one */
	LLVMAtomicRMWBinOpMin, 	/**< Sets the value if it's Smaller than the
								original using a signed comparison and return the old one */
	LLVMAtomicRMWBinOpUMax, /**< Sets the value if it's greater than the
								original using an unsigned comparison and return the old one */
	LLVMAtomicRMWBinOpUMin 	/**< Sets the value if it's greater than the
								original using an unsigned comparison  and return the old one */
} 

enum LLVMCodeModel {
    LLVMCodeModelDefault,
	LLVMCodeModelJITDefault,
	LLVMCodeModelSmall,
	LLVMCodeModelKernel,
	LLVMCodeModelMedium,
	LLVMCodeModelLarge
} 

enum LLVMCodeGenFileType{
    LLVMAssemblyFile,
	LLVMObjectFile
} 

enum LLVMCodeGenOptLevel {
    LLVMCodeGenLevelNone,
	LLVMCodeGenLevelLess,
	LLVMCodeGenLevelDefault,
	LLVMCodeGenLevelAggressive
} 

enum LLVMRelocMode {
    LLVMRelocDefault,
	LLVMRelocStatic,
	LLVMRelocPIC,
	LLVMRelocDynamicNoPic
} 

enum LLVMVerifierFailureAction {
	LLVMAbortProcessAction, /* verifier will print to stderr and abort() */
	LLVMPrintMessageAction, /* verifier will print to stderr and return 1 */
	LLVMReturnStatusAction  /* verifier will just return 1 */
} 