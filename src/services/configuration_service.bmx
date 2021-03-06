' ------------------------------------------------------------------------------
' -- services/configuration_service.bmx
' --
' -- Manages the application configuration. This is the global configuration
' -- that affects all parts of the application. For example, paths to BlitzMax
' -- modules are set here.
' --
' -- Managing the configuration that enables and disables rules is performed by
' -- the RuleConfigurationService.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.File_Util
Import sodaware.file_config
Import sodaware.file_config_iniserializer
Import sodaware.file_config_sodaserializer

Import "service.bmx"
Import "../core/exceptions.bmx"

''' <summary>
''' Manages the application configuration. This is the global configuration
''' that affects all parts of the application.
''' </summary>
Type ConfigurationService Extends Service

	Field _config:Config                '''< Internal configuration object
	Field _configurationFile:String     '''< Full path of configuration file (if set manually)


	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------

	''' <summary>Get a value from the application configuration.</summary>
	Method get:String(sectionName:String, keyName:String)
		If Self._config = Null Then Return ""

		Return Self._config.getKey(sectionName, keyName)
	End Method

	Method setConfigurationFilePath:ConfigurationService(path:String)
		Self._configurationFile = path
		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()
		Self.loadConfiguration()
	End Method

	Method unloadService()
		Self._config = Null
		GCCollect()
	End Method


	' ------------------------------------------------------------
	' -- Loading configuration files
	' ------------------------------------------------------------

	Method loadConfiguration()

		' If configuration file was set manually, load it and ignore local config
		If Self._configurationFile Then
			If FILETYPE_FILE = FileType(Self._configurationFile) Then
				Self._config = Self.loadConfigurationFile(Self._configurationFile)
				Return
			Else
				Throw CommandLineArgumentsException.Create("Configuration file ~q" + Self._configurationFile + "~q not found")
			EndIf
		End If

		' Check for various configuration files and attempt to load them.
		Local path:String = Self._getDefaultConfigPath()
		If RealPath(path) <> path Then path = Self._normalizePath(path)

		' Load configuration file.
		Self._config = Self.loadConfigurationFile(path)
	End Method

	Method loadConfigurationFile:Config(fileName:String)
		Local config:Config = New Config

		Select ExtractExt(fileName.ToLower())
			Case "soda"
				SodaConfigSerializer.Load(config, fileName)
			Case "ini"
				IniConfigSerializer.Load(config, fileName)
		End Select

		Return config
	End Method


	' ------------------------------------------------------------
	' -- Validating the configuration
	' ------------------------------------------------------------

	Method hasConfiguration:Byte()
		Return Self._config <> Null
	End Method

	Method validateConfiguration()

		' Check a module path is set.
		If Self._config.getSectionKeys("mod_path") = Null Or Self._config.getSectionKeys("mod_path").Count() = 0 Then
			Throw ApplicationConfigurationException.Create("Configuration is missing `mod_path` configuration section")
		End If

		' Check module paths.
		If FILETYPE_DIR <> FileType(Self.get("mod_path", Self.getPlatform())) Then
			Throw ApplicationConfigurationException.Create( ..
				"Invalid module path ~q" + Self.get("mod_path", Self.getPlatform()) + "~q", ..
				"mod_path", Self.getPlatform() ..
			)
		End If

	End Method


	' ------------------------------------------------------------
	' -- Configuration location helpers
	' ------------------------------------------------------------

	Method configurationFileExists:Byte(name:String)
		Return FILETYPE_FILE = FileType(Self.configurationFilePath(name))
	End Method

	Method configurationFilePath:String(name:String)
		Return File_Util.PathCombine(AppDir, name)
	End Method

	''' <summary>
	''' Get the full path to the default configuration file.
	'''
	''' Tests for the following file names:
	'''   * `~/.maxcoprc`
	'''   * `~/.config/maxcop.ini`
	'''   * `~/.config/maxcop/config.ini`
	'''   * `maxcop.ini` in the execution directory.
	''' </summary>
	Method _getDefaultConfigPath:String()
		' List of allowed paths, highest-priority first.
		Local allowedPaths:String[] = [ ..
			File_Util.PathCombine(File_Util.GetHomeDir(), ".maxcoprc"), ..
			File_Util.PathCombine(File_Util.GetHomeDir(), ".config/maxcop.ini"), ..
			File_Util.PathCombine(File_Util.GetHomeDir(), ".config/maxcop/config.ini"), ..
			File_Util.PathCombine(AppDir, "maxcop.ini") ..
		]

		' Test each path and return the first one that exists.
		For Local path:String = EachIn allowedPaths
			If FILETYPE_FILE = FileType(path) Then Return path
		Next

		Return ""
	End Method

	Method _normalizePath:String(path:String)
		Return File_Util.PathCombine(LaunchDir, path)
	End Method


	' ------------------------------------------------------------
	' -- Platform Helpers
	' ------------------------------------------------------------

	Method getPlatform:String()
		?Win32
		Return "win32"
		?Linux
		Return "linux"
		?MacOs
		Return "macos"
		?
		Return "unknown"
	End Method

End Type
