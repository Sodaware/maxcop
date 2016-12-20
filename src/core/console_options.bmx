' ------------------------------------------------------------
' -- core/console_options.bmx
' --
' -- Wraps command line options in a type that can be queried.
' ------------------------------------------------------------


SuperStrict

Import brl.map
Import sodaware.Console_Color
Import sodaware.Console_CommandLine

Type ConsoleOptions Extends CommandLineOptions
	
	' ------------------------------------------------------------
	' -- Option Definitions
	' ------------------------------------------------------------

	Field NoLogo:Int = False { ..
		Description="Hides the copyright notice and header information" .. 
		LongName="nologo" .. 
		ShortName="n" }
	
	Field InputFile:String = "" { ..
		Description="The input file or module to parse" .. 
		LongName="input" .. 
		ShortName="i"  }
	
	Field Format:String = "simple" { ..
		Description="The formatter to use" ..
		LongName="format" ..
		ShortName="f" }
	
	Field ModPath:String = "" { ..
		Description="The full path to the blitzmax module directory" ..
		LongName="mod-path" ..
		ShortName="m" }
	
	Field Silent:Int = False { ..
		Description="Supresses output to the console" ..
		LongName="silent" ..
		ShortName="s" }
	
	Field showVersionInfo:Byte = False { ..
		Description="Displays the current version and exits." ..
		LongName="version" ..
		ShortName="v" }
	
	Field showVerboseVersionInfo:Byte = False { ..
		Description="Displays more detailed version info and exits." ..
		LongName="verbose-version" ..
		ShortName="V" }
		
	Field configFile:String = "" { ..
		Description="Path of configuration file to use" ..
		LongName="config" ..
		shortname="c" }

	Field Help:Int		= False
	
	
	' ------------------------------------------------------------
	' -- Help Message
	' ------------------------------------------------------------
	
	''' <summary>Show the help for this application.</summary>
	Method showHelp() 
		
		PrintC "Usage%n: maxcop [options] [--input input] [--output output]"
		PrintC "" 
		PrintC "Checks source code for style guidelines."
		PrintC ""
		
		PrintC "%YCommands:%n "
		
		PrintC(Super.CreateHelp(80, True))
		
	End Method
	
		
	' ------------------------------------------------------------
	' -- Helpers
	' ------------------------------------------------------------

	''' <summary>Check if all required inputs have been sent.</summary>
	Method isEmpty:Byte()
		Return Not(Self.InputFile) And Not(Self.hasArguments())
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	
	Method New()
		Super.Init(AppArgs)
	End Method
	
End Type
