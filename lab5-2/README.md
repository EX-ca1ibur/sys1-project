# lab5-2 · RISC-V 调试挑战

用 OpenOCD + GDB 对 Spike 模拟的 RISC-V 目标做在线调试。

## 提交代码

| 文件 | 说明 |
| --- | --- |
| `challenge.c` | 待调试的挑战程序，主要考察内存布局、栈与传参 |
| `spike.cfg` | OpenOCD 配置：把 Spike 当作可插 JTAG 的调试目标 |

## 调试链路

```
interface remote_bitbang
remote_bitbang_host localhost
remote_bitbang_port 9824
set _CHIPNAME riscv
jtag newtap $_CHIPNAME cpu -irlen 5 -expected-id 0x10e31913
```

Spike 通过 **remote bit-bang** 协议在 `9824` 端口暴露一个 JTAG 接口，OpenOCD 连上去后就能读写寄存器、下断点、单步。

```bash
spike --rbb-port=9824 challenge   # 1. 启动带调试接口的 spike
openocd -f spike.cfg              # 2. 用本仓库配置启动 openocd
riscv64-unknown-elf-gdb challenge # 3. 连 gdb
(gdb) target remote localhost:3333
```
