module llvm.all;

public:

version(LLVM_12) {
    pragma(msg,"Using LLVM 12.0.1");
}
version(LLVM_13) {
    pragma(msg,"Using LLVM 13.0.1");
}

import std.stdio    : writeln, writefln;
import std.string   : toStringz, fromStringz;
import std.algorithm.iteration : each, map;
import std.range    : array;
import std.format   : format;

import llvm.c.all;

import llvm.attributes;
import llvm.basicblock;
import llvm.builder;
import llvm.metadata;
import llvm.module_;
import llvm.pass;
import llvm.target;
import llvm.type;
import llvm.value;
import llvm.wrapper;

bool toBool(LLVMBool b) { return b==1; }
LLVMBool toLLVMBool(bool b) { return b ? 1 : 0; }
