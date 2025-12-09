# RFC#3842: Safety Tags

<SubTOC />

---

<img src="./rfc-safety-tags.png" class="h-full" />

---

<div class="text-xl">

* <a class="text-orange-500 font-bold" href="https://github.com/rust-lang/rfcs/pull/3842" target="_blank">RFC#3842: Safety Tags</a>
  : 172 conversations, 12 reviewers
* Rust [zulipchat thread](https://rust-lang.zulipchat.com/#narrow/channel/136281-t-opsem/topic/Safety.20Property.20System/)
  : 60 conversations, 7 posters
* Pre-RFC: Safety Property System
  * [Rust Internals Forum](https://internals.rust-lang.org/t/pre-rfc-safety-property-system/23252): 37 replies, 10 posters
  * [Reddit](https://www.reddit.com/r/rust/comments/1m5k58y/prerfc_safety_property_system/): 74 upvotes, 15 comments

</div>

---

## Motivation: Granular Unsafe: How Small Is Too Small?

Rust languange and compiler focus on **making unsafety source and usage explicit and visually granular**.


<div class="text-xs pt-20" v-click=1>

There are also some exotic visual unsafety proposals from IRLO:
* 2023-10: [Ability to call unsafe functions without curly brackets](https://internals.rust-lang.org/t/ability-to-call-unsafe-functions-without-curly-brackets/19635/22)
  proposes `unsafe unsafe_fn()` without curly brackets `{}`
* 2024-10: [Detect and Fix Overscope unsafe Block](https://internals.rust-lang.org/t/detect-and-fix-overscope-unsafe-block/21660/19)
  * 2025-01: [RFC: Add safe blocks](https://github.com/rust-lang/rfcs/pull/3768)
    proposes `unsafe { safe { /* code */ } }`
* 2025-02: [Pre-RFC: Single function call unsafe](https://internals.rust-lang.org/t/pre-rfc-single-function-call-unsafe/22343)
  proposes the `.unsafe` postfix

</div>

---

Clippy lints step a bit further towards the <span class="text-orange-500 font-bold">semantic unsafety</span>:
* `missing_safety_doc` checks the existence of `# Safety` section in doc comments.
* `multiple_unsafe_ops_per_block` checks the occurence of unsafe operations in `unsafe { }`.

<Info>
<div class="font-bold text-lg">

Safety tags define the unsafety <span class="text-red-500">at coarse semantic granularity</span>, not just visually! That means
* splitting \# Safety doc section from paragraphs into referencable entities,
* condensing long texts of a safety requirement into single identity.

</div>
</Info>

---

## Other Motivations

<div class="h-5"></div>

3. Safety invariants have no <span class="text-red-500 font-bold">SemVer</span> capability:
  * Downstream crates may be unaware of changes on safety requirements,
    and thus exposed to risks.
  * Tags are a part of API; definition change can be SemVer-breaking,
    so **safety invariants evolve explicitly**.

<div class="h-5"></div>

4. Suit for <span class="text-red-500 font-bold">daily</span> projects:
  * Establish shared vocabulary and **forge consensus in everyday review**.
  * By contrast, formal contracts excel verifying code at extremely fine semantic granularity,
    but they are much harder to maintain.



