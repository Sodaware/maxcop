' ------------------------------------------------------------------------------
' -- core/exceptions.bmx
' --
' -- Exceptions used by application.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type MaxCopException
	Field error:String
	Method ToString:String()
		Return error
	End Method
End Type

Type FormatterNotFoundException Extends MaxCopException
	Function Create:FormatterNotFoundException(message:String)
		Local e:FormatterNotFoundException = New FormatterNotFoundException
		e.error = message
		Return e
	End Function
End Type

''' <summary>
''' Exception thrown when a configuration field is invalid.
''' </summary>
Type ApplicationConfigurationException Extends MaxCopException
	Field _section:String
	Field _key:String

	Function Create:ApplicationConfigurationException(message:String, section:String = "", key:String = "")
		Local e:ApplicationConfigurationException = New ApplicationConfigurationException
		e._section = section
		e._key = key
		e.error = message
		Return e
	End Function
	
	Method ToString:String()
		Local message:String = ""
		If Self._section And Self._key Then
			message = Self._section + ":" + Self._key + " - "
		EndIf
		message :+ Self.error
		Return message
	End Method
End Type

''' <summary>
''' Exception thrown when a command line argument is invalid.
''' </summary>
Type CommandLineArgumentsException Extends MaxCopException
	Field _option:String
	Field _optionValue:String
	
	Function Create:CommandLineArgumentsException(message:String, option:String = "", optionValue:String = "")
		Local e:CommandLineArgumentsException = New CommandLineArgumentsException
		e._option = option
		e._optionValue = optionValue
		e.error = message
		Return e
	End Function
	
	Method ToString:String()
		Local message:String = "Invalid command line option: "
		If Self._option And Self._optionValue
			message:+ Self._option + "=" + Self._optionValue+ " : "
		EndIf
		message :+ Self.error
		Return message
	End Method
End Type
