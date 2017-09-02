' ------------------------------------------------------------------------------
' -- reporters/offense.bmx
' --
' -- An offense stores information about a rule breakage.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import cower.bmxlexer
Import "../core/source_file.bmx"

Type Offense
	
	Field _source:SourceFile
	Field _line:Int
	Field _column:Int
	Field _severity:Int
	Field _message:String
	Field _excerpt:String
	Field _length:Int
	
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	Method setExcerpt:Offense(excerpt:String)
		Self._excerpt = excerpt
		Return Self
	End Method
	
	Method setExcerptLength:Offense(length:Int)
		Self._length = length
		Return Self
	End Method
	
	Method setLocation:Offense(line:Int, column:Int, length:Int = -1)
		Self._line = line
		Self._column = column
		Self._length = length
		Return self
	End Method
	
	Method setLocationFromToken:Offense(token:TToken)
		Self._line   = token.line
		Self._column = token.column
		Return self
	End Method
	
	
	' ------------------------------------------------------------
	' -- Querying
	' ------------------------------------------------------------
	
	Method getExcerpt:String()
		Return Self._excerpt
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------
	
	Function Create:Offense(source:SourceFile, message:String, severity:Int = 0)
		Local this:Offense = New Offense
		this._source = source
		this._message = message
		this._severity = severity
		Return this
	End Function
	
End Type
