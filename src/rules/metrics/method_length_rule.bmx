' ------------------------------------------------------------------------------
' -- rules/style/method_length_rule.bmx
' --
' -- Checks a type method does not have too many lines.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Metrics_MethodLengthRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Field maxLineCount:Int = 35


	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "Method" keywords
		If token.kind <> TToken.TOK_METHOD_KW Then Return

		' Get the method name for error reporting.
		Local methodName:String = lexer.GetToken(position + 1).ToString()

		' Count all lines.
		Local currentLineCount:Int = 0
		For Local i:Int = position To lexer.NumTokens() - 1
			Local currentToken:TToken = lexer.GetToken(i)

			' Finish parsing if the end of the type is reached.
			If currentToken.kind = TToken.TOK_ENDMETHOD_KW Then Exit

			' Count members
			If currentToken.kind = TToken.TOK_NEWLINE Then
				If lexer.GetToken(i - 1).kind <> TToken.TOK_NEWLINE Then
					currentLineCount :+ 1
				EndIf
			End If
		Next

		' Ignore the first line.
		currentLineCount :- 1

		If currentLineCount > Self.maxLineCount Then
			Local o:Offense = Offense.Create(source, Self._buildMessageForLine(methodName, currentLineCount))
			o.setLocationFromToken(token)
			Self.addFileOffense(source, o)
		End If

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _buildMessageForLine:String(methodName:String, lineCount:Int)
		Local message:String = "Method `" + methodName + "` has too many lines."
		message :+ " [" + lineCount + "/" + Self.maxLineCount + "]"
		Return message
	End Method

End Type
