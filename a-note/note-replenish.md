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

- and or 替代逻辑运算&& ||
- 运算符==在切片之间不起作用，大多数情况下要使用`std.mem.eql(u8, str1, str2)`，它将比较两个片段的长度和字节数

```zig
// std.mem.qel does a byte-by-byte comparison
if (std.mem.eql(u8, method, 'GET') or std.mem.eql(u8, method, 'HEAD')) {
    // handle a GET request
} else if (std.mem.eql(u8, method, 'POST')) {
    // handle a POST request
} else {
    // ...
}
```

- `std.mem.eqlIgnoreCase(u8, str1, str2)`

- zig 没有三元运算符（条件运算符）但可以用if/else代替
  - `const super = if (power > 9000) true else false;`

- switch 有穷举
  - `const super = switch (power) {
    9000 => true,
    else => false,
  };`

- for循环，遍历数组、切片和范围
- for 循环同时处理多个序列

- `std.mem.qel(comptime T: type, a: []const T, b: []const T) bool`的大致实现
```zig
pub fn eql(comptime T: type, a: []const T, b: []const T) bool {
	// if they arent' the same length, the can't be equal
	if (a.len != b.len) return false;

	for (a, b) |a_elem, b_elem| {
		if (a_elem != b_elem) return false;
	}

	return true;
}
```

- switch中，范围使用三个点`3...6`是闭区间
- for中，范围使用两个点`3..6`是左闭右开

- for循环不支持常见的`init; compare; step`，这种使用while

- zig也支持 break 和continue
  - break 会中断循环，还可以返回值
  - continue 会继续下一次循环

- 代码块附带标签label

- 枚举是带有标签的整数常量

```zig
pub const Status = enum {
    ok,
    bad,
    unknown,
}
```

- 枚举可以包含其他定义，包括函数，这些函数可以选择性地将枚举作为第一个参数

- `@tagName(enum)`

- Tagged Union 带标签的联合
  - 难题就是要知道设置的是哪个字段

- `@rem`用于捕获余数
- `@intCast`用于将结果转换u16

```zig
const Timestamp = union(enum) {
	unix: i32,
	datetime: DateTime,

	...
}
```

- 可选类型 Optional
  - `?`
  - `null`

- 未定义的值`Undefined`

- Error类型
  - `!`
  - try

- switch 逗号运算符