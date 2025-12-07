
# Community Approaches

---

## Rust for Linux - Safety Standard Proposal (2024.09)

* Kangrejos Conference [Slides](https://kangrejos.com/2024/Rust%20Safety%20Standard.pdf):
  Rust Safety Standard - Increasing the Correctness of unsafe Code
* LWN [article](https://lwn.net/Articles/990273/):
  A discussion of Rust safety documentation
* R4L RFC "Introduce the Rust Safety Standard" 
  [Patches](https://lore.kernel.org/rust-for-linux/20240717221133.459589-1-benno.lossin@proton.me/) by Benno Lossin
* and [more](https://github.com/Artisan-Lab/tag-std/issues/3)

<Info>

* <span class="text-red-500 font-bold underline decoration-wavy decoration-skip-none underline-offset-4">
  Goal: Always use the same wording for the same situation.</span>
* Better documented requirements, justifications, invariants and guarantees:
  * Make authors write as little as possible,
  * Give readers extensive explanations.
* Easier to write: No need to come up with wording yourself.
* Easier to learn: Only one way needs to be learned.
* Leave no room for misinterpretations: everyone knows the semantics of the comments.

</Info>

---

## Rust for Linux: Safety Standard

Provide a correct justification for _every_ safety requirements of _every_ operation:

<CodeblockSmallSized>
<TwoColumns>

<template #left>

```rust
/// # Safety
///
/// `ptr` must have been returned by a previous
/// call to [`Arc::into_raw`]. Additionally, it
/// must not be called more than once for each
/// previous call to [`Arc::into_raw`].
pub unsafe fn from_raw(ptr: *const T) -> Arc<T>;
```

<div class="text-center">Requirements</div>

</template>

<template #right>

```rust
let ptr = Arc::into_raw(arc);
// SAFETY: `ptr` comes from `Arc::into_raw` and
// we only call this function once with `ptr`.
let arc = unsafe { Arc::from_raw(ptr) };
```

<div class="text-center">Justifications</div>

</template>

</TwoColumns>
</CodeblockSmallSized>

<div class="font-bold text-orange-500 pt-4">
Rephrase the safety comments in safety-tool syntax:
</div>

<CodeblockSmallSized>
<TwoColumns>

<template #left>

```rust
#[safety::requires(
  OriginateFrom(ptr, Arc::into_raw),
  CallOnce: "for each previous call to [`Arc::into_raw`]"
)]
pub unsafe fn from_raw(ptr: *const T) -> Self {
```

<div class="text-center text-orange-500">Property</div>

</template>

<template #right>

```rust
let ptr = Arc::into_raw(arc);
#[safety::checked(
  OriginateFrom(ptr, Arc::into_raw), CallOnce
)]
let arc = unsafe { Arc::from_raw(ptr) };
```

<div class="text-center text-orange-500">Discharge</div>

</template>

</TwoColumns>
</CodeblockSmallSized>

---

## Rust for Linux: Common Safety Requirements

```text
+------------------------+---------------------+---------------------------------------------------+
| Syntax                 | Meta Variables      | Meaning                                           |
|                        |                     |                                                   |
+========================+=====================+===================================================+
| ``ptr`` is valid for   |                     | Abbreviation for:                                 |
| reads and writes.      |                     |                                                   |
|                        | * ``ptr: *mut T``   | * ``ptr`` is valid for reads.                     |
|                        |                     | * ``ptr`` is valid for writes.                    |
+------------------------+---------------------+---------------------------------------------------+
| ``ptr`` is valid for   |                     | Abbreviation for:                                 |
| reads.                 |                     |                                                   |
|                        | * ``ptr: *const T`` | * ``ptr`` is valid for reads up to                |
|                        |                     |   ``size_of::<T>()`` bytes for the duration of    |
|                        |                     |   this function call.                             |
+------------------------+---------------------+---------------------------------------------------+
| ``ptr`` is valid for   |                     | Abbreviation for:                                 |
| writes.                |                     |                                                   |
|                        | * ``ptr: *mut T``   | * ``ptr`` is valid for writes up to               |
|                        |                     |   ``size_of::<T>()`` bytes for the duration of    |
|                        |                     |   this function call.                             |
+------------------------+---------------------+---------------------------------------------------+
```

src: [lore.kernel.org/rust-for-linux: RFC PATCH 4/5 safety standard: add safety requirements](https://lore.kernel.org/rust-for-linux/20240717221133.459589-5-benno.lossin@proton.me/)

---

## In safety-tool's tag spec syntax

```toml
# For "ptr is valid for reads and writes", we can
# * define [tag.ValidPtr] or [tag.ValidReadWrite]
# * or just combine the current tags ValidRead and ValidWrite

[tag.ValidRead]
args = [ "ptr" ]
desc = """
The pointer `{ptr}` must be valid for reads up to `size_of::<T>()` bytes for the duration of this function call.
"""

[tag.ValidWrite]
args = [ "ptr" ]
desc = """
The pointer `{ptr}` must be valid for writes up to `size_of::<T>()` bytes for the duration of this function call.
"""
```

---

<CodeblockSmallSized>
<TwoColumns>

<template #left>

```rust
/// # Safety
///
/// `this` must be a valid pointer.
///
/// If `this` does not represent the root group of a configfs subsystem,
/// `this` must be a pointer to a `bindings::config_group` embedded in a
/// `Group<Parent>`.
///
/// Otherwise, `this` must be a pointer to a `bindings::config_group` that
/// is embedded in a `bindings::configfs_subsystem` that is embedded in a
/// `Subsystem<Parent>`.
unsafe fn get_group_data<'a, Parent>(this: *mut bindings::config_group) -> &'a Parent {
    // SAFETY: `this` is a valid pointer.
    let is_root = unsafe { (*this).cg_subsys.is_null() };
    if !is_root {
        // SAFETY: By C API contact,`this` was returned from a call to
        // `make_group`. The pointer is known to be embedded within a
        // `Group<Parent>`.
        unsafe { &(*Group::<Parent>::container_of(this)).data }
    } else {
        // SAFETY: By C API contract, `this` is a pointer to the
        // `bindings::config_group` field within a `Subsystem<Parent>`.
        unsafe { &(*Subsystem::container_of(this)).data }
    }
}
```

</template>

<template #right>

Rust for Linux:
Real Code Example

src: [linux/rust/kernel/configfs.rs](https://github.com/Rust-for-Linux/linux/blob/559e608c46553c107dbba19dae0854af7b219400/rust/kernel/configfs.rs#L297-L322)

</template>

</TwoColumns>
</CodeblockSmallSized>

---

<TwoColumns>

<template #left>

```rust {*|2,8,9,10,12,17,22|3-6,14-17,19-22}{lines:true}
#[safety::requires(
  ValidPtr(this),
  any(
    PointToField(ptr = this, field = bindings::config_group, adt = Group<Parent>),
    PointToField(ptr = this, field = bindings::configfs_subsystem, adt = Subsystem<Parent>)
  )
)]
unsafe fn get_group_data<'a, Parent>(this: *mut bindings::config_group) -> &'a Parent {
    #[safety::delegated(ValidPtr(this))]
    let is_root = unsafe { (*this).cg_subsys.is_null() };

    #[safety::checked(Dereferencible: "`this` is valid to access the data")]
    if !is_root {
        #[safety::delegated(PointToField: 
          "By C API contact,`this` was returned from a call to `make_group`.
           The pointer is known to be embedded within a `Group<Parent>`")]
        unsafe { &(*Group::<Parent>::container_of(this)).data }
    } else {
        #[safety::delegated(PointToField: 
          "By C API contract, `this` is a pointer to the
          `bindings::config_group` field within a `Subsystem<Parent>`")]
        unsafe { &(*Subsystem::container_of(this)).data }
    }
}
```

</template>

<template #right>

Property
* Delegation
* Interaction
* Composition
* Flow

</template>

</TwoColumns>
