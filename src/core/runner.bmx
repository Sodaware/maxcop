' ------------------------------------------------------------------------------
' -- core/runner.bmx
' --
' -- Runs the main scan.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Import "../reporters/base_reporter.bmx"
Import "../parsers/bmx_parser.bmx"

Type Runner

	Field _reporter:BaseReporter
	Field _sources:TList
	Field _enabledRules:TList


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	''' <summary>Set the reporter to use.</summary>
	Method setReporter:Runner(reporter:BaseReporter)
		Self._reporter = reporter
		Return Self
	End Method

	''' <summary>Set the source files to scan.</summary>
	Method setSources:Runner(sources:TList)
		Self._sources = sources
		Return Self
	End Method

	''' <summary>Set the list of rules to use.</summary>
	Method setEnabledRules:Runner(rules:TList)
		Self._enabledRules = rules
		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Main Execution
	' ------------------------------------------------------------

	Method execute()

		' Create the parser, add rules and setup reporting.
		Local parser:BmxParser = New BmxParser
		parser.addRules(Self._enabledRules)
		parser.setReporter(Self._reporter)

		' Start the scan
		Self._reporter.beforeScan(Self._sources)

		' Scan each file
		For Local file:String = EachIn Self._sources

			Self._reporter.beforeFileScan(file)

			parser.parse(file)

			Self._reporter.afterFileScan(file)

		Next

		' Finish the scan.		
		Self._reporter.afterScan()

	End Method

End Type
