# lab0-2 · 三输入与门 / 四输入或门

第一个 Verilog 实验：手写基本门电路，跑通「仿真 → 综合 → 上板」的完整流程。

## 提交代码

| 文件 | 说明 |
| --- | --- |
| `submit/AND_GATE_3_INPUTS.v` | 三输入与门 |
| `submit/OR_GATE_4_INPUTS.v` | 四输入或门 |
| `submit/main.v` | 把两个门组合起来的顶层逻辑 |
| `submit/top.v` | 上板顶层（拨码开关 → LED） |
| `submit/readme.md` | 对模板中 `BubblesMask` 位宽的修正说明 |

## 踩坑记录

课程模板里两个门电路都写成 `parameter [64:0] BubblesMask = 1;`，位宽明显过大。按输入个数改成：

```verilog
// AND_GATE_3_INPUTS.v
parameter [2:0] BubblesMask = 1;

// OR_GATE_4_INPUTS.v
parameter [3:0] BubblesMask = 1;
```

> 运行需要课程框架提供的 testbench、约束和 `Makefile`，做法见[根目录 README](..)。
