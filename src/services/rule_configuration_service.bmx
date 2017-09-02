' ------------------------------------------------------------------------------
' -- services/rule_configuration_service.bmx
' --
' -- Manages which rules are enabled and disabled. These settings may come from
' -- the command line, but can also be loaded from a configuration file in the
' -- project's directory.
' --
' -- Scans for the following files:
' --  - .maxcop_rules.ini
' --  - maxcop_rules.ini
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


' TODO: Allow configuration files to "inherit" from a parent file

SuperStrict

Import brl.retro
Import brl.reflection
Import sodaware.File_Util
Import sodaware.file_config
Import sodaware.file_config_iniserializer

Import "service.bmx"
Import "../rules/base_rule.bmx"

Type RuleConfigurationService Extends Service

	' Config
	Field _config:Config

	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------
	
	Method configureRules(rules:TList)
	
		' Get list of all disabled rules
		Local disabledRules:TList = Self.getDisabledRules()
	
		For Local rule:BaseRule = EachIn rules
			
			' Enable or disable the rule
			rule.setEnabled(Self.isRuleEnabled(rule, disabledRules))
			
			' Set individual configuration options
			Self.configureRule(rule)
			
		Next
		
	End Method
	
	Method isRuleEnabled:Byte(rule:BaseRule, disabledRules:TList)
		Return Not(disabledRules.Contains(TTypeId.ForObject(rule)))
	End Method
	
	Method configureRule(rule:BaseRule)
		
		' Get rule type info and name
		Local ruleType:TTypeId = TTypeId.ForObject(rule)
		Local ruleName:String  = Self.getRuleNameForTypeId(ruleType)
		
		' Get config block
		Local configKeys:TList = Self._config.getSectionKeys(ruleName)
		If configKeys <> Null Then
			For Local key:String = EachIn configKeys
			
				' Skip enable block
				If key.tolower() = "enabled" Then Continue
				If key.StartsWith("_") Then Continue
				
				Local fieldToModify:TField = Self.getTypeFieldForConfigurationKey(ruleType, key)
				If fieldToModify <> Null Then
					fieldToModify.Set(rule, Self._config.getKey(ruleName, key))
				End If
			Next
		EndIf
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Loading
	' ------------------------------------------------------------
	
	Method findAndLoadConfiguration(path:String)
		Self._config = New Config
		IniConfigSerializer.Load(Self._config, path + "/maxcop_rules.ini")
	End Method
	
	Method isRuleBlock:Byte(blockName:String)
		blockName = blockName.ToLower()
		If blockName = "ignored_files" Then Return False
		Return True
	End Method
	
	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()
	End Method
	
	Method unloadService()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Rule configuration helpers
	' ------------------------------------------------------------
	
	Method getDisabledRules:TList()
		
		Local disabledRules:TList = New TList
	
		For Local ruleName:String = EachIn Self._config.getSections()
			
			' Skip none-rule blocks
			If Not(Self.isRuleBlock(ruleName)) Then Continue
			
			If Self._config.getKey(ruleName, "enabled", "true").ToLower() = "false" Then
				disabledRules.AddLast(Self.getTypeIdForRuleName(ruleName))
			EndIf
		Next
		
		Return disabledRules
		
	End Method
	
	Method getTypeIdForRuleName:TTypeId(ruleName:String)
		' TODO: Make this nicer
		Local typeName:String = ruleName.Replace("_", "").Replace("/", "_") + "rule"
		Local ruleType:TTypeId = TTypeId.ForName(typeName)
		If ruleType = Null Then Throw ruleName + " => " + typeName
		Return ruleType
	End Method
	
	Method getRuleNameForTypeId:String(ruleType:TTypeId)
		
		' Get the full type name
		Local typeName:String      = ruleType.Name()
		Local convertedName:String = ""
		
		' Remove "rule" suffix if present
		If typeName.EndsWith("Rule") Then
			typeName = Left(typeName, typeName.Length - 4)
		EndIf
		
		' Extract the namespace and rule name
		Local rulePieces:String[] = typeName.Split("_")
		Local namespace:String    = rulePieces[0]
		Local ruleName:String     = rulePieces[1]
		
 		' Re-assemble and return
		convertedName = namespace + "/" + Self.convertCamelCaseToSnakeCase(ruleName)
		Return convertedName.ToLower()
		
	End Method
	
	Method convertCamelCaseToSnakeCase:String(word:String)
		
		Local convertedName:String = ""
		Local pos:Int = 2
		convertedName :+ Mid(word, 1, 1)
		
		While pos <= word.Length
		
			Local currentLetter:String = Mid(word, pos, 1)
			
			If currentLetter.ToUpper() = currentLetter Then
				convertedName:+ "_"
			End If
		
			convertedName :+ currentLetter
			pos:+ 1
		Wend
		
		Return convertedName
		
	End Method
	
	Method getTypeFieldForConfigurationKey:TField(ruleType:TTypeId, name:String)
		Return ruleType.FindField(name.Replace("_", ""))
	End Method
	
End Type
