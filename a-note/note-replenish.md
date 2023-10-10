> learn zig note 补充

- 以@开头的函数是内置函数，由编译器提供，而不是标准库提供

- 导入标准库
- 导入其他文件
- 导出变量、函数定义

- //
- //! 顶级文档注释
- /// 文档注释

- zig支持任意宽度的整数

- 函数参数是常量

- 字段以逗号终止，且可以指定默认值

```zig
    pub const User = struct {
        power: u64 = 0,
        name: []const u8 = "unknown",

        pub const SUPER_POWER = 100000;

        fn diagnose(user: User) void {
            if (user.power > SUPER_POWER) {
                std.debug.print("User power too high!\n", .{SUPER_POWER});
            }
        }
    }
```

- user.diagnose() 等价于 User.diagnose(user)

- 数组的大小时固定的，长度在编译时已知
  - 长度是类型的一部分

```zig
const a = [5]i32{ 1, 2, 3, 4, 5 };
const b: [5]i32 = .{ 1, 2, 3, 4, 5 };
const c = [_]i32{ 1, 2, 3, 4, 5 };
```

- 切片是指向数组的指针
  - 外加一个运行时确定的长度
  - 没有容量，只有指针和长度

- 切片的长度不是类型的一部分。
- 可变性const-ness也是数组类型的一部分

- 切片的类型总是从底层数组派生出来的

- 字符串是u8的序列（即数组或片段）
  - UTF-8

- `*const [4]u8`
- `const [4]u8`
- `*const [4:0]u8`
- 字符串字面量以空值结束`\0`

- zig会自动进行类型转化
  - 当遇到`[]const u8`类型，表示字符串字面量是可以使用的

- 编译时执行compile-time execute

- comptime会对编码产生直接影响的地方就是整数和浮点数字面的默认类型
  - comptime_int
  - comptime_float

- comptime_int的默认类型是const

- 匿名结构体

- Zig没有函数重载，也没有可变函数。
  - 但编译器能根据传入的类型创建专门的函数，包括编译器自己推导和创建的类型