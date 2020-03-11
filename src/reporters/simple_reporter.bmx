' ------------------------------------------------------------------------------
' -- reporters/simple_reporter.bmx
' --
' -- Very simple reporter. Outputs warnings to the console with some location
' -- and colours.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.Console_Color

Import "base_reporter.bmx"

Type SimpleReporter Extends BaseReporter ..
	{ name = "simple" }

	Field _scannedFileCount:Int = 0


	' ----------------------------------------------------------------------
	' -- Before / After Scan Hooks
	' ----------------------------------------------------------------------

	''' <summary>Display the inspection overview before the scan is run.</summary>
	Method beforeScan(files:TList)
		Self._scannedFileCount = files.Count()
		Self.write(Self._pluralize("Inspecting %d file", Self._scannedFileCount))
	End Method

	Method afterScan()

		' Clear some space
		Print ; Print

		' If offenses, print them
		If Self._reportedOffenses.Count() Then
			Self._displayOffenses()
		EndIf

		' Output summary
		WriteC(Self._pluralize("%d file", Self._scannedFileCount) + " inspected")

		If Self._reportedOffenses.Count() Then
			WriteC(", ")

			PrintC("%R" + Self._pluralize("%d offense", Self._reportedOffenses.Count()) + "%n detected")
		End If

	End Method

	Method _displayOffenses()

		Print "Offenses:~n"

		' Do each file
		For Local fileName:String = EachIn Self._fileOffenses.Keys()

			' TODO: Normalise the filename
			Local offenses:TList = TList(Self._fileOffenses.ValueForKey(filename))

			' TODO: Sort the offenses by line number!
			offenses.Sort(True, SimpleReporter.SortOffenseByLineNumber)

			For Local o:Offense = EachIn offenses

				' Display the NORMALIZED filename
				WriteC("%C" + o._source.name + "%n:")

				' Display the location (line/column)
				WriteC(o._line + ":" + o._column + ": ")

				' Write the error level
				WriteC("%yC%n: " + Self.escape(o._message))

				' Write the line
				If o._excerpt Then
					Print
					Print o._excerpt

					If o._column And o._length Then
						Self._highlightLocation(o._column, o._length)
					End If
				Else
					Print
				End If

			Next
		Next

		Print

	End Method

	Method write(message:String)
		Print message
	End Method

	Method afterFileScan(file:String)

		' If file has warnings, print something else
		If Self.fileHasOffenses(file)
			WriteC("%YC%n")
		Else
			WriteC(".")
		EndIf
	End Method

	Method _highlightLocation(start:Int, length:Int)
		Local highlight:String = ""
		For Local i:Int = 0 To length - 1
			highlight:+ "^"
		Next
		Print RSet(highlight, start + length - 1)
	End Method

	Method escape:String(message:String)
		message = message.Replace("%", "%%")

		Return message
	End Method

	''' <summary>Ultra-simple pluralization support. Not for heavy-duty use.</summary>
	Method _pluralize:String(message:String, value:Int)
		message = message.Replace("%d", value)
		If value <> 1 Then message :+ "s"

		Return message
	End Method

	Function SortOffenseByLineNumber:Int(o1:Object, o2:Object)
		Local offense1:Offense = offense(o1)
		Local offense2:Offense = offense(o2)

		If offense1._line = offense2._line Then Return 0
		If offense1._line > offense2._line Then
			Return 1
		Else
			Return -1
		End If
	End Function

End Type
