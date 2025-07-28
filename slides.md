---
# You can also start simply with 'default'
theme: seriph
# 'auto'，'light' or 'dark'
colorSchema: light
# some information about your slides (markdown enabled)
title: "Pre-RFC: Safety Property System"
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
  # By default, Slidev will use ./og-image.png if it exists,
  # or generate one from the first slide if not found.
  ogImage: auto
  # ogImage: https://cover.sli.dev
monaco: fal
---

<h1 style="font-size: 3.5rem">Pre-RFC: Safety Property System</h1>

2025-07-28

---

# 社区讨论 (1): Zulipchat Opsem 频道

<https://internals.rust-lang.org/t/pre-rfc-safety-property-system/23252>

![](https://github.com/user-attachments/assets/9edba322-23c8-499e-8589-8138ccce3441)

---

# 社区讨论 (2): IRLO 论坛

<https://rust-lang.zulipchat.com/#narrow/channel/136281-t-opsem/topic/Safety.20Property.20System/with/530679491>

![](https://github.com/user-attachments/assets/b1f9b5d4-9716-4a5e-bdc7-5b6277b045a6)

---

# 社区讨论 (3): Reddit

<https://www.reddit.com/r/rust/comments/1m5k58y/prerfc_safety_property_system/>

![](https://github.com/user-attachments/assets/52951f09-979f-418b-af38-8562476bae87)

---

# 社区反馈结果：轻量级标注语法

```rust
#[safety {
  ValidPtr, Align, Init: "`self.head_tail()` returns two slices to live elements";
  NotOwned: "because we incremented...";
  Alias(elem, head.iter());
}]
unsafe { ptr::read(elem) }
```

<div class="m-4"></div>

```rust
//  SAFETY
//  - ValidPtr, Aligned, Init: `head` is a slice of initialized elements.
//  - NotOwned: because we incremented...
//  - Alias: ...
```

---

# safety-parse：实现新语法 `#[safety { }]`

实现新语法：
* 轻量形式：`#[safety { SP1, SP2 }]`
* 带注释：`#[safety { SP1, SP2: "reason" }]`
* 带参数：`#[safety { SP(arg1, arg2) }]`

<p class="text-xs">删除旧语法 <code>#[safety::precond::Prop]</code> 和
  <code>#[safety::discharges]</code>。</p>

--- 

# 轻量级标记：`#[safety { }]`

```rust
// lightweight tags
#[safety { SP }]
#[safety { SP1, SP2 }]
#[safety { SP1; SP2 }]

// tags with reason
#[safety { SP1: "reason" }]
#[safety { SP1: "reason"; SP2: "reason" }]

// grouped tags and shared reason
#[safety { SP1, SP2: "reason" }]
#[safety { SP1, SP2: "reason"; SP3 }]
#[safety { SP3; SP1, SP2: "reason" }]
#[safety { SP3, SP4; SP1, SP2: "reason" }]
#[safety { SP3; SP1, SP2: "reason"; SP4 }]

// optional trailing punctuation
#[safety { SP1, SP2: "reason"; SP3; }]
#[safety { SP1, SP2: "reason"; SP3, }]
```

--- 

# 带参数标记：用于属性验证

```rust
#[safety { SP1(a) }]
#[safety { SP1(a, b) }]

#[safety { SP1(a), SP2: "reason"; SP3 }]
#[safety { SP(a, b): "reason"; SP1, SP2: "reason"; SP3, SP4 }]

// `type.SP` to disambiguate SP type 
#[safety { hazard.Alias(p, q) }]
// arbitrary argument in Rust expression
#[safety { hazard.Alias(A {a: self.a}, a::b(c![])): ""; SP }]
```

RAPx Safety Property Verification:

<https://artisan-lab.github.io/RAPx-Book/6.4-unsafe.html>

---

# safety-parse：Toml 配置文件 - 动态定义属性



````md magic-move {lines: true}
```toml {1|1,2|2,3|4|5,6|*}
[tag.Alias]
args = [ "p1", "p2" ]
desc = "{p1} must not have other alias"
types = [ "hazard" ]
expr = "p1 = p2"
url = "https://github.com/Artisan-Lab/tag-std/blob/main/primitive-sp.md#342-alias"
```
````

```rust
#[safety { Alias }]
unsafe fn foo(p1: *const (), p2: *const ()) {}
```

```rust
#[safety { Alias(p1, p2) }]
unsafe fn foo(p1: *const (), p2: *const ()) {}
```

---

# 文档生成

![](https://github.com/user-attachments/assets/48ec3740-5a49-4afd-b17d-64bfc8b7e8e3)
