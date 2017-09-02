' ------------------------------------------------------------------------------
' -- services/service.bmx
' --
' -- Base type all services must extend.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type Service Abstract
	Method initialiseService() Abstract
	Method unloadService() Abstract
End Type
