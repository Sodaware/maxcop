' ------------------------------------------------------------------------------
' -- rules/style/type_member_count_rule.bmx
' --
' -- Base rule that checks a type does not have too many of a certain member
' -- (e.g. too many functions, methods etc).
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Metrics_TypeMemberCountRule Extends BaseRule ..
	{ ignore_type }

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Field maxMemberCount:Int = 15
	Field memberType:Int
	Field memberTypeName:String

	''' <summary>Use this method to configure the rule.</summary>
	Method configure()

	End Method


	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "Type" keywords
		If token.kind <> TToken.TOK_TYPE_KW Then Return

		' Configure this rule and get the type name.
		Self.configure()
		Local typeName:String = lexer.GetToken(position + 1).ToString()

		' Count all functions in the type.
		Local currentMemberCount:Int = 0
		For Local i:Int = position To lexer.NumTokens() - 1
			Local currentToken:TToken = lexer.GetToken(i)

			' Finish parsing if the end of the type is reached.
			If currentToken.kind = TToken.TOK_ENDTYPE_KW Then Exit

			' Count members
			If Self._isTokenType(currentToken) Then
				currentMemberCount :+ 1
			End If
		Next

		If currentMemberCount > Self.maxMemberCount Then
			Local o:Offense = Offense.Create(source, Self._buildMessageForLine(typeName, currentMemberCount))
			o.setLocationFromToken(token)
			Self.addFileOffense(source, o)
		End If

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Check if a token is one this function is interested in.
	''' </summary>
	Method _isTokenType:Byte(token:TToken)
		Return token.kind = Self.memberType
	End Method

	Method _buildMessageForLine:String(typeName:String, memberCount:Int)
		Local message:String = "Type " + typeName + " has too many " + Self.memberTypeName + "s."
		message :+ " [" + memberCount + "/" + Self.maxMemberCount + "]"
		Return message
	End Method

End Type
