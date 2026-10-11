# 课程 SysY 运行库

`lib/` 从课程提供的 `lib.tar.gz` 原样解压，未改动源码或预编译库。

- 压缩包 SHA-256：`d6fd112ecb6d318e4cb2ea377aa0770cb8b9736c3d024fde4a9300ac2058a0ac`
- 实际验证使用 `lib/sylib.c`，以本次 RV64GC / LP64D / Linux musl 工具链重新编译。
- 新库输出到 `build/libsysy_riscv.a`，不覆盖课程的 `lib/libsysy_riscv.a`。
- 两份库不可混淆。课程预编译库的原始 libc / 工具链未在附件中完整标注，因此本次不将其当作已验证链接产物。
- `include/sysy_decls.h` 仅声明示例所需接口。课程 `sylib.h` 同时定义全局计时变量；若被多个翻译单元包含，现代编译器可能报重复定义。
- 构造/析构函数由 musl 启动与退出流程执行。`TOTAL: ...` 写入 stderr，测试与程序 stdout 分开保存。
