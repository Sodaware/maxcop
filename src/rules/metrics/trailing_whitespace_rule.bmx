' ------------------------------------------------------------------------------
' -- rules/metrics/trailing_whitespace_rule.bmx
' --
' -- Rule to check there is no trailing whitespace at the end of a line.
' -- Ignores empty lines.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.blitzmax_ascii
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

			' Fix Windows line endings on Max/Linux
			line = self._normalizeLineEndings(line)

			If Self._lineHasTrailingWhitespace(line) Then

				' Convert tabs to spaces (for formatting reasons)
				line = line.Replace("~t", "    ")

				' Find the last none-whitespace character
				Local endPos:Int = Self._findLastNoneWhitespaceCharacter(line)

				Local o:Offense = Offense.Create(source, "Trailing whitespace at end of line")
				o.setLocation(lineNumber, endPos, line.Length - endPos + 1)
				o.setExcerpt(line)
				Self.addFileOffense(source, o)
			End If

			lineNumber:+ 1

		Next

	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _normalizeLineEndings:String(line:String)
		If line.Length = 0 Then Return line
		If line[line.Length - 1] = ASC_CR Or line[line.Length - 1] = ASC_LF Then
			line = Left(line, line.Length - 1)
		End If
		Return line
	End Method

	Method _lineHasTrailingWhitespace:Byte(line:String)
		If line.Trim() = "" Then Return False
		Return line.EndsWith(" ") Or line.EndsWith("~t")
	End Method

	Method _findLastNoneWhitespaceCharacter:Int(line:String)
		For Local pos:Int = line.Length - 1 To 0 Step -1
			If Mid(line, pos, 1) <> " " Then Return pos + 1
		Next
	End Method

End Type
