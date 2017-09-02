' ------------------------------------------------------------------------------
' -- services/rule_service.bmx
' --
' -- Service for working with rules. Automatically loads type definitions and
' -- extracts rule information.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "service.bmx"
Import "../rules/base_rule.bmx"

' Style
Import "../rules/style/string_exceptions_rule.bmx"
Import "../rules/style/type_name_prefix_rule.bmx"
Import "../rules/style/field_name_prefix_rule.bmx"
Import "../rules/style/private_field_name_case_rule.bmx"
Import "../rules/style/type_method_name_case_rule.bmx"
Import "../rules/style/uppercase_constants_rule.bmx"

' Metrics
Import "../rules/metrics/line_length_rule.bmx"
Import "../rules/metrics/trailing_whitespace_rule.bmx"
Import "../rules/metrics/type_function_count_rule.bmx"
Import "../rules/metrics/type_method_count_rule.bmx"


Type RuleService Extends Service
	
	Field _availableRules:TList
	
	
	' ------------------------------------------------------------
	' -- Getting Rules
	' ------------------------------------------------------------
	
	Method getAllRules:TList()
		Return Self._availableRules
	End Method
	
	
	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()
		
		' Load all Rule types
		Local baseType:TTypeId = TTypeId.ForName("BaseRule")
		For Local ruleType:TTypeId = EachIn baseType.DerivedTypes()
			Self._availableRules.AddLast(ruleType.NewObject())
		Next
		
	End Method
	
	Method unloadService()
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction & Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self._availableRules = New TList
	End Method

End Type
