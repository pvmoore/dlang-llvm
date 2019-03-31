module test;

import llvm.all;
import test_fibonacci;
import test_coroutines;

void flushStdErrOut() {
    import core.stdc.stdio : fflush, stderr, stdout;
    fflush(stderr);
    fflush(stdout);
}

int main(string[] argv) {
	LLVMWrapper wrapper = new LLVMWrapper();
	scope(exit) wrapper.destroy();

	auto builder	 = wrapper.builder;
	auto passManager = wrapper.passManager;
	auto target		 = wrapper.x86Target;

	// dfdfdfdf

	passManager.addPasses();

	testFibonacci(wrapper);
	testCoroutines(wrapper);

	return 0;
}
