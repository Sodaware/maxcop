' ------------------------------------------------------------------------------
' -- rules/metrics/method_parameter_count_rule.bmx
' --
' -- Check a method does not have too many parameters.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "parameter_count_rule.bmx"

Type Metrics_MethodParameterCountRule Extends Metrics_ParameterCountRule

	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Field maxParameterCount:Int = 5

	Method configure()
		Self.maxItemCount   = Self.maxParameterCount
		Self.memberType     = TToken.TOK_METHOD_KW
		Self.memberTypeName = "Method"
	End Method

End Type
