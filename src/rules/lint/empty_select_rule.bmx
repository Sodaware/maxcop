' ------------------------------------------------------------------------------
' -- rules/lint/empty_select_rule.bmx
' --
' -- Check for empty `select` statements.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Lint_EmptySelectRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "Select" keywords
		If token.kind <> TToken.TOK_SELECT_KW Then Return

		' If no "Case" or "Default" tokens before end, throw an error.
		Local tokenPos:Int  = position
		Local finished:Byte = False
		Repeat
			Local nextToken:TToken = Self.getNextNoneEmptyToken(lexer, tokenPos)

			' If no more tokens, trigger an error.
			If Not nextToken Then
				Self._createSyntaxError(source, token)

				Return
			EndIf

			' If a Case or Default keyword is found, the select is not empty.
			If nextToken.kind = TToken.TOK_CASE_KW Then Return
			If nextToken.kind = TToken.TOK_DEFAULT_KW Then Return

			' End the loop if select is closed.
			If nextToken.kind = TToken.TOK_ENDSELECT_KW Then finished = True

			tokenPos :+ 1
		Until finished

		' Did not quit out, so create an offense.
		Local o:Offense = Offense.Create(source, "Avoid `Select` statements without a body")
		o.setLocationFromToken(token)
		Self.addFileOffense(source, o)

	End Method

	Method _createSyntaxError(source:SourceFile, token:TToken)
		Local o:Offense = Offense.Create(source, "`Select` statement is missing `End Select`")
		o.setLocationFromToken(token)
		Self.addFileOffense(source, o)
	End Method

End Type
