' ------------------------------------------------------------------------------
' -- rules/metrics/trailing_whitespace_rule.bmx
' --
' -- Rule to check there is no trailing whitespace at the
' -- end of a line. Ignores empty lines.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

''' <summary>
''' Checks there is no trailing whitespace at the end of a line. Ignores empty lines.
''' </summary>
Type Metrics_TrailingWhitespaceRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkFile(source:SourceFile)
		
		Local lineNumber:Int = 1
		
		For Local line:String = EachIn source.getLines()
			If Self._lineHasTrailingWhitespace(line) Then
				Local o:Offense = Offense.Create(source, "Trailing whitespace at end of line")
				o.setLocation(lineNumber, 1, line.Length)
				o.setExcerpt(line)
				Self.addFileOffense(source, o)
			End If
			lineNumber:+ 1
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------
	
	Method _lineHasTrailingWhitespace:Byte(line:String)
		If line.Trim() = "" Then Return False
		Return line.EndsWith(" ") Or line.EndsWith("~t")
	End Method
	
End Type
