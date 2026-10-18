# lab5-1 · RISC-V 汇编：C 与汇编对照

同一批函数，分别用 C 写、用编译器生成的汇编（`_plain`）和手写优化的汇编（`_opt`）实现，在 Spike + pk 上运行对比。

## 提交代码

| 函数 | C 源码 | 编译器生成的汇编 | 手写优化汇编 |
| --- | --- | --- | --- |
| 区间求和 | `acc.c` | `acc_plain.s` | `acc_opt.s` |
| 阶乘 | `factor.c` | `factor_plain.s` | `factor_opt.s` |
| 斐波那契 | — | — | `fibonacci.s` |
| 冒泡排序 | — | — | `bubble_sort.s` |
| switch 跳转表 | `switch.c` | `switch.s` | — |
| 测试与示例 | `acc_test` / `factor_test` / `bubble_sort_test` / `fibonacci_test` / `hello.c` | | |

## 实验内容

- **对照编译产物**：`_plain.s` 是低优化级别的原始输出，有大量栈帧操作（`addi sp,sp,-48`、`sd ra,24(sp)`）；`_opt.s` 手写版直接复用寄存器、去掉冗余访存。
- **观察 switch 的实现**：`switch.s` 展示了 RISC-V 编译器如何把 `switch` 编译成跳转表（`jalr` + 偏移表），而不是一长串比较分支。
- **调用约定**：`a0`/`a1` 传参、`a0` 返值、`ra` 保存返回地址、`sp` 维护栈帧——手写汇编必须遵守 C calling convention 才能和 C 测试程序正确链接。

## 运行

课程框架的 `simulate.sh` 封装了 Spike 调用（需填 `SPIKE_PATH` / `PK_PATH`），本仓库未收录该脚本及测试用例。程序结尾写 `tohost` 才能让 Spike 正常退出，否则会跑到超时。
