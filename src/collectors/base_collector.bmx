' ------------------------------------------------------------------------------
' -- collectors/base_collector.bmx
' --
' -- Collectors are used to find source files for loading at
' -- a later time.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type BaseCollector

	Field _files:TList	= New TList
	Field _root:String

	Method setFiles(files:TList)
		Self._files = files
	End Method

	Method setRoot(path:String)
		Self._root = path
	End Method

	Method addPath(path:String)
		Self._files.addLast(path)
	End Method

	Method getSources:TList() Abstract
	Method getRootPath:String() Abstract

End Type
