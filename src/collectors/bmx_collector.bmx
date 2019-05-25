' ------------------------------------------------------------------------------
' -- collectors/bmx_collector.bmx
' --
' -- Finds BlitzMax source files.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.linkedlist
Import cower.bmxlexer
Import sodaware.blitzmax_array
Import sodaware.file_fnmatch

Import "../core/exceptions.bmx"
Import "base_collector.bmx"


Type BmxCollector Extends BaseCollector

	Field _modPath:String


	' ------------------------------------------------------------
	' -- Configuration
	' ------------------------------------------------------------

	Method setModPath:BmxCollector(modPath:String)
		Self._modPath = modPath

		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Fetching Sources
	' ------------------------------------------------------------

	''' <summary>Get all source files passed in to the application.</summary>
	Method getSources:TList()

		' Create list of all source files
		Local sources:TList = New TList

		For Local source:String = EachIn Self._files
			Self._addFilesToSourceList(sources, source)
		Next

		Return sources

	End Method


	' ------------------------------------------------------------
	' -- Finding the root
	' ------------------------------------------------------------

	Method getRootPath:String()
		If Self._root Then Return Self._root


	End Method


	' ------------------------------------------------------------
	' -- Internal Scanning
	' ------------------------------------------------------------

	Method _addFilesToSourceList(sources:TList, source:String)

		' If source is a module, get all sources it contains
		If Self.isModule(source) Then
			' Check mod-path is configured.
			If Self._modPath = "" Then
				Throw ApplicationConfigurationException.Create("Cannot scan module - mod_path is not set for this platform")
			EndIf

			If Self.moduleExists(source) Then
				Local modSources:TList = Self.getModuleSources(source)

				For Local modSource:String = EachIn modSources
					sources.AddLast(modSource)
				Next

				Return
			EndIf
		EndIf

		' If source is a directory, get all sources it contains
		If Self.isDirectory(source) Then
			Local directorySources:TList = Self.getDirectorySources(source)
			For Local dirSource:String = EachIn directorySources
				sources.AddLast(dirSource)
			Next
			Return
		End If

		' If not using the absolute path to the source file AND it's not a module, make it absolute
		sources.AddLast(Self.convertToFullPath(source))

	End Method


	' ----------------------------------------------------------------------
	' -- Module Helpers
	' ----------------------------------------------------------------------

	Method getModulePath:String(moduleName:String)
		Return RealPath(Self._modPath + "/" + moduleName.Replace(".", ".mod/") + ".mod/")
	End Method

	Method getModuleFilePath:String(moduleName:String)
		Local nameParts:String[] = moduleName.Split(".")
		If nameParts.Length <> 2 Then Return ""
		Local mainFile:String = nameParts[1] + ".bmx"
		Return RealPath(Self.getModulePath(moduleName) + "/" + mainFile)
	End Method

	Method moduleExists:Byte(moduleName:String)
		Return FileType(Self.getModulePath(moduleName)) = FILETYPE_DIR
	End Method

	''' <summary>
	''' Get all source files used by a module. Parses each source file to find "include" and
	''' "import" statements and attempts to build a source tree. Can be a little slow, so use
	''' the getModuleSourcesFast if performance is an issue.
	''' <summary>
	Method getModuleSources:TList(moduleName:String)

		' Get the module's main file
		Local moduleFile:String = Self.getModuleFilePath(moduleName)

		' Create initial list of module files and add this one
		Local moduleFiles:TList = New TList
		moduleFiles.AddLast(moduleFile)

		' Add all files
		Self.getAllIncludedFiles(moduleFiles, moduleFile)

		Return moduleFiles

	End Method

	Method getAllIncludedFiles(sources:TList, fileName:String)

		' Get the base path so it's possible to get the absolute path of the file
		Local sourceDirectory:String = ExtractDir(filename)

		' Create the lexer and parse the source file
		Local lexer:TLexer = New TLexer
		lexer.InitWithSource(Self._loadFile(fileName))
		lexer.Run()

		' Extract includes and imports
		Local pos:Int = 0
		Local currentToken:TToken

		While pos < lexer.NumTokens()

			currentToken = lexer.GetToken(pos)

			' Create a type
			Select currentToken.kind

				Case TToken.TOK_INCLUDE_KW, TToken.TOK_IMPORT_KW
					Local filenameToken:ttoken = lexer.GetToken(pos + 1)
					If filenameToken.kind = TToken.TOK_STRING_LIT Then

						' Get the file path
						Local toIncludeFilePath:String = RealPath(sourceDirectory + "/" + filenameToken.ToString().Replace("~q", ""))

						' If filename is NOT in the list already, parse it
						If False = sources.Contains(toIncludeFilePath) Then
							Self.getAllIncludedFiles(sources, toIncludeFilePath)
						End If

						' Add to the list of sources
						sources.AddLast(toIncludeFilePath)

						pos :+ 1

					End If

				' Any of the followign tokens are allowed before an `import` and `include` statement
				Case TToken.TOK_STRICT_KW
				Case TToken.TOK_SUPERSTRICT_KW
				Case TToken.TOK_LINE_COMMENT
				Case TToken.TOK_BLOCK_COMMENT
				Case TToken.TOK_NEWLINE
				Case TToken.TOK_FRAMEWORK_KW
				Case TToken.TOK_MODULE_KW
				Case TToken.TOK_MODULEINFO_KW
				Case TToken.TOK_ID
				Case TToken.TOK_DOT
				Case TToken.TOK_STRING_LIT

				' Keyword is not allowed after an import/include, so exit the loop.
				' This assumes that the source is formatted correctly.
				Default
					Return

			End Select

			pos :+ 1

		Wend


	End Method

	Method _loadFile:String(fileName:String)

		Local fileIn:TStream = ReadFile(fileName)
		Local source:String  = "";
		While Not(fileIn.Eof())
			source:+ fileIn.ReadLine() + "~n"
		Wend

		fileIn.Close()

		Return source

	End Method

	Method getModuleSourcesFast:TList(moduleName:String)

		' Create empty list of files and get the module path
		Local directoryFiles:TList = New TList
		Local directory:String     = Self.getModulePath(moduleName)

		' Read all files in the module's directory
		Self.getAllFilesInDirectory(directoryFiles, directory)

		' Filter the list to only include BlitzMax files
		Return tlist_filter(directoryFiles, isBlitzMaxFile)

	End Method

	Method getDirectorySources:TList(directory:String)

		' Create empty list of files and get the module path
		Local directoryFiles:TList = New TList

		' Read all files in the module's directory
		Self.getAllFilesInDirectory(directoryFiles, directory)

		' Filter the list to only include BlitzMax files
		Return tlist_filter(directoryFiles, isBlitzMaxFile)

	End Method


	Method getAllFilesInDirectory(fileList:TList, directory:String)

		Local folderHandle:Int = ReadDir(directory)
		Local fileName:String

		Repeat

			fileName = NextFile(folderHandle)

			If fileName And fileName <> "." And fileName <> ".." Then
				Local fullPath:String = RealPath(directory + "/" + fileName)

				If FileType(fullPath) = FILETYPE_DIR Then
					Self.getAllFilesInDirectory(fileList, fullPath)
				Else
					fileList.AddLast(fullPath)
				End If
			End If

		Until (fileName = Null)

		CloseDir(folderHandle)

	End Method

	' ----------------------------------------------------------------------
	' -- Input Helpers
	' ----------------------------------------------------------------------

	Method sourceExists:Byte(source:String)

		If Self.isModule(source) Then
			Return Self.moduleExists(source)
		Else
			Return FileType(source) = FILETYPE_FILE
		End If

	End Method

	Method isModule:Byte(source:String)
		Return Not(Self.isBlitzMaxSourceFile(source)) And Not(Self.isDirectory(source))
	End Method

	Method isDirectory:Byte(source:String)
		Return FileType(source) = FILETYPE_DIR
	End Method

	Method convertToFullPath:String(source:String)
		If source.EndsWith(".bmx") And RealPath(source) <> source Then
			Return RealPath(LaunchDir + "/" + source)
		End If

		Return source
	End Method

	Method isBlitzMaxSourceFile:Byte(source:String)
		Return ExtractExt(source) = "bmx"
	End Method

	Function canIgnoreFile:Byte(fileName:String)
		If fnmatch(fileName, "*/tests/*") Then Return True
		If fnmatch(fileName, "*/test/*") Then Return True
		If fnmatch(fileName, "*/examples/*") Then Return True
		Return False
	End Function

	' TODO: Fix this
	Function isBlitzMaxFile:Byte(file:Object)
		Local fileName:String = file.ToString()
		If fnmatch(fileName, "*/tests/*") Then Return False
		If fnmatch(fileName, "*/test/*") Then Return False
		If fnmatch(fileName, "*/examples/*") Then Return False
		If fnmatch(fileName, "*/Copy of*") Then Return False
		Return ExtractExt(fileName) = "bmx"
	End Function

End Type
