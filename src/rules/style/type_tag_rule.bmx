' ------------------------------------------------------------------------------
' -- rules/style/type_tag_rule.bmx
' --
' -- Check for uses of BlitzMax type tags (i.e. $, #, % and ! instead of full
' -- type name).
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import "../base_rule.bmx"

Type Style_TypeTagRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		If token.kind = TToken.TOK_PERCENT Then Self.createOffense(source, token)
		If token.kind = TToken.TOK_HASH Then Self.createOffense(source, token)
		If token.kind = TToken.TOK_BANG Then Self.createOffense(source, token)
		If token.kind = TToken.TOK_DOLLAR Then Self.createOffense(source, token)
	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method createOffense(source:SourceFile, t:TToken)
		Local tagName:String  = Trim(t.toString())
		Local fullName:String = Self.fullNameForTag(tagName)

		Local o:Offense = Offense.Create(source, "Prefer full type name '" + fullName + "' over type tag '" + tagName + "'")
		o.setLocation(t.line, t.column)
		Self.addFileOffense(source, o)
	End Method

	Method fullNameForTag:String(tag:String)
		Select tag
			Case "%"
				Return "Int"
			Case "#"
				Return "Float"
			Case "!"
				Return "Double"
			Case "$"
				Return "String"
		End Select

		Return ""
	End Method
End Type
