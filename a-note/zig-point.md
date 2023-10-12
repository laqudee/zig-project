# Point

- zig 不包含垃圾回收器

- 面向内存编程
- 指针、堆分配、悬挂指针（悬垂指针）

- 数据与内存联系起来
- 变量是将一种类型与特定内存位置联系起来的标签

- 变量指向结构的起点
- 字段是按顺序排列的

- zig不保证结构的内存布局
- packed struct

- 取地址运算符`&`
  - 返回一个变量的地址

- 类型T的值的地址是`*T`

- 结构体方法

- 常量函数
  - 默认情况下，zig会传递一个值的副本（按值传递）

- 小类型可以通过值传递（复制），大类型通过引用传递能方便

- 编译器必须权衡复制的代价和通过指针间接访问字段的代价

- 指向指针的指针
  - `**User`

- 嵌套指针

```zig
pub const User = struct {
  id: u64,
  power: i32,
  name: []const u8,
}

// user.name.ptr 将指向二进制文件中存储所有常量的区域内的一个特定位置
```

- 嵌套指针，只会进行浅拷贝

- 指针的值是一个地址，复制该值意味得到相同的地址

- 递归结构
  - 每种类型都必须在编译时确定大小，而这里的递归结构体大小是无法确定的

- 值的大小
- 类型本身的大小

- 切片，是一个大小已知的类型
- Optional或unio，最大字段的大小是已知的，zig就使用这个
- 递归没有上限

- 垃圾回收器：了解哪些数据不再使用，并释放其内存
- zig不负责垃圾回收，由用户负责

- 内存的是哪个区域：
  - 全局空间，存储程序常量、字符串字面量的区域
    - 全部数据被嵌入到二进制文件中，编译时完全已知，不可更改
    - 整个生命周期存在，不需要增加或减少内存
  - 调用栈
  - 堆

- 局部变量只在声明的范围内有效，从花括号开始到花括号结束

- 当函数被调用时，整个栈帧被推入调用栈，所以需要知道每个类型的大小
- 当函数返回时，它的栈帧（最后推入调用栈的帧）会被弹出，使用的内存会被释放

- 调用栈也由操作系统和可执行文件管理

- 悬空指针

- ` 数据的生命周期 `

- C 语言的malloc

- 在堆中，可以在运行时创建大小已知的内存，并完全控制其生命周期
  
- 调用栈
  - 优点：管理数据的方式简单且可预测（通过推送和弹出堆栈帧）
  - 缺点：数据的lifetime与它在调用栈中的位置息息相关

- 堆
  - 优点：没有内置的生命周期，数据可长可短
  - 缺点： 如果不手动释放内存，就会一直存在

- 分配器是`std.mem.Allocator`类型
  - alloc()
  - free()
  - 需要一个类型T和一个计数，成功后返回`[]T`切片
  - 分配发生在运行时

- 每次alloc，都会有相应的free
- 可以在HTTP处理程序中分配内存，在后台线程中释放，这是代码中两个独立的部分

- defer
  - 在退出作用域时，执行给定的代码
  - 【作用域退出】包括到达作用域的结尾或从作用域返回
  - defer与分配器或内存管理器并无严格关系

- defer将在其包含作用域的末尾运行
- errdefer
  - 只在返回错误时执行

- 不能释放同一内存两次
- 不能释放没有引用的内存

- 双重释放是无效的

- 申请的内存要及时销毁，否则会造成内存泄露

- create
- destory
  - 用于创建单值
- create返回指向该类型的指针或一个错误即 `!*T`

```zig
const User = struct {
  id: u64,
  power: i32,
  
  fn init(allocator: std.mem.Allocator, id: u64, power: i32) !*User {
    var user = try allocator.create(User);
    user.* = .{
      .id = id,
      .power = power,
    };
  }
  return user;
}
```

- zig核心原则之一：无隐藏内存分配
- zig没有默认的分配器

- `std.fmt.allocPrint`
```zig
  const say = std.fmt.allocPrint(allocator, "it's over {d}!!!", .{user.power});
  defer alloccator.free(say);
```

- 注入分配器
  - 显式
  - 灵活

- 通用分配器GeneralPurposeAllocator
  - 通用的、线程安全的分配器
  - 可作为应用程序的主分配器

```zig
const T - std.heap.GeneralPurposeAllocator(.{})
var gpa = T{};

// is the same  as
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
```

- 动态数组ArrayList

- `std.testing.alloator`

- `@as`执行类型强制的内置函数

- `ArenaAllocator`
  - 通用分配器
  - 接收一个子分配器

- 解析器Parser

- `var arena = std.heap.ArenaAllactor.init(allocator);`

- `defer arena.deinit();`

- 需要确保ArenaAllocator的deinit会在合理的内存增长范围内被调用

- 固定缓冲区分配器FixedBufferAllocator
  - `std.heap.FixedBufferAllocator`
  - 从缓冲区[]u8中分配内存
  - 使用的内存都是预先创建的，因此速度快
  - 限制分配内存的数量
  - free和destory只对最后分配/创建的项目有效
  - 按照栈的方式进行内存分配和释放

- 固定缓冲区分配器的常见模式是重置并重复使用
- ArenaAllocator也是如此

- 动态分配的另一个可行替代方案：将数据流传输到std.io.Writer