

--- Elementos de sintaxe ---
pythonStatement xxx return None False True
                   lambda
                   nextgroup=pythonFunction  skipwhite def
                   del
                   nextgroup=pythonFunction  skipwhite class
                   global nonlocal as yield with
                   print continue break pass
                   assert exec
                   links to Statement
pythonFunction xxx match /\h\w*/  display contained 
                   links to Function
pythonConditional xxx if else elif
                   links to Conditional
pythonRepeat   xxx for while
                   links to Repeat
pythonOperator xxx or is and in not
                   links to Operator
pythonException xxx finally raise except try
                   links to Exception
pythonInclude  xxx from import
                   links to Include
pythonAsync    xxx async await
                   links to Statement
pythonDecorator xxx match /@/  display contained 
                   links to Define
pythonDecoratorName xxx match /@\s*\h\%(\w\|\.\)*/  display contains=pythonDecorator 
                   links to Function
pythonDoctestValue xxx start=/^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\+/ end=/$/  contained 
                   links to Define
pythonMatrixMultiply xxx match /\%(\w\|[])]\)\s*@/  transparent contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue 
                   match /[^\\]\\\s*\n\%(\s*\.\.\.\s\)\=\s\+@/  transparent contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue 
                   match /^\s*\%(\%(>>>\|\.\.\.\)\s\+\)\=\zs\%(\h\|\%(\h\|[[(]\).\{-}\%(\w\|[])]\)\)\s*\n\%(\s*\.\.\.\s\)\=\s\+@\%(.\{-}\n\%(\s*\.\.\.\s\)\=\s\+@\)*/  transparent contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue 
pythonTodo     xxx contained NOTE XXX TODO NOTES
                   contained FIXME
                   links to Todo
pythonComment  xxx match /#.*$/  contains=pythonTodo,@Spell 
                   links to Comment
pythonEscape   xxx match /\\[abfnrtv'"\\]/  contained 
                   match /\\\o\{1,3}/  contained 
                   match /\\x\x\{2}/  contained 
                   match /\%(\\u\x\{4}\|\\U\x\{8}\)/  contained 
                   match /\\N{\a\+\%(\s\a\+\)*}/  contained 
                   match /\\$/  
                   links to Special
pythonString   xxx matchgroup=pythonQuotes start=/[uU]\=\z(['"]\)/ skip=/\\\\\|\\\z1/ end=/\z1/  contains=pythonEscape,@Spell 
                   matchgroup=pythonTripleQuotes start=/[uU]\=\z('''\|"""\)/ skip=/\\["']/ end=/\z1/  keepend contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell 
                   links to String
pythonDoctest  xxx start=/^\s*>>>\s/ end=/^\s*$/  contained contains=ALLBUT,pythonDoctest,pythonFunction,@Spell 
                   links to Special
pythonRawString xxx matchgroup=pythonQuotes start=/[uU]\=[rR]\z(['"]\)/ skip=/\\\\\|\\\z1/ end=/\z1/  contains=@Spell 
                   matchgroup=pythonTripleQuotes start=/[uU]\=[rR]\z('''\|"""\)/ end=/\z1/  keepend contains=pythonSpaceError,pythonDoctest,@Spell 
                   links to String
pythonNumber   xxx match /\<0[oO]\=\o\+[Ll]\=\>/  
                   match /\<0[xX]\x\+[Ll]\=\>/  
                   match /\<0[bB][01]\+[Ll]\=\>/  
                   match /\<\%([1-9]\d*\|0\)[Ll]\=\>/  
                   match /\<\d\+[jJ]\>/  
                   match /\<\d\+[eE][+-]\=\d\+[jJ]\=\>/  
                   match /\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@=/  
                   match /\%(^\|\W\)\zs\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>/  
                   links to Number
pythonBuiltin  xxx list all classmethod None abs
                   cmp reduce ord hex object
                   memoryview enumerate
                   __debug__ compile str False
                   True issubclass input hasattr
                   frozenset slice callable sum
                   filter range any long
                   execfile min type locals
                   sorted reload super complex
                   xrange file ascii setattr
                   unicode staticmethod
                   basestring unichr float iter
                   map globals max isinstance
                   dict chr reversed buffer
                   delattr __import__ oct dir
                   eval raw_input hash getattr
                   tuple id bin vars apply bytes
                   repr pow print zip open
                   NotImplemented intern round
                   format bool help property
                   coerce Ellipsis len int next
                   exec set divmod bytearray
                   links to Function
pythonAttribute xxx match /\.\h\w*/hs=s+1  transparent contains=ALLBUT,pythonBuiltin,pythonFunction,pythonAsync 
pythonExceptions xxx OSError Warning
                   EnvironmentError
                   IsADirectoryError UserWarning
                   NameError ArithmeticError
                   NotImplementedError
                   NotADirectoryError
                   ConnectionAbortedError
                   ReferenceError BaseException
                   StopAsyncIteration
                   PermissionError LookupError
                   ImportWarning OverflowError
                   SystemExit IndentationError
                   GeneratorExit
                   ChildProcessError
                   RuntimeError MemoryError
                   WindowsError AssertionError
                   UnicodeWarning KeyError
                   TypeError TabError
                   BlockingIOError ImportError
                   SyntaxWarning SyntaxError
                   UnboundLocalError
                   KeyboardInterrupt
                   UnicodeDecodeError
                   BrokenPipeError IOError
                   Exception FutureWarning
                   InterruptedError
                   AttributeError
                   UnicodeTranslateError
                   VMSError EOFError
                   FloatingPointError ValueError
                   IndexError FileNotFoundError
                   ConnectionRefusedError
                   RuntimeWarning
                   DeprecationWarning
                   ResourceWarning
                   ProcessLookupError
                   PendingDeprecationWarning
                   RecursionError
                   UnicodeEncodeError
                   StopIteration UnicodeError
                   TimeoutError
                   ConnectionResetError
                   BytesWarning StandardError
                   SystemError ZeroDivisionError
                   ConnectionError
                   FileExistsError BufferError
                   links to Structure
Spell          cluster=NONE
NoSpell        cluster=NONE
