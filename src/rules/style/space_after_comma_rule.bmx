' ------------------------------------------------------------------------------
' -- rules/style/space_after_comma_rule.bmx
' --
' -- Check that a comma has a space after it.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_SpaceAfterCommaRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------
	
	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for commas
		If token.kind <> TToken.TOK_COMMA Then Return

		' Get the comma position in the line
		Local tokenLine:String = source.getLine(token.line - 1)

		' If character after the comma is not a space, create an offense.
		If Mid(tokenLine, token.column + 1, 1) <> " " Then
			Local o:Offense = Offense.Create(source, "Space missing after comma")

			' Convert tabs to spaces and correct the token's position.
			Local preComma:String = Left(tokenline, token.column + 1)
			preComma = preComma.Replace("~t", "    ")

			o.setLocation(token.line - 1, preComma.Length + 2, 1)
			o.setExcerpt(tokenLine.Replace("~t", "    "))
			o.setExcerptLength(1)
			Self.addFileOffense(source, o)
		End If

	End Method

End Type
