% SPDX-License-Identifier: GPL-3.0-only
\NeedsTeXFormat{LaTeX2e}
\ProvidesExplClass{fduthesis}{}{1.0.0}{Independent Fudan thesis template}
\RequirePackage{expl3}
\ExplSyntaxOn
\sys_if_engine_xetex:F { \sys_if_engine_luatex:F { \ClassError{fduthesis}{XeLaTeX or LuaLaTeX required}{Use xelatex or lualatex to compile this document.} } }
\bool_new:N \g_fduthesis_english_bool
\keys_define:nn { fduthesis / class }
  {
    lang .choice:,
    lang / zh .code:n = { \bool_gset_false:N \g_fduthesis_english_bool },
    lang / cn .meta:n = { lang = zh },
    lang / en .code:n = { \bool_gset_true:N \g_fduthesis_english_bool },
    unknown .code:n = { \PassOptionsToClass{\CurrentOption}{ctexbook} }
  }
% Use the same base size ladder for the plain and Chinese ctex schemes.
\PassOptionsToClass{zihao=5}{ctexbook}
\ProcessKeyOptions[fduthesis/class]
\bool_if:NT \g_fduthesis_english_bool { \PassOptionsToClass{scheme=plain}{ctexbook} }
\cs_new:Npn \fduthesis_text:nn #1#2
  { \bool_if:NTF \g_fduthesis_english_bool {#2}{#1} }
\LoadClass[UTF8,openany]{ctexbook}
\msg_new:nnn {fduthesis}{missing-times-new-roman}
  {Times~New~Roman~is~required~for~English~text~and~digits.~
   Install~Times~New~Roman~and~compile~again.}
\IfFontExistsTF{Times~New~Roman}
  {\setmainfont{Times~New~Roman}}
  {
    \file_if_exist:nTF {./fonts/times.ttf}
      {\setmainfont[Path=./fonts/,BoldFont=timesbd.ttf,ItalicFont=timesi.ttf,
                    BoldItalicFont=timesbi.ttf]{times.ttf}}
      {\msg_fatal:nn {fduthesis}{missing-times-new-roman}}
  }
\msg_new:nnn {fduthesis}{missing-simsun}
  {SimSun~not~found;~defaulting~to~Fandol~Song.~
   Install~SimSun~or~enable~the~project~font~in~main.tex.}
% Give an explicitly selected serif font its own xeCJK family.
\cs_new_protected:Npn \fduthesis_select_serif_family:
  { \sys_if_engine_xetex:T { \tl_set:Nn \CJKrmdefault { fduthesis-simsun } } }
\NewHook{fduthesis/cjk-font}
\IfHookEmptyTF{fduthesis/cjk-font}
  {
    % A latexmkrc may already have checked Fontconfig for the whole build.
    % Otherwise only skip the system probe on a successful, empty Linux query.
    \cs_if_exist:NF \fduthesisNoSystemSimSun
      {
        \sys_if_engine_xetex:T
          {
            \sys_if_platform_unix:T
              {
                \sys_if_shell_unrestricted:T
                  {
                    \sys_get_shell:nnNT
                      { test~-r~/proc/sys/kernel/ostype~&&~
                        test~-x~/usr/bin/fc-list~&&~
                        /usr/bin/fc-list~':family=SimSun'~family~&&~echo~DONE }
                      { \endlinechar=-1 } \l_tmpa_tl
                      {
                        \tl_trim_spaces:N \l_tmpa_tl
                        \str_if_eq:VnT \l_tmpa_tl {DONE}
                          { \cs_new:Npn \fduthesisNoSystemSimSun {} }
                      }
                  }
              }
          }
      }
    \cs_if_exist:NTF \fduthesisNoSystemSimSun
      {\use_ii:nn}
      {\IfFontExistsTF{SimSun}}
      {\fduthesis_select_serif_family: \setCJKmainfont[AutoFakeBold=2]{SimSun}}
      {
        \cs_if_exist:cF {ver@ctex-fontset-fandol.def}
          {
            \setCJKmainfont[Extension=.otf,BoldFont=FandolSong-Bold,
                            ItalicFont=FandolKai-Regular]{FandolSong-Regular}
          }
        \msg_warning:nn {fduthesis}{missing-simsun}
      }
  }
  {\fduthesis_select_serif_family: \UseHook{fduthesis/cjk-font}}
\RequirePackage[a4paper,top=30mm,bottom=25mm,left=30mm,right=25mm,headheight=15pt]{geometry}
\RequirePackage{array,circledsteps,emptypage,etoolbox,fancyhdr,graphicx,perpage}
\RequirePackage[hidelinks]{hyperref}

\tl_new:N \g_fduthesis_float_separator_tl
\tl_new:N \g_fduthesis_equation_separator_tl
\tl_new:N \g_fduthesis_header_style_tl
\bool_new:N \g_fduthesis_main_roman_bool
\tl_new:N \g_fduthesis_type_tl
\tl_new:N \g_fduthesis_title_tl
\tl_new:N \g_fduthesis_title_en_tl
\tl_new:N \g_fduthesis_author_tl
\tl_new:N \g_fduthesis_student_id_tl
\tl_new:N \g_fduthesis_supervisor_tl
\tl_new:N \g_fduthesis_supervisor_title_tl
\clist_new:N \g_fduthesis_committee_clist
\tl_new:N \g_fduthesis_major_tl
\tl_new:N \g_fduthesis_department_tl
\tl_new:N \g_fduthesis_degree_tl
\tl_new:N \g_fduthesis_date_tl
\bool_new:N \g_fduthesis_equivalent_qualification_bool
\tl_new:N \g_fduthesis_clc_tl
\tl_new:N \g_fduthesis_school_id_tl
\tl_new:N \g_fduthesis_secret_level_tl
\tl_new:N \g_fduthesis_keywords_tl
\tl_new:N \g_fduthesis_keywords_en_tl

\bool_new:N \g_fduthesis_english_cover_bool
\cs_new:Npn \fduthesis_cover_text:nn #1#2
  { \bool_if:NTF \g_fduthesis_english_cover_bool {#2}{#1} }

\keys_define:nn { fduthesis / setup }
  {
    cover-language .choice:,
    cover-language / chinese .code:n = { \bool_gset_false:N \g_fduthesis_english_cover_bool },
    cover-language / english .code:n = { \bool_gset_true:N \g_fduthesis_english_cover_bool },
    figure-table-separator .choice:,
    figure-table-separator / hyphen .code:n = { \tl_gset:Nn \g_fduthesis_float_separator_tl {-} },
    figure-table-separator / dot .code:n = { \tl_gset:Nn \g_fduthesis_float_separator_tl {.} },
    figure-table-separator .initial:n = dot,
    equation-separator .choice:,
    equation-separator / dot .code:n = { \tl_gset:Nn \g_fduthesis_equation_separator_tl {.} },
    equation-separator / hyphen .code:n = { \tl_gset:Nn \g_fduthesis_equation_separator_tl {-} },
    equation-separator .initial:n = dot,
    header-style .choices:nn = { centered, alternating, outer }
      { \tl_gset_eq:NN \g_fduthesis_header_style_tl \l_keys_choice_tl },
    header-style .initial:n = alternating,
    main-page-numbering .choice:,
    main-page-numbering / arabic .code:n = { \bool_gset_false:N \g_fduthesis_main_roman_bool },
    main-page-numbering / roman  .code:n = { \bool_gset_true:N \g_fduthesis_main_roman_bool },
    main-page-numbering .initial:n = arabic,
    type .choice:,
    type / academic .code:n = { \tl_gset:Nn \g_fduthesis_type_tl {学术学位} },
    type / professional .code:n = { \tl_gset:Nn \g_fduthesis_type_tl {专业学位} },
    type .initial:n = academic,
    degree .choices:nn = { bachelor, master, doctor }
      { \tl_gset_eq:NN \g_fduthesis_degree_tl \l_keys_choice_tl },
    degree .initial:n = master,
    title .tl_gset:N = \g_fduthesis_title_tl,
    title-en .tl_gset:N = \g_fduthesis_title_en_tl,
    author .tl_gset:N = \g_fduthesis_author_tl,
    student-id .tl_gset:N = \g_fduthesis_student_id_tl,
    supervisor .tl_gset:N = \g_fduthesis_supervisor_tl,
    supervisor-title .tl_gset:N = \g_fduthesis_supervisor_title_tl,
    committee .clist_gset:N = \g_fduthesis_committee_clist,
    major .tl_gset:N = \g_fduthesis_major_tl,
    department .tl_gset:N = \g_fduthesis_department_tl,
    date .tl_gset:N = \g_fduthesis_date_tl,
    % The English-program marker comes from lang, including for older examples
    % which also set student-category to 英文项目.
    student-category .code:n =
      {
        \bool_gset:Nn \g_fduthesis_equivalent_qualification_bool
          { \str_if_eq_p:nn {#1}{同等学力人员} || \str_if_eq_p:nn {#1}{同等学力} }
      },
    clc .tl_gset:N = \g_fduthesis_clc_tl,
    school-id .tl_gset:N = \g_fduthesis_school_id_tl,
    school-id .initial:n = 10246,
    secret-level .tl_gset:N = \g_fduthesis_secret_level_tl,
    keywords .tl_gset:N = \g_fduthesis_keywords_tl,
    keywords-en .tl_gset:N = \g_fduthesis_keywords_en_tl,
  }
\cs_new:Npn \fduthesis_chapter_number:nN #1#2
  {
    \int_compare:nNnT {\value{chapter}} > {0}
      { \thechapter #2 }
    \arabic{#1}
  }
\cs_set:Npn \thefigure { \fduthesis_chapter_number:nN {figure} \g_fduthesis_float_separator_tl }
\cs_set:Npn \thetable  { \fduthesis_chapter_number:nN {table} \g_fduthesis_float_separator_tl }

\cs_set:Npn \theequation { \fduthesis_chapter_number:nN {equation} \g_fduthesis_equation_separator_tl }

% Extend the ruled style locally so caption still recognizes it by name.
\cs_new_protected:Npn \fduthesis_algorithm_rules:
  {
    \tl_put_right:Nn \fs@ruled
      {
        \cs_set:Npn \@fs@pre  { \hrule height 0.75bp \kern 6bp }
        \cs_set:Npn \@fs@mid  { \kern 6bp \hrule height 0.5bp \kern 2pt }
        \cs_set:Npn \@fs@post { \kern 2pt \hrule height 0.75bp }
      }
  }
\AddToHook{env/algorithm/begin}{\fduthesis_algorithm_rules:}
\AddToHook{env/algorithm*/begin}{\fduthesis_algorithm_rules:}
\AddToHook{env/algorithmic/begin}
  {
    \cs_if_exist:NT \@captype
      { \str_if_eq:VnT \@captype {algorithm} { \fduthesis_font:nn {12bp}{16bp} } }
  }
\AddToHook{package/algorithm/after}
  {
    \counterwithin{algorithm}{chapter}
    \floatname{algorithm}{\fduthesis_text:nn {算法}{Algorithm}}
    \renewcommand*{\listalgorithmname}{\fduthesis_text:nn {算法清单}{List~of~Algorithms}}
    \providecommand*{\algorithmautorefname}{\fduthesis_text:nn {算法}{Algorithm}}
  }
\RequirePackage{caption}
\DeclareCaptionLabelSeparator{fduthesiscjkspace}{\hspace{\ccwd}}
\captionsetup[figure]{labelsep=fduthesiscjkspace}
\captionsetup[table]{labelsep=fduthesiscjkspace}
\AddToHook{package/listings/after}
  {
    \captionsetup[lstlisting]{labelsep=fduthesiscjkspace}
    \lstset{
      basicstyle=\normalfont\ttfamily\fduthesis_font:nn {10.5bp}{14bp}\color{black},
      keywordstyle={}, keywordstyle=[2]{}, commentstyle={}, stringstyle={},
      columns=fullflexible, keepspaces=true, breaklines=true, showstringspaces=false,
      backgroundcolor={}, frame=tb, framerule=0.5bp, framesep=4bp,
      captionpos=t, numbers=none, numberbychapter=true
    }
    \renewcommand*{\lstlistingname}{\fduthesis_text:nn {代码}{Listing}}
    \renewcommand*{\lstlistlistingname}{\fduthesis_text:nn {代码清单}{List~of~Listings}}
  }

\msg_new:nnn { fduthesis } { missing } { Required~metadata~'#1'~is~missing. }
\NewDocumentCommand \fdusetup { m } { \keys_set:nn { fduthesis / setup } {#1} }
\cs_new_protected:Npn \fduthesis_require:n #1
  {
    \tl_set:Nn \l_tmpa_tl { g_fduthesis_#1_tl }
    \tl_replace_all:Nnn \l_tmpa_tl {-} {_}
    \tl_if_empty:cT { \l_tmpa_tl }
      { \msg_warning:nnn { fduthesis } { missing } {#1} }
  }

\cs_new_protected:Npn \fduthesis_geometry_begin:n #1
  {
    \savegeometry{fduthesis-before-special-page}
    \newgeometry{#1}
  }
\cs_new_protected:Npn \fduthesis_geometry_end:
  { \loadgeometry{fduthesis-before-special-page} }

% Word stores page margins in twentieths of a PDF point (twips).
\cs_new_protected:Npn \fduthesis_sample_geometry:n #1
  { \fduthesis_geometry_begin:n {left=87.6bp,right=87.6bp,top=#1,bottom=72bp,headheight=15pt} }

\cs_new_protected:Npn \fduthesis_font:nn #1#2
  { \linespread{1}\fontsize{#1}{#2}\selectfont }

\MakePerPage{footnote}
\cs_new_protected:Npn \fduthesis_circled:n #1
  {
    \group_begin:
      \pgfkeys{/csteps/inner~xsep=0.12em,/csteps/inner~ysep=0.12em}
      \Circled{#1}
    \group_end:
  }
\cs_set:Npn \thefootnote { \fduthesis_circled:n {\arabic{footnote}} }
\cs_set_protected:Npn \@makefntext #1
  {
    \normalfont\linespread{1}\zihao{-5}
    \setlength{\leftskip}{1.5em}
    \setlength{\parindent}{0pt}
    \noindent\llap{\@thefnmark\hspace{0.5em}}#1\par
  }

% Number through subsubsection; tocdepth independently controls the contents.
\setcounter{secnumdepth}{3}
\ctexset{
  part = {
    format = \huge\bfseries\centering,
    nameformat = {}, titleformat = {}
  },
  chapter = {
    number = \arabic{chapter},
    lofskip = 0bp, lotskip = 0bp,
    pagestyle = fancy,
    % In scheme=plain these two hooks would override the shared heading size.
    nameformat = {}, titleformat = {},
    format = \if@mainmatter\fduthesis_font:nn {16bp}{20bp}\else\huge\fi \bfseries\centering,
    beforeskip = \if@mainmatter 24bp\else 50pt\fi,
    afterskip = \if@mainmatter 18bp\else 40pt\fi,
    aftername = \quad
  },
  section = {
    format = \fduthesis_font:nn {14bp}{20bp}\bfseries\centering,
    aftername = \quad, beforeskip = 24bp, afterskip = 6bp
  },
  subsection = {
    format = \fduthesis_font:nn {13bp}{20bp}\bfseries,
    aftername = \quad, beforeskip = 12bp, afterskip = 6bp
  },
  subsubsection = {
    format = \fduthesis_font:nn {12bp}{20bp}\bfseries,
    aftername = \quad, beforeskip = 12bp, afterskip = 6bp
  }
}

% For consecutive headings, use the larger of the two paragraph spacings.
% ctex otherwise skips the second heading's before-skip in this case.
\cs_new_protected:Npn \fduthesis_merge_heading_skip:n #1
  {
    \ifvmode
      \if@nobreak
        \dim_compare:nNnT {\lastskip} > {0pt}
          { \addvspace{#1} }
      \fi
    \fi
  }
\AddToHook{cmd/section/before}
  { \fduthesis_merge_heading_skip:n {\CTEX@section@beforeskip} }
\AddToHook{cmd/subsection/before}
  { \fduthesis_merge_heading_skip:n {\CTEX@subsection@beforeskip} }
\AddToHook{cmd/subsubsection/before}
  { \fduthesis_merge_heading_skip:n {\CTEX@subsubsection@beforeskip} }

% Apply the school's body type size and leading when the main text begins.
\AddToHook{cmd/mainmatter/after}
  {
    \bool_if:NT \g_fduthesis_main_roman_bool { \pagenumbering{roman} }
    % Use the body baseline without extra glue between rows of display math.
    \setlength{\jot}{0bp}
    \AddToHook{cmd/normalsize/after}[fduthesis-body]{\fduthesis_font:nn {12bp}{20bp}}
    \normalsize
  }

\cs_new_protected:Npn \fduthesis_special_page:n #1
  {
    \clearpage
    \group_begin:
      \thispagestyle{empty}
      #1
      \par\clearpage
    \group_end:
  }

\cs_new_protected:Npn \fduthesis_cover_right_column:n #1
  { \hfill \makebox[100bp][l]{#1}\par }

\cs_new_protected:Npn \fduthesis_cover_header:
  {
    \tl_if_empty:NF \g_fduthesis_secret_level_tl
      {
        \tl_if_eq:NnF \g_fduthesis_secret_level_tl {none}
          { \hfill \fduthesis_cover_text:nn {密级：}{Classification:~}\g_fduthesis_secret_level_tl \par }
      }
    \noindent \fduthesis_cover_text:nn {中图分类号：}{CLC~number:~}\g_fduthesis_clc_tl
    \fduthesis_cover_right_column:n
      { \fduthesis_cover_text:nn {学校代码：}{School~code:~}\g_fduthesis_school_id_tl }
    \bool_if:nT { \g_fduthesis_equivalent_qualification_bool || \g_fduthesis_english_bool }
      {
        \noindent \fduthesis_cover_right_column:n
          {
            \bool_if:NT \g_fduthesis_equivalent_qualification_bool
              { 同等学力人员 \bool_if:NT \g_fduthesis_english_bool { / } }
            \bool_if:NT \g_fduthesis_english_bool { 英文项目 }
          }
      }
  }

\cs_new:Npn \fduthesis_degree_title:n #1
  {
    \str_case:Vn \g_fduthesis_degree_tl
      {
        {master}{#1 {硕士学位论文}{Master's~Thesis}}
        {doctor}{#1 {博士学位论文}{Doctoral~Dissertation}}
        {bachelor}{#1 {本科毕业论文}{Bachelor's~Thesis}}
      }
  }

\cs_new_protected:Npn \fduthesis_cover_titles:
  {
    {\includegraphics[width=217.5bp,height=81bp]{fduthesis-logo.png}\par}
    {\fduthesis_font:nn {22bp}{31.2bp}
      % The university cover uses the Chinese degree heading in both languages.
      \fduthesis_degree_title:n \use_i:nn
      \par
      \tl_if_eq:NnF \g_fduthesis_degree_tl {bachelor}
        {
          \vspace{6bp}
          \fduthesis_font:nn {15bp}{31.2bp}\bfseries
          （\g_fduthesis_type_tl）\par
        }
    }
    \vspace{28bp}
    {\fduthesis_font:nn {18bp}{30bp}\bfseries \g_fduthesis_title_tl \par}
    \vspace{10bp} % 与英文题名的 20 bp 行距合计为 30 bp 基线距离。
    {\fduthesis_font:nn {14bp}{20bp}\bfseries
      % Reserve the second title line when the English title is already above.
      \bool_if:nTF
        { \g_fduthesis_english_cover_bool &&
          ( \tl_if_empty_p:N \g_fduthesis_title_en_tl ||
            \tl_if_eq_p:NN \g_fduthesis_title_tl \g_fduthesis_title_en_tl ) }
        { \strut } { \g_fduthesis_title_en_tl } \par}
  }

\cs_new_protected:Npn \fduthesis_cover_details:
  {
    \fduthesis_font:nn {14bp}{31.2bp}
    \begin{tabular}{@{}>{\raggedleft\arraybackslash}p{190bp}@{\hspace{14bp}}p{\dimexpr\linewidth-204bp\relax}@{}}
      \fduthesis_cover_text:nn {学生姓名：}{Student~name:} & \g_fduthesis_author_tl           \\
      \fduthesis_cover_text:nn {学号：}{Student~ID:}     & \g_fduthesis_student_id_tl       \\
      \fduthesis_cover_text:nn {导师姓名、职称：}{Supervisor~and~title:} & \g_fduthesis_supervisor_tl
                          \quad \g_fduthesis_supervisor_title_tl \\
      \fduthesis_cover_text:nn {学科专业：}{Major:} & \g_fduthesis_major_tl            \\
      \fduthesis_cover_text:nn {培养单位：}{Department:} & \g_fduthesis_department_tl       \\
      \fduthesis_cover_text:nn {论文提交日期：}{Submission~date:} & \g_fduthesis_date_tl
    \end{tabular}
  }

\NewDocumentCommand \makecoverpage {}
  {
    \clist_map_function:nN {title,author,student-id} \fduthesis_require:n
    \tl_if_eq:NnF \g_fduthesis_degree_tl {bachelor}
      {
        \bool_if:NF \g_fduthesis_english_cover_bool { \fduthesis_require:n {title-en} }
        \clist_map_function:nN
          {clc,supervisor,supervisor-title,major,department,date}
          \fduthesis_require:n
      }
    \fduthesis_sample_geometry:n {72bp}
    \fduthesis_special_page:n
      {
        \pdfbookmark[0]{\fduthesis_cover_text:nn {封面}{Title~Page}}{fdu.cover}
        {\fduthesis_font:nn {9bp}{18bp}\fduthesis_cover_header:}
        \vskip 0pt plus 1.35fill \centering \fduthesis_cover_titles:
        \vfill \fduthesis_cover_details:
        \vspace*{60bp}
      }
    \fduthesis_geometry_end:
  }

\cs_new_protected:Npn \fduthesis_unnumbered_heading_setup:
  {
    \ctexset{chapter={
      format=\normalfont\fduthesis_font:nn {16bp}{20bp}\bfseries\centering,
      beforeskip=24bp, afterskip=18bp}}
  }

\cs_new_protected:Npn \fduthesis_typeset_list:N #1
  {
    \group_begin:
      \fduthesis_unnumbered_heading_setup:
      \normalfont\rmfamily\fduthesis_font:nn {12bp}{20bp}
      \setlength{\parskip}{0bp}
      #1
    \group_end:
  }

% Ship the unnumbered opening pages before assigning I to the first contents page.
\AddToHook{cmd/frontmatter/after}
  {
    % Reserve page.i, page.ii, ... for the main text in hyperref.
    \bool_if:NT \g_fduthesis_main_roman_bool { \pagenumbering{arabic} }
    \AddToHookNext{cmd/tableofcontents/before}{\cleardoublepage\pagenumbering{Roman}}
  }
\NewCommandCopy \fduthesis_original_toc: \tableofcontents
\NewCommandCopy \fduthesis_original_lof: \listoffigures
\NewCommandCopy \fduthesis_original_lot: \listoftables
% Keep book's chapter entry layout, omitting its extra inter-paragraph skip.
\ExplSyntaxOff
\patchcmd{\l@chapter}{\vskip 1.0em \@plus\p@}{}{}
  {\ClassWarning{fduthesis}{Could not remove chapter entry skip}}
\ExplSyntaxOn
\RenewDocumentCommand \tableofcontents {}
  { \fduthesis_typeset_list:N \fduthesis_original_toc: }
\RenewDocumentCommand \listoffigures {}
  { \fduthesis_typeset_list:N \fduthesis_original_lof: }
\RenewDocumentCommand \listoftables {}
  { \fduthesis_typeset_list:N \fduthesis_original_lot: }

\NewDocumentCommand \makecommittee {}
  {
    \clist_if_empty:NT \g_fduthesis_committee_clist
      { \msg_warning:nnn {fduthesis}{missing}{committee} }
    \fduthesis_special_page:n
      {
        \pdfbookmark[0]{指导小组成员名单}{fdu.committee}
        \centering
        \setlength{\parskip}{0pt}
        {\zihao{3}\bfseries 指导小组成员名单\par}
        \nobreak\vskip 18bp\relax
        \zihao{-3}
        \clist_map_inline:Nn \g_fduthesis_committee_clist { ##1\par\medskip }
      }
  }

% Vertical offsets are measured from the first university heading in Appendix II.
\cs_new_protected:Npn \fduthesis_statement_heading:n #1
  {
    {\centering \fduthesis_font:nn {18bp}{31.2bp}\bfseries
      复旦大学\par #1\par}
  }
\cs_new_protected:Npn \fduthesis_signature_line:n #1
  { \rule[-2bp]{#1bp}{0.6bp} }
\NewDocumentCommand \makeauthorization {}
  {
    \fduthesis_sample_geometry:n {102.6bp}
    \fduthesis_special_page:n
      {
        \fduthesis_font:nn {12bp}{20bp}
        \phantomsection
        \addcontentsline{toc}{chapter}{学位论文独创性声明和使用授权声明}
        \vbox to 343.2bp {
          \vbox to 81bp {\fduthesis_statement_heading:n {学位论文独创性声明}\vss}
          \nointerlineskip
          \vbox to 140.4bp {
            \fduthesis_font:nn {12bp}{31.2bp}\parindent=30bp
            本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。论文中除特别标注的内容外，不包含任何其他个人或机构已经发表或撰写过的研究成果。对本研究做出重要贡献的个人和集体，均已在论文中作了明确的声明并表示了谢意。本声明的法律结果由本人承担。\par\vss
          }
          \nointerlineskip
          \noindent\hspace*{168bp}作者签名：\fduthesis_signature_line:n {72}
          \hspace{18bp}日期：\fduthesis_signature_line:n {60}\par\vss
        }
        \nointerlineskip
        \vbox to 109bp {\fduthesis_statement_heading:n {学位论文使用授权声明}\vss}
        \nointerlineskip
        \vbox to 113bp {
          \fduthesis_font:nn {12bp}{23.4bp}\parindent=24bp
          本人完全了解复旦大学有关收藏和利用博士、硕士学位论文的规定，即：学校有权收藏、使用并向国家有关部门或机构送交论文的印刷本和电子版本；允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其它复制手段保存论文。涉密学位论文在解密后遵守此规定。\par\vss
        }
        \nointerlineskip
        \noindent\hspace*{30bp}作者签名：\fduthesis_signature_line:n {78}
        \hspace{12bp}导师签名：\fduthesis_signature_line:n {72}
        \hspace{12bp}日期：\fduthesis_signature_line:n {54}\par
      }
    \fduthesis_geometry_end:
  }
% Abstracts may span several pages. Anchor the front matter entry on the first.
\cs_new_protected:Npn \fduthesis_summary_begin:nnn #1#2#3
  {
    \fduthesis_sample_geometry:n {72bp}
    \fduthesis_font:nn {12bp}{20bp}
    \pagestyle{fancy}
    \phantomsection
    \addcontentsline{toc}{chapter}{#1}
    \markboth{#1}{#1}
    {
      \vbox_set_top:Nn \l_tmpa_box { \centering #2\par }
      % Preserve the natural first baseline even when its line exceeds topskip.
      \vbox:n
        {
          \skip_vertical:n { 24bp + \dim_max:nn {0pt} {\topskip - \box_ht:N \l_tmpa_box} }
          \vbox_unpack_drop:N \l_tmpa_box
        }
    }
    \nobreak\vskip 1bp
    \noindent #3\ignorespaces
  }

\clist_new:N \l_fduthesis_summary_keywords_clist
\msg_new:nnn {fduthesis}{keyword-count}
  {The~#1~abstract~has~#2~keywords;~the~specification~requires~3--8.}
\cs_new_protected:Npn \fduthesis_summary_end:nnn #1#2#3
  {
    \int_set:Nn \l_tmpa_int { \clist_count:N \l_fduthesis_summary_keywords_clist }
    \int_compare:nF { 3 <= \l_tmpa_int <= 8 }
      { \msg_warning:nnnn {fduthesis}{keyword-count}{#1}{\int_use:N \l_tmpa_int} }
    \clist_if_empty:NF \l_fduthesis_summary_keywords_clist
      {
        \par\noindent #2
        \clist_use:Nn \l_fduthesis_summary_keywords_clist {#3}
      }
    \par\fduthesis_geometry_end:
  }

\cs_new:Npn \fduthesis_english_title:
  { \tl_if_empty:NTF \g_fduthesis_title_en_tl {\g_fduthesis_title_tl}{\g_fduthesis_title_en_tl} }
\NewDocumentEnvironment { fdusummary } { O{摘要} }
  {
    \clist_set:NV \l_fduthesis_summary_keywords_clist \g_fduthesis_keywords_tl
    \fduthesis_summary_begin:nnn {#1}{\g_fduthesis_title_tl}{摘要：}
  }
  { \fduthesis_summary_end:nnn {Chinese}{关键词：}{；} }

\NewDocumentEnvironment { fdusummaryen } { O{Abstract} }
  {
    \clist_set:NV \l_fduthesis_summary_keywords_clist \g_fduthesis_keywords_en_tl
    \fduthesis_summary_begin:nnn {#1}{\fduthesis_english_title:}{Abstract:~}
  }
  { \fduthesis_summary_end:nnn {English}{Keywords:~}{;~} }

\box_new:N \l_fduthesis_spine_box
\tl_new:N \l_fduthesis_spine_text_tl
% Keep TeX groups and math intact while stacking literal Latin letters and digits.
\cs_new_protected:Npn \fduthesis_spine_character:n #1
  {
    \regex_match:nnTF { \A [A-Za-z0-9] \Z } {#1}
      { \tl_put_right:Nn \l_fduthesis_spine_text_tl { \allowbreak\makebox[1em]{#1}\allowbreak } }
      { \tl_put_right:Nn \l_fduthesis_spine_text_tl {#1} }
  }
\cs_new_protected:Npn \fduthesis_spine_text:N #1
  {
    \tl_clear:N \l_fduthesis_spine_text_tl
    \exp_args:NV \text_map_function:nN #1 \fduthesis_spine_character:n
    \l_fduthesis_spine_text_tl \par
  }
\bool_new:N \g_fduthesis_spine_bool
\NewDocumentCommand \makespine {} { \bool_gset_true:N \g_fduthesis_spine_bool }
\AtEndDocument{\bool_if:NT \g_fduthesis_spine_bool {\fduthesis_spine:}}
\cs_new_protected:Npn \fduthesis_spine:
  {
    \fduthesis_geometry_begin:n {margin=30mm}
    \fduthesis_special_page:n
      {
        \vbox_set:Nn \l_fduthesis_spine_box
          {
            \zihao{4}\hsize=1em\parindent=0pt\parskip=0pt
            \baselineskip=1.1em\relax
            \centering
            \fduthesis_spine_text:N \g_fduthesis_title_tl
            \vskip 1em~plus~1fill\relax
            \fduthesis_spine_text:N \g_fduthesis_author_tl
            \vskip 1em~plus~1fill\relax
            复旦大学\par\kern0pt
          }
        \hbox_to_wd:nn {\linewidth}
          {
            \hfil
            \dim_compare:nNnTF {\box_ht:N \l_fduthesis_spine_box} > {\textheight}
              {\resizebox*{!}{\textheight}{\box_use:N \l_fduthesis_spine_box}}
              {\vbox_to_ht:nn {\textheight} {\vbox_unpack:N \l_fduthesis_spine_box}}
            \hfil
          }
      }
    \fduthesis_geometry_end:
  }

% 两张逻辑 A4 页按原尺寸拼版，封底留白。
\NewDocumentCommand \fdusetupcoverprint { m m }
  {
    \RequirePackage{pgfpages}
    \pgfpagesphysicalpageoptions{
      logical~pages=2,
      physical~width=\dimexpr420mm+#1+#2*2\relax,
      physical~height=\dimexpr297mm+#2*2\relax}
    \pgfpageslogicalpageoptions{1}{
      center=\pgfpoint{\dimexpr210mm+#1/2+#2\relax}{\dimexpr148.5mm+#2\relax}}
    \pgfpageslogicalpageoptions{2}{
      center=\pgfpoint{\dimexpr315mm+#1+#2\relax}{\dimexpr148.5mm+#2\relax}}
    \tl_set:Ne \l_tmpa_tl
      {
        /TrimBox~[\dim_to_decimal_in_bp:n{#2}~\dim_to_decimal_in_bp:n{#2}~
          \dim_to_decimal_in_bp:n{420mm+#1+#2}~\dim_to_decimal_in_bp:n{297mm+#2}]
        /BleedBox~[0~0~\dim_to_decimal_in_bp:n{420mm+#1+#2*2}~
          \dim_to_decimal_in_bp:n{297mm+#2*2}]
      }
    \sys_if_engine_xetex:TF
      { \exp_args:Nne \AddToHook {shipout/foreground}
          { \special{pdf:put~@thispage~<<\l_tmpa_tl>>} } }
      { \tex_global:D \pdfvariable pageattr \exp_after:wN {\l_tmpa_tl} }
    \AddToHook{cmd/makecoverpage/before}{\fduthesis_spine:}
    \AddToHook{cmd/makecoverpage/after}
      {\bool_gset_false:N \g_fduthesis_spine_bool \end{document}}
  }

\cs_new_protected:Npn \fduthesis_back_heading:n #1
  {
    \group_begin:
      \fduthesis_unnumbered_heading_setup:
      \chapter*{#1}
      \markboth{#1}{#1}
      \addcontentsline{toc}{chapter}{#1}
    \group_end:
  }

\AddToHook{package/gbt7714/after}
  {
    \renewcommand{\bibfont}{\normalfont\fontsize{10.5bp}{14bp}\selectfont}
    \setlength{\bibsep}{3bp}
    % natbib normally indents continuations by the width of the widest label.
    % Keep its first-line label position and set continuations to two characters.
    \apptocmd{\NAT@bibsetnum}
      {
        \setlength{\itemindent}{\dimexpr\leftmargin-21bp\relax}
        \setlength{\leftmargin}{21bp}
        \setlength{\topsep}{3bp}
        \setlength{\partopsep}{0pt}
      }{}{\ClassError{fduthesis}{Could~not~configure~numeric~bibliography~spacing}{}}
    \AddToHook{env/thebibliography/end}{\setlength{\@topsepadd}{0pt}}
    \renewcommand{\bibsection}
      {\fduthesis_back_heading:n {\fduthesis_text:nn {参考文献}{References}}}
  }

\AddToHook{package/biblatex/after}
  {
    \cs_set:Npn \bibfont {\normalfont\zihao{5}}
    \defbibenvironment{bibliography}
      {
        \list{}
          {
            \setlength{\leftmargin}{2em}
            \setlength{\itemindent}{-\leftmargin}
            \setlength{\labelwidth}{0pt}
            \setlength{\labelsep}{0pt}
            \setlength{\itemsep}{3bp}
            \setlength{\parsep}{0pt}
            \setlength{\topsep}{3bp}
            \setlength{\partopsep}{0pt}
          }
      }
      {\setlength{\@topsepadd}{0pt}\endlist}
      {\item\leavevmode\mkbibbrackets{\printfield{labelprefix}\printfield{labelnumber}}\hspace{0.5em}}
    \defbibheading{fduthesis}[\fduthesis_text:nn {参考文献}{References}]
      {\fduthesis_back_heading:n {#1}}
    \DeclarePrintbibliographyDefaults{heading=fduthesis}
  }

\cs_new:Npn \fduthesis_acknowledgments_name:
  { \fduthesis_text:nn {致谢}{Acknowledgments} }
\NewDocumentEnvironment {acknowledgements} {}
  {
    \fduthesis_back_heading:n {\fduthesis_acknowledgments_name:}
    \fduthesis_font:nn {12bp}{20bp}
    \setlength{\parindent}{24bp}
  }
  {\par}
\cs_new_protected:Npn \fduthesis_page_number:
  { \normalfont\rmfamily\zihao{5}\thepage }
\AtBeginDocument{
  \pagestyle{fancy}
  \fancyhf{}
  \fancyheadinit{\normalfont\rmfamily\zihao{5}}
  \renewcommand{\headrulewidth}{0.5bp}
  \str_case:Vn \g_fduthesis_header_style_tl
    {
      {centered}{\fancyhead[C]{\nouppercase{\leftmark}}}
      {alternating}{
        \fancyhead[C]{
          \if@mainmatter
            \ifodd\value{page}\relax \nouppercase{\leftmark}
            \else \fduthesis_text:nn {复旦大学}{Fudan~University~}\fduthesis_degree_title:n \fduthesis_text:nn \fi
          \else \nouppercase{\leftmark} \fi
        }
      }
      {outer}{
        \fancyhead[C]{\if@mainmatter\else \nouppercase{\leftmark}\fi}
        \fancyhead[R]{\if@mainmatter \ifodd\value{page}\relax \nouppercase{\leftmark}\fi \fi}
        \fancyhead[L]{\if@mainmatter \ifodd\value{page}\relax \else \fduthesis_text:nn {复旦大学}{Fudan~University~}\fduthesis_degree_title:n \fduthesis_text:nn \fi \fi}
      }
    }
  \fancyfoot[C]{\fduthesis_page_number:}
  \fancypagestyle{plain}{
    \fancyhf{}
    \fancyfoot[C]{\fduthesis_page_number:}
    \renewcommand{\headrulewidth}{0pt}
  }
  \hypersetup{pdftitle={\fduthesis_text:nn {\g_fduthesis_title_tl}{\fduthesis_english_title:}},pdfauthor={\tl_use:N \g_fduthesis_author_tl}}
}
% At this point all pages have shipped and LaTeX has closed the main .aux.
% Its modification time gives a wall-clock timestamp without a shell call.
\AddToHook{enddocument/afteraux}
  {
    \if@filesw
      \tl_set:Ne \l_tmpa_tl { \file_timestamp:n { \jobname.aux } }
      \tl_if_empty:NF \l_tmpa_tl
        {
          \regex_replace_once:nnN
            { \A D: (\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2}) }
            { \1-\2-\3T\4:\5:\6 } \l_tmpa_tl
          \regex_replace_once:nnN { ([-+]\d{2})'(\d{2})'\Z } { \1:\2 } \l_tmpa_tl
          \iow_term:e { fduthesis~timing:~TeX~pass~ended~at~\l_tmpa_tl }
        }
    \fi
    \iow_term:e
      { fduthesis~timing:~TeX~pass~duration~=~\fp_eval:n {round(\sys_timer:/65536,2)}~s }
  }
\ExplSyntaxOff
