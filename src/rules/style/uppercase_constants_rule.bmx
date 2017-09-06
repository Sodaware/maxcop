' ------------------------------------------------------------------------------
' -- rules/style/uppercase_constants_rule.bmx
' --
' -- Check constant names are upper-case.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_UppercaseConstantsRule Extends BaseRule
	
	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------
	
	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		
		' Only for "Const" keywords
		If token.kind <> TToken.TOK_CONST_KW Then Return
		
		Local nextToken:TToken = lexer.GetToken(position + 1)
		
		' If next token is not uppercase
		If Not(Self._isTokenUppercase(nextToken)) Then
			Local o:Offense = Offense.Create(source, Self._getMessage(nextToken))
			o.setLocation(token.line, token.column + 5, nextToken.ToString().Length)
			o.setExcerpt( "Const " + nextToken.ToString())
	
			
			Self.addFileOffense(source, o)
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------
	
	Method _isTokenUppercase:Byte(nameToken:TToken)
		Return nametoken.ToString() = nametoken.ToString().ToUpper()
	End Method
	
	Method _getMessage:String(nameToken:TToken)
		Return "Constant name `" + nameToken.ToString() + "` should be uppercase"
	End Method
	
End Type
