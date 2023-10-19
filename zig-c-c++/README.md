# C/C++/Zig 混合工程

> zig version 0.12.0-dev.800+a9b37ac63

> 学习自 [C/C++/Zig 混合工程](http://docs.cardkit.cn/docs/zig/zig-1eutuc924icto)

## 目的
- 一个模块用c编写，一个模块用 Zig 编写，一个模块用 c++ 编写
- 测量一段代码的运行时间，用微妙来计算，分辨率是纳秒
- c做一个被测函数
- zig做一个被测函数
- 测量时间的函数用c++完成

## 初始化

```shell
zig init-exe
```

## 项目结构

```shell
│  build.zig            # 构建用的文件
│  README.md
│  
├─src                   # 源代码目录
│  │  fabinaci.zig      # zig模块
│  │  main.zig          # 可执行程序
│  │  
│  ├─include            # 头文件
│  │      sum.h
│  │      timeit.h
│  │      
│  ├─sum                # c 模块
│  │      sum.c
│  │      
│  └─timeit             # c++ 模块
│          timeit.cpp
│          
└─zig-cache
```

## build 说明

- 使用 `exe.addIncludePath()`时，接受`LazyPath`参数
- 所以传参使用如下:

```zig
const includePath = std.Build.LazyPath {.path = "src/include"};
exe.addIncludePath(includePath);
```

- 注意zig的版本不同，相同函数的用法会不同

## build run

```shell
# use zig command
zig build run

#  or
zig build
cd zig-out\bin
.\zig-c-c++.exe run
```

## callconv()的作用

- 是一种函数调用方式

- In Zig, the attribute callconv may be given to a function. The calling conventions available may be found in std.builtin.CallingConvention. Here we make use of the cdecl calling convention.