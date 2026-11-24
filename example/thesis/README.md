# 复旦大学学位论文模板


本仓库实现依照 [26.06版研究生学位论文规范](https://gs.fudan.edu.cn/6b/9f/c2806a27551/page.htm)。

[Github项目主页](https://github.com/kzhoa/fduthesis)

打开 thesis.pdf 预览渲染效果。

英文论文默认使用中文封面字段。`title` 和 `title-en` 分别填写中文和英文题名。`\makecommittee` 生成中文指导小组页；目录之后依次用 `fdusummary` 和 `fdusummaryen` 排中英文摘要，关键词分别填入 `keywords` 和 `keywords-en`。文末用 `\makeauthorization` 生成中文声明页。

使用 `lang=en` 时，封面学校代码下方自动显示“英文项目”。同等学力人员可在 `\fdusetup` 中填写 `student-category={同等学力人员}`，其他学生省略该字段。两项同时适用时显示“同等学力人员/英文项目”。

### 字体

学校学位论文规范要求中文正文使用 Windows 宋体（SimSun）。

- Windows 环境下默认自带宋体，模板会自动加载。
- 未指定项目字体且系统缺少 SimSun 时，模板会使用 Fandol 宋体，并在编译日志中给出警告。
  Fandol 宋体的字形与官方样本有差异。课程论文无所谓，学位论文请严格使用 SimSun 字体。

要使用项目内的本地字体，请上传字体文件到 `fonts/simsun.ttc`，在 `main.tex` 的 `\documentclass` 前取消以下示例命令的注释。将 `Path` 和文件名改为实际值，大小写须与上传文件一致。启用后模板直接加载指定字体，跳过系统宋体查询。

```latex
\AddToHook{fduthesis/cjk-font}{\setCJKmainfont[Path=fonts/,FontIndex=0,AutoFakeBold=2]{simsun.ttc}}
```

西文正文和数字要求 Times New Roman。
- Windows环境默认自带，Overleaf上也默认自带。
- Linux发行版一般不包含该字体，需要手动安装该字体家族。缺少必需的西文字体时编译会报错。
    - Ubuntu / Debian 安装: `sudo apt update && sudo apt install -y ttf-mscorefonts-installer`
    - 手动复制： 将常规、粗体、斜体和粗斜体四个文件 `times.ttf`、`timesbd.ttf`、`timesi.ttf`、`timesbi.ttf` 放入 `fonts/`。

### 中英文切换

在导言区通过`lang`手动控制。默认中文。

```latex
\documentclass{fduthesis}          % 默认中文
\documentclass[lang=zh]{fduthesis} % 显式指定中文，也接受 lang=cn
\documentclass[lang=en]{fduthesis} % 英文
```


使用 `lang=en` 时，封面学校代码下方自动显示“英文项目”。同等学力人员可在 `\fdusetup` 中填写 `student-category={同等学力人员}`，其他学生省略该字段。两项同时适用时显示“同等学力人员/英文项目”。

按照大部分学院的通行要求，英文学位论文保留使用中文封面、中文指导小组页和中文版权声明页。
英文标记 `lang=en` 只影响目录、图表清单页、正文、参考文献、附录、致谢、页眉。
- 部分学院如不需要中文摘要，注释 `\begin{fdusummary} ... \end{fdusummary}`即可；
- 页眉在 `lang=en` 下自动翻译为 `Fudan University Doctoral Dissertation`, `Fudan University Master’s Thesis`, `Fudan University Bachelor’s Thesis`；
- `lang=en`时，正文部分的页码默认保留阿拉伯数字编号。如需转为小写罗马 `i, ii, iii...` 编号，在导言区设置 `\fdusetup{main-page-numbering=roman}`；

英文渲染样式参照 [英文示例 PDF](https://github.com/kzhoa/fduthesis/blob/main/example/thesis_en/thesis.pdf)。


## 编译

在 Overleaf 上，请选择 `main.tex` 为主文档，编译器选用 XeLaTeX。示例中的两幅图均直接读取矢量 PDF。

### 直接编译

1. 确认本机已安装 TeX Live 和 latexmk。
2. 下载 `fduthesis.zip` 并解压 `thesis/` 目录 （ 或者 `git clone` 后复制 `example/thesis/` 目录）。
3. 执行编译命令
    ~~~sh
    cd thesis/
    latexmk -xelatex -jobname=thesis main.tex
    ~~~

    编译完成后，在同一目录生成 `thesis.pdf`。
    也可以使用 `latexmk -lualatex -jobname=thesis main.tex`。中文示例中，latexmk 会调用 BibTeX 处理参考文献并更新目录、引文和图号。
    按需安装 TeX Live 时，请包含 ctex、Fandol 字体、BibTeX 和提供 `gbt7714-2025-numeric` 样式的 `gbt7714` 宏包。

### Docker编译

1. `git clone` 克隆完整仓库，确认本机已安装 Docker。
   将 Times New Roman 的四个字体文件放入 `$HOME/texmf/fonts/truetype/`，或用 `FDU_TEX_ROOT` 指向已准备好的个人 TeX 目录。
2. 在仓库根目录运行 `scripts/latex-env.sh`。
   首次运行时，如果本机还没有 `texlive/texlive:latest` 镜像，Docker 会自动从 Docker Hub 下载（需要科学上网）。
   也可以自行设置国内源，运行 `docker pull texlive/texlive:latest` 准备好镜像。
   若本机已有该镜像，脚本会直接用它启动临时容器。
3. 容器启动后，脚本会使用容器内的TeX Live编译，生成 `build/compile/xelatex/example/thesis/main/main.pdf`。


## 排版格式

### 扉页：指导小组成员名单

按学校规范，指导小组成员名单列在封面之后、目录之前的扉页。学校未单独规定这页的字号和段后间距。本模板将标题设为三号（16 bp），加粗居中，标题段后固定加 18 bp。成员名单用小三号（15 bp），每人一行，居中排列。

在 `main.tex` 的 `\fdusetup` 中填写 `committee = {李四教授, 王五副教授}`，用英文逗号分隔成员。`\makecommittee` 按填写顺序生成名单页。

### 目录

按学校 2026 年 6 月修订的学位论文规范，目录排在中英文摘要之前。

> 注：FDU从最早可查的08年开始一直是先目录后摘要。其它学校很多是先摘要后目录。

> 本模板约定，目录页不收录目录页自身。
> 所以默认情况下，条目从 "摘要" (页码Ⅱ) 开始呈列。

学校规范未单独规定目录字号。本模板的目录与插图、表格清单采用相同的标题和条目间距。标题用三号（16 bp）粗体，居中，固定行距 20 bp，段前空 24 bp，段后空 18 bp。条目用小四号（12 bp），中文宋体，英文和数字用 Times New Roman，固定行距 20 bp，段前、段后均为 0 bp。目录保留章条目加粗和各级标题缩进。

目录默认列到三级标题，如第 `1.1.1` 节。若只列到二级标题，如第 `1.1` 节，在 `main.tex` 的 `\tableofcontents` 前取消 `\setcounter{tocdepth}{1}` 的注释。


### 摘要

中英文摘要的标题与正文均用小四号（12 bp），字号与学校官方 Word 样本一致。标题和正文均采用固定行距 20 bp，中文用宋体，英文和数字用 Times New Roman。

标题居中。官方 Word 模板的摘要标题段前、段后均为 0 bp。本模板自行增加标题留白，段前空 24 bp，段后空 1 bp。

### 插图和附表清单

学校规范要求插图和附表清单“有则必备”，未单独规定字号。本模板约定“插图”和“表格”两页的标题居中，用三号（16 bp）粗体，固定行距 20 bp，段前空 24 bp，段后空 18 bp。清单条目用小四号（12 bp），中文用宋体，英文和数字用 Times New Roman，固定行距 20 bp，段前、段后均为 0 bp。不同章的条目之间也不额外留白。

图和表按章分别计数，默认编号为“图 1.1”“表 1.1”。在 `main.tex` 的 `\fdusetup` 中设置 `figure-table-separator = hyphen`，重新编译后即改为“图 1-1”“表 1-1”，清单和正文引用同步更新。

图题和表题的编号与题名之间空一个汉字符，不加冒号，例如“图 1.1　二分查找判定树”和“表 1.1　比较次数”。在 `\caption{...}` 中只写题名，模板自动排入编号和间距。

示例在英文摘要后用 `\listoffigures` 和 `\listoftables` 分别生成两份清单。题名取自 `\caption{...}`，页码由模板自动生成。没有插图或表格时，可注释掉对应的清单命令。

### 正文

按学校规范，正文用小四号（12 bp），行距固定为 20 磅（20 bp），字符间距为标准。中文用宋体，英文和数字用 Times New Roman。

学校规范未单列正文段落首行缩进的要求。本模板将普通正文段落的首行缩进两个汉字符（小四号下为 24 bp）。

双面打印时，学校要求“正文部分应从另页右页开始，每一章应另起页”。模板在 `\mainmatter` 处按需插入空白页，使正文第一页位于右页。后续各章由 `\chapter` 另起一页，可从左页或右页开始。

### 章标题

学校规范未单独规定各级标题的字号与间距。本模板约定各级标题均采用 20 bp 固定行距，中文用宋体，英文和数字用 Times New Roman。编号与标题之间自动留一个汉字宽的空格。

- **章标题**（`\chapter`），如“第1章　绪论”。三号（16 bp），段前 24 bp，段后 18 bp。
- **一级节标题**（`\section`），如“1.1　背景”。四号（14 bp），段前 24 bp，段后 6 bp。
- **二级节标题**（`\subsection`），如“1.1.1　进展”。字号 13 bp，段前 12 bp，段后 6 bp。
- **三级节标题**（`\subsubsection`），如“1.1.1.1　相关文献”。小四号（12 bp），段前 12 bp，段后 6 bp。

一般不建议使用三级节标题。即便使用，目录默认列到二级节标题（如 1.1.1）。


### 公式

行内公式和块级公式均采用与正文相同的小四号（12 bp）与 20 bp 。

>独立公式与上下段落之间的留白由 LaTeX 控制。遇到较高的分式等内容时，实际行距可能随公式高度增大。这是LaTex默认行为。

本模板约定正文公式按章编号，章号与章内序号默认用点号连接，公式编号带括号。例如，第三章第一个公式在正文中引用为“式（3.1）”。

若需使用短横线，在 `main.tex` 的 `\fdusetup` 中设置 `equation-separator = hyphen`，重新编译后即为“式（3-1）”。设置为 `dot` 可切回点号。此选项同时控制正文和附录公式编号中的所有连接符。

>用户须知：
> 行内公式应尽量控制在一行文字的高度内。分数可用斜线表示，如 `a/b`；根式可用分数指数表示，如 $\sqrt{2}=2^{1/2}$。根式在分母时可用负指数，如 $1/\sqrt{2}=2^{-1/2}$。
>
> 较长的表达式必须转行时，应在 `=`、`+`、`-`、`×`、`/` 等运算符或 `]`、`}` 等右括号之后断行，将该符号留在上一行末尾。断行位置由作者根据表达式结构和版面宽度选择。可使用 `amsmath` 的 `multline` 环境，或在 `equation` 内使用 `split` 环境，在选定符号后写 `\\` 换行。
>
> 上述行为由用户自行控制，模板无法自动完成校准。

### 算法与代码清单

算法和带题名的代码片段各自按章连续编号，跨节接续，每章从 1 开始。章号与序号用点号连接，如“算法 3.1”和“代码 3.1”。附录用字母代替章号，如“代码 A.1”。两者的题名都在内容上方，默认均不显示行号。宏包加载、题名和交叉引用的写法见[二分查找示例](main.tex)。

**算法**

用 `algorithm` 环境排算法，题名左对齐，上下各留 6 bp。顶线和底线均为 0.75 bp，题名与步骤之间的分隔线为 0.5 bp。步骤区上下各留 2 TeX pt（约 1.993 bp）。伪代码采用小四号（12 bp），基线间距为 16 bp，步骤之间不另加段距。伪代码步骤用 `algpseudocode` 宏包的 `algorithmic` 环境排版，循环和条件分支按层级缩进。

**代码片段**

用 `listings` 宏包的 `lstlisting` 环境排代码。提供 `caption` 时自动编号，题名位于上横线之上，编号与题名之间空一个汉字符，如“代码 3.1　顺序查找”。

代码采用五号（10.5 bp）黑色等宽字体，固定行距 14 bp，无底色。上下横线均为 0.5 bp，边框内距为 4 bp，单个片段可用 `frame=none` 取消横线。排版保留空格和缩进，字符串中的空格按普通空白显示，长行自动折行。

语法高亮默认关闭。要显示代码行号或启用语法高亮，在 `main.tex` 导言区找到“显示代码行号”或“启用语法高亮”，去掉对应 `\lstset` 行开头的 `%`。两项可分别开启。行号显示在左侧，语法高亮按该片段的 `language` 设置识别关键字、注释和字符串。

### 脚注

在需要注释的句末标点后使用 `\footnote{注释内容}`，例如 `比较次数按此定义计算。\footnote{一次比较返回小于、等于或大于。}`。正文自动显示带圈上标数字①、②……，每页从①重新编号。

脚注正文用小五号（9 bp），中文用宋体，英文和数字用 Times New Roman，单倍行距。脚注序号与文字之间空半个汉字符，采用 1.5 个汉字符的悬挂缩进。调整内容后，运行 latexmk 即可更新逐页编号。

### 参考文献

“参考文献”标题与章标题格式相同，用三号（16 bp），固定行距 20 bp，段前 24 bp，段后 18 bp。文献条目用五号（10.5 bp），中文用宋体，英文和数字用 Times New Roman。每条段前 3 bp、段后 0，续行悬挂缩进两个汉字符（21 bp）。

中文示例默认使用 BibTeX。如需切换到 biblatex + Biber，请在 `main.tex` 中调整两处注释：

1. 在导言区注释掉 BibTeX 的 `\usepackage[uppercasefamily=false]{gbt7714}` 和 `\bibliographystyle{gbt7714-2025-numeric}`，取消 biblatex 的 `\usepackage[backend=biber,style=gb7714-2025]{biblatex}` 和 `\addbibresource{reference.bib}` 两行的注释。
2. 在正文结束、附录开始之前，注释掉 `\bibliography{reference}`，取消 `\printbibliography` 的注释。

两种方式共用 `reference.bib`，均使用 `\cite{条目键}` 引用文献。正文与各附录按首次引用顺序统一编号，同一条文献再次引用时沿用原编号，在参考文献表中只列一次。著录格式采用 GB/T 7714—2025。

### 附录

本模板约定，附录排在参考文献之后、致谢之前。

在 `\appendix` 后用 `\chapter{标题}` 开始每个附录。模板按 A、B、C……依次编号，附录序号与标题之间空一个汉字符。附录正文与论文正文相同，用小四号（12 bp），中文用宋体，英文和数字用 Times New Roman，固定行距 20 bp。

附录的节标题沿用正文对应层级的格式，编号与标题之间空一个汉字符。以附录 C 为例：

- 一级节标题：`\section{实验设置}` 生成“C.1　实验设置”，用四号（14 bp），行距 20 bp，段前 24 bp、段后 6 bp。
- 二级节标题：`\subsection{测试环境}` 生成“C.1.1　测试环境”，用 13 bp，行距 20 bp，段前 12 bp、段后 6 bp。

图、表和公式在每个附录内各自从 1 起跨节连续编号，换到下一个附录时分别重新计数。附录引用的文献沿用全文编号。

附录沿用正文的编号设置。图和表由 `figure-table-separator` 控制，默认写作“图 C.1”“表 C.1”，设为 `hyphen` 后写作“图 C-1”“表 C-1”。公式由 `equation-separator` 控制，默认写作“式（C.1）”，设为 `hyphen` 后写作“式（C-1）”。图、表和公式用 `\label` 标记、`\ref` 引用，文献用 `\cite` 引用。

### 致谢

“致谢”标题沿用章标题格式，三号（16 bp）加粗居中，固定行距 20 bp，段前 24 bp、段后 18 bp。致谢内容同正文，用小四号（12 bp），中文用宋体，英文和数字用 Times New Roman，固定行距 20 bp。每段首行缩进两个汉字符（24 bp）。

在 `main.tex` 的附录之后（无附录时在参考文献之后）使用 `acknowledgements` 环境，段落之间留一个空行即可。

```latex
\begin{acknowledgements}
感谢导师的指导。
\end{acknowledgements}
```

### 页眉

学校规范未单独规定页眉格式。本模板自行约定，从目录首页起显示页眉。页眉横线为 0.5 bp 粗。页眉统一用五号（10.5 bp），中文用宋体，英文和数字用 Times New Roman。

> 注：校图书馆的历史PPT中给出的建议是页眉小五号字（9 bp），考虑到阅读难度，本模板采用高校间更为通用的五号字。

> 如需隐藏每章首页的页眉和横线，在 `main.tex` 的 `\mainmatter` 后取消 `\ctexset{chapter/pagestyle=plain}` 这一行的注释即可。该设置也适用于后面的附录、参考文献和致谢首页。

在 `main.tex` 的 `\fdusetup` 中设置 `header-style`，默认值为 `alternating`。如需自定义页眉文字或位置，可在导言区使用 `\AddToHook{begindocument/end}{...}`，在其中先用 `\fancyhead{}` 清空预设页眉，再用 `\fancyhead` 指定内容和位置。

- `centered`：奇偶页均居中显示当前章标题。
- `alternating`（默认）：目录、中英文摘要及图表清单的每一页均居中显示本部分标题。进入正文（`\mainmatter`）后，奇数页居中显示章标题，偶数页居中显示“复旦大学硕士学位论文”等论文类型文字。进入 `\backmatter` 后恢复为每页居中显示本部分标题。
- `outer`：目录、中英文摘要及图表清单的每一页均居中显示本部分标题。正文奇数页在右侧显示章标题，偶数页在左侧显示论文类型文字，双面打印时均靠纸张外侧。进入 `\backmatter` 后恢复为居中显示本部分标题。

目录、摘要和图表清单以各自的标题作为当前章标题。论文类型随 `degree` 设置切换，例如博士论文显示“复旦大学博士学位论文”。

### 页码

页码置于页脚中央，采用五号（10.5 bp）Times New Roman。

页码编号从目录首页开始。
目录、中英文摘要和图表清单用大写罗马数字 I、II、III、IV……连续编号。
正文默认从第 1 章首页起以阿拉伯数字 1 重新编号（`main-page-numbering=arabic`）。


## 书脊

需要 **A4 书脊页**时，在 `main.tex` 开头取消 `\makespine` 的注释，重新编译。论文 PDF 的最后一页就是书脊，题名、作者和校名自上而下竖排，上下页边距各为 30 mm。

需要**完整外封展开图**时，在 `main.tex` 所在目录运行以下命令，生成单页 `cover-print.pdf`。

```sh
latexmk -xelatex cover-print.tex
```

展开图直接读取 `main.tex` 中的论文信息，无需启用 `\makespine`。

展开图从左至右为留白封底、书脊、封面。默认书脊宽 12 mm，**四周各留 3 mm 出血**，整页为 438 × 303 mm。送印前请向装订方确认书脊宽度，在 `cover-print.tex` 的 `\fdusetupcoverprint{12mm}{3mm}` 中修改第一个参数，第二个参数控制出血宽度。

**Overleaf 编译书脊**
在 Overleaf 上可将主文档切换为 `cover-print.tex` 后编译。

**Docker 编译书脊**
克隆完整仓库，确保本机已安装 Docker。在仓库根目录运行以下命令。

```sh
scripts/latex-env.sh xelatex example/thesis/cover-print.tex
```

编译成功后，可直接打开 `example/thesis/cover-print.pdf`。

## 其它说明

- 请根据论文主题查找相应的中图分类号，再将其填入 `main.tex` 中 `\fdusetup` 的 `clc` 字段。[中图分类号查询](https://www.clcindex.com/)
- 在 `reference.bib` 添加文献，在正文用 `\cite{条目键}` 引用，文末自动列出已引文献。
- 将图片放在 figures/ 下，在 main.tex 的 `\includegraphics` 中填写文件名，用 `\caption` 写图题，用 `\label` 和 `\ref` 交叉引用。

## 许可证

模板原创代码由 fduthesis_template 项目贡献者按 GNU 通用公共许可证第 3 版（`GPL-3.0-only`）授权。分发时请保留版权和许可声明。学校标识、学校规范及其样本、第三方字体的权利归各自权利人。[许可证全文](LICENSE)
