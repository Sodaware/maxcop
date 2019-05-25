' ------------------------------------------------------------------------------
' -- src/core/service_manager.bmx
' --
' -- Manages application services. Keeps track of all services and can start
' -- and stop them.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "../services/service.bmx"

Type ServiceManager

	Field _services:TList           = New TList
	Field _serviceLookup:TMap       = New TMap


	' ------------------------------------------------------------
	' -- Adding and getting services
	' ------------------------------------------------------------

	''' <summary>Add a service to the manager.</summary>
	''' <param name="service">The service object to add.</param>
	Method addService(service:Service)
		Self._services.AddLast(service)
		Self._serviceLookup.Insert(TTypeId.ForObject(service), service)
	End Method

	''' <summary>Get a service by its name.</summary>
	Method get:Service(name:String)
		Return Self.getService(TTypeId.ForName(name))
	End Method

	''' <summary>Get a service by its type id.</summary>
	''' <param name="serviceType">The TTypeId to find.</param>
	Method getService:Service(serviceType:TTypeId)

		' Get service from lookup
		Local theService:Service = Service(Self._serviceLookup.ValueForKey(serviceType))

		' If not found, search the list of services
		If theService = Null Then

			For Local tService:Service = EachIn Self._services
				If TTypeId.ForObject(tService) = serviceType Then
					theService = tService
					Exit
				End If
			Next
			' TODO: If still not found, throw an error
		EndIf

		' Done
		Return theService

	End Method


	' ------------------------------------------------------------
	' -- Initializing and stopping services
	' ------------------------------------------------------------

	Method initaliseServices()
		For Local tService:Service = EachIn Self._services
			tService.initialiseService()
		Next
	End Method

	Method stopServices()
		Self._services.Reverse()
		For Local tService:Service = EachIn Self._services
			tService.unloadService()
		Next
	End Method

End Type
