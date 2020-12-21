' ------------------------------------------------------------------------------
' -- rules/style/type_name_suffix_rule.bmx
' --
' -- Check Type names ends with a specific string.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

''' <summary>
''' Check Type names ends with a specific string.
'''
''' This rule is disabled by default and requires configuration to work.
''' </summary>
Type Style_TypeNameSuffixRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Field suffix:String = ""


	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		' Only for "Type" keywords and only if configured.
		If token.kind <> TToken.TOK_TYPE_KW Then Return
		If Self.suffix = "" Then Return

		Local nextToken:TToken = lexer.GetToken(position + 1)

		' If next token does not end with suffix, complain.
		If Not nextToken.ToString().endsWith(Self.suffix) Then
			Local o:Offense = Offense.Create(source, "Type name `" + nextToken.ToString() + "` should end with `" + Self.suffix + "`")
			o.setLocation(token.line, token.column + 5, nextToken.ToString().Length)
			o.setExcerpt("Type " + nextToken.ToString())

			Self.addFileOffense(source, o)
		End If
	End Method

End Type
