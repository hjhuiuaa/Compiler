# LaTeX 报告

主文件：`main.tex`

本目录采用课程提供的 Overleaf 模板版式。`NKU.png` 为模板校徽，
`NKU-watermark.png` 为打印兼容的浅色水印，`references.bib` 保存参考文献。

在本目录执行 XeLaTeX、BibTeX，再执行两次 XeLaTeX：

```powershell
xelatex -interaction=nonstopmode -halt-on-error main.tex
bibtex main
xelatex -interaction=nonstopmode -halt-on-error main.tex
xelatex -interaction=nonstopmode -halt-on-error main.tex
```

最终提交 PDF 复制到 `../output/pdf/实验一_预备实验报告_马禹翔_胡家华.pdf`。

正文使用 `ctexart`，需要完整的中文 LaTeX 环境。推荐 TeX Live 或 MiKTeX，并确保安装 `ctex`、`booktabs`、`longtable`、`listings`、`fancyhdr`、`tikz` 和 `hyperref`。
