' ------------------------------------------------------------
' -- services/service.bmx
' --
' -- Base type all services must extend.
' ------------------------------------------------------------


SuperStrict

Type Service Abstract
	Method initialiseService() Abstract
	Method unloadService() Abstract
End Type