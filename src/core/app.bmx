' ------------------------------------------------------------------------------
' -- core/app.bmx
' --
' -- Main application logic. Handles pretty much everything.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
Import brl.reflection
Import brl.retro

' -- Application Setup
Import "../assembly_info.bmx"
Import "exceptions.bmx"
Import "console_options.bmx"
Import "service_manager.bmx"
Import "runner.bmx"

' -- Services
Import "../services/configuration_service.bmx"
Import "../services/reporter_service.bmx"
Import "../services/rule_service.bmx"
Import "../services/rule_configuration_service.bmx"

' -- Collectors
Import "../collectors/base_collector.bmx"
Import "../collectors/bmx_collector.bmx"

' -- Reporters
Import "../reporters/simple_reporter.bmx"


''' <summary>Main maxcop application.</summary>
Type App
	
	Field _options:ConsoleOptions			'''< Command line options
	Field _services:ServiceManager			'''< Application services
	
	
	' ------------------------------------------------------------
	' -- Main application entry
	' ------------------------------------------------------------
	
	''' <summary>Application entry point.</summary>
	Method run:Int()
	
		' -- Setup the app
		Self._setup()
		
		' -- Show help message if requested - quit afterwards
		If Self._options.Help Then
			If Not(Self._options.NoLogo) Then Self.writeHeader()
			Self._options.showHelp()
			Self._shutdown()
		End If
		
		' -- Show version if requested and quit
		If Self._options.showVersionInfo Then
			Print AssemblyInfo.VERSION
			Return Self._shutdown()
		End If

		If Self._options.showVerboseVersionInfo Then
			Print AssemblyInfo.NAME + " " + AssemblyInfo.VERSION + " (Released: " + AssemblyInfo.RELEASE_DATE + ")"
			Print "(C)opyright " + AssemblyInfo.COPYRIGHT
			Return Self._shutdown()
		End If
		
		' -- Add standard services to ServiceManager
		Self.registerServices()
		
		' -- Initialise the services
		Self._services.initaliseServices()
		
		' -- Run!
		' TODO: Make these prettier...
'		Try
			Self._execute()
'		Catch e:FormatterNotFoundException
'			Print "Formatter not found: " + e.toString()
'		Catch e:MaxCopException
'			Print "oopS" + e.toString()
'		End Try
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Private execution
	' ------------------------------------------------------------
	
	''' <summary>Executes the selected build script & target.</summary>
	Method _execute()
		
		' Get required services
		Local reporters:ReporterService            = ReporterService(Self._services.get("ReporterService"))
		Local rules:RuleService                    = RuleService(Self._services.get("RuleService"))
		Local config:ConfigurationService          = ConfigurationService(Self._services.get("ConfigurationService"))
		Local rulesConfig:RuleConfigurationService = RuleConfigurationService(Self._services.get("RuleConfigurationService"))
		
		' Validate options
		If reporters.reporterExists(Self._options.Format) = False Then
			' TODO: Do something else here...
			Throw FormatterNotFoundException.Create(Self._options.Format)
		End If
		
		' Validate the configuration file
		Try
			config.validateConfiguration()
		Catch e:ApplicationConfigurationException
			Printc "%rConfiguration Error: %n" + e.tostring()
			Self._shutdown()
		End Try
		
		' Create a new runner
		Local run:Runner = New Runner
		
		' Set required options
		
		' Add parsers and formatters
		run.setReporter(reporters.getReporter(Self._options.Format))
		
		' Show the header
		If Not( Self._options.NoLogo Or run._reporter.hidesBanner() ) Then
			Self.writeHeader()
		EndIf
		
		' Set options
        ' [todo] - Don't pass these in direct
		'gen._options = Self._options
		
		' Collect all of the source files
		Local collector:BmxCollector = New BmxCollector
		collector.setModPath(config.get("mod_path", config.getPlatform()))
		Self._addFilesToCollector(collector)
		
		' Set source files
		run.setSources(collector.getSources())
		
		' TODO: Throw an error if no source files
		
		' Load the local rules configuration
		rulesConfig.findAndLoadConfiguration(collector.getRootPath())
		
		' Get and configure rules
		Local availableRules:TList = rules.getAllRules()
		rulesConfig.configureRules(availableRules)
		
		' Add all rules
		run.setEnabledRules(availableRules)

		' Run the whole thing
		run.execute()
		
		'loggers.getLogger().logSuccess("Documentation saved to ~q" + Self._options.output + "~q")
		
		' -- All done!
		Self._shutdown()
				
	End Method
	
	
	' ------------------------------------------------------------
	' -- Output methods
	' ------------------------------------------------------------
	
	''' <summary>Writes the application header.</summary>
	Method writeHeader()
		
		PrintC "%g" + AssemblyInfo.NAME + " " + AssemblyInfo.VERSION + " (Released: " + AssemblyInfo.RELEASE_DATE + ")"
		PrintC "(C)opyright " + AssemblyInfo.COPYRIGHT
		PrintC "%c" + AssemblyInfo.HOMEPAGE + "%n"
		PrintC ""
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Application setup & shutdown
	' ------------------------------------------------------------
	
	Method _setup()
	
		' Get command line options
		Self._options = New ConsoleOptions
		
		' Setup service manager
		Self._services = New ServiceManager
		
	End Method
	
	Method _shutdown()
		Self._services.StopServices()
		End
	End Method
	
	
	' ------------------------------------------------------------
	' -- Service Setup
	' ------------------------------------------------------------
	
	Method registerServices()
	
		' Add basic services that don't need configurating
		Self._services.addService(New ReporterService)
		Self._services.addService(New RuleService)
		
		' Setup and dd the rules configuration service
		Self._services.addService(New RuleConfigurationService)
		
		' Setup and add the configuration service
		Local configService:ConfigurationService = New ConfigurationService
		configService.setConfigurationFilePath(Self._options.configFile)
		Self._services.addService(configService)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Input Helpers
	' ------------------------------------------------------------
	
	Method _addFilesToCollector(collector:BmxCollector)
		
		' If input file is present, add it as-is
		If Self._options.inputfile Then
			collector.addPath(Self._options.InputFile)
		ElseIf Self._options.Arguments.Count() Then
			For Local arg:String = EachIn Self._options.Arguments
				
				' If this is a full-path, add it
				If RealPath(arg) = arg Then
					collector.addPath(arg)
				Else
					Local path:String = RealPath(LaunchDir + "/" + arg)
					If FileType(path) <> FILETYPE_NONE Then
						collector.addPath(path)
					Else
						collector.addpath(arg)
					EndIf
				EndIf
			Next
		Else
			' Default to the current directory
			collector.addPath(LaunchDir)
			collector.setRoot(LaunchDir)
		EndIf
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / destruction
	' ------------------------------------------------------------
	
	Function Create:App()
		Local this:App	= New App
		Return this
	End Function
	
End Type