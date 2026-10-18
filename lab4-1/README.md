# lab4-1 · 卷积模块

用硬件实现卷积算子，按 **valid-ready 握手协议**组织数据流。

## 提交代码

| 文件 | 说明 |
| --- | --- |
| `submit/ConvOperator.sv` | 卷积算子顶层：组织乘法、移位与累加 |
| `submit/ConvUnit.sv` | 卷积计算单元，由两个子模块通过 valid-ready 级联 |
| `submit/Multiplier.sv` | 乘法器 |
| `submit/Shift.sv` | 移位寄存器，维护 4 个数据的滑动窗口 |

## 架构要点

- **valid-ready 握手**：模块间不靠固定延迟传数据，而是用 `valid`/`ready` 确认「数据有效 + 下游可收」，各级速率不同也不会丢数。
- **计算拆分**：`Multiplier` 相乘、`Shift` 滑动窗口、`ConvUnit` 累加、`ConvOperator` 整体调度，便于逐级验证。
- `Shift` 是一个两状态 FSM（`RDATA ↔ TDATA`），负责从外部接收数据并维护滑动窗口。

> 运行需要课程框架提供的 testbench、约束和 `Makefile`，做法见[根目录 README](..)。
