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
	
	Field m_Services:TList			= New TList
	Field m_ServiceLookup:TMap		= New TMap
	
	Method addService(service:Service)
		Self.m_Services.AddLast(service)
		Self.m_ServiceLookup.Insert(TTypeId.ForObject(service), service)
	End Method
	
	Method hasService:Byte(name:String)
		
	End Method
	
	Method get:Service(name:String)
		Return Self.getService(TTypeId.ForName(name))
	End Method
	
	Method getService:Service(serviceName:TTypeId)
		
		' Get service from lookup
		Local theService:Service = Service(Self.m_ServiceLookup.ValueForKey(serviceName))
		
		' If not found, search the list of services
		If theService = Null Then
			
			For Local tService:Service = EachIn Self.m_Services
				If TTypeId.ForObject(tService) = serviceName Then
					theService = tService
					Exit
				End If
			Next
			' If still not found, throw an error
		EndIf
		
		' Done
		Return theService
		
	End Method
	
	Method initaliseServices()
		For Local tService:Service = EachIn Self.m_Services
			tService.InitialiseService()
		Next
	End Method
	
	Method stopServices()
		Self.m_Services.Reverse()
		For Local tService:Service = EachIn Self.m_Services
			tService.UnloadService()
		Next	
	End Method
	
End Type