# project · RISC-V 处理器 Core 设计

课程综合大作业：补齐一个 RV32 处理器的各个子模块，让它能跑通 riscv-tests，并与 Spike 协同仿真对拍。

## 提交代码

| 文件 | 作用 |
| --- | --- |
| `submit/Core.sv` | 处理器顶层：连接取指 / 译码 / 执行 / 访存通路，对外提供 `imem_ift`、`dmem_ift` 接口 |
| `submit/Controller.sv` | 控制单元：由指令译出 `we_reg`、`we_mem`、`ALUSrc`、访存宽度等控制信号 |
| `submit/ALU.sv` | 算术逻辑单元，按 `alu_op_enum` 执行加减、逻辑、移位 |
| `submit/Cmp.sv` | 比较单元，按 `cmp_op_enum` 产生分支/跳转条件 |
| `submit/RegFile.sv` | 32 个通用寄存器堆，双读一写 |
| `submit/DataPkg.sv` | **写数据对齐**：按 `MEM_B / MEM_H / MEM_W` 把寄存器值复制成总线上的重复字节/半字 |
| `submit/DataTrunc.sv` | **读数据截取**：由访存地址选出正确通道，再符号/零扩展 |
| `submit/MaskGen.sv` | **写掩码生成**：按地址和访存宽度产生 `dmem_wmask` |

## 设计要点

- **共享结构体**：所有模块都 `include "core_struct.vh"`，类型（`data_t`、`addr_t`）、枚举（`alu_op_enum`、`mem_op_enum`、`cmp_op_enum`）和接口（`Mem_ift`）由课程框架统一定义，模块间只通过这些类型通信。
- **访存三件套**：RISC-V 允许 LB/LH/LW 与 SB/SH/SW。写侧要解决「一个字节怎么摆到 32 位总线上」（`MaskGen` 出掩码 + `DataPkg` 复制数据），读侧要解决「从哪个通道取」（`DataTrunc` 选通道 + 扩展）。

## 运行

依赖课程框架的协同仿真库（`libcosim.a`、`libriscv.a`、`libfesvr.a` 等）和测试用例生成脚本：

```bash
make verilate TESTCASE=sample   # 编译并仿真指定用例
make uart                        # UART 相关用例
```

`testcase.elf` / `testcase.hex` 由框架的 `testcode/testcase` 生成后拷进 `build/verilate`。
