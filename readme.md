# Dlang LLVM Wrapper Library

## Features
-


## Requirements
- Dlang https://dlang.org/
- LLVM 9 http://llvm.org/

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
6) cmake -G "Visual Studio 16 2019" -A x64 c:\temp\llvm
7) Open the Visual Studio .sln file in the build directory

8) Set to Release build

9) Add code:

    - Libraries/LLVMCore/Core.cpp
    ```
    extern "C" {
        void LLVMSetFastMath(LLVMBuilderRef Builder, bool fast = true) {
          auto fmf = FastMathFlags();
          fmf.setFast(fast);
          unwrap(Builder)->setFastMathFlags(fmf);
        }
    }
    ```

    - Libraries/LLVMCoroutines/Coroutines.cpp
    ```
    extern "C" {
        void LLVMInitializeCoroutines(LLVMPassRegistryRef R) {
          initializeCoroutines(*unwrap(R));
        }
    }
    ```

10) Set everything to C/C++/Code Generation/Runtime Library = /MT (static multithreaded)

    Ignore these files:

    - Examples/Kaleidoscope

    - Loadable Modules/*
    - Misc/*
    - Tablegenning/*


    - Tests/check
    - Tests/check-lit
    - Tests/check-llvm
    - Tests/llvm-test-depends
    - Tests/prepare-check-lit
    - Tests/test-depends
    - Tests/TestPlugin
    - Tests/UnitTests


    - Tools/llvm-addr2line
    - Tools/llvm-dlltool
    - Tools/llvm-lib
    - Tools/llvm-ranlib
    - Tools/llvm-readelf
    - Tools/llvm-strip


    - Utils/LLVMVisualizers

11) Rebuild ALL-BUILD

12) Copy the lib files from build\Release\lib to somwehere safe and point to them in the dub.sdl file (lflags).

