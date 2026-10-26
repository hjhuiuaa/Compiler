# 词法分析器共用 Token 接口

依据《词法分析器共用接口约定_新版》与 2026 年实验指导。成员 A 负责 `lexer.l`，成员 B 负责 `yacc.y` 声明、`token.h` 与 `parser.cpp` 转换。为联调通过官方样例，A 已按同一清单补全 `yacc.y` 中缺失的 Token 声明，并在 `parser.cpp` 中接上 `LL_CONST`、`FLOAT_CONST` 的属性读取。B 可继续调整默认值和输出检查，但不得改名。

## 五列输出

| 列 | 含义 |
|---|---|
| Token | 类别名称，与 Bison Token 名称一致 |
| Lexeme | 源文件中的原始文本 |
| Property | 整数或浮点的转换值；标识符等于词素；其余留空 |
| Line | 词素首字符所在行，从 1 开始 |
| Column | 词素首字符所在列，从 0 开始 |

## Token 名称

IDENT，INT_CONST，LL_CONST，FLOAT_CONST，CONST，INT，FLOAT，VOID，IF，ELSE，WHILE，BREAK，CONTINUE，RETURN，PLUS，MINUS，STAR，SLASH，MOD，ASSIGN，EQ，NE，LT，LE，GT，GE，NOT，AND，OR，SEMICOLON，COMMA，LPAREN，RPAREN，LBRACKET，RBRACKET，LBRACE，RBRACE，END，ERR_TOKEN。框架中已有的 FOR、SWITCH 等扩展名保留。

## 数值约定

负号单独识别为 MINUS。`-2147483648` 是 `MINUS` 加 `LL_CONST 2147483648`。`012` 的属性是 10，`0xA` 的属性是 10，`0x.Ap-3` 的属性是 0.078125。

## 联调命令

```bash
make
bin/compiler -lexer -o simple.out testcase/lexer/simple.sy
bin/compiler -lexer -o witharray.out testcase/lexer/witharray.sy
bin/compiler -lexer -o withfloat.out testcase/lexer/withfloat.sy
diff -u testcase/lexer/simple.lexer simple.out
```
