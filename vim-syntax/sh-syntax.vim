

--- Elementos de sintaxe ---
shDoError      xxx match /\<done\>/  
                   links to Error
shIfError      xxx match /\<fi\>/  
                   links to Error
shInError      xxx match /\<in\>/  
                   links to Error
shCaseError    xxx match /;;/  
                   links to Error
shEsacError    xxx match /\<esac\>/  
                   links to Error
shCurlyError   xxx match /}/  
                   links to Error
shParenError   xxx match /)/  
                   links to Error
shTestError    xxx match /]/  
                   links to Error
shOK           xxx match /\.\(done\|fi\|in\|esac\)/  
shArithmetic   xxx matchgroup=shArithRegion start=/\$((/ skip=/\\\\\|\\./ end=/))/  contains=@shArithList 
                   matchgroup=shArithRegion start=/\$\[/ skip=/\\\\\|\\./ end=/\]/  contains=@shArithList 
                   links to Special
shCaseEsac     xxx matchgroup=shConditional start=/\<case\>/ end=/\<esac\>/  contains=@shCaseEsacList 
shComment      xxx match /^\s*\zs#.*$/  contains=@shCommentGroup 
                   match /\s\zs#.*$/  contains=@shCommentGroup 
                   match /#.*$/  contained contains=@shCommentGroup 
                   links to Comment
shDeref        xxx matchgroup=PreProc start=/\${/ end=/}/  contains=@shDerefList,shDerefVarArray 
                   links to shShellVariables
shDo           xxx matchgroup=shConditional start=/\<do\>/ end=/\<done\>/  transparent contains=@shLoopList 
shDerefSimple  xxx match /\$\%(\h\w*\|\d\)/  nextgroup=@shNoZSList 
                   match /\$[-#*@!?]/  nextgroup=@shNoZSList 
                   match /\$\$/  nextgroup=@shNoZSList 
                   match /\${\d}/  nextgroup=@shNoZSList 
                   links to shDeref
shEcho         xxx matchgroup=shStatement start=/\<echo\>/ skip=/\\$/ matchgroup=NONE end=/\s#/me=e-2 end=/\d[<>]/me=e-2 end=/[<>;&|()`]/me=e-1 matchgroup=shEchoDelim end=/$/  contains=@shEchoList nextgroup=shQuickComment skipwhite 
                   matchgroup=shStatement start=/\<print\>/ skip=/\\$/ matchgroup=NONE end=/\s#/me=e-2 end=/\d[<>]/me=e-2 end=/[<>;&|()`]/me=e-1 matchgroup=shEchoDelim end=/$/  contains=@shEchoList nextgroup=shQuickComment skipwhite 
                   links to shString
shEscape       xxx match /\%(^\)\@!\%(\\\\\)*\\./  contained 
                   links to shCommandSub
shNumber       xxx match /\<\d\+\>#\=/  
                   match /\<-\=\.\=\d\+\>#\=/  
                   links to Number
shOperator     xxx match /<<\|>>/  contained 
                   match /[!&;|]/  contained 
                   match /\[[[^:]\|\]]/  contained 
                   match #[-=/*+%]\==#  nextgroup=shPattern skipwhite 
                   links to Operator
shExSingleQuote xxx matchgroup=Error start=/\$'/ skip=/\\\\\|\\./ end=/'/  contains=shStringSpecial 
                   links to shSingleQuote
shExDoubleQuote xxx matchgroup=Error start=/\$"/ skip=/\\\\\|\\./ end=/"/  contains=shStringSpecial 
                   links to shDoubleQuote
shRedir        xxx match /\d\=>\(&[-0-9]\)\=/  
                   match /\d\=>>-\=/  
                   match /\d\=<\(&[-0-9]\)\=/  
                   match /\d<<-\=/  
                   links to shOperator
shSingleQuote  xxx matchgroup=shQuote start=/'/ end=/'/  contains=@Spell 
                   links to shString
shDoubleQuote  xxx matchgroup=shQuote start=/\%(\%(\\\\\)*\\\)\@<!"/ skip=/\\"/ end=/"/  contains=@shDblQuoteList,shStringSpecial,@Spell 
                   links to shString
shStatement    xxx umask pwd exit newgrp test
                   wait readonly break continue
                   chdir ulimit exec return eval
                   read kill cd trap shift
                   links to Statement
shVariable     xxx match /\<\([bwglsav]:\)\=[a-zA-Z0-9.!@_%+,]*\ze=/  nextgroup=shVarAssign 
                   links to shSetList
shTest         xxx matchgroup=shStatement start=/\<test\s/ skip=/\\\\\|\\$/ matchgroup=NONE end=/$/ end=/[;&|]/me=e-1  transparent contains=@shExprList1 
shCtrlSeq      xxx match /\\\d\d\d\|\\[abcfnrtv0]/  contained 
                   links to Special
shSpecial      xxx match /[^\\]\zs\%(\\\\\)*\\[\\"'`$()#]/  nextgroup=shBkslshSnglQuote,shBkslshDblQuote,@shNoZSList 
                   match /^\%(\\\\\)*\\[\\"'`$()#]/  
                   links to Special
shParen        xxx matchgroup=shArithRegion start=/\$\@!(\%(\ze[^(]\|$\)/ end=/)/  contains=@shArithParenList 
                   links to shArithmetic
shIf           xxx matchgroup=shConditional start=/\<if\_s/ skip=/-fi\>/ end=/\<fi\>/ end=/\<;\_s*then\>/  transparent contains=@shIfList 
shFor          xxx matchgroup=shLoop start=/\<for\ze\_s\s*\%(((\)\@!/ end=/\<do\>/me=e-2 end=/\<in\>/  contains=@shLoopList,shDblParen nextgroup=shCurlyIn skipwhite 
shCaseStart    xxx match /(/  contained nextgroup=shCase,shCaseBar skipwhite skipnl 
                   links to shConditional
shCase         xxx matchgroup=shSnglCase start=/\%(\\.\|[^#$()'" \t]\)\{-}\zs)/ end=/esac/me=s-1 end=/;;/  contained contains=@shCaseList nextgroup=shCaseStart,shCase,shComment skipwhite skipnl 
shCaseBar      xxx match /\(^\|[^\\]\)\(\\\\\)*\zs|/  contained nextgroup=shCase,shCaseStart,shCaseBar,shComment,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote skipwhite 
                   links to shConditional
shCaseIn       xxx contained nextgroup=shCase,shCaseStart,shCaseBar,shComment,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote  skipnl skipwhite in
                   links to shConditional
shCaseCommandSub xxx start=/`/ skip=/\\\\\|\\./ end=/`/  contained contains=@shCommandSubList nextgroup=shCaseBar skipwhite skipnl 
                   links to shCommandSub
shCaseExSingleQuote xxx matchgroup=Error start=/\$'/ skip=/\\\\\|\\./ end=/'/  contained contains=shStringSpecial nextgroup=shCaseBar skipwhite skipnl 
shCaseSingleQuote xxx matchgroup=shQuote start=/'/ end=/'/  contained contains=shStringSpecial nextgroup=shCaseBar skipwhite skipnl 
                   links to shSingleQuote
shCaseDoubleQuote xxx matchgroup=shQuote start=/"/ skip=/\\\\\|\\./ end=/"/  contained contains=@shDblQuoteList,shStringSpecial nextgroup=shCaseBar skipwhite skipnl 
                   links to shDoubleQuote
shStringSpecial xxx match /[^[:print:] \t]/  contained 
                   match /[^\\]\zs\%(\\\\\)*\\[\\"'`$()#]/  
                   links to shSpecial
shCaseRange    xxx matchgroup=Delimiter start=/\[/ skip=/\\\\/ end=/\]/  contained 
shCommandSub   xxx start=/`/ skip=/\\\\\|\\./ end=/`/  contains=@shCommandSubList 
                   matchgroup=shCmdSubRegion start=/\$(/ skip=/\\\\\|\\./ end=/)/  contains=@shCommandSubList 
                   links to Special
shExpr         xxx matchgroup=shExprRegion start=/{/ end=/}/  transparent contains=@shExprList2 nextgroup=shSpecialNxt 
                   matchgroup=shRange start=/\[/ skip=/\\\\\|\\$\|\[/ end=/\]/  contains=@shTestList,shSpecial 
shHereDoc      xxx matchgroup=shHereDoc01 start=/<<\s*\\\=\z([^ \t|>]\+\)/ end=/^\z1\s*$/  contains=@shDblQuoteList 
                   matchgroup=shHereDoc02 start=/<<\s*\"\z([^ \t|>]\+\)\"/ end=/^\z1\s*$/  
                   matchgroup=shHereDoc03 start=/<<-\s*\z([^ \t|>]\+\)/ end=/^\s*\z1\s*$/  contains=@shDblQuoteList 
                   matchgroup=shHereDoc04 start=/<<-\s*'\z([^']\+\)'/ end=/^\s*\z1\s*$/  
                   matchgroup=shHereDoc05 start=/<<\s*'\z([^']\+\)'/ end=/^\z1\s*$/  
                   matchgroup=shHereDoc06 start=/<<-\s*\"\z([^ \t|>]\+\)\"/ end=/^\s*\z1\s*$/  
                   matchgroup=shHereDoc07 start=/<<\s*\\\_$\_s*\z([^ \t|>]\+\)/ end=/^\z1\s*$/  contains=@shDblQuoteList 
                   matchgroup=shHereDoc08 start=/<<\s*\\\_$\_s*'\z([^ \t|>]\+\)'/ end=/^\z1\s*$/  
                   matchgroup=shHereDoc09 start=/<<\s*\\\_$\_s*\"\z([^ \t|>]\+\)\"/ end=/^\z1\s*$/  
                   matchgroup=shHereDoc10 start=/<<-\s*\\\_$\_s*\z([^ \t|>]\+\)/ end=/^\s*\z1\s*$/  
                   matchgroup=shHereDoc11 start=/<<-\s*\\\_$\_s*\\\z([^ \t|>]\+\)/ end=/^\s*\z1\s*$/  
                   matchgroup=shHereDoc12 start=/<<-\s*\\\_$\_s*'\z([^ \t|>]\+\)'/ end=/^\s*\z1\s*$/  
                   matchgroup=shHereDoc13 start=/<<-\s*\\\_$\_s*\"\z([^ \t|>]\+\)\"/ end=/^\s*\z1\s*$/  
                   matchgroup=shHereDoc14 start=/<<\\\z([^ \t|>]\+\)/ end=/^\z1\s*$/  
                   matchgroup=shHereDoc15 start=/<<-\s*\\\z([^ \t|>]\+\)/ end=/^\s*\z1\s*$/  
                   links to shString
shSetList      xxx matchgroup=shSet start=+\<\(set\|export\|unset\)\>\ze[^/]+ matchgroup=NONE end=/\ze\s\+[#=]/ matchgroup=shSetListDelim end=/\ze[}|);&]/ matchgroup=shSet end=/$/  oneline contains=@shIdList 
                   links to Identifier
shSource       xxx match /^\.\s/  
                   match /\s\.\s/  
                   links to shOperator
shCmdParenRegion xxx matchgroup=shCmdSubRegion start=/(\ze[^(]/ skip=/\\\\\|\\./ end=/)/  contains=@shCommandSubList 
shOption       xxx match /\s\zs[-+][-_a-zA-Z#@]\+/  
                   match /\s\zs--[^ \t$`'"|);]\+/  
                   links to shCommandSub
shSubSh        xxx matchgroup=shSubShRegion start=/[^(]\zs(/ end=/)/  transparent contains=@shSubShList nextgroup=shSpecialNxt 
shComma        xxx match /,/  contained 
shDerefSpecial xxx match /{\@<=[-*@?0]/  contained nextgroup=shDerefOp,shDerefOpError 
                   match /\({[#!]\)\@<=[[:alnum:]*@_]\+/  contained nextgroup=@shDerefVarList,shDerefOp 
                   links to shDeref
shDerefVar     xxx match /{\@<=\h\w*/  contained nextgroup=@shDerefVarList 
                   match /\d/  contained nextgroup=@shDerefVarList 
                   links to shDeref
shDerefWordError xxx match /[^}$[~]/  contained 
                   links to Error
shDerefOp      xxx match /:\=[-=?]/  contained nextgroup=@shDerefPatternList 
                   match /:\=+/  contained nextgroup=@shDerefPatternList 
                   links to shOperator
shDerefVarArray xxx matchgroup=shDeref start=/\[/ end=/]/  contained contains=@shCommandSubList nextgroup=shDerefOp,shDerefOpError 
shDerefOpError xxx match /:[[:punct:]]/  contained 
                   links to Error
shEchoQuote    xxx match /\%(\\\\\)*\\["`'()]/  contained 
                   links to shString
shCharClass    xxx match /\[:\(backspace\|escape\|return\|xdigit\|alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|tab\):\]/  contained 
                   links to Identifier
shWrapLineOperator xxx match /\\$/  
                   links to shOperator
shSetOption    xxx match /\s\zs[-+][a-zA-Z0-9]\+\>/  contained 
                   links to shOption
shAtExpr       xxx start=/@(/ end=/)/  contained contains=@shIdList 
                   links to shSetList
shFunctionOne  xxx matchgroup=shFunction start=/^\s*\h\w*\s*()\_s*{/ end=/}/  contains=@shFunctionList nextgroup=shFunctionStart,shQuickComment skipwhite skipnl 
shFunctionTwo  xxx matchgroup=shFunction start=/\%(do\)\@!\&\<\h\w*\>\s*\%(()\)\=\_s*{/ end=/}/  contained contains=shFunctionKey,@shFunctionList nextgroup=shFunctionStart,shQuickComment skipwhite skipnl 
shConditional  xxx contained elif then else
                   links to Conditional
shForPP        xxx matchgroup=shLoop start=/\<for\>\_s*((/ end=/))/  contains=shTestOpr 
                   links to shLoop
shTestOpr      xxx match #[^-+/%]\zs=#  contained nextgroup=shTestDoubleQuote,shTestSingleQuote,shTestPattern skipwhite 
                   match /<=\|>=\|!=\|==\|=\~\|-.\>\|-\(nt\|ot\|ef\|eq\|ne\|lt\|le\|gt\|ge\)\>\|[!<>]/  contained 
                   links to shConditional
shSpecialNoZS  xxx match /\%(\\\\\)*\\[\\"'`$()#]/  contained 
                   links to shSpecial
shQuickComment xxx match /#.*$/  contained 
                   links to shComment
shEmbeddedEcho xxx matchgroup=shStatement start=/\<print\>/ skip=/\\$/ matchgroup=NONE end=/\s#/me=e-2 end=/\d[<>]/me=e-2 end=/[<>;&|`)]/me=e-1 matchgroup=shEchoDelim end=/$/  contained contains=shNumber,shExSingleQuote,shSingleQuote,shDeref,shDerefSimple,shSpecialVar,shOperator,shExDoubleQuote,shDoubleQuote,shCharClass,shCtrlSeq 
                   links to shString
shPattern      xxx match /\<\S\+\())\)\@=/  contained contains=shExSingleQuote,shSingleQuote,shExDoubleQuote,shDoubleQuote,shDeref 
                   links to shString
shSpecialNxt   xxx match /\\[\\"'`$()#]/  contained 
                   links to shSpecial
shNoQuote      xxx start=/\S/ skip=/\%(\\\\\)*\\./ end=/\ze['"]/ end=/\ze\s/  contained contains=shDerefSimple,shDeref 
                   links to shDoubleQuote
shAstQuote     xxx match /\*\ze"/  contained nextgroup=shString 
                   links to shDoubleQuote
shTestDoubleQuote xxx start=/\%(\%(\\\\\)*\\\)\@<!"/ skip=/\\\\\|\\"/ end=/"/  contained contains=shDeref,shDerefSimple,shDerefSpecial 
                   links to shString
shTestSingleQuote xxx match /\\./  contained nextgroup=shTestSingleQuote 
                   match /'[^']*'/  contained 
                   links to shString
shTestPattern  xxx match /\w\+/  contained 
                   links to shString
shCurlyIn      xxx matchgroup=Delimiter start=/{/ end=/}/  contained contains=@shCurlyList 
shRepeat       xxx matchgroup=shLoop start=/\<while\_s/ end=/\<do\>/me=e-2  contains=@shLoopList 
                   matchgroup=shLoop start=/\<until\_s/ end=/\<do\>/me=e-2  contains=@shLoopList 
                   links to Repeat
shSkipInitWS   xxx match /^\s\+/  contained 
shBkslshSnglQuote xxx matchgroup=shQuote start=/'/ end=/'/  contained contains=@Spell 
shBkslshDblQuote xxx matchgroup=shQuote start=/"/ skip=/\\"/ end=/"/  contained contains=@shDblQuoteList,shStringSpecial,@Spell 
shTodo         xxx contained XXX FIXME TODO
                   contained COMBAK
                   links to Todo
shVarAssign    xxx match /=/  contained nextgroup=shCmdParenRegion,shPattern,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shSingleQuote,shExSingleQuote 
shFunctionThree xxx matchgroup=shFunction start=/^\s*\h\w*\s*()\_s*(/ end=/)/  contains=@shFunctionList nextgroup=shFunctionStart,shQuickComment skipwhite skipnl 
shFunctionFour xxx matchgroup=shFunction start=/\%(do\)\@!\&\<\h\w*\>\s*\%(()\)\=\_s*(/ end=/)/  contained contains=shFunctionKey,@shFunctionList nextgroup=shFunctionStart,shQuickComment skipwhite skipnl 
shDerefString  xxx matchgroup=shDerefDelim start=/\%(\\\)\@<!'/ end=/'/  contained contains=shStringSpecial 
                   matchgroup=shDerefDelim start=/\%(\\\)\@<!"/ skip=/\\"/ end=/"/  contained contains=@shDblQuoteList,shStringSpecial 
                   match /\\["']/  contained nextgroup=shDerefPattern 
                   links to shDoubleQuote
shCondError    xxx elif then else
                   links to Error
shErrorList    cluster=shDoError,shIfError,shInError,shCaseError,shEsacError,shCurlyError,shParenError,shTestError,shOK 
shArithParenList cluster=shArithmetic,shCaseEsac,shComment,shDeref,shDo,shDerefSimple,shEcho,shEscape,shNumber,shOperator,shPosnParm,shExSingleQuote,shExDoubleQuote,shHereString,shRedir,shSingleQuote,shDoubleQuote,shStatement,shVariable,shAlias,shTest,shCtrlSeq,shSpecial,shParen,bashSpecialVariables,bashStatement,shIf,shFor 
shArithList    cluster=@shArithParenList,shParenError 
shCaseEsacList cluster=shCaseStart,shCase,shCaseBar,shCaseIn,shComment,shDeref,shDerefSimple,shCaseCommandSub,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote,shCtrlSeq,@shErrorList,shStringSpecial,shCaseRange 
shCaseList     cluster=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shHereDoc,shIf,shHereString,shRedir,shSetList,shSource,shStatement,shVariable,shCtrlSeq 
shCommandSubList cluster=shAlias,shArithmetic,shCmdParenRegion,shCtrlSeq,shDeref,shDerefSimple,shDoubleQuote,shEcho,shEscape,shExDoubleQuote,shExpr,shExSingleQuote,shHereDoc,shNumber,shOperator,shOption,shPosnParm,shHereString,shRedir,shSingleQuote,shSpecial,shStatement,shSubSh,shTest,shVariable 
shCurlyList    cluster=shNumber,shComma,shDeref,shDerefSimple,shDerefSpecial 
shDblQuoteList cluster=shCommandSub,shDeref,shDerefSimple,shEscape,shPosnParm,shCtrlSeq,shSpecial 
shDerefList    cluster=shDeref,shDerefSimple,shDerefVar,shDerefSpecial,shDerefWordError,shDerefPSR,shDerefPPS 
shDerefVarList cluster=shDerefOff,shDerefOp,shDerefVarArray,shDerefOpError 
shEchoList     cluster=shArithmetic,shCommandSub,shDeref,shDerefSimple,shEscape,shExpr,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shCtrlSeq,shEchoQuote 
shExprList1    cluster=shCharClass,shNumber,shOperator,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shExpr,shDblBrace,shDeref,shDerefSimple,shCtrlSeq 
shExprList2    cluster=@shExprList1,@shCaseList,shTest 
shFunctionList cluster=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shHereDoc,shIf,shOption,shHereString,shRedir,shSetList,shSource,shStatement,shVariable,shOperator,shCtrlSeq 
shHereBeginList cluster=@shCommandSubList 
shHereList     cluster=shBeginHere,shHerePayload 
shHereListDQ   cluster=shBeginHere,@shDblQuoteList,shHerePayload 
shIdList       cluster=shCommandSub,shWrapLineOperator,shSetOption,shDeref,shDerefSimple,shHereString,shRedir,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shExpr,shCtrlSeq,shStringSpecial,shAtExpr 
shIfList       cluster=@shLoopList,shDblBrace,shDblParen,shFunctionKey,shFunctionOne,shFunctionTwo 
shLoopList     cluster=@shCaseList,@shErrorList,shCaseEsac,shConditional,shDblBrace,shExpr,shFor,shForPP,shIf,shOption,shSet,shTest,shTestOpr,shTouch 
shPPSRightList cluster=shComment,shDeref,shDerefSimple,shEscape,shPosnParm 
shSubShList    cluster=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shIf,shHereString,shRedir,shSetList,shSource,shStatement,shVariable,shCtrlSeq,shOperator 
shTestList     cluster=shCharClass,shCommandSub,shCtrlSeq,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shExpr,shExSingleQuote,shNumber,shOperator,shSingleQuote,shTest,shTestOpr 
shNoZSList     cluster=shSpecialNoZS 
Spell          cluster=NONE
shCommentGroup cluster=shTodo,@Spell 
shSpecialNoZS  cluster=NONE
shDerefVarArray cluster=NONE
shDerefPatternList cluster=shDerefPattern,shDerefString 
