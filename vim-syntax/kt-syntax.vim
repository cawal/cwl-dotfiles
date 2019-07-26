

--- Elementos de sintaxe ---
ktStatement    xxx return continue break
                   links to Statement
ktConditional  xxx else when if
                   links to Conditional
ktRepeat       xxx do for while
                   links to Repeat
ktOperator     xxx by in is
                   match #\v\?:|::|\<\=? | \>\=?|[!=]\=\=?|<as>\??|[-!%&*+/|]#  
                   links to Operator
ktKeyword      xxx this super get out set where
                   links to Keyword
ktException    xxx throw finally catch try
                   links to Exception
ktInclude      xxx import package
                   links to Include
ktType         xxx Byte Unit Short Long Int
                   Nothing Boolean Double Float
                   Char Any
                   links to Type
ktModifier     xxx expect actual companion
                   inline protected annotation
                   open const final abstract
                   operator vararg external
                   lateinit reified infix
                   dynamic data suspend public
                   enum sealed inner private
                   internal override crossinline
                   noinline tailrec
                   links to StorageClass
ktStructure    xxx fun interface typealias class
                   object init constructor val
                   var
                   links to Structure
ktReservedKeyword xxx typeof
                   links to Error
ktBoolean      xxx false true
                   links to Boolean
ktConstant     xxx null
                   links to Constant
ktTodo         xxx contained FIXME TODO XXX
                   links to Todo
ktShebang      xxx match /\v^#!.*$/  
                   links to Comment
ktLineComment  xxx match +\v//.*$+  contains=ktTodo,@Spell 
                   links to Comment
ktComment      xxx matchgroup=ktCommentMatchGroup start=+/\*+ end=+\*/+  contains=ktComment,ktTodo,@Spell 
                   match +/\*\*/+  
                   links to Comment
ktDocTag       xxx match /\v\@(author|constructor|receiver|return|since|suppress)>/  contained 
                   match /\v\@(exception|param|property|throws|see|sample)>\s*\S+/  contained contains=ktDocTagParam 
                   links to Special
ktDocComment   xxx start=+/\*\*+ end=+\*/+  contains=ktDocTag,ktTodo,@Spell 
                   links to Comment
ktDocTagParam  xxx match /\v(\s|\[)\S+/  contained 
                   links to Identifier
ktSpecialCharError xxx match /\v\\./  contained 
                   links to Error
ktSpecialChar  xxx match /\v\\([tbnr'"$\\]|u\x{4})/  contained 
                   links to SpecialChar
ktSimpleInterpolation xxx match /\v\$\h\w*/  contained 
                   links to Identifier
ktComplexInterpolation xxx matchgroup=ktComplexInterpolationBrace start=/\v\$\{/ end=/\v\}/  contains=ALLBUT,ktSimpleInterpolation,ktTodo,ktSpecialCharError,ktSpecialChar,ktDocTag,ktDocTagParam 
ktString       xxx start=/"/ skip=/\\"/ end=/"/  contains=ktSimpleInterpolation,ktComplexInterpolation,ktSpecialChar,ktSpecialCharError 
                   start=/"""/ end=/""""*/  contains=ktSimpleInterpolation,ktComplexInterpolation,ktSpecialChar,ktSpecialCharError 
                   links to String
ktCharacter    xxx match /\v'[^']*'/  contains=ktSpecialChar,ktSpecialCharError 
                   match /\v'\\''/  contains=ktSpecialChar 
                   match /\v'[^\\]'/  
                   links to Character
ktAnnotation   xxx match /\v(\w)@<!\@[[:alnum:]_.]*(:[[:alnum:]_.]*)?/  
                   links to Identifier
ktLabel        xxx match /\v\w+\@/  
                   links to Identifier
ktNumber       xxx match /\v<\d+[_[:digit:]]*(uL?|UL?|[LFf])?/  
                   match /\v<0[Xx]\x+[_[:xdigit:]]*(uL?|UL?|L)?/  
                   match /\v<0[Bb][01]+[_01]*(uL?|UL?|L)?/  
                   links to Number
ktFloat        xxx match /\v<\d*(\d[eE][-+]?\d+|\.\d+([eE][-+]?\d+)?)[Ff]?/  
                   links to Float
ktEscapedName  xxx match /\v`.*`/  
ktExclExcl     xxx match /!!/  
                   links to Special
ktArrow        xxx match /->/  
                   links to Structure
Spell          cluster=NONE
