---
title: Rust Safety Tags
titleTemplate: '%s'
info: Idea and work to tag unsafe code with properties.
author: zjp-CN (苦瓜小仔)
date: 2025-12-14
theme: seriph
# background: https://picsum.photos/800/600
transition: slide-left
routerMode: hash
download: true
monaco: false
hideInToc: true
---

<h1 class="font-bold !text-orange-500">Rust Safety Tags</h1>

Github Repo: [Artisan-Lab/tag-std](https://github.com/Artisan-Lab/tag-std)

Presenter: 周积萍

<style scoped>
.slidev-layout.cover {
  background: var(--slidev-theme-background) !important;
  color: var(--slidev-theme-foreground) !important;
}
</style>

---
hideInToc: true
---

# Self-Intro

* [os-checker](https://github.com/os-checker/os-checker) 作者
  * 来自唐图 ([rCoreOS](https://github.com/rcore-os/)) 开源社区；检查 ArceOS、Starry、axVisor 代码库
  * 收录于旋武社区项目 [#26](https://xuanwu.openatom.cn/articles/project/26-os-checker/)
* [safety-tool](https://github.com/Artisan-Lab/tag-std) 作者
  * 安全属性标注；[RFC#3842](https://github.com/rust-lang/rfcs/pull/3842)
* [distributed-verification](https://github.com/os-checker/distributed-verification) 作者
  * Kani 资源节约验证；verify-rust-std & Google 开源之夏
* Rust 中文社区 ([rustcc](https://rustcc.cn/)) 新闻日报编辑：苦瓜小仔

---
hideInToc: true
routeAlias: toc
---

# Table of Contents

<Toc maxDepth="1" />

---

# What is a Rust Safety-Tag?

---

# Current Lints on Unsafe Code

* [`#![forbid(unsafe_code)]`](https://doc.rust-lang.org/rustc/lints/listing/allowed-by-default.html#unsafe-code)
  * Compilation error on the existence of `unsafe { }` and `unsafe fn`.

<CodeblockSmallSized>
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
</CodeblockSmallSized>



