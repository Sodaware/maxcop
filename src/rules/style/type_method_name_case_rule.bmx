' ------------------------------------------------------------
' -- rules/style/type_method_name_case_rule.bmx
' --
' -- Check pseudo-private field names are prefixed with an
' -- underscore, not `m_`.
' ------------------------------------------------------------


SuperStrict

Import brl.retro
Import "../base_rule.bmx"

Type Style_TypeMethodNameCaseRule Extends BaseRule

	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------
	
	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		
		' Only for "Method" keywords
		If token.kind <> TToken.TOK_METHOD_KW Then Return
		
		' Get the method name
		Local methodToken:TToken = lexer.GetToken(position + 1)
		
		' Ignore "New"
		If methodToken.ToString().ToLower() = "new" Then Return
		
		' Get the first character
		Local firstLetter:String = Left(methodToken.ToString().Replace("_", ""), 1)
		If firstLetter.ToLower() <> firstLetter Then
			Local o:Offense = Offense.Create(source, Self._getMessage(methodToken))
			o.setLocation(token.line, token.column, 7 + methodToken.ToString().Length)
			o.setExcerpt(source.getLine(token.line - 1))
			Self.addFileOffense(source, o)
		End If
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------
	
	Method _getMessage:String(methodToken:TToken)
		Local message:String = "First letter of method name `"
		message :+ methodToken.ToString()
		message :+ "` should be lower-case"
		Return message
	End Method
	
End Type
