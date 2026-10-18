# sys1-project

系统综合实验（2026 春）课程实验代码，共 **14 个实验**：从门电路、组合逻辑、时序电路，一路做到卷积加速器、串口通信、RISC-V 汇编和处理器设计。

> 本仓库**只收录每个实验 `submit/` 目录下自己实现的代码**。testbench、约束文件、`Makefile`、协同仿真库等课程框架内容不在其中。

## 实验一览

| 实验 | 主题 | 提交文件 |
| --- | --- | --- |
| [lab0-1](lab0-1/) | sky130 反相器 SPICE 仿真 | `inv.sp` |
| [lab0-2](lab0-2/) | 三输入与门 / 四输入或门 | 4 个 `.v` |
| [lab0-3](lab0-3/) | 四输入逻辑函数化简 | `main.v` |
| [lab1-1](lab1-1/) | 与门、4 选 1 / 8 选 1 选择器 | 4 个 `.v` |
| [lab1-2](lab1-2/) | 32 位选择器 + 数码管译码 | 2 个 `.v` |
| [lab2-1](lab2-1/) | 加法器与加减法器 | 3 个 `.v` |
| [lab3-1](lab3-1/) | 序列检测有限状态机 | `FSM.sv` |
| [lab3-2](lab3-2/) | 参数化计数器 | 2 个 `.sv` |
| [lab3-3](lab3-3/) | 乘法器 | `Multiplier.sv` |
| [lab4-1](lab4-1/) | 卷积算子（valid-ready 握手） | 4 个 `.sv` |
| [lab4-2](lab4-2/) | UART 回环（bonus） | `UartLoop.sv` |
| [lab5-1](lab5-1/) | RISC-V 汇编：C 与汇编对照 | 7 个 `.s` + 6 个 `.c` |
| [lab5-2](lab5-2/) | RISC-V 调试挑战 | `challenge.c`、`spike.cfg` |
| [project](project/) | RV32 处理器 Core | 8 个 `.sv` |

每个实验目录下都有自己的 `README.md`，说明设计要点与文件作用。

## 代码组织

```
labX-Y/
├── README.md        本实验说明
└── submit/          自己实现的模块（本仓库唯一收录的内容）
```

`lab0-1`、`lab5-1`、`lab5-2` 没有 `submit/` 目录，源码直接放在实验目录下。

## 工具链

| 用途 | 工具 |
| --- | --- |
| 仿真 | Verilator + GTKWave |
| 综合与上板 | Vivado 2022.2，Nexys A7-100T（`xc7a100tcsg324-1`） |
| RISC-V 参考模型 | Spike + riscv-pk（`lab5-1`） |
| 模拟电路仿真 | ngspice + sky130 PDK（`lab0-1`） |

## 如何运行

这些模块需要放回课程框架的实验目录才能编译运行——testbench（`sim/`）、引脚约束（`syn/`）、`Makefile` 和协同仿真库都由课程框架提供：

```bash
# 把对应 lab 的 submit/ 放回课程实验目录后
make verilate      # Verilator 编译 + 运行 testbench
make wave          # GTKWave 打开波形
make bitstream     # Vivado 综合（需先设置 VIVADO_SETUP）
```

`lab5-1` 的汇编实验直接配合 Spike + pk 运行；`lab5-2` 用 OpenOCD + GDB 通过 `spike.cfg` 连接调试。

## 说明

- 仓库只含源码，构建产物（`build/`、网表、bitstream、波形）全部通过 `.gitignore` 排除。
- `lab0-1` 的 sky130 PDK 模型文件因体积与授权原因未收录，运行前需从课程框架复制到 `lab0-1/pdk/`。
- `lab4-1`、`lab4-2` 的实验报告属于课程提交材料，未收录。
- 本仓库为个人课程作业存档，欢迎参考思路，请勿直接复制提交。
