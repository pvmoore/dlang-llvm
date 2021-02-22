module llvm.test.test;

import llvm.all;
import llvm.test.test_common;
import llvm.test.misc.test_fastmath;
import llvm.test.misc.test_fib;
import llvm.test.misc.test_misc;
import llvm.test.coro.test_coro1;
import llvm.test.coro.test_coro2;
import llvm.test.coro.test_coro3;
import llvm.test.misc.test_async;

void main(string[] argv) {

	LLVMWrapper wrapper = new LLVMWrapper();
	scope(exit) wrapper.destroy();

	auto t = new Tester(wrapper);

	new TestMisc(t)
	 	.test();

	new TestFib(t)
		.test();

	new TestFastMath(t)
		.test();

	new TestCoro1(t)
		.testSingleSuspendPoint();

	new TestCoro2(t)
		.testMultipleSuspendPoints();

	new TestCoro3(t)
		.testPromise();

	new TestAsyncAwait(t)
		.test();
}
