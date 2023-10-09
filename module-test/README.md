# Zig version 0.12.dev 使用文件模块系统

```zig
// main.zig

const one = @import("directory/one.zig")

pub fn main() void {
    one.run();
}
```