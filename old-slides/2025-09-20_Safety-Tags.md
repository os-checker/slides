---
# You can also start simply with 'default'
theme: seriph
# 'auto'，'light' or 'dark'
colorSchema: auto
# some information about your slides (markdown enabled)
title: "Safety Tags"
info: |
  tag-std: https://github.com/Artisan-Lab/tag-asterinas
# apply unocss classes to the current slide
class: text-center
# https://sli.dev/features/drawing
drawings:
  persist: false
# slide transition: https://sli.dev/guide/animations.html#slide-transitions
transition: slide-left
# enable MDC Syntax: https://sli.dev/features/mdc
# mdc: true
# open graph
seoMeta:
  ogImage: https://cover.sli.dev
monaco: false
# controls whether texts in slides are selectable
selectable: true
routerMode: hash
---

<h1 style="font-size: 3.5rem">Safety Tags</h1>

2025-09-20

---

# 星绽周会：处理标量（指针、数字类型）的所有权

示例：`write_pte` 要求 PTE 具有所有权

[write_pte]: https://github.com/asterinas/asterinas/blob/391f11f1aa112382e7a68d6eb6ec443bc5289eeb/ostd/src/mm/page_table/node/mod.rs#L234-L236C71
[from_raw]: https://doc.rust-lang.org/std/sync/struct.Arc.html#method.from_raw
[into_raw]: https://doc.rust-lang.org/std/sync/struct.Arc.html#method.into_raw

* [write_pte] 接受了 PTE 应该表示资源消耗，即便 PTE 是一个标量
* 这和 Box/Arc::[from_raw]、[into_raw] 面临类似的要求
* 针对这类 API，在手动管理资源时，虽然安全文档只允许释放一次，但实际可以通过指针构造另一个实例来释放两个实例（问题：这属于 hazard 吗？）
* 参会者提到 linear ghost type，应该指的是 [verus-ghost paper](https://www.andrew.cmu.edu/user/bparno/papers/verus-ghost.pdf)

```rust
impl<'rcu, C: PageTableConfig> PageTableGuard<'rcu, C> {
    /// # Safetey
    ///  3. The page table node will have the ownership of the [`Child`]
    ///     after this method.
    pub(super) unsafe fn write_pte(&mut self, idx: usize, pte: C::E) { ... }
}
```

---

# 星绽周会：insensitive resource

* 构造 Serial Port 是也要求该资源具有所有权，但它是 insensitive resource 
  * insensitive 表示误用资源不会对内核造成内存安全问题，见星绽 ATC'25 [论文](https://www.usenix.org/system/files/atc25-peng-yuke.pdf)
* 在标注安全属性时，可能需要携带或者考虑以下信息/参数：有效的值（不同外设具有唯一有效的端口号）、区分用途/目的

```rust
#[safety {
  Valid(port, 0x1234, "Peripheral1")
}]
```

or 

```rust
#[safety {
  Valid(port): "Peripheral1 only requires 0x1234 port"
}]
```

src: [SerialPort::new](https://github.com/Artisan-Lab/tag-asterinas/blob/ec72f34e13121ccb30dea53bb8f533af23cb4efa/ostd/src/arch/x86/device/serial.rs#L34-L40)

---

# 星绽周会：下周正式汇报

目标：
* 尽可能高的覆盖率
  * ostd 不公开 unsafe API，因此需要考虑所有 unsafe API 
  * 对于特别难标注的特殊的 unsafe API，可以暂时不标注
* 展示效果最明显的改进
  * 足够说服大家在星绽中采用我们的安全属性标注

--- 

# 如何达到目标？

高覆盖率：
1. 有多少 unsafe API
    * 暂时只关注 unsafe fn 和 unsafe block
2. 较为通用的安全属性能够覆盖多少

如何效果明显：
1. 易于理解和采用
2. 相当常见（减少繁琐和重复）
3. 作为类型系统的补充？
4. 用实际例子说明有帮助：
    * 遗漏了某些安全文档
    * 遗漏而造成了问题
    * 代码和文档发生变动是，易于审查相应的安全属性需要更新或者重新考虑

---

# 讨论：模块内的文档


* Define rules in documentation in [`cfg_noodle::safety_guide`](https://docs.rs/cfg-noodle/latest/cfg_noodle/safety_guide/index.html) module

```md
3. The Node "Data Item" may be modified IFF:
    1. The Node is attached to a List, AND:
        1. The mutex for the List is locked
        2. Any of the following are true:
            1. If updated by `process_reads()`: The Node is in the "Initial" state, OR
            2. If updated by `attach()`: The Node is in the "NonResident" state, OR
            3. If updated by `Handle::write()` (no additional requirements).
    2. The Node is NOT attached to a List, and the "Data Item" is being reset during `detach()`.
```

* [Usage](https://docs.rs/cfg-noodle/latest/src/cfg_noodle/storage_list.rs.html#773-813)

```rust
// Call the deserialization function
//
// SAFETY:
// - Rule 3.1: The node is part of this list
// - Rule 3.1.1: The mutex is locked
// - Rule 3.1.2.1: We checked the node is in the Initial state
let res = unsafe { (vtable.deserialize)(nodeptr, kvpair.body) };
```

---

<div style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 500px;">
  <img src="https://github.com/user-attachments/assets/c8ff6ec5-08dd-4d37-8f1b-4e1919cd3004" style="height: 95%">
  <div style="background-color:green; color:white">RFC#3842: <a href="https://github.com/rust-lang/rfcs/pull/3842">Safety Tags</a> </div>
</div>

---


```rust
#[safety::requires( // 💡 define safety tags on an unsafe function
    valid_ptr = "src must be [valid](https://doc.rust-lang.org/std/ptr/index.html#safety) for reads",
    aligned = "src must be properly aligned, even if T has size 0",
    initialized = "src must point to a properly initialized value of type T"
)]
pub unsafe fn read<T>(ptr: *const T) { }

#[safety::checked(valid_ptr, aligned, initialized)] // 💡 discharge
unsafe { read(&()) };
```

<div style="text-align: center">
主要差异：细分 safety；定义在 API 之上 vs 全局 TOML 定义；不携带参数 vs 携带参数
</div>

```toml
# safety-tool/assets/sp-core.toml
[tag.ValidPtr]
args = [ "p", "T", "len" ]
desc = "pointer `{p}` must be valid for reading and writing the `sizeof({T})*{len}` memory from it"
expr = "Size(T, 0) || (!Size(T,0) && Deref(p, T, len))"

[tag.Align]
args = [ "p", "T" ]
desc = "pointer `{p}` must be properly aligned for type `{T}`"
expr = "p % alignment(T) = 0"

[tag.Init]
args = [ "p", "T", "len" ]
desc = "the memory range `[{p}, {p} + sizeof({T})*{len}]` must be fully initialized for type `{T}`"
expr = "∀ i ∈ 0..len, mem(p + sizeof(T) * i, p + sizeof(T) * (i+1)) = valid(T)"
```

---

# 安全属性定义在 API 的优缺点

优点：

1. 每个 API 都是各自的命名空间
    * 永远不需要标签担心重名
    * 无需路径引入：可以使用 API，就可以使用标签
2. 非常简单直观、易于理解
    * 适合不通用的安全属性、直接反映上下文相关的安全要求
    * 结构化安全注释在属性宏上的直接表达

缺点：

1. 没有通用标签
    * 这可能是一个根本矛盾：安全属性到底有多通用？
    * 我们正在解决什么问题？

---

# RFC Unresolved Question：携带参数的设计

```rust
#[safety::requires(
  valid_ptr = {
    args = [ "p", "T", "len" ],
    desc = "pointer `{p}` must be valid for \
      reading and writing the `sizeof({T})*{n}` memory from it"
  }
)]
unsafe fn foo<T>(ptr: *const T) -> T { ... }

#[safety::checked(valid_ptr(p))] // p will not be type-checked
unsafe { bar(p) }
```

vs 

```toml
[tag.ValidPtr]
args = [ "p", "T", "len" ]
desc = "pointer `{p}` must be valid for reading and writing the `sizeof({T})*{len}` memory from it"
expr = "Size(T, 0) || (!Size(T,0) && Deref(p, T, len))"
```

---

# RFC 其他设计：batch_checked

[`#[safety::batch_checked]`](https://github.com/Artisan-Lab/rfcs/blob/safety-tags/text/0000-safety-tags.md#safetybatch_checked-shares-tag-discharging)
同时消除多个 unsafe 操作中的安全属性

```rust
#[safety::batch_checked(
  aligned = "arrays are properly aligned",
  valid_for_reads = "the arrays are owned by this function, and contain the copy type f32",
)]
unsafe {
    float32x4x4_t(
        vld1q_f32(a.as_ptr()),
        vld1q_f32(b.as_ptr()),
        vld1q_f32(c.as_ptr()),
        vld1q_f32(d.as_ptr()),
    )
}
```

---

# RFC 其他设计：delegated

[`#[safety::delegated]`](https://github.com/rust-lang/rfcs/pull/3842#discussion_r2364998883) 委托消除安全属性的责任到调用者

```rust
struct Vec<T> {
  #[safety::requires(
    no_more_than_cap = "0 <= len <= cap",
    valid_T_all_in_length_range = "all elements in the Vec<T> between 0 and len are valid T"
  )]
  unsafe len: usize,
  ...
}
```

```rust
#[safety::requires(no_more_than_cap, valid_T_all_in_length_range)]
unsafe fn set_len(&mut self, new_len: usize) {
  debug_assert!(new_len <= self.capacity());
  #[safety::delegated(no_more_than_cap, valid_T_all_in_length_range)]
  unsafe { self.len = new_len }
}
```
