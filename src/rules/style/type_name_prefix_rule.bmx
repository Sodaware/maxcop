' ------------------------------------------------------------------------------
' -- rules/style/type_name_prefix_rule.bmx
' --
' -- Check Type names start with "T"
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_TypeNamePrefixRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)

		' Only for "Type" keywords
		If token.kind <> TToken.TOK_TYPE_KW Then Return

		Local nextToken:TToken = lexer.GetToken(position + 1)

		' If next token does not start with T, complain
		If False = nextToken.ToString().StartsWith("T") Then
			Local o:Offense = Offense.Create(source, "Type name `" + token.ToString() + "` should start with T")
			o.setLocation(token.line, token.column + 5, nextToken.ToString().Length)
			o.setExcerpt( "Type " + nextToken.ToString())


			Self.addFileOffense(source, o)
		End If

	End Method

End Type
