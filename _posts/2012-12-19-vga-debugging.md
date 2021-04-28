---
layout: post
title: Visual Debugging with VGA
---

I recently had a bit of a memory corruption bug with my kernel's heap allocator and I thought I'd share how I went about debugging it. In a kernel it's somewhat hard to debug code and off-by-one errors because it doesn't crash like a user program and instead just keep chugging along. You have to either setup a remote GDB session or try something a little more clever. Using GDB is usually okay for segfaults or reading structs, but when you have to deal with something like a heap allocator, it's just not enough for me.

My allocator is a simple free-list allocator (I know its slow) and I had a case in my `free()` implementation that rarely wrote a null when it shouldn't have. The only way I've found to debug a heap is to print it out somehow and if anything looks wrong in the printout then figure out what causes it. Normally you'd print out all the block sizes in the heap in two different colors, green if it's free and red if its used. But heaps are vast, and printing out megabytes of debug information is A) slows and B) unreadable. I needed a way to both debug the heap and not really slow anything down while still being understandable so I turned to the next best thing:

```c
void print_heap(void) {
  uint64_t o = 0;
  uint64_t i = 0;
  auto *c = (blk_t *)((u8 *)kheap_lo() + OVERHEAD);
  for (; (void *)c < kheap_hi(); c = NEXT_BLK(c)) {
    bool free = IS_FREE(c);
    int blocks = GET_SIZE(c);
    // shade (so adjacent blocks are different colors)
    int c = 200 + ((i * 16) % 56);
    // red (used) or green (free)
    int color = free ? vga::rgb(0, c, 0) : vga::rgb(c, 0, 0);
    // draw the pixels
    for (int b = 0; b < blocks; b++) {
      vga::set_pixel(o + b, color);
    }
    // update loop variables
    o += blocks;
    i++;
  }
}
```


Just print it over VGA! Here's what it looks like as I allocate memory:

![Image of Yaktocat](/images/vga-heap.gif)


