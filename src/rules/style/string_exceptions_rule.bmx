' ------------------------------------------------------------------------------
' -- rules/style/string_exceptions_rule.bmx
' --
' -- Check "Throw" does not throw strings.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_StringExceptionsRule Extends BaseRule
	
	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------
	
	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		
		' Only for "throw" keywords
		If token.kind <> TToken.TOK_ID or token.ToString().ToLower() <> "throw" Then return
		
		Local nextToken:TToken = lexer.GetToken(position + 1)
		
		' If next token is a string literal, complain
		If nextToken.kind = TToken.TOK_STRING_LIT Then
			Local o:Offense = Offense.Create(source, "Use a custom type when throwing exceptions, not a string")
			o.setLocation(token.line, token.column, 6 + nextToken.ToString().Length)
			o.setExcerpt( "Throw " + nextToken.ToString())
			
			' Add the offense
			Self.addFileOffense(source, o)
		End If
		
	End Method
	
End Type
