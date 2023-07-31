const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
});

pub fn main() void {
    _ = c;
}

// use
// zig build-exe verbose.zig -lc --verbose-cimport
// info(compilation): C import source: WE:\Users\la\AppData\Local\zig\o\66f55a194b642ad62d5926788bdf4cce\cimport.h
// info(compilation): C import .d file: WE:\Users\la\AppData\Local\zig\o\66f55a194b642ad62d5926788bdf4cce\cimport.h.d
// info(compilation): C import output: WE:\Users\la\AppData\Local\zig\o\93c0b99b5383eb3cf5c06ac6eadab27e\cimport.zig
