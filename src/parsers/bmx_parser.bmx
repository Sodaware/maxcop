' ------------------------------------------------------------
' -- parsers/bmx_parser.bmx
' --
' -- Basic parser for scanning BlitzMax source files. Reads
' -- the source code and extracts types, functions, methods,
' -- globals and other constructs.
' ------------------------------------------------------------


SuperStrict

Import brl.reflection
Import cower.bmxlexer
Import sodaware.File_Util

Import "../core/source_file.bmx"
Import "../reporters/base_reporter.bmx"

' Base rules
Import "../rules/base_rule.bmx"

Type BmxParser
	
	' Options
	Field parseIncludes:Byte  = False
	
	' Internals
	Field _reporter:BaseReporter
	Field _inputs:TList       = New TList
	Field _parsedFiles:TList  = New TList
	Field _enabledRules:TList = New TList
	
	
	' ----------------------------------------------------------------------
	' -- Configuring the Parser
	' ----------------------------------------------------------------------
	
	Method setReporter(reporter:BaseReporter)
		Self._reporter = reporter
	End Method
	
	Method addRule(rule:BaseRule)
		Self._enabledRules.addLast(rule)
	End Method
	
	
	' ----------------------------------------------------------------------
	' -- Parsing Files
	' ----------------------------------------------------------------------
	
	''' <summary>	
	''' Parses a single file and returns the parsed source file. Can add
	''' includes and imports if configured to do so.
	''' </summary>
	Method parse:SourceFile(fileName:String)
		
		' Load the file
		Local source:String = Self.loadFile(fileName)
		
		' Create a new source file and set full details
		Local file:SourceFile = New SourceFile
		file.name             = StripDir(fileName)
		file.path             = RealPath(fileName)
		file.lastModified     = File_Util.GetInfo(file.path).ToString()
		file.source           = source
		
		' Create the lexer and parse the source file
		Local lexer:TLexer = New TLexer
		lexer.InitWithSource(source)
		lexer.Run()
		
		' Load tokens into source file
		Local pos:Int = 0
		Local currentToken:TToken
		
		' Do an initial pass of all file-level rules
		For Local rule:BaseRule = EachIn Self._enabledRules
			If rule.isDisabled() Then Continue
		
			' TODO: this elsewhere
			rule._reporter = Self._reporter
			rule.checkFile(file)
		Next
		
		'Local x:StringExceptionsRule = New StringExceptionsRule
		
		
		' Read all tokens
		While pos < lexer.NumTokens()
			currentToken = lexer.GetToken(pos)
			
			For Local rule:BaseRule = EachIn Self._enabledRules
				if rule.isDisabled() Then Continue
				rule._reporter = Self._reporter
				rule.checkToken(currentToken, lexer, pos, file)
			Next
			
			pos :+ 1
		WEnd
		
		Return file
		
	End Method
	
	Method loadFile:String(fileName:String)
		
		Local fileIn:TStream = ReadFile(fileName)
		Local source:String  = "";
		While Not(fileIn.Eof())
			source:+ fileIn.ReadLine() + "~n"
		Wend
		
		fileIn.Close()
		
		Return source
		
	End Method
	
End Type