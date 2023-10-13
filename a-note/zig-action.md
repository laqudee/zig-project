# Action

- zig 参数是按照值传递的，我们传递的是指的浅副本

- getPtr方法返回的是指向map中值的指针

- Ownership所有权

```zig
var it = lookup.iterator();
while (it.next()) |kv| {
    std.debug.print("{s} => {any}\n", .{ kv.key_ptr.*, kv.value_ptr.* });
}
```

- 依赖while和可选类型Optional之间的协同作用

- 哈希表不仅需要长生命周期的值，还需要长生命周期的键

- ArrayList

- Anytype
  - 非常有用的编译时duck类型

- @TypeOf
  - 检查各种变量的类型