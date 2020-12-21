' ------------------------------------------------------------------------------
' -- rules/metrics/function_parameter_count_rule.bmx
' --
' -- Check a function does not have too many parameters.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Metrics_FunctionParameterCountRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Field maxParameterCount:Int = 0' 3

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		' Only for "Function" keywords
		If token.kind <> TToken.TOK_FUNCTION_KW Then Return
		Local functionName:String = lexer.getToken(position + 1).toString()

		' Count all parameters.
		Local searchPos:Int       = Self._findFunctionStart(lexer, position)
		Local startPos:Int        = searchPos
		Local parameterCount:Int  = 0
		Local currentToken:TToken = Null

		Repeat
			currentToken = lexer.getToken(searchPos)

			' If there's an open parenthesis in the parameter list, we're in a
			' function pointer reference. Keep going until we're out of the definition.
			If currentToken.kind = TToken.TOK_OPENPAREN Then
				searchPos = Self._skipFunctionPointer(lexer, searchPos)
			EndIf

			' Comma indicates a new parameter.
			If currentToken.kind = TToken.TOK_COMMA Then parameterCount :+ 1

			' Finish parsing if the end of the definition.
			If currentToken.kind = TToken.TOK_CLOSEPAREN Then
				If searchPos > startPos Then parameterCount :+ 1
				Exit
			EndIf

			' Move to the next one.
			searchPos :+ 1

			' Check for EOF.
			If searchPos >= lexer.numTokens() Then Exit
		Forever

		If parameterCount > Self.maxParameterCount Then
			Local o:Offense = Offense.Create(source, Self._buildMessageForLine(functionName, parameterCount))
			o.setLocationFromToken(token)
			Self.addFileOffense(source, o)
		EndIf
	End Method

	Method _buildMessageForLine:String(name:String, paramCount:Int)
		Local message:String = "Function " + name + " has too many parameters."
		message :+ " [" + paramCount + "/" + Self.maxParameterCount + "]"

		Return message
	End Method

	Method _findFunctionStart:Int(lexer:TLexer, position:Int)
		Local currentToken:TToken

		Repeat
			currentToken = lexer.getToken(position)
			If currentToken.kind = TToken.TOK_OPENPAREN Then Return position + 1
			position :+ 1
		Until position >= lexer.numTokens()
	End Method

	Method _skipFunctionPointer:Int(lexer:TLexer, position:Int)
		Local currentToken:TToken

		Repeat
			position :+ 1
			currentToken = lexer.getToken(position)

			If currentToken.kind = TToken.TOK_OPENPAREN Then
				position = Self._skipFunctionPointer(lexer, position + 1)
			EndIf


		Until position >= lexer.numTokens() Or currentToken.kind = TToken.TOK_CLOSEPAREN

		Return position
	End Method
End Type
