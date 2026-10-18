# lab1-1 · 组合逻辑：与门与多路选择器

练习参数化、位宽与选择逻辑，实现 1 位宽的与门和 4 选 1 / 8 选 1 多路选择器。

## 提交代码

| 文件 | 说明 |
| --- | --- |
| `submit/AND_GATE.v` | 参数化与门 |
| `submit/MUX4T1_1.v` | 4 选 1 多路选择器（1 bit） |
| `submit/Mux8T1_1.v` | 8 选 1 多路选择器（1 bit） |
| `submit/OR_GATE_4_INPUTS.v` | 四输入或门 |
| `submit/readme.md` | `BubblesMask` 位宽修正说明 |

## 踩坑记录

模板里的 `BubblesMask` 位宽需要按端口个数改：

```verilog
// AND_GATE.v
parameter [1:0] BubblesMask = 1;

// OR_GATE_4_INPUTS.v
parameter [3:0] BubblesMask = 1;
```

> 运行需要课程框架提供的 testbench、约束和 `Makefile`，做法见[根目录 README](..)。
