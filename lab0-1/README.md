# lab0-1 · sky130 反相器 SPICE 仿真

用 sky130 130nm PDK 对一个 CMOS 反相器做直流/瞬态仿真。

## 提交代码

| 文件 | 说明 |
| --- | --- |
| `inv.sp` | 反相器网表：`.option scale=1E-6` 配合 `w=650000u l=150000u`（即 0.65 µm / 0.15 µm），`.include` 引入 PDK 的 nfet / pfet 模型，`X0` 实例化 `sky130_fd_pr__nfet_01v8` |

## 说明

PDK 模型（`pdk/nfet.spice`、`pdk/pfet.spice`，各约 1.2 MB）属于第三方工艺文件，未收录。运行前从课程框架复制到 `lab0-1/pdk/`，然后：

```bash
ngspice inv.sp
```
