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

# Pre-RFC: Safety Property System

2025-07-28

<style>
h1 { font-size: 3.5rem; }
</style>

---

# 社区讨论 (1): Zulipchat Opsem 频道

<https://internals.rust-lang.org/t/pre-rfc-safety-property-system/23252>

![](https://github.com/user-attachments/assets/b1f9b5d4-9716-4a5e-bdc7-5b6277b045a6)


---

# 社区讨论 (2): IRLO 论坛

<https://rust-lang.zulipchat.com/#narrow/channel/136281-t-opsem/topic/Safety.20Property.20System/with/530679491>

![](https://github.com/user-attachments/assets/9edba322-23c8-499e-8589-8138ccce3441)

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

```rust
//  SAFETY
//  - ValidPtr, Aligned, Init: `head` is a slice of initialized elements.
//  - NotOwned: because we incremented...
//  - Alias: ...
```
