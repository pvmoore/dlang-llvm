module llvm.attributes;
/**
 *
 */
import llvm.all;

/*
// from AttributesCompatFunc.inc:

    "align", Attribute::Alignment)
    "allocsize", Attribute::AllocSize)
    "alwaysinline", Attribute::AlwaysInline)
    "argmemonly", Attribute::ArgMemOnly)
    "builtin", Attribute::Builtin)
    "byval", Attribute::ByVal)
    "cold", Attribute::Cold)
    "convergent", Attribute::Convergent)
    "dereferenceable", Attribute::Dereferenceable)
    "dereferenceable_or_null", Attribute::DereferenceableOrNull)
    "inalloca", Attribute::InAlloca)
    "inreg", Attribute::InReg)
    "inaccessiblememonly", Attribute::InaccessibleMemOnly)
    "inaccessiblemem_or_argmemonly", Attribute::InaccessibleMemOrArgMemOnly)
    "inlinehint", Attribute::InlineHint)
    "jumptable", Attribute::JumpTable)
    "minsize", Attribute::MinSize)
    "naked", Attribute::Naked)
    "nest", Attribute::Nest)
    "noalias", Attribute::NoAlias)
    "nobuiltin", Attribute::NoBuiltin)
    "nocapture", Attribute::NoCapture)
    "noduplicate", Attribute::NoDuplicate)
    "noimplicitfloat", Attribute::NoImplicitFloat)
    "noinline", Attribute::NoInline)
    "norecurse", Attribute::NoRecurse)
    "noredzone", Attribute::NoRedZone)
    "noreturn", Attribute::NoReturn)
    "nounwind", Attribute::NoUnwind)
    "nonlazybind", Attribute::NonLazyBind)
    "nonnull", Attribute::NonNull)
    "optsize", Attribute::OptimizeForSize)
    "optnone", Attribute::OptimizeNone)
    "readnone", Attribute::ReadNone)
    "readonly", Attribute::ReadOnly)
    "returned", Attribute::Returned)
    "returns_twice", Attribute::ReturnsTwice)
    "signext", Attribute::SExt)
    "safestack", Attribute::SafeStack)
    "sanitize_address", Attribute::SanitizeAddress)
    "sanitize_memory", Attribute::SanitizeMemory)
    "sanitize_thread", Attribute::SanitizeThread)
    "alignstack", Attribute::StackAlignment)
    "ssp", Attribute::StackProtect)
    "sspreq", Attribute::StackProtectReq)
    "sspstrong", Attribute::StackProtectStrong)
    "sret", Attribute::StructRet)
    "swifterror", Attribute::SwiftError)
    "swiftself", Attribute::SwiftSelf)
    "uwtable", Attribute::UWTable)
    "writeonly", Attribute::WriteOnly)
    "zeroext", Attribute::ZExt)
*/
enum LLVMAttribute : string {
    Cold            = "cold",           // function rarely called
    NoUnwind        = "nounwind",       // function
    NoInline        = "noinline",       // function
    AlwaysInline    = "alwaysinline",   // function
    InlineHint      = "inlinehint",     // function
    ReadOnly        = "readonly",       // function or argument
    WriteOnly       = "writeonly",      // function or argument
    OptimiseNone    = "optnone",        // function


    NonNull         = "nonnull"
}
private __gshared const LLVMAttribute[uint] kindToAttrib;

shared static this() {
    import std.traits : EnumMembers;
    foreach(e; EnumMembers!LLVMAttribute) {
        string n = cast(string)e;
        uint k   = LLVMGetEnumAttributeKindForName(n.ptr, n.length);
        kindToAttrib[k] = e;
    }
    //writefln("kindToAttrib=%s", kindToAttrib);
}

// https://patchwork.freedesktop.org/patch/120211/

void addFunctionAttribute(LLVMValueRef func, LLVMAttribute attr) {
    LLVMAddAttributeAtIndex(func, -1, getEnumAttribute(attr));
}
void removeFunctionAttribute(LLVMValueRef func, LLVMAttribute attr) {
    uint kind  = getKindId(attr);
    LLVMRemoveEnumAttributeAtIndex(func, -1, kind);
}
/// arg -1 is the func, arg 0 is the return value, arg 1 is the first parameter
void addFunctionArgAttribute(LLVMValueRef func, uint index, LLVMAttribute attr) {
    LLVMAddAttributeAtIndex(func, index, getEnumAttribute(attr));
}
/// arg -1 is the func, arg 0 is the return value, arg 1 is the first parameter
void removeFunctionArgAttribute(LLVMValueRef func, uint index, LLVMAttribute attr) {
    uint kind = getKindId(attr);
    LLVMRemoveEnumAttributeAtIndex(func, index, kind);
}
LLVMAttribute[] getFunctionAttributes(LLVMValueRef func) {
    return getFunctionArgAttributes(func, -1);
}
/// arg -1 is the func, arg 0 is the return value, arg 1 is the first parameter
LLVMAttribute[] getFunctionArgAttributes(LLVMValueRef func, int index) {
    uint count = LLVMGetAttributeCountAtIndex(func, index);
    if(count==0) return [];
    LLVMAttributeRef[] attrs1 = new LLVMAttributeRef[count];
    LLVMGetAttributesAtIndex(func, index, attrs1.ptr);
    LLVMAttribute[] attrs2;
    foreach(a; attrs1) {
        uint kind = LLVMGetEnumAttributeKind(a);
        attrs2 ~= kindToAttrib[kind];
    }
    return attrs2;
}
void addAttribute(LLVMValueRef instr, uint index, LLVMAttribute attr) {
    // todo
}

private LLVMAttributeRef getEnumAttribute(LLVMAttribute attr, ulong value=0) {
    uint kind = getKindId(attr);
    return LLVMCreateEnumAttribute(LLVMGetGlobalContext(), kind, 0);
}
private uint getKindId(LLVMAttribute attr) {
    string str = cast(string)attr;
    return LLVMGetEnumAttributeKindForName(str.ptr, str.length);
}


/+
+#if HAVE_LLVM < 0x0400
+   LLVMAttribute attr = str_to_attr(attr_name, attr_len);
+   if (attr_idx == -1) {
+      LLVMAddFunctionAttr(function, attr);
+   } else {
+      LLVMAddAttribute(LLVMGetParam(function, attr_idx), attr);
+   }
+#else
+   LLVMContextRef context = LLVMGetModuleContext(LLVMGetGlobalParent(function));
+   unsigned kind_id = LLVMGetEnumAttributeKindForName(attr_name, attr_len);
+   LLVMAttributeRef attr = LLVMCreateEnumAttribute(context, kind_id, 0);
+   LLVMAddAttributeAtIndex(function, attr_idx, attr);
+#endif
+/

