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

Import brl.reflection
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
	' -- Helpers
	' ------------------------------------------------------------

	Method getNextNoneEmptyToken:TToken(lexer:TLexer, position:Int)
		Local nextToken:TToken
		While position < lexer.NumTokens()
			nextToken = lexer.GetToken(position)
			If Self._tokenIsWhitespace(nextToken)
				position :+ 1
				Continue
			EndIf

			Return nextToken
		Wend
	End Method

	Method _tokenIsWhitespace:Byte(token:TToken)
		If token.kind = TToken.TOK_NEWLINE Then Return True
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


	' ------------------------------------------------------------
	' -- BlitzMax methods
	' ------------------------------------------------------------

	Method clone:BaseRule()
		Local r:BaseRule = BaseRule(TTypeId.forObject(self).NewObject())

		r._name      = Self._name
		r._category  = Self._category
		r._isEnabled = Self._isEnabled

		Return r
	End Method

	Method toString:String()
		Local out:String = "#<BaseRule:" + TTypeId.forobject(Self).Name() + ", "
		If Self._isEnabled Then out :+ "on" Else out :+ "off"
		out :+ ">"

		Return out
	End Method

End Type
