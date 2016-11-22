' ------------------------------------------------------------
' -- core/exceptions.bmx
' --
' -- Exceptions used by application.
' ------------------------------------------------------------


SuperStrict

Type MaxCopException Extends TRuntimeException
End Type

Type FormatterNotFoundException Extends MaxCopException
	Function Create:FormatterNotFoundException(message:String)
		Local e:FormatterNotFoundException = New FormatterNotFoundException
		e.error = message
		Return e
	End Function
End Type
