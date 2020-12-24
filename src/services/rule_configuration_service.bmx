' ------------------------------------------------------------------------------
' -- services/rule_configuration_service.bmx
' --
' -- Manages which rules are enabled and disabled. These settings may come from
' -- the command line, but can also be loaded from a configuration file in the
' -- project's directory.
' --
' -- Scans for the following files:
' --  - .maxcop.ini
' --  - maxcop_rules.ini
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.reflection
Import sodaware.file_util
Import sodaware.file_config
Import sodaware.file_config_iniserializer

Import "service.bmx"
Import "../rules/base_rule.bmx"

Type RuleConfigurationService Extends Service

	Field _rootPath:String              '< Project root path.
	Field _config:Config                '< Holds the base configuration that all others will extend (for now).
	Field _rules:TList                  '< Holds all rules.


	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------

	Method setProjectRoot:RuleConfigurationService(path:String)
		Self._rootPath = path

		Return Self
	End Method

	Method setRules:RuleConfigurationService(rules:TList)
		Self._rules = rules

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Fetching Rules
	' ------------------------------------------------------------

	' Get rules with default configuration.
	Method getDefaultRules:TList()
		Return Self.configureRules(Self._copyRules(), Self._config)
	End Method

	' Get rules with configuration for file.
	Method getRulesForFile:TList(file:String)
		Return Self.configureRules(Self._copyRules(), Self.getConfigurationForFile(file))
	End Method


	' ------------------------------------------------------------
	' -- Loading
	' ------------------------------------------------------------

	' Load the default configuration.
	Method loadDefaultConfiguration()
		Local path:String = Self.findConfigForDirectory(Self._rootPath)
		If path <> "" Then
			Self._config = Self.loadConfigurationFile(path)
		EndIf

		' TODO: Configure rules here?
	End Method

	Method getConfigurationForFile:Config(file:String)
		Local path:String = Self.findConfigForFile(file)
		If path = "" Then Return Self._config

		Return Self.loadConfigurationFile(path)
	End Method

	Method findConfigForFile:String(path:String)
		' Strip file name.
		path = ExtractDir(path)

		While path <> "/" And ExtractDir(path) <> path
			Local configPath:String = Self.findConfigForDirectory(path)
			If configPath <> "" Then Return configPath

			path = ExtractDir(path)
		Wend

		Return ""
	End Method

	Method findConfigForDirectory:String(path:String)
		Local allowedFiles:String[] = ["maxcop_rules.ini", ".maxcop.ini"]

		For Local file:String = EachIn allowedFiles
			If FileType(file_util.pathCombine(path, file)) = FILETYPE_FILE Then
				Return file_util.pathCombine(path, file)
			EndIf
		Next

		Return ""
	End Method

	Method loadConfigurationFile:Config(path:String)
		Local c:Config = New Config
		IniConfigSerializer.Load(c, path)

		Return c
	End Method


	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()
		Self._config = New Config
	End Method

	Method unloadService()
	End Method


	' ------------------------------------------------------------
	' -- Rule configuration helpers
	' ------------------------------------------------------------

	' Configure a collection of rules and return it.
	Method configureRules:TList(rules:TList, c:Config)
		' Get list of all disabled rules.
		Local disabledRules:TList = Self.getDisabledRules(c)

		For Local rule:BaseRule = EachIn rules
			' Enable or disable the rule and configure it.
			rule.setEnabled(Self.isRuleEnabled(rule, disabledRules))
			Self.configureRule(rule, c)
		Next

		Return rules
	End Method

	Method configureRule(rule:BaseRule, c:Config)
		' Get rule type info and name.
		Local ruleType:TTypeId = TTypeId.ForObject(rule)
		Local ruleName:String  = Self.getRuleNameForTypeId(ruleType)

		' Get config block.
		Local configKeys:TList = c.getSectionKeys(ruleName)
		If configKeys <> Null Then
			For Local key:String = EachIn configKeys

				' Skip enable block.
				If key.tolower() = "enabled" Then Continue
				If key.StartsWith("_") Then Continue

				Local fieldToModify:TField = Self.getTypeFieldForConfigurationKey(ruleType, key)
				If fieldToModify <> Null Then
					fieldToModify.Set(rule, c.getKey(ruleName, key))
				End If
			Next
		EndIf

	End Method

	Method isRuleBlock:Byte(blockName:String)
		Return blockName.toLower() <> "ignored_files"
	End Method

	Method isRuleEnabled:Byte(rule:BaseRule, disabledRules:TList)
		Return Not(disabledRules.Contains(TTypeId.ForObject(rule)))
	End Method

	Method getDisabledRules:TList(c:Config)
		Local disabledRules:TList = New TList

		For Local ruleName:String = EachIn c.getSections()
			' Skip none-rule blocks
			If Not(Self.isRuleBlock(ruleName)) Then Continue

			If c.getKey(ruleName, "enabled", "true").ToLower() = "false" Then
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

	Method _copyRules:Tlist()
		Local rules:TList = New TList

		For Local r:BaseRule = EachIn Self._rules
			rules.addLast(r.clone())
		Next

		Return rules
	End Method

End Type
