' ------------------------------------------------------------------------------
' -- rules/lint/empty_case_rule.bmx
' --
' -- Check for empty `case` statements.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Lint_EmptyCaseRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		' Only for "Case" keywords.
		If token.kind <> TToken.TOK_CASE_KW Then Return

		' Search forwards to the next blank line.
		Local bodyStart:Int    = Self.searchToNextLine(lexer, position)
		Local bodyToken:TToken = lexer.getToken(bodyStart)

		Select bodyToken.kind
			Case TToken.TOK_CASE_KW, ..
				 TToken.TOK_DEFAULT_KW, ..
				 TToken.TOK_ENDSELECT_KW
				Self._signalError(source, token)
		End Select
	End Method

	Method searchToNextLine:Int(lexer:TLexer, position:Int)
		Local tokenPos:Int  = position + 1
		Local finished:Byte = False
		Local token:TToken  = Null

		Repeat
			token = lexer.getToken(tokenPos)
			
			If Self.isNewlineToken(token) Then
				' Weirdness happens with semi-colons.
				If token.kind = TToken.TOK_SEMICOLON And Self.isNewlineToken(lexer.getToken(tokenPos + 1)) Then
					tokenPos :+ 1
					Continue
				EndIf

				Return tokenPos + 1
			EndIf

			tokenPos :+ 1
		Until finished Or tokenPos >= lexer.NumTokens()
	End Method

	Method isNewlineToken:Byte(token:TToken)
		Return token.toString() = "\n" Or token.kind = TToken.TOK_NEWLINE Or token.kind = TToken.TOK_SEMICOLON
	End Method

	Method _signalError(source:SourceFile, token:TToken)
		Local o:Offense = Offense.Create(source, "Avoid `Case` statements without a body")
		o.setLocationFromToken(token)
		Self.addFileOffense(source, o)
	End Method

	Method _createSyntaxError(source:SourceFile, token:TToken)
		Local o:Offense = Offense.Create(source, "`Select` statement is missing `End Select`")
		o.setLocationFromToken(token)
		Self.addFileOffense(source, o)
	End Method

End Type
