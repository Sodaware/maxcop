' ------------------------------------------------------------
' -- rules/style/line_length_rule.bmx
' --
' -- Check line length is under a specific limit.
' ------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Metrics_LineLengthRule Extends BaseRule
	
	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------
	
	Field maxLineLength:Int = 120
	
	
	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------
	
	Method checkFile(source:SourceFile)
		
		Local lineNumber:Int = 1
		
		For Local line:String = EachIn source.getLines()
			If Self._lineIsTooLong(line) Then
				Local o:Offense = Offense.Create(source, Self._buildMessageForLine(line))
				o.setLocation(lineNumber, Self.maxLineLength, line.Length - Self.maxLineLength)
				o.setExcerpt(line)
				Self.addFileOffense(source, o)
			End If
			lineNumber:+ 1
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------
	
	Method _lineIsTooLong:Byte(line:String)
		Return line.Length > Self.maxLineLength
	End Method
	
	Method _buildMessageForLine:String(line:String)
		Return "Line is too long. [" + line.Length + "/" + Self.maxLineLength + "]"
	End Method
	
End Type
