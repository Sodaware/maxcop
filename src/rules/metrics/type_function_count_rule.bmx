' ------------------------------------------------------------------------------
' -- rules/style/type_function_count_rule.bmx
' --
' -- Check a type does not have too many functions.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "type_member_count_rule.bmx"

Type Metrics_TypeFunctionCountRule Extends Metrics_TypeMemberCountRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	' Add a type field so it can be configured via INI
	Field maxFunctionCount:Int = 15

	Method configure()
		Self.maxMemberCount = Self.maxFunctionCount
		Self.memberType     = TToken.TOK_FUNCTION_KW
		Self.memberTypeName = "function"
	End Method

End Type
