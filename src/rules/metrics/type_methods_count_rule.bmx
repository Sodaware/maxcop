' ------------------------------------------------------------------------------
' -- rules/style/type_methods_count_rule.bmx
' --
' -- Check a type does not have too many methods.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Metrics_TypeMethodsCountRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Field maxMethodsCount:Int = 15


	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "Type" keywords
		If token.kind <> TToken.TOK_TYPE_KW Then Return

		' Get the type name.
		Local typeName:String = lexer.GetToken(position + 1).ToString()

		' Count all methods in the type.
		Local currentMethodCount:Int = 0
		For Local i:Int = position To lexer.NumTokens() - 1
			Local currentToken:TToken = lexer.GetToken(i)

			' Finish parsing if the end of the type is reached.
			If currentToken.kind = TToken.TOK_ENDTYPE_KW Then Exit

			' Count methods
			If currentToken.kind = TToken.TOK_METHOD_KW Then
				currentMethodCount :+ 1
			End If
		Next

		If currentMethodCount > Self.maxMethodsCount Then
			Local o:Offense = Offense.Create(source, Self._buildMessageForLine(typeName, currentMethodCount))
			o.setLocationFromToken(token)
			o.setExcerpt(source.getLine(token.line - 1))
			Self.addFileOffense(source, o)
		End If

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _buildMessageForLine:String(typeName:String, methodCount:Int)
		Return "Type " + typeName + " has too many methods. [" + methodCount + "/" + Self.maxMethodsCount + "]"
	End Method

End Type
