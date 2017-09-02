' ------------------------------------------------------------------------------
' -- rules/base_rule.bmx
' --
' -- Type that ALL rules must extend.
' --
' -- This file is part of "maxcop" (https://www.sodaware.net/maxcop/)
' -- Copyright (c) 2016-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import cower.bmxlexer

Import "../core/source_file.bmx"
Import "../reporters/base_reporter.bmx"

Type BaseRule Abstract
	
	' -- Basic rule information
	Field _name:String
	Field _category:String
	Field _reporter:BaseReporter
	Field _isEnabled:Byte = True
	
	
	' ------------------------------------------------------------
	' -- Rule Information
	' ------------------------------------------------------------
	
	Method isDisabled:Byte()
		Return Not(Self._isEnabled)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Enabling / Disabling Rules
	' ------------------------------------------------------------
	
	Method enable()
		Self._isEnabled = True
	End Method
	
	Method disable()
		Self._isEnabled = False
	End Method
	
	Method setEnabled(isEnabled:Byte)
		Self._isEnabled = isEnabled
	End Method
	
	
	' ------------------------------------------------------------
	' -- Checking Stubs
	' ------------------------------------------------------------
	
	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		
	End Method
	
	Method checkFile(source:SourceFile)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Handling Offenses
	' ------------------------------------------------------------
	
	Method addFileOffense(source:SourceFile, o:Offense)
		Self._reporter.addFileOffense(source, o)
	End Method
	
End Type
