' ------------------------------------------------------------
' -- services/configuration_service.bmx
' --
' -- Manages the application configuration. This is the global
' -- configuration that affects all parts of the application.
' ------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.File_Util
Import sodaware.file_config
Import sodaware.file_config_iniserializer
Import sodaware.file_config_sodaserializer

Import "service.bmx"

''' <summary>
''' Manages the application configuration. This is the global
''' configuration that affects all parts of the application.
''' </summary>
Type ConfigurationService Extends Service

	Field _config:Config			'''< Internal configuration object
	
	
	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------
	
	''' <summary>Get a value from the application configuration.</summary>
	Method get:String(sectionName:String, keyName:String)
		Return Self._config.getKey(sectionName, keyName)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()
		Self._config = New Config
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
	
		' Check for various configuration files and attempt to load them.
		If Self.configurationFileExists("maxcop.soda") Then
			SodaConfigSerializer.Load(Self._config, Self.configurationFilePath("maxcop.soda"))
		ElseIf Self.configurationFileExists("maxcop.ini") Then
			IniConfigSerializer.Load(Self._config, Self.configurationFilePath("maxcop.ini"))
		EndIf
		
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
	
End Type
