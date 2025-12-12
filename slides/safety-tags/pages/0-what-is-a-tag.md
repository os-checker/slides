
# What is a Rust Safety Tag?

<SubTOC />

---

## Terminology

<style>
strong { @apply text-orange-500; @apply font-bold; }
</style>

<div class="h-4"></div>

<div class="text-xl">

**Safety requirements are texts** written on unsafe code to demostrate what responsibilities
of the caller are in using the unsafe function correctly and how the callee fulfills these
safety responsibilities.

A **safety tag** is a safety requirement that is **structural and machine-readable**, in the
Rust's attribute syntax `#[safety::<predicate>(TagName(arguments))]`. We'll delve into the
mechanism in the slides.

A **safety property** (SP) refers to the **meaning of a safety requirement**, by virtue of a tag
name with optional arguments.

</div>

---

## Attribute Syntax

```
SafetyTags   -> `#` `[` `safety::` Predicate `(` Tags `)` `]`

Predicate    -> `requires` | `checked` | `delegated`

Tags         -> Tag (`,` Tag)* `,`?

Tag          -> (Type `.`)? TagName ( TagArguments )? (`:` LiteralString)?

Type         -> `precond` | `hazard`

TagName      -> SingleIdent

TagArguments -> `(` RustExpression (, RustExpression)* `)`
```

e.g.

```rust
#[safety::requires( Tag )]
#[safety::requires( Tag1, Tag2 )]

#[safety::requires( Tag3: "declare a safety requirement" )]
#[safety::checked ( Tag3: "how the requirement is met" )]
#[safety::checked ( Tag1, Tag2: "shared reasons for both requirements to be met" )]
```

---

## Predicate: `requires` | `checked` | `delegated`

<div class="h-4"></div>

<v-clicks>

* `#[safety::requires]` is placed on an unsafe function’s signature to state the safety
requirements that callers must uphold. It's a direct <span class="text-orange-500 font-bold">
replacement for the safety section</span> in doc comments.
* `#[safety::checked]` is placed on an expression that wraps an unsafe operation like
calling an unsafe function. It's a direct <span class="text-orange-500 font-bold">
replacement for inline safety comments</span> written above an unsafe block.
* `#[safety::delegated]` acts like `checked`, but delivers improved ergonomics and
supplementrary checks when <span class="text-orange-500 font-bold">transferring safety responsiblities</span>
from a function body to its signature.

</v-clicks>

<div class="h-4"></div>

<CodeblockSmallSized v-click>
<TwoColumns>
<template #right>

```rust
#[safety::requires(Tag1)] unsafe fn f1() {}
#[safety::requires(Tag2)] unsafe fn f2() {}
```

<div class="text-sm text-gray">

e.g. safety of `f1` is justified in `f3`, while safety of `f2` is guaranteed by the caller of `f3`.

</div>

</template>
<template #left>

```rust
#[safety::requires(Tag2)]
unsafe fn f3() { 
  #[safety::checked(Tag1: "justify why this reqirement is met")]
  unsafe { f1() }

  #[safety::delegated(Tag2: "safety is ensured by the caller of f3")]
  unsafe { f2() }
}
```

</template>
</TwoColumns>
</CodeblockSmallSized>

---

## Spec TOML and Tag Arguments

```rust
impl FaultEventRegisters {
    /// Creates an instance from the IOMMU base address.
    ///
    /// # Safety
    ///
    /// The caller must ensure that the base address is a valid IOMMU base address
    /// and that it has exclusive ownership of the IOMMU fault event registers.
    unsafe fn new(base_register_vaddr: NonNull<u8>) -> Self {
```

<div class="text-sm leading-[0.5]">

| **Property**  | **Arguments**  | **Description**                                                             |
| ------------- | -------------- | --------------------------------------------------------------------------- |
| ValidBaseAddr | addr, hardware | `addr` must be a valid base address of `hardware`.                          |
| OwnedResource | value, owner   | `value` must be exclusively owned by `owner`.                               |

</div>

```toml
# sp-asterinas.toml
[tag.ValidBaseAddr]
args = [ "addr", "hardware" ]
desc = "`{addr}` must be a valid base address of {hardware}."

[tag.OwnedResource]
args = [ "value", "owner" ]
desc = "`{value}` must be exclusively owned by {owner}."
```

---

<style scoped>
.slidev-layout p {
    margin-top: 0.8rem;
    margin-bottom: 0.5rem;
    line-height: 1rem;
}
</style>

Raw version:

```rust
/// # Safety
///
/// The caller must ensure that the base address is a valid IOMMU base address
/// and that it has exclusive ownership of the IOMMU fault event registers.
unsafe fn new(base_register_vaddr: NonNull<u8>) -> Self {
```

Safety tag version:

```rust
#[safety::requires(
    ValidBaseAddr(base_register_vaddr, hardware = "IOMMU"),
    OwnedResource(base_register_vaddr, owner = FaultEventRegisters)
)]
unsafe fn new(base_register_vaddr: NonNull<u8>) -> Self {
```

Macro expanded:

```rust
/// # Safety
///
/// - ValidBaseAddr: `base_register_vaddr` must be a valid base address of IOMMU.
/// - OwnedResource: `base_register_vaddr` must be exclusively owned by FaultEventRegisters.
unsafe fn new(base_register_vaddr: NonNull<u8>) -> Self {
```

---

## Linter: Identify and Report Missing Tags

<div class="h-2"></div>

<LinterReport />

<div v-click>

```diff
/// Initializes the fault reporting function.
///
-/// # Safety
-///
-/// The caller must ensure that the base address is a valid IOMMU base address and that it has
-/// exclusive ownership of the IOMMU fault event registers.
+#[safety::requires(
+    ValidBaseAddr(base_register_vaddr, hardware = "IOMMU"),
+    OwnedResource(base_register_vaddr, owner = FaultEventRegisters)
+)]
unsafe fn init(base_register_vaddr: NonNull<u8>) {
-   // SAFETY: The safety is upheld by the caller.
+   #[safety::delegated]
    FAULT_EVENT_REGS.call_once(|| SpinLock::new(unsafe { FaultEventRegisters::new(base_register_vaddr) }));
}
```

</div>

---

<style scoped>
.iommu p { margin-top: 0.2rem; margin-bottom: 0.2rem; line-height: 1rem; }
</style>

## Spec: What Does the Word "Valid" Mean?

<TwoColumns class="pt-4 pb-1 flex items-center justify-center">

<template #left>
<div class="text-xl text-red-500 font-bold">
This single tag means a lot!
</div>
</template>

<template #right>

```rust
#[safety::requires(ValidBaseAddr(base_register_vaddr, hardware = "IOMMU"))]
```

</template>

</TwoColumns>

<div class="text-xs iommu">

Key Steps for IOMMU Base Address Initialization:

1. **Hardware Detection and Configuration**
   - **Check Hardware Support**: Ensure that the hardware supports IOMMU features (e.g., Intel VT-d for Intel platforms, AMD-Vi for AMD platforms).
   - **Enable IOMMU in BIOS/UEFI**: Enable IOMMU-related features in the BIOS/UEFI settings (e.g., Intel VT-d).

2. **Parse the DMAR Table**
   - **Locate DMAR Table**: During system boot, locate the DMAR table in the ACPI tables, which contains detailed information about the IOMMU hardware, including the register base address and device scopes.
   - **Parse DRHD Structures**: Extract the `reg_base_addr` from the DRHD (DMA Remapping Hardware Unit Definition) structures within the DMAR table.

3. **Initialize IOMMU Hardware**
   - **Map Base Address**: Map the IOMMU register base address (`reg_base_addr`) to the kernel’s virtual address space.
   - **Set Up Tables**:
     - **Root Table**: Allocate and initialize the Root Table for each PCI Segment.
     - **Context Table**: Create Context Tables for devices that require DMA remapping.

4. **Configure IOMMU Features**
   - **Initialize IOMMU Domains**: Allocate domain IDs and structures for IOMMU domains and set up Root Entries.
   - **Set Up Global Domain**: Establish a global IOMMU domain responsible for address translation tables, mapping IOVA to HPA (Host Physical Address).
   - **Associate Devices**: Link devices to IOMMU domains by locating the Root Table using the device’s Bus number and creating Context Entries.

</div>

---

<style scoped>
.iommu p { margin-top: 0.2rem; margin-bottom: 0.2rem; line-height: 1rem; }
</style>

The value of IOMMU base address is specified by hardware manuals:

<img src="https://github.com/user-attachments/assets/ef19c115-94b9-4bd9-a3c8-739c61261a5a" class="h-[50%] block mx-auto">

<div class="text-center">

UEFI ACPI (Advanced Configuration and Power Interface) Specification [v6.6](https://uefi.org/sites/default/files/resources/ACPI_Spec_6.6.pdf)

</div>

<div class="text-xs iommu">

Also see

* [Intel® Virtualization Technology for Directed I/O Architecture Specification](https://www.intel.com/content/www/us/en/content-details/868911/intel-virtualization-technology-for-directed-i-o-architecture-specification.html) November 2025, Revision 5.10
  * 8.3 DMA Remapping Hardware Unit Definition Structure

* [AMD I/O Virtualization Technology (IOMMU) Specification](https://docs.amd.com/api/khub/documents/GD6kOXjzWsek8QUbn_qMvg/content) 48882-PUB—Rev 3.10—Feb 2025
  * Table 87: I/O Virtualization Hardware Definition (IVHD) Block Generic Format

</div>

---

## Spec: "Valid" Also Means a Lot in Rust!

<CodeblockSmallSized>

```toml
# sp-core.toml
[tag.ValidPtr]
args = [ "p", "T", "len" ]
desc = "pointer `{p}` must be valid for reading and writing the `sizeof({T})*{len}` memory from it"
expr = "Size(T, 0) || (!Size(T,0) && Deref(p, T, len))"
url = "https://doc.rust-lang.org/std/ptr/index.html#safety"

[tag.Deref]
args = [ "p", "T", "len" ]
desc = "pointer `{p}` must be dereferencable in the `sizeof({T})*{len}` memory from it"
expr = "Allocated(p, T, len, *) && InBound(p, T, len)"
url = "https://doc.rust-lang.org/std/ptr/index.html#safety"

[tag.Allocated]
args = [ "p", "T", "len", "A" ]
desc = "the memory range `[{p}, {p} + sizeof({T})*{len})` must be allocated by allocator `{A}`"
expr = "∀ i ∈ 0..sizeof(T)∗len, allocator(p + i) = A"
url = "https://doc.rust-lang.org/nightly/std/ptr/index.html#allocation"

[tag.InBound]
args = [ "p", "T", "len" ]
desc = "the pointer `{p}` and its offset up to `sizeof({T})*{len}` must point to a single allocated object"
expr = "mem(p, p+ sizeof(T) * len) ∈ single allocated object"
url = "https://github.com/Artisan-Lab/tag-std/blob/main/primitive-sp.md#321-allocation"
```

</CodeblockSmallSized>
