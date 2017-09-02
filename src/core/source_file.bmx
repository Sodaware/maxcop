' ------------------------------------------------------------------------------
' -- core/source_file.bmx
' --
' -- Wraps information about a single source file.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist

Type SourceFile
	
	' Module stuff (handle this differently?)
	Field isModule:Byte
	Field moduleName:String
	
	Field name:String
	Field path:String
	Field source:String
	
	Field lastModified:String
	
	Field _lines:String[]
	
	Method getLines:String[]()
		If Self._lines = Null Then
			Self._lines = Self.source.Split("~n")
		EndIf
		Return Self._lines
	End Method
	
	Method getLine:String(line:Int)
		Return Self.getLines()[line]
	End Method
	
End Type
