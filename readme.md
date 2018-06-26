# Dlang LLVM Wrapper Library

## Features
- 


## Requirements
- Dlang https://dlang.org/
- LLVM 6 http://llvm.org/

LLVM .lib files are required (statically compiled).

## Generating the LLVM .lib files (On Windows)
Required software: python 2.7, cmake, visual studio

1) Download the source from the LLVM website to c:\temp\llvm
2) create a 'build' directory eg.
    c:\temp\llvm\build
3) Use a command prompt with visual studio vars setup
4) Edit CMakeLists.txt: 
    - Change LLVM_TARGETS_TO_BUILD from "all" to X86 (Unless you need other targets)
5) cd \temp\llvm\build
6) cmake -G "Visual Studio 15 2017 Win64" c:\temp\llvm	
7) Open the Visual Studio .sln file in the build directory
8) Set to Release mode

9) Set everything to C/C++/Code Generation/Runtime Library = /MT (static multithreaded) 

Ignore these files: 

    - Tools/llvm-dlltool
    - Tools/llvm-lib
    - Tools/llvm-ranlib
    - Tools/llvm-readelf	
    - Utils/LLVMVisualizers
	
10) Rebuild ALL-BUILD
	
11) Copy the lib files from build\Release\lib to somwehere safe and point to them in the dub.sdl file (lflags).

