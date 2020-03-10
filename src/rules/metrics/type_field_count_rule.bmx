' ------------------------------------------------------------------------------
' -- rules/style/type_field_count_rule.bmx
' --
' -- Check a type does not have too many fields.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "type_member_count_rule.bmx"

Type Metrics_TypeFieldCountRule Extends Metrics_TypeMemberCountRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	' Add a type field so it can be configured via INI
	Field maxFieldCount:Int = 15

	Method configure()
		Self.maxMemberCount = Self.maxFieldCount
		Self.memberType     = TToken.TOK_ID
		Self.memberTypeName = "field"
	End Method

	' Override the built-in checker so we can test it is a field type.
	Method _isTokenType:Byte(token:TToken)
		Return (token.kind = Self.memberType And token.toString().toLower() = "field")
	End Method

End Type
