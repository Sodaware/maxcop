' ------------------------------------------------------------------------------
' -- assembly_info.bmx
' --
' -- Application information that won't change that often.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Const FINAL_BUILD:Int		= True

''' <summary>Type containing information about this assembly (application)</summary>
Type AssemblyInfo
	
	Const NAME:String         = "maxcop"
	Const VERSION:String      = "0.1.0.0"
	Const RELEASE_DATE:String = "November 11th, 2016"
	Const COPYRIGHT:String    = "2016-2017 Phil Newton"
	Const HOMEPAGE:String     = "https://www.sodaware.net/maxcop/"
	
End Type
