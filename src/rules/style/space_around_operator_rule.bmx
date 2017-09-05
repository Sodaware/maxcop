' ------------------------------------------------------------------------------
' -- rules/style/space_around_operator_rule.bmx
' --
' -- Check that operators (+, -, / and *) have a space around them.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_SpaceAroundOperatorRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for operators.
		If Not Self._isOperatorToken(token.kind) Then Return

		' Get the operator position in the line
		Local tokenLine:String = source.getLine(token.line - 1)

		' If character after the comma is not a space, create an offense.
		If Self._tokenIsMissingSpace(tokenLine, token.column) Then
			Local o:Offense = Offense.Create(source, "Space missing from around `" + token.ToString() + "` operator")

			' Convert tabs to spaces and correct the token's position.
			Local preToken:String = Left(tokenLine, token.column)
			preToken = preToken.Replace("~t", "    ")

			o.setLocation(token.line, preToken.Length, 1)
			o.setExcerpt(tokenLine.Replace("~t", "    "))
			o.setExcerptLength(1)
			Self.addFileOffense(source, o)
		End If

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _isOperatorToken:Byte(tokenKind:Int)
		If tokenKind = TToken.TOK_PLUS Then Return True
		If tokenKind = TToken.TOK_MINUS Then Return True
		If tokenKind = TToken.TOK_ASTERISK Then Return True
		If tokenKind = TToken.TOK_SLASH Then Return True
		Return False
	End Method

	Method _tokenIsMissingSpace:Byte(tokenLine:String, column:Int)
		If Mid(tokenLine, column - 1, 1) <> " " Then Return True
		If Mid(tokenLine, column + 1, 1) <> " " Then Return True
		Return False
	End Method

End Type
