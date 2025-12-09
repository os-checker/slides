<template>
<AnsiCodeBlock>
<pre>
boot::call_ostd_main
├── init <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Context</span></span> <span class="ef246">}</span>
│   ├── mm::frame::allocator::init_early_allocator <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">PostToFunc</span></span> <span class="ef246">}</span>
│   ├── cpu::init_on_bsp <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">Context</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">PostToFunc</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Unaccessed</span></span> <span class="ef246">}</span>
│   │   ├── cpu::local::copy_bsp_for_ap <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">Context</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Unaccessed</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Valid</span></span> <span class="ef246">}</span>
│   │   │   ├── core::intrinsics::write_bytes
│   │   │   ├── core::slice::from_raw_parts_mut
│   │   │   ├── cpu::local::__cpu_local_start
│   │   │   ├── cpu::local::__cpu_local_end
│   │   │   └── core::intrinsics::copy_nonoverlapping
│   │   ├── cpu::set_this_cpu_id <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">Valid</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span> <span class="ef246">}</span>
│   │   └── cpu::init_num_cpus <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">Context</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Valid</span></span> <span class="ef246">}</span>
│   ├── mm::frame::meta::init <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Context</span></span> <span class="ef246">}</span>
│   │   └── mm::page_table::boot_pt::BootPageTable::&lt;E, C&gt;::map_base_page <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">KernelMemorySafe</span></span> <span class="ef246">}</span>
│   │       ├── core::ptr::mut_ptr::&lt;impl *mut T&gt;::add
│   │       ├── core::ptr::mut_ptr::&lt;impl *mut T&gt;::read
│   │       └── core::ptr::mut_ptr::&lt;impl *mut T&gt;::write
│   ├── mm::frame::allocator::init <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">PostToFunc</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">PostToFunc</span></span> <span class="ef246">}</span>
│   ├── arch::late_init_on_bsp <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">Context</span></span> <span class="ef246">}</span>
│   └── mm::kspace::activate_kernel_page_table <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span> <span class="ef246">}</span>
│       ├── mm::page_table::PageTable::&lt;C&gt;::first_activate_unchecked <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span> <span class="ef246">}</span>
│       │   └── mm::page_table::node::&lt;impl ...&gt;::first_activate <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">Valid</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span> <span class="ef246">}</span>
│       │       └── arch::mm::activate_page_table <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">ValidInstanceAddr</span></span> <span class="ef246">}</span>
│       └── mm::page_table::boot_pt::dismiss <span class="ef246">{</span> <span class="bold"><span style="color:rgb(255,165,000)">NotPriorToFunc</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">NotPostToFunc</span></span>, <span class="bold"><span style="color:rgb(255,165,000)">CallOnce</span></span> <span class="ef246">}</span>
└── boot::call_ostd_main::__ostd_main
</pre>
</AnsiCodeBlock>
</template>
