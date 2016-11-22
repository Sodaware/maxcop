' ------------------------------------------------------------
' -- core/exceptions.bmx
' --
' -- Exceptions used by application.
' ------------------------------------------------------------


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