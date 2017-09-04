' ------------------------------------------------------------------------------
' -- rules/lint/empty_else_rule.bmx
' --
' -- Check for empty `else` statements.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Lint_EmptyElseRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "Else"/"ElseIf" keywords
		If token.kind <> TToken.TOK_ELSE_KW Then Return

		' Find the next none-empty token.
		Local nextToken:TToken = Self.getNextNoneEmptyToken(lexer, position + 1)

		If nextToken.kind = TToken.TOK_ENDIF_KW Then
			Local o:Offense = Offense.Create(source, "Avoid `Else` statements without a body")
			o.setLocationFromToken(token)
			Self.addFileOffense(source, o)
		End If

	End Method

End Type
