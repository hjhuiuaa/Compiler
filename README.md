# 预备实验：RISC-V 汇编与 LLVM IR 整合

马禹翔（2410933）：汇编分工；胡家华（2410935）：LLVM 分工；指导教师：王刚。

## 来源与分工

合作仓库：https://github.com/hjhuiuaa/Compiler

获取分支：`预备工作`；基准提交：`5c88f9d2900a346a87ccc1a0c9719c8c256d6d49`。
原有 `fib.c`、`fib.sy`、`fib.ll`、`fib-sysy.ll`、`预备工作.md` 均保持不变。
新增内容在此基准上独立整理，原始文件未作改动。

- `asm/`：两份手写 RISC-V 汇编。
- `ir/fib-riscv.ll`：小组原始手写 IR 的 RISC-V 目标移植版；`scripts/port_ir.py` 可重新生成。
- `examples/features.sy`、`ir/features-riscv.ll`：为补齐基础语言覆盖而新增的 SysY 与手写 IR。
- `runtime/`：课程提供的 SysY 运行库；详见其中 README。
- `scripts/build.py`：各阶段输出、汇编、链接与 ELF 检查。
- `scripts/test.py`：源程序 / 手写 IR / 手写汇编对照，另用独立 Python 算法核验。
- `build/commands.json`、`build/test-results.json`：实际执行命令、退出码、完整标准输出与错误输出。
- `build/stages/`：预处理、AST、LLVM IR、汇编、ELF 与符号表等文本化阶段证据。
- `report-latex/`：按课程 Overleaf 模板整理的 LaTeX 源码、参考文献和校徽资源。
- `output/pdf/`：由上述 LaTeX 源码编译得到的整合实验报告。

新增汇编、补充 IR、构建测试脚本和实验报告均经过实际构建与运行记录核验；原始 LLVM 内容来自上述小组仓库。项目没有采用其他编译器项目的实现代码。

## 本机复现

在本目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\run.ps1
```

已配置专用 WSL 发行版 `CompilerLab`，磁盘放在本项目上级 `.tools/wsl` 中。
Windows PATH 与已有课程 Python 环境未修改。

Linux 内执行：

```sh
python3 scripts/build.py
python3 scripts/test.py
echo 5 | qemu-riscv64 build/fib-asm
printf '7 3\n' | qemu-riscv64 build/features-asm
```

重新建环境时，在独立 Alpine 3.22 x86_64 Linux 环境执行 `sh scripts/setup-alpine.sh`。
需要网络。工具版本和运行库源码哈希记录在 `build/environment.json`。
目标 sysroot 默认 `/opt/riscv-sysroot`，可用 `RISCV_SYSROOT` 修改。
构建固定为 Linux musl 静态 ELF，不需要在 QEMU 命令中指定动态加载器目录。

最终验证结果：110 组输入、570 次执行全部通过。首次链接缺少 libc 使用的四倍精度辅助函数，已通过目标 compiler-rt builtins 解决；初次诊断保存在 `evidence/initial-link-missing-builtins.json`。最终 58 条构建/检查命令均返回 0。

日志中的 `overriding the module target triple` 是构建参数将 IR 的 Linux GNU 标记明确覆盖为 Linux musl；汇编阶段的个别“参数未使用”诊断源于把共同编译参数传给已经生成的汇编文件。这些诊断均保留在日志中，并非未解决的构建错误。

## 语义与覆盖范围

`fib.sy` 保持指导书输出顺序：不论 n 大小都先输出 0 和 1；n>1 时继续计算直到 F(n)。
验证 n≤46，以避免有符号 32 位溢出；未定义行为不作为三版本等价性的测试依据。

`features.sy` 输入 x、d，范围 [-100,100]；按以下顺序输出 15 行：
加、减、乘、除、余、符号分类、短路与、短路或、副作用计数、逻辑非组合、数组归约、浮点计算转整数、单目负、内层同名变量、外层变量。
当 d=0 时除法和取模输出 0，且短路与不执行除法；短路或不调用 touch。

基础覆盖：int、常量/变量/初始化、赋值、表达式、语句块、if/else、while、return、算术/比较/逻辑运算、函数调用与返回、嵌套作用域、break/continue、注释、SysY 输入输出。
额外示例：一维数组参数与索引、单精度运算和隐式转换。没有声称实现完整 SysY 编译器，未覆盖多维数组或张量扩展。

## 报告与提交

PDF 为课程要求的提交格式，两位成员均需在小雅提交同一份报告。
报告中的 MLIR 部分基于课程资料与官方文档完成分析，未将其表述为昇腾设备实测结果。
源码和日志随提交压缩包提供；`.tools` 虚拟机磁盘、Git 元数据与临时渲染图不进入压缩包。
