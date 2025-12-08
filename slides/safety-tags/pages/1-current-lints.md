
# Current Lints on Unsafe Code

<SubTOC />

---

## Rustc Lint: `unsafe_code`

[`#![forbid(unsafe_code)]`](https://doc.rust-lang.org/rustc/lints/listing/allowed-by-default.html#unsafe-code)
errs on the existence of `unsafe { }` and `unsafe fn`.

<TwoColumns>

<template #left>

```rust
#![forbid(unsafe_code)]
fn main() {
    unsafe { }
}

unsafe fn foo() { }
```

<div v-click=2 class="pt-2">

Also catch other potentially unsound constructs like `no_mangle`, `export_name`, and `link_section`.

</div>
</template>

<template #right>
<v-click at=1>

```rust
error: usage of an `unsafe` block
 --> src/main.rs:3:5
  |
3 |     unsafe { }
  |     ^^^^^^^^^^
  |
note: the lint level is defined here
 --> src/main.rs:1:9
  |
1 | #![deny(unsafe_code)]
  |         ^^^^^^^^^^^

error: declaration of an `unsafe` function
 --> src/main.rs:6:1
  |
6 | unsafe fn foo() { }
  | ^^^^^^^^^^^^^^^^^^^
```

</v-click>
</template>

</TwoColumns>

---

## Edition 2024 Enforces Granular Isolation of Unsafety

1. [Unsafe attributes](https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-attributes.html)
  must now be marked as `unsafe`.

<CodeblockSmallSized>
<TwoColumns>
<template #left>

```diff
-#[no_mangle]
+#[unsafe(no_mangle)]

-#[export_name = "malloc"]
+#[unsafe(export_name = "malloc")]

-#[link_section = ".section"]
+#[unsafe(link_section = ".section")]

pub fn example() {}
```

</template>

<template #right>

```rust
error: unsafe attribute used without unsafe
 --> src/lib.rs:1:3
  |
1 | #[no_mangle]
  |   ^^^^^^^^^ usage of unsafe attribute
  |
help: wrap the attribute in `unsafe(...)`
  |
1 | #[unsafe(no_mangle)]
  |   +++++++         +
```

</template>
</TwoColumns>
</CodeblockSmallSized>

<div v-click=1>

2. [`extern` blocks](https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-extern.html)
  must now be marked as `unsafe`.

<CodeblockSmallSized>
<TwoColumns>

<template #left>

```diff
-extern "C" {
+unsafe extern "C" {
    pub safe fn sqrt(x: f64) -> f64;
}

assert_eq!(sqrt(1.0), 1.0);
```

</template>
<template #right>

```rust
error: extern blocks must be unsafe
 --> src/main.rs:1:1
1 | / extern "C" {
2 | |     pub safe fn sqrt(x: f64) -> f64;
3 | | }
  | |_^
```

</template>
</TwoColumns>
</CodeblockSmallSized>

</div>

---
hideInToc: true
---

## Edition 2024 Enforces Granular Isolation of Unsafety

3. Rustc lint [`unsafe_op_in_unsafe_fn`](https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-op-in-unsafe-fn.html)
now warns by default.

<CodeblockSmallSized>

```diff
unsafe fn get_unchecked<T>(x: &[T], i: usize) -> &T {
-  x.get_unchecked(i)
+  unsafe { x.get_unchecked(i) }
}
```

If the unsafe call is not wrapped in unsafe block, Rust compiler warns

```rust
warning[E0133]: call to unsafe function `core::slice::<impl [T]>::get_unchecked` is unsafe and requires unsafe block
 --> src/lib.rs:2:3
  |
2 |   x.get_unchecked(i)
  |   ^^^^^^^^^^^^^^^^^^ call to unsafe function
  |
  = note: for more information, see <https://doc.rust-lang.org/edition-guide/rust-2024/unsafe-op-in-unsafe-fn.html>
  = note: consult the function's documentation for information on how to avoid undefined behavior
note: an unsafe function restricts its caller, but its body is safe by default
 --> src/lib.rs:1:1
  |
1 | unsafe fn get_unchecked<T>(x: &[T], i: usize) -> &T {
  | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  = note: `#[warn(unsafe_op_in_unsafe_fn)]` (part of `#[warn(rust_2024_compatibility)]`) on by default
```

</CodeblockSmallSized>

---

## Clippy Lints

1. [`missing_safety_doc`](https://rust-lang.github.io/rust-clippy/master/index.html?search=missing_safety_doc)
  checks for the doc comments of publicly visible unsafe functions and warns if there is no `# Safety` section.

<CodeblockSmallSized>
<TwoColumns>

<template #left>

```diff
+/// # Safety
+///
+/// Shouldn't call this before the horsemen are ready.
pub unsafe fn start_apocalypse(u: &mut Universe) { }
```

</template>

<template #right>

```rust
warning: unsafe function's docs are missing a `# Safety` section
 --> src/lib.rs:1:1
1 | pub unsafe fn start_apocalypse(u: &mut Universe) { }
  | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

</template>

</TwoColumns>
</CodeblockSmallSized>

<div v-click=1>

2. [`multiple_unsafe_ops_per_block`](https://rust-lang.github.io/rust-clippy/master/index.html?search=multiple_unsafe_ops_per_block)
  checks for unsafe blocks that contain more than one unsafe operation.

<CodeblockSmallSized>

```rust
fn read_char(ptr: *const u8) -> char {
    // SAFETY: The caller has guaranteed that the value pointed to by `bytes` is a valid `char`.
    unsafe { char::from_u32_unchecked(*ptr.cast::<u32>()) }
}
```

</CodeblockSmallSized>

</div>

---

<CodeblockSmallSized>

```rust
error: this `unsafe` block contains 2 unsafe operations, expected only one
 --> src/lib.rs:5:5
5 |     unsafe { core::char::from_u32_unchecked(*ptr.cast::<u32>()) }
  |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
note: unsafe function call occurs here
 --> src/lib.rs:5:14
5 |     unsafe { core::char::from_u32_unchecked(*ptr.cast::<u32>()) }
  |              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
note: raw pointer dereference occurs here
 --> src/lib.rs:5:45
5 |     unsafe { core::char::from_u32_unchecked(*ptr.cast::<u32>()) }
  |                                             ^^^^^^^^^^^^^^^^^^
```

```diff
#![deny(clippy::multiple_unsafe_ops_per_block)] // 👈
fn read_char(ptr: *const u8) -> char {
-  // SAFETY: The caller has guaranteed that the value pointed to by `bytes` is a valid `char`.
-  unsafe { char::from_u32_unchecked(*ptr.cast::<u32>()) }

+  // SAFETY: `ptr` is 4-byte aligned, points to four consecutive initialized bytes, and valid for reads of 4 bytes.
+  let int_value = unsafe { *ptr.cast::<u32>() };

+  // SAFETY: The caller has guaranteed that the four bytes pointed to by `bytes` represent a valid `char`.
+  unsafe { char::from_u32_unchecked(int_value) }
}
```

</CodeblockSmallSized>
