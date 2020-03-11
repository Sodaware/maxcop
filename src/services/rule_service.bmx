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

Import brl.reflection

Import "service.bmx"
Import "../rules/base_rule.bmx"

' Linting
Import "../rules/lint/empty_else_rule.bmx"
Import "../rules/lint/empty_select_rule.bmx"
Import "../rules/lint/handle_exceptions_rule.bmx"

' Metrics
Import "../rules/metrics/line_length_rule.bmx"
Import "../rules/metrics/method_length_rule.bmx"
Import "../rules/metrics/trailing_whitespace_rule.bmx"
Import "../rules/metrics/type_field_count_rule.bmx"
Import "../rules/metrics/type_function_count_rule.bmx"
Import "../rules/metrics/type_method_count_rule.bmx"

' Style
Import "../rules/style/string_exceptions_rule.bmx"
Import "../rules/style/type_name_prefix_rule.bmx"
Import "../rules/style/field_name_prefix_rule.bmx"
Import "../rules/style/private_field_name_case_rule.bmx"
Import "../rules/style/space_after_comma_rule.bmx"
Import "../rules/style/space_around_operator_rule.bmx"
Import "../rules/style/type_method_name_case_rule.bmx"
Import "../rules/style/uppercase_constants_rule.bmx"


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

	''' <summary>Autoload all rules when the service starts.</summary>
	Method initialiseService()
		Self._loadRulesForType(TTypeId.ForName("BaseRule"))
	End Method

	Method unloadService()
		
	End Method


	' ------------------------------------------------------------
	' -- Internal rule helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Loads all rules that extend a particular type. Also checks for rules
	''' that extend any of the children. Rules can be ignored by including
	'''  'ignore_type' in their meta-data.
	''' </summary>
	Method _loadRulesForType(typeInfo:TTypeId)

		For Local ruleType:TTypeId = EachIn typeInfo.DerivedTypes()

			' If type should be ignored (i.e. has meta "ignore_type") don't add it.
			If Not ruleType.MetaData().Contains("ignore_type") Then
				Self._availableRules.AddLast(ruleType.NewObject())
			EndIf

			' Add any types that extend this type
			Self._loadRulesForType(ruleType)

		Next

	End Method


	' ------------------------------------------------------------
	' -- Construction & Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self._availableRules = New TList
	End Method

End Type
