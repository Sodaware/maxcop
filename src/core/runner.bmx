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
		
	Method setReporter(reporter:BaseReporter)
		Self._reporter = reporter
	End Method
	
	Method setSources(sources:TList)
		Self._sources = sources
	End Method
	
	Method setEnabledRules(rules:TList)
		Self._enabledRules = rules
	End Method
	
	Method execute:Byte()
		
		' Start the scan
		Self._reporter.beforeScan(Self._sources)
		
		' Scan each file
		For Local file:String = EachIn Self._sources

			Self._reporter.beforeFileScan(file)

					
			' Create a parser for this file
			' TODO: This will change to Scanner I thnk...
			' TODO: This can be created outside of the loop
			Local parser:BmxParser = New BmxParser
			
			' Add rules
			For Local rule:BaseRule = EachIn Self._enabledRules
				parser.addRule(rule)
			Next
			
			
			' Parse the file into tokens
			' Set the reporter for this parser
			parser.setReporter(Self._reporter)
			'Local parsedFile:SourceFile = parser.parse(file)
			
			' Run each rule
			parser.parse(file)
			
			Self._reporter.afterFileScan(file)
			
			
		Next
		
		Self._reporter.afterScan()
		
	End Method
	
End Type
