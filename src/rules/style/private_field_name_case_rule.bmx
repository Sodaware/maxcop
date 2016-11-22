' ------------------------------------------------------------
' -- rules/style/private_field_name_case_rule.bmx
' --
' -- Check that private fields (_ prefixed rules) start with
' -- a lower-case letter.
' ------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_PrivateFieldNameCasePrefixRule Extends BaseRule
	
	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------

	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		
		' Only for "Type" keywords
		'If token.kind <> TToken. Then Return
		If token.kind <> TToken.TOK_ID Or token.ToString().ToLower() <> "field" Then Return
		
		Local nextToken:TToken = lexer.GetToken(position + 1)
		
		' If next token does not start with _, ignore this rule
		If nextToken.ToString().StartsWith("_") = False Then Return
		
		' Get the first character
		Local firstLetter:String = Left(nextToken.ToString().Replace("_", ""), 1)
		If firstLetter.ToLower() <> firstLetter Then
			Local o:Offense = Offense.Create(source, Self._getMessage(nextToken))
			o.setLocation(token.line, token.column, 5 + nextToken.ToString().Length)
			o.setExcerpt(source.getLine(token.line - 1))
			Self.addFileOffense(source, o)
		End If
	End Method

	
	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------
	
	Method _getMessage:String(nameToken:TToken)
		Return "First letter of field name `" + nameToken.ToString() + "` should be lower-case"
	End Method
	
End Type
