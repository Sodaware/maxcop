' ------------------------------------------------------------------------------
' -- rules/lint/handle_exceptions_rule.bmx
' --
' -- Check for empty exception handlers.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Lint_HandleExceptionsRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "catch" exceptions.
		If token.kind <> TToken.TOK_CATCH_KW Then Return

		' Next token should be a variable. Skip it and get the token that starts the block.
		Local blockOffset:Int = Self._getBlockStartOffset(lexer, position)

		' Find the next none-empty token.
		Local nextToken:TToken = Self.getNextNoneEmptyToken(lexer, position + blockOffset)

		' Check if it's a Finally, another Catch or an End Try keyword
		If Self._catchBlockIsEmpty(nextToken) Then
			Local o:Offense = Offense.Create(source, "Avoid `Catch` statements without a body)")
			o.setLocationFromToken(token)
			o.setExcerpt(source.getLine(token.line - 1))
			Self.addFileOffense(source, o)
		End If

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _getBlockStartOffset:Int(lexer:TLexer, position:Int)
		Local offset:Int = 2

		If lexer.GetToken(position + offset).kind = TToken.TOK_COLON Then
			offset :+ 2
		Else
			offset :+ 1
		End If

		Return offset
	End Method

	Method _catchBlockIsEmpty:Byte(token:TToken)
		If token.kind = TToken.TOK_ENDTRY_KW Then Return True
		If token.kind = TToken.TOK_CATCH_KW Then Return True
		If token.kind = TToken.TOK_FINALLY_KW Then Return True
		Return False
	End Method

End Type
