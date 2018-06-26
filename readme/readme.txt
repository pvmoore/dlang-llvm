LLVM Wrapper Library

Compiling LLVM from source
=============================
Required software: python 2.7, cmake, visual studio

- Download the source from the LLVM website to c:\temp\llvm
- create a 'build' directory eg.
	c:\temp\llvm\build
- Use a command prompt with visual studio vars setup
- Edit CMakeLists.txt -> 
	- Change LLVM_TARGETS_TO_BUILD from "all" to X86 (Approx line 326)
- cd \temp\llvm\build
- cmake -G "Visual Studio 15 2017 Win64" c:\temp\llvm	
- Open the Visual Studio .sln file in the build directory
- Set to Release mode
----------------------------------------------------------------------------
5) Check that libraries and tools are set to /MD (DLL)
   (Should already start off with this setting but check):
   
	C/C++/Code Generation/Runtime Library=multi-threaded DLL 
	
5.a) Rebuild ALL-BUILD
	
6) Copy the tools from build\Release\bin to the work directory
-----------------------------------------------------------------------------
7) Set the C runtime on library,tools and utils files to:
	C/C++/Code Generation/Runtime Library=static multithreaded (/MT) 
	
	(Ensure Object Libraries/obj.llvm-tblgen is also /MT )
	
	Don't have option to change lib on these files:
	
	Tools/llvm-dlltool
	Tools/llvm-lib
	Tools/llvm-ranlib
	Tools/llvm-readelf	
	Utils/LLVMVisualizers
	
7a)	Rebuild ALL-BUILD
	
8) Copy the lib files from build\Release\lib to the work directory
------------------------------------------------------------------------------
#1 If you get 'can't find Attributes.inc' error then build the Tablegenning projects first
 