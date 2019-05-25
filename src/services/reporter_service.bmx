' ------------------------------------------------------------------------------
' -- services/reporter_service.bmx
' --
' -- Service for working with output Reporters.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "service.bmx"
Import "../reporters/base_reporter.bmx"

Type ReporterService Extends Service

	Field _availableReporters:TMap


	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------

	Method getReporter:BaseReporter(name:String)

		' Only create valid Reporters
		If Not(Self.reporterExists(name)) Then Return Null

		' Create the new Reporter
		Local ReporterType:TTypeId = TTypeId(Self._availableReporters.ValueForKey(name))
		Return BaseReporter(ReporterType.NewObject())

	End Method

	Method reporterExists:Byte(name:String)
		Return (Self._availableReporters.ValueForKey(name) <> Null)
	End Method


	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()

		' Load all Reporter types using reflection data
		Local baseType:TTypeId = TTypeId.ForName("BaseReporter")
		For Local ReporterType:TTypeId = EachIn baseType.DerivedTypes()
			If ReporterType.MetaData("name") <> "" Then
				Self._availableReporters.Insert(ReporterType.MetaData("name"), ReporterType)
			EndIf
		Next

	End Method

	Method unloadService()

	End Method


	' ------------------------------------------------------------
	' -- Construction & Destruction
	' ------------------------------------------------------------

	Method New()
		Self._availableReporters = New TMap
	End Method

End Type
