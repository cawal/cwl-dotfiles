

--- Elementos de sintaxe ---
javaFold       xxx start=/{/ end=/}/  transparent fold 
javaError      xxx const goto
                   match /[\\@`]/  
                   match +<<<\|\.\.\|=>\|||=\|&&=\|\*\/+  
                   links to Error
javaOK         xxx match /\.\.\./  
javaError2     xxx match /#\|=</  
                   links to javaError
javaExternal   xxx native package
                   match /\<import\>\(\s\+static\>\)\?/  
                   links to Include
javaConditional xxx if else switch
                   links to Conditional
javaRepeat     xxx do for while
                   links to Repeat
javaBoolean    xxx true false
                   links to Boolean
javaConstant   xxx null
                   links to Constant
javaTypedef    xxx this super
                   match /\.\s*\<class\>/ms=s+1  
                   links to Typedef
javaOperator   xxx new instanceof
                   links to Operator
javaType       xxx float boolean long void
                   double short char byte int
                   links to Type
javaStatement  xxx return
                   links to Statement
javaStorageClass xxx transient strictfp
                   serializable synchronized
                   static final volatile
                   links to StorageClass
javaExceptions xxx finally catch try throw
                   links to Exception
javaAssert     xxx assert
                   links to Statement
javaMethodDecl xxx synchronized throws
                   links to javaStorageClass
javaClassDecl  xxx interface implements enum
                   extends
                   match /^class\>/  
                   match /[^.]\s*\<class\>/ms=s+1  
                   match /@interface\>/  
                   links to javaStorageClass
javaString     xxx start=/"/ end=/$/ end=/"/  contains=javaSpecialChar,javaSpecialError,@Spell 
                   links to String
javaAnnotation xxx match /@\([_$a-zA-Z][_$a-zA-Z0-9]*\.\)*[_$a-zA-Z][_$a-zA-Z0-9]*\>\(([^)]*)\)\=/  contains=javaString 
                   links to PreProc
javaBranch     xxx nextgroup=javaUserLabelRef  skipwhite continue
                   nextgroup=javaUserLabelRef  skipwhite break
                   links to Conditional
javaUserLabelRef xxx match /\k\+/  contained 
                   links to javaUserLabel
javaVarArg     xxx match /\.\.\./  
                   links to Function
javaScopeDecl  xxx protected public private
                   abstract
                   links to javaStorageClass
javaLabel      xxx default
                   links to Label
javaNumber     xxx match /\<\(0[bB][0-1]\+\|0[0-7]*\|0[xX]\x\+\|\d\(\d\|_\d\)*\)[lL]\=\>/  
                   match /\(\<\d\(\d\|_\d\)*\.\(\d\(\d\|_\d\)*\)\=\|\.\d\(\d\|_\d\)*\)\([eE][-+]\=\d\(\d\|_\d\)*\)\=[fFdD]\=/  
                   match /\<\d\(\d\|_\d\)*[eE][-+]\=\d\(\d\|_\d\)*[fFdD]\=\>/  
                   match /\<\d\(\d\|_\d\)*\([eE][-+]\=\d\(\d\|_\d\)*\)\=[fFdD]\>/  
                   links to Number
javaCharacter  xxx match /'[^']*'/  contains=javaSpecialChar,javaSpecialCharError 
                   match /'\\''/  contains=javaSpecialChar 
                   match /'[^\\]'/  
                   links to Character
javaLabelRegion xxx matchgroup=javaLabel start=/\<case\>/ matchgroup=NONE end=/:/  transparent contains=javaNumber,javaCharacter,javaString 
javaUserLabel  xxx match /^\s*[_$a-zA-Z][_$a-zA-Z0-9_]*\s*:/he=e-1  contains=javaLabel 
                   links to Label
javaTodo       xxx contained TODO XXX FIXME
                   links to Todo
javaSpecial    xxx match /\\u\d\{4\}/  
                   links to Special
javaCommentStar xxx match +^\s*\*[^/]+me=e-1  contained 
                   match /^\s*\*$/  contained 
                   links to javaComment
javaSpecialChar xxx match /\\\([4-9]\d\|[0-3]\d\d\|[\"\\'ntbrf]\|u\x\{4\}\)/  contained 
                   links to SpecialChar
javaComment    xxx start=+/\*+ end=+\*/+  contains=@javaCommentSpecial,javaTodo,@Spell 
                   match +/\*\*/+  
                   links to Comment
javaLineComment xxx match +//.*+  contains=@javaCommentSpecial2,javaTodo,@Spell 
                   links to Comment
htmlError      xxx match /[<>&]/  contained 
                   links to Error
htmlSpecialChar xxx match /&#\=[0-9A-Za-z]\{1,8};/  contained 
                   links to Special
htmlString     xxx start=/"/ end=/"/  contained contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc 
                   start=/'/ end=/'/  contained contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc 
                   links to String
htmlValue      xxx match /=[\t ]*[^'" \t>][^ \t>]*/hs=s+1  contained contains=javaScriptExpression,@htmlPreproc 
                   links to String
htmlTagN       xxx match /<\s*[-a-zA-Z0-9]\+/hs=s+1  contained contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster 
                   match =</\s*[-a-zA-Z0-9]\+=hs=s+2  contained contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster 
htmlTagError   xxx match /[^>]</ms=s+1  contained 
                   links to htmlError
htmlEndTag     xxx start=+</+ end=/>/  contained contains=htmlTagN,htmlTagError 
                   links to Identifier
htmlArg        xxx contained below color list
                   contained name gutter span
                   contained async placeholder
                   contained noresize alt
                   contained marginheight target
                   contained contenteditable
                   contained rows srcdoc optimum
                   contained bgcolor ismap
                   contained cellspacing object
                   contained method autofocus
                   contained frame noshade data
                   contained for bordercolor
                   contained accept minlength
                   contained rowspan contextmenu
                   contained high dropzone defer
                   contained cellpadding shape
                   contained inputmode usemap
                   contained rules sandbox
                   contained multiple start
                   contained selected language
                   contained summary hspace
                   contained lowsrc icon
                   contained controls min type
                   contained valign default loop
                   contained hreflang sizes
                   contained classid scheme
                   contained formnovalidate
                   contained class visibility
                   contained checked srcset
                   contained pagex pagey title
                   contained srclang headers
                   contained scrolling
                   contained crossorigin clear
                   contained charset novalidate
                   contained allowfullscreen id
                   contained id declare codebase
                   contained muted formaction
                   contained nonce standby
                   contained version link
                   contained profile clip max
                   contained autoplay coords
                   contained compact pattern
                   contained background vspace
                   contained tabindex width
                   contained alink marginwidth
                   contained above reversed
                   contained content border
                   contained poster maxlength
                   contained prompt dir
                   contained typemustmatch value
                   contained challenge charoff
                   contained hidden formtarget
                   contained height translate
                   contained draggable longdesc
                   contained nowrap step
                   contained accesskey cols cite
                   contained rel formmethod rev
                   contained style keytype
                   contained codetype download
                   contained form size src axis
                   contained vlink valuetype
                   contained colspan nohref face
                   contained lang frameborder
                   contained dirname enctype
                   contained wrap top readonly
                   contained action spellcheck
                   contained left text
                   contained autocomplete url
                   contained char align scope
                   contained code disabled abbr
                   contained radiogroup preload
                   contained open required low
                   contained kind datetime
                   contained formenctype archive
                   match /\<\(http-equiv\|href\|title\)=/me=e-1  contained 
                   match /\<z-index\>/  contained 
                   match /\<\(accept-charset\|label\)\>/  contained 
                   links to Type
htmlTag        xxx start=+<[^/]+ end=/>/  contained fold contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent,htmlCssDefinition,@htmlPreproc,@htmlArgCluster 
                   links to Function
htmlTagName    xxx contained marquee hgroup span
                   contained meter ol embed
                   contained thead pre blink
                   contained tbody a p q s
                   contained object legend
                   contained details frame
                   contained acronym noframes
                   contained blockquote canvas
                   contained section data var
                   contained table rtc input hr
                   contained button bdi output
                   contained bdo font caption
                   contained sub sup col
                   contained basefont xmp iframe
                   contained rb rp rt dfn mark
                   contained html meta datalist
                   contained nobr template wbr
                   contained optgroup option
                   contained keygen main applet
                   contained nav link map li
                   contained fieldset td th tr
                   contained audio tt figcaption
                   contained param center slot
                   contained area address small
                   contained frameset label
                   contained video article time
                   contained footer ul dir div
                   contained aside kbd source
                   contained cite big figure
                   contained header layer
                   contained colgroup form
                   contained textarea base tfoot
                   contained br samp ruby
                   contained menuitem select
                   contained menu img picture
                   contained nolayer spacer
                   contained progress ilayer
                   contained code abbr isindex
                   contained track dd ins dl dt
                   contained noscript
                   match /\<\(b\|i\|u\|h[1-6]\|em\|strong\|head\|body\|title\)\>/  contained 
                   links to htmlStatement
htmlSpecialTagName xxx contained script style
                   links to Exception
htmlCommentPart xxx start=/--/ end=/--\s*/  contained contains=@htmlPreproc,@Spell 
                   links to Comment
htmlCommentError xxx match /[^><!]/  contained 
                   links to htmlError
htmlComment    xxx start=/<!/ end=/>/  contained contains=htmlCommentPart,htmlCommentError,@Spell 
                   start=/<!DOCTYPE/ end=/>/  contained keepend 
                   links to Comment
htmlPreStmt    xxx match /<!--#\(config\|echo\|exec\|fsize\|flastmod\|include\|printenv\|set\|if\|elif\|else\|endif\|geoguide\)\>/  contained 
                   links to PreProc
htmlPreError   xxx match /<!--#\S*/ms=s+4  contained 
                   links to Error
htmlPreAttr    xxx match /\w\+=[^"]\S\+/  contained contains=htmlPreProcAttrError,htmlPreProcAttrName 
                   start=/\w\+="/ skip=/\\\\\|\\"/ end=/"/  contained keepend contains=htmlPreProcAttrName 
                   links to String
htmlPreProc    xxx start=/<!--#/ end=/-->/  contained contains=htmlPreStmt,htmlPreError,htmlPreAttr 
                   links to PreProc
htmlPreProcAttrError xxx match /\w\+=/he=e-1  contained 
                   links to Error
htmlPreProcAttrName xxx match /\(expr\|errmsg\|sizefmt\|timefmt\|var\|cgi\|cmd\|file\|virtual\|value\)=/he=e-1  contained 
                   links to PreProc
htmlLink       xxx start=/<a\>\_[^>]*\<href\>/ end=+</a>+me=e-4  contained contains=@Spell,htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,htmlLeadingSpace,javaScript,@htmlPreproc 
                   links to Underlined
htmlStrike     xxx start=/<del\>/ end=+</del>+me=e-6  contained contains=@htmlTop 
                   start=/<strike\>/ end=+</strike>+me=e-9  contained contains=@htmlTop 
htmlBoldUnderline xxx start=/<u\>/ end=+</u>+me=e-4  contained contains=@htmlTop,htmlBoldUnderlineItalic 
htmlBoldItalic xxx start=/<i\>/ end=+</i>+me=e-4  contained contains=@htmlTop,htmlBoldItalicUnderline 
                   start=/<em\>/ end=+</em>+me=e-5  contained contains=@htmlTop,htmlBoldItalicUnderline 
htmlBold       xxx start=/<b\>/ end=+</b>+me=e-4  contained contains=@htmlTop,htmlBoldUnderline,htmlBoldItalic 
                   start=/<strong\>/ end=+</strong>+me=e-9  contained contains=@htmlTop,htmlBoldUnderline,htmlBoldItalic 
htmlBoldUnderlineItalic xxx start=/<i\>/ end=+</i>+me=e-4  contained contains=@htmlTop 
                   start=/<em\>/ end=+</em>+me=e-5  contained contains=@htmlTop 
htmlBoldItalicUnderline xxx start=/<u\>/ end=+</u>+me=e-4  contained contains=@htmlTop,htmlBoldUnderlineItalic 
                   links to htmlBoldUnderlineItalic
htmlUnderlineBold xxx start=/<b\>/ end=+</b>+me=e-4  contained contains=@htmlTop,htmlUnderlineBoldItalic 
                   start=/<strong\>/ end=+</strong>+me=e-9  contained contains=@htmlTop,htmlUnderlineBoldItalic 
                   links to htmlBoldUnderline
htmlUnderlineItalic xxx start=/<i\>/ end=+</i>+me=e-4  contained contains=@htmlTop,htmlUnderlineItalicBold 
                   start=/<em\>/ end=+</em>+me=e-5  contained contains=@htmlTop,htmlUnderlineItalicBold 
htmlUnderline  xxx start=/<u\>/ end=+</u>+me=e-4  contained contains=@htmlTop,htmlUnderlineBold,htmlUnderlineItalic 
htmlUnderlineBoldItalic xxx start=/<i\>/ end=+</i>+me=e-4  contained contains=@htmlTop 
                   start=/<em\>/ end=+</em>+me=e-5  contained contains=@htmlTop 
                   links to htmlBoldUnderlineItalic
htmlUnderlineItalicBold xxx start=/<b\>/ end=+</b>+me=e-4  contained contains=@htmlTop 
                   start=/<strong\>/ end=+</strong>+me=e-9  contained contains=@htmlTop 
                   links to htmlBoldUnderlineItalic
htmlItalicBold xxx start=/<b\>/ end=+</b>+me=e-4  contained contains=@htmlTop,htmlItalicBoldUnderline 
                   start=/<strong\>/ end=+</strong>+me=e-9  contained contains=@htmlTop,htmlItalicBoldUnderline 
                   links to htmlBoldItalic
htmlItalicUnderline xxx start=/<u\>/ end=+</u>+me=e-4  contained contains=@htmlTop,htmlItalicUnderlineBold 
                   links to htmlUnderlineItalic
htmlItalic     xxx start=/<i\>/ end=+</i>+me=e-4  contained contains=@htmlTop,htmlItalicBold,htmlItalicUnderline 
                   start=/<em\>/ end=+</em>+me=e-5  contained contains=@htmlTop 
htmlItalicBoldUnderline xxx start=/<u\>/ end=+</u>+me=e-4  contained contains=@htmlTop 
                   links to htmlBoldUnderlineItalic
htmlItalicUnderlineBold xxx start=/<b\>/ end=+</b>+me=e-4  contained contains=@htmlTop 
                   start=/<strong\>/ end=+</strong>+me=e-9  contained contains=@htmlTop 
                   links to htmlBoldUnderlineItalic
htmlLeadingSpace xxx match /^\s\+/  contained 
                   links to None
htmlH1         xxx start=/<h1\>/ end=+</h1>+me=e-5  contained contains=@htmlTop 
                   links to Title
htmlH2         xxx start=/<h2\>/ end=+</h2>+me=e-5  contained contains=@htmlTop 
                   links to htmlH1
htmlH3         xxx start=/<h3\>/ end=+</h3>+me=e-5  contained contains=@htmlTop 
                   links to htmlH2
htmlH4         xxx start=/<h4\>/ end=+</h4>+me=e-5  contained contains=@htmlTop 
                   links to htmlH3
htmlH5         xxx start=/<h5\>/ end=+</h5>+me=e-5  contained contains=@htmlTop 
                   links to htmlH4
htmlH6         xxx start=/<h6\>/ end=+</h6>+me=e-5  contained contains=@htmlTop 
                   links to htmlH5
htmlTitle      xxx start=/<title\>/ end=+</title>+me=e-8  contained contains=htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,javaScript,@htmlPreproc 
                   links to Title
htmlHead       xxx start=/<head\>/ end=/<h[1-6]\>/me=e-3 end=/<body\>/me=e-5 end=+</head>+me=e-7  contained contains=htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,htmlLink,htmlTitle,javaScript,cssStyle,@htmlPreproc 
                   links to PreProc
javaCommentTitle xxx matchgroup=javaDocComment start=+/\*\*+ matchgroup=javaCommentTitle end=+\*/+me=s-1,he=s-1 end=/[^{]@/me=s-2,he=s-1 end=/\.[ \t\r<&]/me=e-1 end=/\.$/  contained keepend contains=@javaHtml,javaCommentStar,javaTodo,@Spell,javaDocTags,javaDocSeeTag 
                   links to SpecialComment
javaDocTags    xxx start=/{@\(code\|link\|linkplain\|inherit[Dd]oc\|doc[rR]oot\|value\)/ end=/}/  contained 
                   match /@\(param\|exception\|throws\|since\)\s\+\S\+/  contained contains=javaDocParam 
                   match /@\(version\|author\|return\|deprecated\|serial\|serialField\|serialData\)\>/  contained 
                   links to Special
javaDocSeeTag  xxx matchgroup=javaDocTags start=/@see\s\+/ matchgroup=NONE end=/\_./re=e-1  contained contains=javaDocSeeTagParam 
javaDocComment xxx start=+/\*\*+ end=+\*/+  keepend contains=javaCommentTitle,@javaHtml,javaDocTags,javaDocSeeTag,javaTodo,@Spell 
                   links to Comment
javaDocParam   xxx match /\s\S\+/  contained 
                   links to Function
javaDocSeeTagParam xxx match @"\_[^"]\+"\|<a\s\+\_.\{-}</a>\|\(\k\|\.\)*\(#\k\+\((\_[^)]\+)\)\=\)\=@  contained extend 
                   links to Function
javaSpecialError xxx match /\\./  contained 
                   links to Error
javaSpecialCharError xxx match /[^']/  contained 
                   links to Error
javaParenT1    xxx matchgroup=javaParen1 start=/(/ end=/)/  contained transparent contains=@javaTop,javaParenT2 
                   matchgroup=javaParen1 start=/\[/ end=/\]/  contained transparent contains=@javaTop,javaParenT2 
javaParenT     xxx matchgroup=javaParen start=/(/ end=/)/  transparent contains=@javaTop,javaParenT1 
                   matchgroup=javaParen start=/\[/ end=/\]/  transparent contains=@javaTop,javaParenT1 
javaParenT2    xxx matchgroup=javaParen2 start=/(/ end=/)/  contained transparent contains=@javaTop,javaParenT 
                   matchgroup=javaParen2 start=/\[/ end=/\]/  contained transparent contains=@javaTop,javaParenT 
javaParenError xxx match /)/  
                   match /\]/  
                   links to javaError
javaTop        cluster=javaError,javaError,javaError,javaError2,javaExternal,javaConditional,javaRepeat,javaBoolean,javaConstant,javaTypedef,javaOperator,javaType,javaType,javaStatement,javaStorageClass,javaExceptions,javaAssert,javaMethodDecl,javaClassDecl,javaClassDecl,javaClassDecl,javaString,javaAnnotation,javaBranch,javaVarArg,javaScopeDecl,javaLangObject,javaLabel,javaNumber,javaCharacter,javaLabelRegion,javaUserLabel,javaSpecial,javaComment,javaLineComment,javaStringError 
Spell          cluster=NONE
javaCommentSpecial cluster=NONE
javaCommentSpecial2 cluster=NONE
javaHtml       cluster=htmlError,htmlSpecialChar,htmlEndTag,htmlTag,htmlComment,htmlPreProc,htmlLink,htmlStrike,htmlBold,htmlUnderline,htmlItalic,htmlH1,htmlH2,htmlH3,htmlH4,htmlH5,htmlH6,htmlTitle,htmlHead 
htmlPreproc    cluster=NONE
htmlArgCluster cluster=NONE
htmlTagNameCluster cluster=NONE
htmlTop        cluster=@Spell,htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,htmlLink,javaScript,@htmlPreproc 
htmlJavaScript cluster=@htmlPreproc 
htmlVbScript   cluster=NONE
htmlCss        cluster=NONE
javaClasses    cluster=NONE

E475: Argumento inválido: 
