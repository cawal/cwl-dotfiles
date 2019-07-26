

--- Elementos de sintaxe ---
texCmdBody     xxx matchgroup=Delimiter start=/{/rs=s+1 skip=/\\\\\|\\[{}]/ end=/}/  contained contains=@texCmdGroup 
texComment     xxx match /%.*$/  contains=@texCommentGroup 
                   links to Comment
texDefParm     xxx match /#\d\+/  contained 
                   links to Special
texDelimiter   xxx match /&/  
                   match /\\\\/  
                   links to Delimiter
texDocType     xxx match /\\documentclass\>\|\\documentstyle\>\|\\usepackage\>/  nextgroup=texBeginEndName,texDocTypeArgs 
                   links to texCmdName
texInput       xxx match =\\input\s\+[a-zA-Z/.0-9_^]\+=hs=s+7  contains=texStatement 
                   links to Special
texLength      xxx match /\<\d\+\([.,]\d\+\)\=\s*\(true\)\=\s*\(bp\|cc\|cm\|dd\|em\|ex\|in\|mm\|pc\|pt\|sp\)\>/  
                   links to Number
texLigature    xxx match /\\\([ijolL]\|ae\|oe\|ss\|AA\|AE\|OE\)\A/me=e-1  
                   match /\\\([ijolL]\|ae\|oe\|ss\|AA\|AE\|OE\)$/  
                   match /\\AE\>/  conceal 
                   match /\\ae\>/  conceal 
                   match /\\oe\>/  conceal 
                   match /\\OE\>/  conceal 
                   match /\\ss\>/  conceal 
                   match /--/  conceal 
                   match /---/  conceal 
                   links to texSpecialChar
texMathDelim   xxx match /\\left\[/  contained 
                   match /\\left\\{/  contained contains=texMathSymbol nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad skipwhite 
                   match /\\right\\}/  contained contains=texMathSymbol nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad skipwhite 
                   match /\\[bB]igg\=[lr]/  contained nextgroup=texMathDelimBad 
                   match /\\[bB]igg\=[lr]\=</  contained conceal 
                   match /\\[bB]igg\=[lr]\=>/  contained conceal 
                   match /\\[bB]igg\=[lr]\=(/  contained conceal 
                   match /\\[bB]igg\=[lr]\=)/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\[/  contained conceal 
                   match /\\[bB]igg\=[lr]\=]/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\{/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\}/  contained conceal 
                   match /\\[bB]igg\=[lr]\=|/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\|/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\backslash/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\downarrow/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\Downarrow/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\lbrace/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\lceil/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\lfloor/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\lgroup/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\lmoustache/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\rbrace/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\rceil/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\rfloor/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\rgroup/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\rmoustache/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\uparrow/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\Uparrow/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\updownarrow/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\Updownarrow/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\langle/  contained conceal 
                   match /\\[bB]igg\=[lr]\=\\rangle/  contained conceal 
                   match /\\\(left\|right\)arrow\>\|\<\([aA]rrow\|brace\)\=vert\>/  contained 
                   match /\\lefteqn\>/  contained 
                   links to Statement
texMathOper    xxx match /[_^=]/  contained 
                   links to Operator
texNewCmd      xxx match /\\newcommand\>/  nextgroup=texCmdName skipwhite skipnl 
                   links to Statement
texNewEnv      xxx match /\\newenvironment\>/  nextgroup=texEnvName skipwhite skipnl 
                   links to Statement
texRefZone     xxx matchgroup=texStatement start=/\\nocite{/ end=/}\|%stopzone\>/  contains=@texRefGroup 
                   matchgroup=texStatement start=/\\bibliography{/ end=/}\|%stopzone\>/  contains=@texRefGroup 
                   matchgroup=texStatement start=/\\label{/ end=/}\|%stopzone\>/  contains=@texRefGroup 
                   matchgroup=texStatement start=/\\\(page\|eq\)ref{/ end=/}\|%stopzone\>/  contains=@texRefGroup 
                   matchgroup=texStatement start=/\\v\=ref{/ end=/}\|%stopzone\>/  contains=@texRefGroup 
                   match /\\cite\%([tp]\*\=\)\=/  nextgroup=texRefOption,texCite 
                   links to Special
texBeginEnd    xxx match /\\begin\>\|\\end\>/  nextgroup=texBeginEndName 
                   links to texCmdName
texBeginEndName xxx matchgroup=Delimiter start=/{/ end=/}/  contained contains=texComment nextgroup=texBeginEndModifier 
                   links to texSection
texSpecialChar xxx match /\\[$&%#{}_]/  
                   match /\\[SP@]\A/me=e-1  
                   match /\\\\/  
                   match /\^\^[0-9a-f]\{2}\|\^\^\S/  
                   links to SpecialChar
texStatement   xxx match /\\\a\+/  
                   links to Statement
texString      xxx match /\(``\|''\|,,\)/  
                   links to String
texTypeSize    xxx match /\\tiny\>/  
                   match /\\scriptsize\>/  
                   match /\\footnotesize\>/  
                   match /\\small\>/  
                   match /\\normalsize\>/  
                   match /\\large\>/  
                   match /\\Large\>/  
                   match /\\LARGE\>/  
                   match /\\huge\>/  
                   match /\\Huge\>/  
                   links to texType
texTypeStyle   xxx match /\\rm\>/  
                   match /\\em\>/  
                   match /\\bf\>/  
                   match /\\it\>/  
                   match /\\sl\>/  
                   match /\\sf\>/  
                   match /\\sc\>/  
                   match /\\tt\>/  
                   match /\\textmd\>/  
                   match /\\textrm\>/  
                   match /\\textsc\>/  
                   match /\\textsf\>/  
                   match /\\textsl\>/  
                   match /\\texttt\>/  
                   match /\\textup\>/  
                   match /\\emph\>/  
                   match /\\mathbb\>/  
                   match /\\mathbf\>/  
                   match /\\mathcal\>/  
                   match /\\mathfrak\>/  
                   match /\\mathit\>/  
                   match /\\mathnormal\>/  
                   match /\\mathrm\>/  
                   match /\\mathsf\>/  
                   match /\\mathtt\>/  
                   match /\\rmfamily\>/  
                   match /\\sffamily\>/  
                   match /\\ttfamily\>/  
                   match /\\itshape\>/  
                   match /\\scshape\>/  
                   match /\\slshape\>/  
                   match /\\upshape\>/  
                   match /\\bfseries\>/  
                   match /\\mdseries\>/  
                   links to texType
texMathError   xxx match /}/  contained 
                   links to texError
texMatcher     xxx matchgroup=Delimiter start=/{/ skip=/\\\\\|\\[{}]/ end=/}/  transparent contains=@texMatchGroup,texError 
                   matchgroup=Delimiter start=/\[/ end=/]/  transparent contains=@texMatchGroup,texError,@NoSpell 
texAccent      xxx match /\\[bcdvuH]\A/me=e-1  
                   match /\\[bcdvuH]$/  
                   match /\\[=^.\~"`']/  
                   match /\\['=t'.c^ud"vb~Hr]{\a}/  
                   match /\\`\s*\({a}\|a\)/  conceal 
                   match /\\\'\s*\({a}\|a\)/  conceal 
                   match /\\^\s*\({a}\|a\)/  conceal 
                   match /\\"\s*\({a}\|a\)/  conceal 
                   match /\\\~\s*\({a}\|a\)/  conceal 
                   match /\\\.\s*\({a}\|a\)/  conceal 
                   match /\\=\s*\({a}\|a\)/  conceal 
                   match /\\k\(\s*{a}\|\s\+a\)/  conceal 
                   match /\\r\(\s*{a}\|\s\+a\)/  conceal 
                   match /\\u\(\s*{a}\|\s\+a\)/  conceal 
                   match /\\v\(\s*{a}\|\s\+a\)/  conceal 
                   match /\\`\s*\({A}\|A\)/  conceal 
                   match /\\\'\s*\({A}\|A\)/  conceal 
                   match /\\^\s*\({A}\|A\)/  conceal 
                   match /\\"\s*\({A}\|A\)/  conceal 
                   match /\\\~\s*\({A}\|A\)/  conceal 
                   match /\\\.\s*\({A}\|A\)/  conceal 
                   match /\\=\s*\({A}\|A\)/  conceal 
                   match /\\k\(\s*{A}\|\s\+A\)/  conceal 
                   match /\\r\(\s*{A}\|\s\+A\)/  conceal 
                   match /\\u\(\s*{A}\|\s\+A\)/  conceal 
                   match /\\v\(\s*{A}\|\s\+A\)/  conceal 
                   match /\\\'\s*\({c}\|c\)/  conceal 
                   match /\\^\s*\({c}\|c\)/  conceal 
                   match /\\\.\s*\({c}\|c\)/  conceal 
                   match /\\c\(\s*{c}\|\s\+c\)/  conceal 
                   match /\\v\(\s*{c}\|\s\+c\)/  conceal 
                   match /\\\'\s*\({C}\|C\)/  conceal 
                   match /\\^\s*\({C}\|C\)/  conceal 
                   match /\\\.\s*\({C}\|C\)/  conceal 
                   match /\\c\(\s*{C}\|\s\+C\)/  conceal 
                   match /\\v\(\s*{C}\|\s\+C\)/  conceal 
                   match /\\v\(\s*{d}\|\s\+d\)/  conceal 
                   match /\\v\(\s*{D}\|\s\+D\)/  conceal 
                   match /\\`\s*\({e}\|e\)/  conceal 
                   match /\\\'\s*\({e}\|e\)/  conceal 
                   match /\\^\s*\({e}\|e\)/  conceal 
                   match /\\"\s*\({e}\|e\)/  conceal 
                   match /\\\~\s*\({e}\|e\)/  conceal 
                   match /\\\.\s*\({e}\|e\)/  conceal 
                   match /\\=\s*\({e}\|e\)/  conceal 
                   match /\\c\(\s*{e}\|\s\+e\)/  conceal 
                   match /\\k\(\s*{e}\|\s\+e\)/  conceal 
                   match /\\u\(\s*{e}\|\s\+e\)/  conceal 
                   match /\\v\(\s*{e}\|\s\+e\)/  conceal 
                   match /\\`\s*\({E}\|E\)/  conceal 
                   match /\\\'\s*\({E}\|E\)/  conceal 
                   match /\\^\s*\({E}\|E\)/  conceal 
                   match /\\"\s*\({E}\|E\)/  conceal 
                   match /\\\~\s*\({E}\|E\)/  conceal 
                   match /\\\.\s*\({E}\|E\)/  conceal 
                   match /\\=\s*\({E}\|E\)/  conceal 
                   match /\\c\(\s*{E}\|\s\+E\)/  conceal 
                   match /\\k\(\s*{E}\|\s\+E\)/  conceal 
                   match /\\u\(\s*{E}\|\s\+E\)/  conceal 
                   match /\\v\(\s*{E}\|\s\+E\)/  conceal 
                   match /\\\'\s*\({g}\|g\)/  conceal 
                   match /\\^\s*\({g}\|g\)/  conceal 
                   match /\\\.\s*\({g}\|g\)/  conceal 
                   match /\\c\(\s*{g}\|\s\+g\)/  conceal 
                   match /\\u\(\s*{g}\|\s\+g\)/  conceal 
                   match /\\v\(\s*{g}\|\s\+g\)/  conceal 
                   match /\\\'\s*\({G}\|G\)/  conceal 
                   match /\\^\s*\({G}\|G\)/  conceal 
                   match /\\\.\s*\({G}\|G\)/  conceal 
                   match /\\c\(\s*{G}\|\s\+G\)/  conceal 
                   match /\\u\(\s*{G}\|\s\+G\)/  conceal 
                   match /\\v\(\s*{G}\|\s\+G\)/  conceal 
                   match /\\^\s*\({h}\|h\)/  conceal 
                   match /\\v\(\s*{h}\|\s\+h\)/  conceal 
                   match /\\v\(\s*{H}\|\s\+H\)/  conceal 
                   match /\\`\s*\({i}\|i\)/  conceal 
                   match /\\\'\s*\({i}\|i\)/  conceal 
                   match /\\^\s*\({i}\|i\)/  conceal 
                   match /\\"\s*\({i}\|i\)/  conceal 
                   match /\\\~\s*\({i}\|i\)/  conceal 
                   match /\\\.\s*\({i}\|i\)/  conceal 
                   match /\\=\s*\({i}\|i\)/  conceal 
                   match /\\k\(\s*{i}\|\s\+i\)/  conceal 
                   match /\\u\(\s*{i}\|\s\+i\)/  conceal 
                   match /\\v\(\s*{i}\|\s\+i\)/  conceal 
                   match /\\`\s*\({I}\|I\)/  conceal 
                   match /\\\'\s*\({I}\|I\)/  conceal 
                   match /\\^\s*\({I}\|I\)/  conceal 
                   match /\\"\s*\({I}\|I\)/  conceal 
                   match /\\\~\s*\({I}\|I\)/  conceal 
                   match /\\\.\s*\({I}\|I\)/  conceal 
                   match /\\=\s*\({I}\|I\)/  conceal 
                   match /\\k\(\s*{I}\|\s\+I\)/  conceal 
                   match /\\u\(\s*{I}\|\s\+I\)/  conceal 
                   match /\\v\(\s*{I}\|\s\+I\)/  conceal 
                   match /\\v\(\s*{J}\|\s\+J\)/  conceal 
                   match /\\c\(\s*{k}\|\s\+k\)/  conceal 
                   match /\\v\(\s*{k}\|\s\+k\)/  conceal 
                   match /\\c\(\s*{K}\|\s\+K\)/  conceal 
                   match /\\v\(\s*{K}\|\s\+K\)/  conceal 
                   match /\\\'\s*\({l}\|l\)/  conceal 
                   match /\\^\s*\({l}\|l\)/  conceal 
                   match /\\c\(\s*{l}\|\s\+l\)/  conceal 
                   match /\\v\(\s*{l}\|\s\+l\)/  conceal 
                   match /\\\'\s*\({L}\|L\)/  conceal 
                   match /\\^\s*\({L}\|L\)/  conceal 
                   match /\\c\(\s*{L}\|\s\+L\)/  conceal 
                   match /\\v\(\s*{L}\|\s\+L\)/  conceal 
                   match /\\\'\s*\({n}\|n\)/  conceal 
                   match /\\\~\s*\({n}\|n\)/  conceal 
                   match /\\c\(\s*{n}\|\s\+n\)/  conceal 
                   match /\\v\(\s*{n}\|\s\+n\)/  conceal 
                   match /\\\'\s*\({N}\|N\)/  conceal 
                   match /\\\~\s*\({N}\|N\)/  conceal 
                   match /\\c\(\s*{N}\|\s\+N\)/  conceal 
                   match /\\v\(\s*{N}\|\s\+N\)/  conceal 
                   match /\\`\s*\({o}\|o\)/  conceal 
                   match /\\\'\s*\({o}\|o\)/  conceal 
                   match /\\^\s*\({o}\|o\)/  conceal 
                   match /\\"\s*\({o}\|o\)/  conceal 
                   match /\\\~\s*\({o}\|o\)/  conceal 
                   match /\\\.\s*\({o}\|o\)/  conceal 
                   match /\\=\s*\({o}\|o\)/  conceal 
                   match /\\H\(\s*{o}\|\s\+o\)/  conceal 
                   match /\\k\(\s*{o}\|\s\+o\)/  conceal 
                   match /\\u\(\s*{o}\|\s\+o\)/  conceal 
                   match /\\v\(\s*{o}\|\s\+o\)/  conceal 
                   match /\\`\s*\({O}\|O\)/  conceal 
                   match /\\\'\s*\({O}\|O\)/  conceal 
                   match /\\^\s*\({O}\|O\)/  conceal 
                   match /\\"\s*\({O}\|O\)/  conceal 
                   match /\\\~\s*\({O}\|O\)/  conceal 
                   match /\\\.\s*\({O}\|O\)/  conceal 
                   match /\\=\s*\({O}\|O\)/  conceal 
                   match /\\H\(\s*{O}\|\s\+O\)/  conceal 
                   match /\\k\(\s*{O}\|\s\+O\)/  conceal 
                   match /\\u\(\s*{O}\|\s\+O\)/  conceal 
                   match /\\v\(\s*{O}\|\s\+O\)/  conceal 
                   match /\\\'\s*\({r}\|r\)/  conceal 
                   match /\\c\(\s*{r}\|\s\+r\)/  conceal 
                   match /\\v\(\s*{r}\|\s\+r\)/  conceal 
                   match /\\\'\s*\({R}\|R\)/  conceal 
                   match /\\c\(\s*{R}\|\s\+R\)/  conceal 
                   match /\\v\(\s*{R}\|\s\+R\)/  conceal 
                   match /\\\'\s*\({s}\|s\)/  conceal 
                   match /\\^\s*\({s}\|s\)/  conceal 
                   match /\\c\(\s*{s}\|\s\+s\)/  conceal 
                   match /\\k\(\s*{s}\|\s\+s\)/  conceal 
                   match /\\v\(\s*{s}\|\s\+s\)/  conceal 
                   match /\\\'\s*\({S}\|S\)/  conceal 
                   match /\\^\s*\({S}\|S\)/  conceal 
                   match /\\c\(\s*{S}\|\s\+S\)/  conceal 
                   match /\\v\(\s*{S}\|\s\+S\)/  conceal 
                   match /\\c\(\s*{t}\|\s\+t\)/  conceal 
                   match /\\v\(\s*{t}\|\s\+t\)/  conceal 
                   match /\\c\(\s*{T}\|\s\+T\)/  conceal 
                   match /\\v\(\s*{T}\|\s\+T\)/  conceal 
                   match /\\`\s*\({u}\|u\)/  conceal 
                   match /\\\'\s*\({u}\|u\)/  conceal 
                   match /\\^\s*\({u}\|u\)/  conceal 
                   match /\\"\s*\({u}\|u\)/  conceal 
                   match /\\\~\s*\({u}\|u\)/  conceal 
                   match /\\=\s*\({u}\|u\)/  conceal 
                   match /\\H\(\s*{u}\|\s\+u\)/  conceal 
                   match /\\k\(\s*{u}\|\s\+u\)/  conceal 
                   match /\\r\(\s*{u}\|\s\+u\)/  conceal 
                   match /\\u\(\s*{u}\|\s\+u\)/  conceal 
                   match /\\v\(\s*{u}\|\s\+u\)/  conceal 
                   match /\\`\s*\({U}\|U\)/  conceal 
                   match /\\\'\s*\({U}\|U\)/  conceal 
                   match /\\^\s*\({U}\|U\)/  conceal 
                   match /\\"\s*\({U}\|U\)/  conceal 
                   match /\\\~\s*\({U}\|U\)/  conceal 
                   match /\\=\s*\({U}\|U\)/  conceal 
                   match /\\H\(\s*{U}\|\s\+U\)/  conceal 
                   match /\\k\(\s*{U}\|\s\+U\)/  conceal 
                   match /\\r\(\s*{U}\|\s\+U\)/  conceal 
                   match /\\u\(\s*{U}\|\s\+U\)/  conceal 
                   match /\\v\(\s*{U}\|\s\+U\)/  conceal 
                   match /\\^\s*\({w}\|w\)/  conceal 
                   match /\\^\s*\({W}\|W\)/  conceal 
                   match /\\`\s*\({y}\|y\)/  conceal 
                   match /\\\'\s*\({y}\|y\)/  conceal 
                   match /\\^\s*\({y}\|y\)/  conceal 
                   match /\\"\s*\({y}\|y\)/  conceal 
                   match /\\\~\s*\({y}\|y\)/  conceal 
                   match /\\`\s*\({Y}\|Y\)/  conceal 
                   match /\\\'\s*\({Y}\|Y\)/  conceal 
                   match /\\^\s*\({Y}\|Y\)/  conceal 
                   match /\\"\s*\({Y}\|Y\)/  conceal 
                   match /\\\~\s*\({Y}\|Y\)/  conceal 
                   match /\\\'\s*\({z}\|z\)/  conceal 
                   match /\\\.\s*\({z}\|z\)/  conceal 
                   match /\\v\(\s*{z}\|\s\+z\)/  conceal 
                   match /\\\'\s*\({Z}\|Z\)/  conceal 
                   match /\\\.\s*\({Z}\|Z\)/  conceal 
                   match /\\v\(\s*{Z}\|\s\+Z\)/  conceal 
                   match /\\`\s*\({\\i}\|\\i\)/  conceal 
                   match /\\\'\s*\({\\i}\|\\i\)/  conceal 
                   match /\\^\s*\({\\i}\|\\i\)/  conceal 
                   match /\\"\s*\({\\i}\|\\i\)/  conceal 
                   match /\\\~\s*\({\\i}\|\\i\)/  conceal 
                   match /\\\.\s*\({\\i}\|\\i\)/  conceal 
                   match /\\u\(\s*{\\i}\|\s\+\\i\)/  conceal 
                   match /\\aa\>/  conceal 
                   match /\\AA\>/  conceal 
                   match /\\o\>/  conceal 
                   match /\\O\>/  conceal 
                   links to texStatement
texBadMath     xxx match /\\end\s*{\s*\(array\|gathered\|bBpvV]matrix\|split\|subequations\|smallmatrix\|xxalignat\)\s*}/  
                   match /\\end\s*{\s*\(align\|alignat\|displaymath\|displaymath\|eqnarray\|equation\|flalign\|gather\|math\|multline\|xalignat\)\*\=\s*}/  
                   match /\\[\])]/  
                   links to texError
texDefCmd      xxx match /\\def\>/  nextgroup=texDefName skipwhite skipnl 
                   links to texDef
texInputFile   xxx match /\\include\(graphics\|list\)\=\(\[.\{-}\]\)\=\s*{.\{-}}/  contains=texStatement,texInputCurlies,texInputFileOpt 
                   match /\\\(epsfig\|input\|usepackage\)\s*\(\[.*\]\)\={.\{-}}/  contains=texStatement,texInputCurlies,texInputFileOpt 
                   links to Special
texMathZoneV   xxx matchgroup=Delimiter start=/\\(/ end=/\\)\|%stopzone\>/  keepend concealends contains=@texMathZoneGroup 
                   links to texMath
texMathZoneW   xxx matchgroup=Delimiter start=/\\\[/ end=/\\]\|%stopzone\>/  keepend concealends contains=@texMathZoneGroup 
                   links to texMath
texMathZoneX   xxx matchgroup=Delimiter start=/\$/ skip=/\\\\\|\\\$/ end=/%stopzone\>/ end=/\$/  concealends contains=@texMathZoneGroup 
                   links to texMath
texMathZoneY   xxx matchgroup=Delimiter start=/\$\$/ end=/%stopzone\>/ end=/\$\$/  keepend concealends contains=@texMathZoneGroup 
                   links to texMath
texMathZoneZ   xxx matchgroup=texStatement start=/\\ensuremath\s*{/ end=/%stopzone\>/ end=/}/  contains=@texMathZoneGroup 
                   links to texMath
texOnlyMath    xxx match /[_^]/  
                   links to texError
texOption      xxx match /[^\\]\zs#\d\+\|^#\d\+/  
                   links to Number
texParen       xxx start=/(/ end=/)/  transparent contains=@texMatchGroup,@Spell 
texSectionZone xxx matchgroup=texSection start=/\\section\>/ end=/\ze\s*\\\%(section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@texSectionGroup,@Spell 
texSpaceCode   xxx match /\\\(math\|cat\|del\|lc\|sf\|uc\)code`/me=e-1  nextgroup=texSpaceCodeChar 
                   links to texStatement
texZone        xxx start=/\\begin{[vV]erbatim}/ end=/\\end{[vV]erbatim}\|%stopzone\>/  
                   start=/\\verb\*\=\z([^\ta-zA-Z]\)/ end=/\z1\|%stopzone\>/  
                   matchgroup=texStatement start=/@samp{/ end=/}\|%stopzone\>/  contains=@texRefGroup 
                   links to PreCondit
texTitle       xxx matchgroup=texSection start=/\\\%(author\|title\)\>\s*{/ end=/}/  contains=@texFoldGroup,@Spell 
texAbstract    xxx matchgroup=texSection start=/\\begin\s*{\s*abstract\s*}/ end=/\\end\s*{\s*abstract\s*}/  contains=@texFoldGroup,@Spell 
texBoldStyle   xxx matchgroup=texTypeStyle start=/\\textbf\s*{/ end=/}/  concealends contains=@texBoldGroup,@Spell 
texItalStyle   xxx matchgroup=texTypeStyle start=/\\textit\s*{/ end=/}/  concealends contains=@texItalGroup,@Spell 
texNoSpell     xxx matchgroup=texComment start=/%\s*nospell\s*{/ end=/%\s*nospell\s*}/  contained contains=@texFoldGroup,@NoSpell 
texBoldItalStyle xxx matchgroup=texTypeStyle start=/\\textit\s*{/ end=/}/  concealends contains=@texItalGroup,@Spell 
texItalBoldStyle xxx matchgroup=texTypeStyle start=/\\textbf\s*{/ end=/}/  concealends contains=@texBoldGroup,@Spell 
texMatcherNM   xxx matchgroup=Delimiter start=/{/ skip=/\\\\\|\\[{}]/ end=/}/  transparent contains=@texMatchNMGroup,texError 
                   matchgroup=Delimiter start=/\[/ end=/]/  transparent contains=@texMatchNMGroup,texError,@NoSpell 
texStyleStatement xxx match /\\[a-zA-Z@]\+/  contained 
                   links to texStatement
texStyleMatcher xxx matchgroup=Delimiter start=/{/ skip=/\\\\\|\\[{}]/ end=/}/  contained contains=@texStyleGroup,texError 
                   matchgroup=Delimiter start=/\[/ end=/]/  contained contains=@texStyleGroup,texError 
texMathDelimBad xxx match /\S/  contained 
                   links to texError
texMathMatcher xxx matchgroup=Delimiter start=/{/ skip=/\%(\\\\\)*\\}/ end=/%stopzone\>/ end=/}/  contained contains=@texMathMatchGroup 
                   links to texMath
texMathSymbol  xxx match /\\|/  contained conceal 
                   match /\\aleph\>/  contained conceal 
                   match /\\amalg\>/  contained conceal 
                   match /\\angle\>/  contained conceal 
                   match /\\approx\>/  contained conceal 
                   match /\\ast\>/  contained conceal 
                   match /\\asymp\>/  contained conceal 
                   match /\\backepsilon\>/  contained conceal 
                   match /\\backsimeq\>/  contained conceal 
                   match /\\backslash\>/  contained conceal 
                   match /\\barwedge\>/  contained conceal 
                   match /\\because\>/  contained conceal 
                   match /\\beth\>/  contained conceal 
                   match /\\between\>/  contained conceal 
                   match /\\bigcap\>/  contained conceal 
                   match /\\bigcirc\>/  contained conceal 
                   match /\\bigcup\>/  contained conceal 
                   match /\\bigodot\>/  contained conceal 
                   match /\\bigoplus\>/  contained conceal 
                   match /\\bigotimes\>/  contained conceal 
                   match /\\bigsqcup\>/  contained conceal 
                   match /\\bigtriangledown\>/  contained conceal 
                   match /\\bigtriangleup\>/  contained conceal 
                   match /\\bigvee\>/  contained conceal 
                   match /\\bigwedge\>/  contained conceal 
                   match /\\blacksquare\>/  contained conceal 
                   match /\\bot\>/  contained conceal 
                   match /\\bowtie\>/  contained conceal 
                   match /\\boxdot\>/  contained conceal 
                   match /\\boxminus\>/  contained conceal 
                   match /\\boxplus\>/  contained conceal 
                   match /\\boxtimes\>/  contained conceal 
                   match /\\Box\>/  contained conceal 
                   match /\\bullet\>/  contained conceal 
                   match /\\bumpeq\>/  contained conceal 
                   match /\\Bumpeq\>/  contained conceal 
                   match /\\cap\>/  contained conceal 
                   match /\\Cap\>/  contained conceal 
                   match /\\cdot\>/  contained conceal 
                   match /\\cdots\>/  contained conceal 
                   match /\\circ\>/  contained conceal 
                   match /\\circeq\>/  contained conceal 
                   match /\\circlearrowleft\>/  contained conceal 
                   match /\\circlearrowright\>/  contained conceal 
                   match /\\circledast\>/  contained conceal 
                   match /\\circledcirc\>/  contained conceal 
                   match /\\clubsuit\>/  contained conceal 
                   match /\\complement\>/  contained conceal 
                   match /\\cong\>/  contained conceal 
                   match /\\coprod\>/  contained conceal 
                   match /\\copyright\>/  contained conceal 
                   match /\\cup\>/  contained conceal 
                   match /\\Cup\>/  contained conceal 
                   match /\\curlyeqprec\>/  contained conceal 
                   match /\\curlyeqsucc\>/  contained conceal 
                   match /\\curlyvee\>/  contained conceal 
                   match /\\curlywedge\>/  contained conceal 
                   match /\\dagger\>/  contained conceal 
                   match /\\dashv\>/  contained conceal 
                   match /\\ddagger\>/  contained conceal 
                   match /\\ddots\>/  contained conceal 
                   match /\\diamond\>/  contained conceal 
                   match /\\diamondsuit\>/  contained conceal 
                   match /\\div\>/  contained conceal 
                   match /\\doteq\>/  contained conceal 
                   match /\\doteqdot\>/  contained conceal 
                   match /\\dotplus\>/  contained conceal 
                   match /\\dots\>/  contained conceal 
                   match /\\dotsb\>/  contained conceal 
                   match /\\dotsc\>/  contained conceal 
                   match /\\dotsi\>/  contained conceal 
                   match /\\dotso\>/  contained conceal 
                   match /\\doublebarwedge\>/  contained conceal 
                   match /\\downarrow\>/  contained conceal 
                   match /\\Downarrow\>/  contained conceal 
                   match /\\ell\>/  contained conceal 
                   match /\\emptyset\>/  contained conceal 
                   match /\\eqcirc\>/  contained conceal 
                   match /\\eqsim\>/  contained conceal 
                   match /\\eqslantgtr\>/  contained conceal 
                   match /\\eqslantless\>/  contained conceal 
                   match /\\equiv\>/  contained conceal 
                   match /\\eth\>/  contained conceal 
                   match /\\exists\>/  contained conceal 
                   match /\\fallingdotseq\>/  contained conceal 
                   match /\\flat\>/  contained conceal 
                   match /\\forall\>/  contained conceal 
                   match /\\frown\>/  contained conceal 
                   match /\\ge\>/  contained conceal 
                   match /\\geq\>/  contained conceal 
                   match /\\geqq\>/  contained conceal 
                   match /\\gets\>/  contained conceal 
                   match /\\gimel\>/  contained conceal 
                   match /\\gg\>/  contained conceal 
                   match /\\gneqq\>/  contained conceal 
                   match /\\gtrdot\>/  contained conceal 
                   match /\\gtreqless\>/  contained conceal 
                   match /\\gtrless\>/  contained conceal 
                   match /\\gtrsim\>/  contained conceal 
                   match /\\hbar\>/  contained conceal 
                   match /\\heartsuit\>/  contained conceal 
                   match /\\hookleftarrow\>/  contained conceal 
                   match /\\hookrightarrow\>/  contained conceal 
                   match /\\iff\>/  contained conceal 
                   match /\\iiint\>/  contained conceal 
                   match /\\iint\>/  contained conceal 
                   match /\\Im\>/  contained conceal 
                   match /\\imath\>/  contained conceal 
                   match /\\implies\>/  contained conceal 
                   match /\\in\>/  contained conceal 
                   match /\\infty\>/  contained conceal 
                   match /\\int\>/  contained conceal 
                   match /\\jmath\>/  contained conceal 
                   match /\\land\>/  contained conceal 
                   match /\\lceil\>/  contained conceal 
                   match /\\ldots\>/  contained conceal 
                   match /\\le\>/  contained conceal 
                   match /\\leadsto\>/  contained conceal 
                   match /\\left(/  contained conceal 
                   match /\\left\[/  contained conceal 
                   match /\\left\\{/  contained conceal 
                   match /\\leftarrow\>/  contained conceal 
                   match /\\Leftarrow\>/  contained conceal 
                   match /\\leftarrowtail\>/  contained conceal 
                   match /\\leftharpoondown\>/  contained conceal 
                   match /\\leftharpoonup\>/  contained conceal 
                   match /\\leftrightarrow\>/  contained conceal 
                   match /\\Leftrightarrow\>/  contained conceal 
                   match /\\leftrightsquigarrow\>/  contained conceal 
                   match /\\leftthreetimes\>/  contained conceal 
                   match /\\leq\>/  contained conceal 
                   match /\\leq\>/  contained conceal 
                   match /\\leqq\>/  contained conceal 
                   match /\\lessdot\>/  contained conceal 
                   match /\\lesseqgtr\>/  contained conceal 
                   match /\\lesssim\>/  contained conceal 
                   match /\\lfloor\>/  contained conceal 
                   match /\\ll\>/  contained conceal 
                   match /\\lmoustache\>/  contained conceal 
                   match /\\lneqq\>/  contained conceal 
                   match /\\lor\>/  contained conceal 
                   match /\\ltimes\>/  contained conceal 
                   match /\\mapsto\>/  contained conceal 
                   match /\\measuredangle\>/  contained conceal 
                   match /\\mid\>/  contained conceal 
                   match /\\models\>/  contained conceal 
                   match /\\mp\>/  contained conceal 
                   match /\\nabla\>/  contained conceal 
                   match /\\natural\>/  contained conceal 
                   match /\\ncong\>/  contained conceal 
                   match /\\ne\>/  contained conceal 
                   match /\\nearrow\>/  contained conceal 
                   match /\\neg\>/  contained conceal 
                   match /\\neq\>/  contained conceal 
                   match /\\nexists\>/  contained conceal 
                   match /\\ngeq\>/  contained conceal 
                   match /\\ngeqq\>/  contained conceal 
                   match /\\ngtr\>/  contained conceal 
                   match /\\ni\>/  contained conceal 
                   match /\\nleftarrow\>/  contained conceal 
                   match /\\nLeftarrow\>/  contained conceal 
                   match /\\nLeftrightarrow\>/  contained conceal 
                   match /\\nleq\>/  contained conceal 
                   match /\\nleqq\>/  contained conceal 
                   match /\\nless\>/  contained conceal 
                   match /\\nmid\>/  contained conceal 
                   match /\\notin\>/  contained conceal 
                   match /\\nparallel\>/  contained conceal 
                   match /\\nprec\>/  contained conceal 
                   match /\\nrightarrow\>/  contained conceal 
                   match /\\nRightarrow\>/  contained conceal 
                   match /\\nsim\>/  contained conceal 
                   match /\\nsucc\>/  contained conceal 
                   match /\\ntriangleleft\>/  contained conceal 
                   match /\\ntrianglelefteq\>/  contained conceal 
                   match /\\ntriangleright\>/  contained conceal 
                   match /\\ntrianglerighteq\>/  contained conceal 
                   match /\\nvdash\>/  contained conceal 
                   match /\\nvDash\>/  contained conceal 
                   match /\\nVdash\>/  contained conceal 
                   match /\\nwarrow\>/  contained conceal 
                   match /\\odot\>/  contained conceal 
                   match /\\oint\>/  contained conceal 
                   match /\\ominus\>/  contained conceal 
                   match /\\oplus\>/  contained conceal 
                   match /\\oslash\>/  contained conceal 
                   match /\\otimes\>/  contained conceal 
                   match /\\owns\>/  contained conceal 
                   match /\\P\>/  contained conceal 
                   match /\\parallel\>/  contained conceal 
                   match /\\partial\>/  contained conceal 
                   match /\\perp\>/  contained conceal 
                   match /\\pitchfork\>/  contained conceal 
                   match /\\pm\>/  contained conceal 
                   match /\\prec\>/  contained conceal 
                   match /\\precapprox\>/  contained conceal 
                   match /\\preccurlyeq\>/  contained conceal 
                   match /\\preceq\>/  contained conceal 
                   match /\\precnapprox\>/  contained conceal 
                   match /\\precneqq\>/  contained conceal 
                   match /\\precsim\>/  contained conceal 
                   match /\\prime\>/  contained conceal 
                   match /\\prod\>/  contained conceal 
                   match /\\propto\>/  contained conceal 
                   match /\\rceil\>/  contained conceal 
                   match /\\Re\>/  contained conceal 
                   match /\\rfloor\>/  contained conceal 
                   match /\\right)/  contained conceal 
                   match /\\right]/  contained conceal 
                   match /\\right\\}/  contained conceal 
                   match /\\rightarrow\>/  contained conceal 
                   match /\\Rightarrow\>/  contained conceal 
                   match /\\rightarrowtail\>/  contained conceal 
                   match /\\rightleftharpoons\>/  contained conceal 
                   match /\\rightsquigarrow\>/  contained conceal 
                   match /\\rightthreetimes\>/  contained conceal 
                   match /\\risingdotseq\>/  contained conceal 
                   match /\\rmoustache\>/  contained conceal 
                   match /\\rtimes\>/  contained conceal 
                   match /\\S\>/  contained conceal 
                   match /\\searrow\>/  contained conceal 
                   match /\\setminus\>/  contained conceal 
                   match /\\sharp\>/  contained conceal 
                   match /\\sim\>/  contained conceal 
                   match /\\simeq\>/  contained conceal 
                   match /\\smile\>/  contained conceal 
                   match /\\spadesuit\>/  contained conceal 
                   match /\\sphericalangle\>/  contained conceal 
                   match /\\sqcap\>/  contained conceal 
                   match /\\sqcup\>/  contained conceal 
                   match /\\sqsubset\>/  contained conceal 
                   match /\\sqsubseteq\>/  contained conceal 
                   match /\\sqsupset\>/  contained conceal 
                   match /\\sqsupseteq\>/  contained conceal 
                   match /\\star\>/  contained conceal 
                   match /\\subset\>/  contained conceal 
                   match /\\Subset\>/  contained conceal 
                   match /\\subseteq\>/  contained conceal 
                   match /\\subseteqq\>/  contained conceal 
                   match /\\subsetneq\>/  contained conceal 
                   match /\\subsetneqq\>/  contained conceal 
                   match /\\succ\>/  contained conceal 
                   match /\\succapprox\>/  contained conceal 
                   match /\\succcurlyeq\>/  contained conceal 
                   match /\\succeq\>/  contained conceal 
                   match /\\succnapprox\>/  contained conceal 
                   match /\\succneqq\>/  contained conceal 
                   match /\\succsim\>/  contained conceal 
                   match /\\sum\>/  contained conceal 
                   match /\\supset\>/  contained conceal 
                   match /\\Supset\>/  contained conceal 
                   match /\\supseteq\>/  contained conceal 
                   match /\\supseteqq\>/  contained conceal 
                   match /\\supsetneq\>/  contained conceal 
                   match /\\supsetneqq\>/  contained conceal 
                   match /\\surd\>/  contained conceal 
                   match /\\swarrow\>/  contained conceal 
                   match /\\therefore\>/  contained conceal 
                   match /\\times\>/  contained conceal 
                   match /\\to\>/  contained conceal 
                   match /\\top\>/  contained conceal 
                   match /\\triangle\>/  contained conceal 
                   match /\\triangleleft\>/  contained conceal 
                   match /\\trianglelefteq\>/  contained conceal 
                   match /\\triangleq\>/  contained conceal 
                   match /\\triangleright\>/  contained conceal 
                   match /\\trianglerighteq\>/  contained conceal 
                   match /\\twoheadleftarrow\>/  contained conceal 
                   match /\\twoheadrightarrow\>/  contained conceal 
                   match /\\ulcorner\>/  contained conceal 
                   match /\\uparrow\>/  contained conceal 
                   match /\\Uparrow\>/  contained conceal 
                   match /\\updownarrow\>/  contained conceal 
                   match /\\Updownarrow\>/  contained conceal 
                   match /\\urcorner\>/  contained conceal 
                   match /\\varnothing\>/  contained conceal 
                   match /\\vartriangle\>/  contained conceal 
                   match /\\vdash\>/  contained conceal 
                   match /\\vDash\>/  contained conceal 
                   match /\\Vdash\>/  contained conceal 
                   match /\\vdots\>/  contained conceal 
                   match /\\vee\>/  contained conceal 
                   match /\\veebar\>/  contained conceal 
                   match /\\Vvdash\>/  contained conceal 
                   match /\\wedge\>/  contained conceal 
                   match /\\wp\>/  contained conceal 
                   match /\\wr\>/  contained conceal 
                   match /\\right\\rangle\>/  contained conceal 
                   match /\\left\\langle\>/  contained conceal 
                   match /\\gg\>/  contained conceal 
                   match /\\ll\>/  contained conceal 
                   match /\\hat{a}/  contained conceal 
                   match /\\hat{A}/  contained conceal 
                   match /\\hat{c}/  contained conceal 
                   match /\\hat{C}/  contained conceal 
                   match /\\hat{e}/  contained conceal 
                   match /\\hat{E}/  contained conceal 
                   match /\\hat{g}/  contained conceal 
                   match /\\hat{G}/  contained conceal 
                   match /\\hat{i}/  contained conceal 
                   match /\\hat{I}/  contained conceal 
                   match /\\hat{o}/  contained conceal 
                   match /\\hat{O}/  contained conceal 
                   match /\\hat{s}/  contained conceal 
                   match /\\hat{S}/  contained conceal 
                   match /\\hat{u}/  contained conceal 
                   match /\\hat{U}/  contained conceal 
                   match /\\hat{w}/  contained conceal 
                   match /\\hat{W}/  contained conceal 
                   match /\\hat{y}/  contained conceal 
                   match /\\hat{Y}/  contained conceal 
                   links to texStatement
texMathText    xxx matchgroup=texStatement start=/\\\(\(inter\)\=text\|mbox\)\s*{/ end=/}/  contains=@texFoldGroup,@Spell 
texPartZone    xxx matchgroup=texSection start=/\\part\>/ end=/\ze\s*\\\%(part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@texPartGroup,@Spell 
texChapterZone xxx matchgroup=texSection start=/\\chapter\>/ end=/\ze\s*\\\%(chapter\>\|part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@texChapterGroup,@Spell 
texParaZone    xxx matchgroup=texSection start=/\\paragraph\>/ end=/\ze\s*\\\%(paragraph\>\|\%(sub\)*section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@texParaGroup,@Spell 
texSubSectionZone xxx matchgroup=texSection start=/\\subsection\>/ end=/\ze\s*\\\%(\%(sub\)\=section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@texSubSectionGroup,@Spell 
texSubSubSectionZone xxx matchgroup=texSection start=/\\subsubsection\>/ end=/\ze\s*\\\%(\%(sub\)\{,2}section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@texSubSubSectionGroup,@Spell 
texSubParaZone xxx matchgroup=texSection start=/\\subparagraph\>/ end=/\ze\s*\\\%(\%(sub\)\=paragraph\>\|\%(sub\)*section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)/  contains=@texFoldGroup,@Spell 
texGreek       xxx match /\\alpha\>/  contained conceal 
                   match /\\beta\>/  contained conceal 
                   match /\\gamma\>/  contained conceal 
                   match /\\delta\>/  contained conceal 
                   match /\\epsilon\>/  contained conceal 
                   match /\\varepsilon\>/  contained conceal 
                   match /\\zeta\>/  contained conceal 
                   match /\\eta\>/  contained conceal 
                   match /\\theta\>/  contained conceal 
                   match /\\vartheta\>/  contained conceal 
                   match /\\kappa\>/  contained conceal 
                   match /\\lambda\>/  contained conceal 
                   match /\\mu\>/  contained conceal 
                   match /\\nu\>/  contained conceal 
                   match /\\xi\>/  contained conceal 
                   match /\\pi\>/  contained conceal 
                   match /\\varpi\>/  contained conceal 
                   match /\\rho\>/  contained conceal 
                   match /\\varrho\>/  contained conceal 
                   match /\\sigma\>/  contained conceal 
                   match /\\varsigma\>/  contained conceal 
                   match /\\tau\>/  contained conceal 
                   match /\\upsilon\>/  contained conceal 
                   match /\\phi\>/  contained conceal 
                   match /\\varphi\>/  contained conceal 
                   match /\\chi\>/  contained conceal 
                   match /\\psi\>/  contained conceal 
                   match /\\omega\>/  contained conceal 
                   match /\\Gamma\>/  contained conceal 
                   match /\\Delta\>/  contained conceal 
                   match /\\Theta\>/  contained conceal 
                   match /\\Lambda\>/  contained conceal 
                   match /\\Xi\>/  contained conceal 
                   match /\\Pi\>/  contained conceal 
                   match /\\Sigma\>/  contained conceal 
                   match /\\Upsilon\>/  contained conceal 
                   match /\\Phi\>/  contained conceal 
                   match /\\Psi\>/  contained conceal 
                   match /\\Omega\>/  contained conceal 
                   links to texStatement
texSuperscript xxx matchgroup=Delimiter start=/\^{/ skip=/\\\\\|\\[{}]/ end=/}/  contained concealends contains=texSpecialChar,texSuperscripts,texStatement,texSubscript,texSuperscript,texMathMatcher 
                   match /\^0/  contained conceal 
                   match /\^1/  contained conceal 
                   match /\^2/  contained conceal 
                   match /\^3/  contained conceal 
                   match /\^4/  contained conceal 
                   match /\^5/  contained conceal 
                   match /\^6/  contained conceal 
                   match /\^7/  contained conceal 
                   match /\^8/  contained conceal 
                   match /\^9/  contained conceal 
                   match /\^a/  contained conceal 
                   match /\^b/  contained conceal 
                   match /\^c/  contained conceal 
                   match /\^d/  contained conceal 
                   match /\^e/  contained conceal 
                   match /\^f/  contained conceal 
                   match /\^g/  contained conceal 
                   match /\^h/  contained conceal 
                   match /\^i/  contained conceal 
                   match /\^j/  contained conceal 
                   match /\^k/  contained conceal 
                   match /\^l/  contained conceal 
                   match /\^m/  contained conceal 
                   match /\^n/  contained conceal 
                   match /\^o/  contained conceal 
                   match /\^p/  contained conceal 
                   match /\^r/  contained conceal 
                   match /\^s/  contained conceal 
                   match /\^t/  contained conceal 
                   match /\^u/  contained conceal 
                   match /\^v/  contained conceal 
                   match /\^w/  contained conceal 
                   match /\^x/  contained conceal 
                   match /\^y/  contained conceal 
                   match /\^z/  contained conceal 
                   match /\^A/  contained conceal 
                   match /\^B/  contained conceal 
                   match /\^D/  contained conceal 
                   match /\^E/  contained conceal 
                   match /\^G/  contained conceal 
                   match /\^H/  contained conceal 
                   match /\^I/  contained conceal 
                   match /\^J/  contained conceal 
                   match /\^K/  contained conceal 
                   match /\^L/  contained conceal 
                   match /\^M/  contained conceal 
                   match /\^N/  contained conceal 
                   match /\^O/  contained conceal 
                   match /\^P/  contained conceal 
                   match /\^R/  contained conceal 
                   match /\^T/  contained conceal 
                   match /\^U/  contained conceal 
                   match /\^W/  contained conceal 
                   match /\^,/  contained conceal 
                   match /\^:/  contained conceal 
                   match /\^;/  contained conceal 
                   match /\^+/  contained conceal 
                   match /\^-/  contained conceal 
                   match /\^</  contained conceal 
                   match /\^>/  contained conceal 
                   match +\^/+  contained conceal 
                   match /\^(/  contained conceal 
                   match /\^)/  contained conceal 
                   match /\^\./  contained conceal 
                   match /\^=/  contained conceal 
                   links to texStatement
texSubscript   xxx matchgroup=Delimiter start=/_{/ skip=/\\\\\|\\[{}]/ end=/}/  contained concealends contains=texSpecialChar,texSubscripts,texStatement,texSubscript,texSuperscript,texMathMatcher 
                   match /_0/  contained conceal 
                   match /_1/  contained conceal 
                   match /_2/  contained conceal 
                   match /_3/  contained conceal 
                   match /_4/  contained conceal 
                   match /_5/  contained conceal 
                   match /_6/  contained conceal 
                   match /_7/  contained conceal 
                   match /_8/  contained conceal 
                   match /_9/  contained conceal 
                   match /_a/  contained conceal 
                   match /_e/  contained conceal 
                   match /_h/  contained conceal 
                   match /_i/  contained conceal 
                   match /_j/  contained conceal 
                   match /_k/  contained conceal 
                   match /_l/  contained conceal 
                   match /_m/  contained conceal 
                   match /_n/  contained conceal 
                   match /_o/  contained conceal 
                   match /_p/  contained conceal 
                   match /_r/  contained conceal 
                   match /_s/  contained conceal 
                   match /_t/  contained conceal 
                   match /_u/  contained conceal 
                   match /_v/  contained conceal 
                   match /_x/  contained conceal 
                   match /_,/  contained conceal 
                   match /_+/  contained conceal 
                   match /_-/  contained conceal 
                   match +_/+  contained conceal 
                   match /_(/  contained conceal 
                   match /_)/  contained conceal 
                   match /_\./  contained conceal 
                   match /_r/  contained conceal 
                   match /_v/  contained conceal 
                   match /_x/  contained conceal 
                   match /_\\beta\>/  contained conceal 
                   match /_\\delta\>/  contained conceal 
                   match /_\\phi\>/  contained conceal 
                   match /_\\gamma\>/  contained conceal 
                   match /_\\chi\>/  contained conceal 
                   links to texStatement
texError       xxx match /[}\])]/  
                   match /\\\a*@[a-zA-Z@]*/  
                   links to Error
texBeginEndModifier xxx matchgroup=Delimiter start=/\[/ end=/]/  contained contains=texComment,@texMathZones,@NoSpell 
texDocTypeArgs xxx matchgroup=Delimiter start=/\[/ end=/]/  contained contains=texComment,@NoSpell nextgroup=texBeginEndName 
                   links to texCmdArgs
texStyle       xxx matchgroup=texStatement start=/\\makeatletter/ end=/\\makeatother/  contained contains=@texStyleGroup 
texInputCurlies xxx match /[{}]/  contained 
                   links to texDelimiter
texInputFileOpt xxx matchgroup=Delimiter start=/\[/ end=/\]/  contained contains=texComment 
                   links to texCmdArgs
texSpaceCodeChar xxx match /`\\\=.\(\^.\)\==\(\d\|\"\x\{1,6}\|`.\)/  contained 
                   links to Special
texDocZone     xxx matchgroup=texSection start=/\\begin\s*{\s*document\s*}/ end=/\\end\s*{\s*document\s*}/  contains=@texFoldGroup,@texDocGroup,@Spell 
                   matchgroup=texSection start=/^\s*%begin-include\>/ end=/^\s*%end-include\>/  contains=@texFoldGroup,@texDocGroup,@Spell 
texMathZoneA   xxx start=/\\begin\s*{\s*align\s*}/ end=/\\end\s*{\s*align\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneAS  xxx start=/\\begin\s*{\s*align\*\s*}/ end=/\\end\s*{\s*align\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneB   xxx start=/\\begin\s*{\s*alignat\s*}/ end=/\\end\s*{\s*alignat\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneBS  xxx start=/\\begin\s*{\s*alignat\*\s*}/ end=/\\end\s*{\s*alignat\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneC   xxx start=/\\begin\s*{\s*displaymath\s*}/ end=/\\end\s*{\s*displaymath\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneCS  xxx start=/\\begin\s*{\s*displaymath\*\s*}/ end=/\\end\s*{\s*displaymath\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneD   xxx start=/\\begin\s*{\s*eqnarray\s*}/ end=/\\end\s*{\s*eqnarray\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneDS  xxx start=/\\begin\s*{\s*eqnarray\*\s*}/ end=/\\end\s*{\s*eqnarray\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneE   xxx start=/\\begin\s*{\s*equation\s*}/ end=/\\end\s*{\s*equation\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneES  xxx start=/\\begin\s*{\s*equation\*\s*}/ end=/\\end\s*{\s*equation\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneF   xxx start=/\\begin\s*{\s*flalign\s*}/ end=/\\end\s*{\s*flalign\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneFS  xxx start=/\\begin\s*{\s*flalign\*\s*}/ end=/\\end\s*{\s*flalign\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneG   xxx start=/\\begin\s*{\s*gather\s*}/ end=/\\end\s*{\s*gather\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneGS  xxx start=/\\begin\s*{\s*gather\*\s*}/ end=/\\end\s*{\s*gather\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneH   xxx start=/\\begin\s*{\s*math\s*}/ end=/\\end\s*{\s*math\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneHS  xxx start=/\\begin\s*{\s*math\*\s*}/ end=/\\end\s*{\s*math\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneI   xxx start=/\\begin\s*{\s*multline\s*}/ end=/\\end\s*{\s*multline\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneIS  xxx start=/\\begin\s*{\s*multline\*\s*}/ end=/\\end\s*{\s*multline\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneJ   xxx start=/\\begin\s*{\s*xalignat\s*}/ end=/\\end\s*{\s*xalignat\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneJS  xxx start=/\\begin\s*{\s*xalignat\*\s*}/ end=/\\end\s*{\s*xalignat\*\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texMathZoneK   xxx start=/\\begin\s*{\s*xxalignat\s*}/ end=/\\end\s*{\s*xxalignat\s*}/  keepend contains=@texMathZoneGroup 
                   links to texMath
texTodo        xxx contained fixme xxx combak
                   contained todo
                   links to Todo
texRefOption   xxx matchgroup=Delimiter start=/\[/ end=/]/  contained contains=@texRefGroup,texRefZone nextgroup=texRefOption,texCite 
texCite        xxx matchgroup=Delimiter start=/{/ end=/}/  contained contains=@texRefGroup,texRefZone,texCite 
                   links to texRefZone
texCmdName     xxx matchgroup=Delimiter start=/{/rs=s+1 end=/}/  contained nextgroup=texCmdArgs,texCmdBody skipwhite skipnl 
                   links to Statement
texCmdArgs     xxx matchgroup=Delimiter start=/\[/rs=s+1 end=/]/  contained nextgroup=texCmdBody skipwhite skipnl 
                   links to Number
texEnvName     xxx matchgroup=Delimiter start=/{/rs=s+1 end=/}/  contained nextgroup=texEnvBgn skipwhite skipnl 
texEnvBgn      xxx matchgroup=Delimiter start=/{/rs=s+1 end=/}/  contained contains=@texEnvGroup nextgroup=texEnvEnd skipwhite skipnl 
texEnvEnd      xxx matchgroup=Delimiter start=/{/rs=s+1 end=/}/  contained contains=@texEnvGroup 
texDefName     xxx match /\\\a\+/  contained nextgroup=texDefParms,texCmdBody skipwhite skipnl 
                   match /\\\A/  contained nextgroup=texDefParms,texCmdBody skipwhite skipnl 
                   links to texDef
texDefParms    xxx match /#[^{]*/  contained contains=texDefParm nextgroup=texCmdBody skipwhite skipnl 
texSuperscripts xxx match /0/  contained conceal nextgroup=texSuperscripts 
                   match /1/  contained conceal nextgroup=texSuperscripts 
                   match /2/  contained conceal nextgroup=texSuperscripts 
                   match /3/  contained conceal nextgroup=texSuperscripts 
                   match /4/  contained conceal nextgroup=texSuperscripts 
                   match /5/  contained conceal nextgroup=texSuperscripts 
                   match /6/  contained conceal nextgroup=texSuperscripts 
                   match /7/  contained conceal nextgroup=texSuperscripts 
                   match /8/  contained conceal nextgroup=texSuperscripts 
                   match /9/  contained conceal nextgroup=texSuperscripts 
                   match /a/  contained conceal nextgroup=texSuperscripts 
                   match /b/  contained conceal nextgroup=texSuperscripts 
                   match /c/  contained conceal nextgroup=texSuperscripts 
                   match /d/  contained conceal nextgroup=texSuperscripts 
                   match /e/  contained conceal nextgroup=texSuperscripts 
                   match /f/  contained conceal nextgroup=texSuperscripts 
                   match /g/  contained conceal nextgroup=texSuperscripts 
                   match /h/  contained conceal nextgroup=texSuperscripts 
                   match /i/  contained conceal nextgroup=texSuperscripts 
                   match /j/  contained conceal nextgroup=texSuperscripts 
                   match /k/  contained conceal nextgroup=texSuperscripts 
                   match /l/  contained conceal nextgroup=texSuperscripts 
                   match /m/  contained conceal nextgroup=texSuperscripts 
                   match /n/  contained conceal nextgroup=texSuperscripts 
                   match /o/  contained conceal nextgroup=texSuperscripts 
                   match /p/  contained conceal nextgroup=texSuperscripts 
                   match /r/  contained conceal nextgroup=texSuperscripts 
                   match /s/  contained conceal nextgroup=texSuperscripts 
                   match /t/  contained conceal nextgroup=texSuperscripts 
                   match /u/  contained conceal nextgroup=texSuperscripts 
                   match /v/  contained conceal nextgroup=texSuperscripts 
                   match /w/  contained conceal nextgroup=texSuperscripts 
                   match /x/  contained conceal nextgroup=texSuperscripts 
                   match /y/  contained conceal nextgroup=texSuperscripts 
                   match /z/  contained conceal nextgroup=texSuperscripts 
                   match /A/  contained conceal nextgroup=texSuperscripts 
                   match /B/  contained conceal nextgroup=texSuperscripts 
                   match /D/  contained conceal nextgroup=texSuperscripts 
                   match /E/  contained conceal nextgroup=texSuperscripts 
                   match /G/  contained conceal nextgroup=texSuperscripts 
                   match /H/  contained conceal nextgroup=texSuperscripts 
                   match /I/  contained conceal nextgroup=texSuperscripts 
                   match /J/  contained conceal nextgroup=texSuperscripts 
                   match /K/  contained conceal nextgroup=texSuperscripts 
                   match /L/  contained conceal nextgroup=texSuperscripts 
                   match /M/  contained conceal nextgroup=texSuperscripts 
                   match /N/  contained conceal nextgroup=texSuperscripts 
                   match /O/  contained conceal nextgroup=texSuperscripts 
                   match /P/  contained conceal nextgroup=texSuperscripts 
                   match /R/  contained conceal nextgroup=texSuperscripts 
                   match /T/  contained conceal nextgroup=texSuperscripts 
                   match /U/  contained conceal nextgroup=texSuperscripts 
                   match /W/  contained conceal nextgroup=texSuperscripts 
                   match /,/  contained conceal nextgroup=texSuperscripts 
                   match /:/  contained conceal nextgroup=texSuperscripts 
                   match /;/  contained conceal nextgroup=texSuperscripts 
                   match /+/  contained conceal nextgroup=texSuperscripts 
                   match /-/  contained conceal nextgroup=texSuperscripts 
                   match /</  contained conceal nextgroup=texSuperscripts 
                   match />/  contained conceal nextgroup=texSuperscripts 
                   match +/+  contained conceal nextgroup=texSuperscripts 
                   match /(/  contained conceal nextgroup=texSuperscripts 
                   match /)/  contained conceal nextgroup=texSuperscripts 
                   match /\./  contained conceal nextgroup=texSuperscripts 
                   match /=/  contained conceal nextgroup=texSuperscripts 
                   links to texSuperscript
texSubscripts  xxx match /0/  contained conceal nextgroup=texSubscripts 
                   match /1/  contained conceal nextgroup=texSubscripts 
                   match /2/  contained conceal nextgroup=texSubscripts 
                   match /3/  contained conceal nextgroup=texSubscripts 
                   match /4/  contained conceal nextgroup=texSubscripts 
                   match /5/  contained conceal nextgroup=texSubscripts 
                   match /6/  contained conceal nextgroup=texSubscripts 
                   match /7/  contained conceal nextgroup=texSubscripts 
                   match /8/  contained conceal nextgroup=texSubscripts 
                   match /9/  contained conceal nextgroup=texSubscripts 
                   match /a/  contained conceal nextgroup=texSubscripts 
                   match /e/  contained conceal nextgroup=texSubscripts 
                   match /h/  contained conceal nextgroup=texSubscripts 
                   match /i/  contained conceal nextgroup=texSubscripts 
                   match /j/  contained conceal nextgroup=texSubscripts 
                   match /k/  contained conceal nextgroup=texSubscripts 
                   match /l/  contained conceal nextgroup=texSubscripts 
                   match /m/  contained conceal nextgroup=texSubscripts 
                   match /n/  contained conceal nextgroup=texSubscripts 
                   match /o/  contained conceal nextgroup=texSubscripts 
                   match /p/  contained conceal nextgroup=texSubscripts 
                   match /r/  contained conceal nextgroup=texSubscripts 
                   match /s/  contained conceal nextgroup=texSubscripts 
                   match /t/  contained conceal nextgroup=texSubscripts 
                   match /u/  contained conceal nextgroup=texSubscripts 
                   match /v/  contained conceal nextgroup=texSubscripts 
                   match /x/  contained conceal nextgroup=texSubscripts 
                   match /,/  contained conceal nextgroup=texSubscripts 
                   match /+/  contained conceal nextgroup=texSubscripts 
                   match /-/  contained conceal nextgroup=texSubscripts 
                   match +/+  contained conceal nextgroup=texSubscripts 
                   match /(/  contained conceal nextgroup=texSubscripts 
                   match /)/  contained conceal nextgroup=texSubscripts 
                   match /\./  contained conceal nextgroup=texSubscripts 
                   match /r/  contained conceal nextgroup=texSubscripts 
                   match /v/  contained conceal nextgroup=texSubscripts 
                   match /x/  contained conceal nextgroup=texSubscripts 
                   match /\\beta\>/  contained conceal nextgroup=texSubscripts 
                   match /\\delta\>/  contained conceal nextgroup=texSubscripts 
                   match /\\phi\>/  contained conceal nextgroup=texSubscripts 
                   match /\\gamma\>/  contained conceal nextgroup=texSubscripts 
                   match /\\chi\>/  contained conceal nextgroup=texSubscripts 
                   links to texSubscript
texCmdGroup    cluster=texCmdBody,texComment,texDefParm,texDelimiter,texDocType,texInput,texLength,texLigature,texMathDelim,texMathOper,texNewCmd,texNewEnv,texRefZone,texSection,texBeginEnd,texBeginEndName,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texMathError,@texMathZones 
texMathZones   cluster=texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texMathZoneA,texMathZoneAS,texMathZoneB,texMathZoneBS,texMathZoneC,texMathZoneCS,texMathZoneD,texMathZoneDS,texMathZoneE,texMathZoneES,texMathZoneF,texMathZoneFS,texMathZoneG,texMathZoneGS,texMathZoneH,texMathZoneHS,texMathZoneI,texMathZoneIS,texMathZoneJ,texMathZoneJS,texMathZoneK 
texEnvGroup    cluster=texMatcher,texMathDelim,texSpecialChar,texStatement 
texFoldGroup   cluster=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texBoldStyle,texItalStyle,texNoSpell 
texBoldGroup   cluster=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texBoldStyle,texBoldItalStyle,texNoSpell 
texItalGroup   cluster=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texItalStyle,texItalBoldStyle,texNoSpell 
texMatchGroup  cluster=texComment,texDelimiter,texDocType,texInput,texLength,texLigature,texNewCmd,texNewEnv,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texMatcher,texAccent,texBadMath,texDefCmd,texInputFile,texOnlyMath,texOption,texParen,texZone,@texMathZones,@Spell 
Spell          cluster=NONE
texMatchNMGroup cluster=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcherNM,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,@Spell 
texStyleGroup  cluster=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texStyleStatement,@Spell,texStyleMatcher 
texPreambleMatchGroup cluster=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcherNM,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTitle,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texMathZoneZ 
texRefGroup    cluster=texMatcher,texComment,texDelimiter 
texMathDelimGroup cluster=texMathDelimBad,texMathDelimKey,texMathDelimSet1,texMathDelimSet2 
texMathMatchGroup cluster=texComment,texDelimiter,texDocType,texInput,texLength,texLigature,texMathDelim,texMathOper,texNewCmd,texNewEnv,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texMathError,texDefCmd,texZone,texMathMatcher,texMathSymbol,texGreek,texSuperscript,texSubscript,@texMathZones 
texMathZoneGroup cluster=texComment,texDelimiter,texLength,texMathDelim,texMathOper,texRefZone,texSpecialChar,texStatement,texTypeSize,texTypeStyle,texMathError,texMathMatcher,texMathSymbol,texMathText,texGreek,texSuperscript,texSubscript,@NoSpell 
NoSpell        cluster=NONE
texDocGroup    cluster=texPartZone,@texPartGroup 
texPartGroup   cluster=texChapterZone,texSectionZone,texParaZone 
texChapterGroup cluster=texSectionZone,texParaZone 
texSectionGroup cluster=texSubSectionZone,texParaZone 
texSubSectionGroup cluster=texSubSubSectionZone,texParaZone 
texSubSubSectionGroup cluster=texParaZone 
texParaGroup   cluster=texSubParaZone 
texCommentGroup cluster=texTodo,@Spell 
