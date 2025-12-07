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
src: ./pages/1-current-lints.md
---
