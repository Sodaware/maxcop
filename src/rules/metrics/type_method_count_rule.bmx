' ------------------------------------------------------------------------------
' -- rules/style/type_methods_count_rule.bmx
' --
' -- Check a type does not have too many methods.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "type_member_count_rule.bmx"

Type Metrics_TypeMethodsCountRule Extends Metrics_TypeMemberCountRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	' Add a type field so it can be configured via INI
	Field maxMethodCount:Int = 15
	
	Method configure()
		Self.maxMemberCount = Self.maxMethodCount
		Self.memberType     = TToken.TOK_METHOD_KW
		Self.memberTypeName = "method"
	End Method

End Type
