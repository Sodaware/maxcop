' ------------------------------------------------------------
' -- rules/style/field_name_prefix_rule.bmx
' --
' -- Check pseudo-private field names are prefixed with an
' -- underscore, not `m_`.
' ------------------------------------------------------------


SuperStrict

Import "../base_rule.bmx"

Type Style_FieldNamePrefixRule Extends BaseRule
	
	' ------------------------------------------------------------
	' -- Main Rule Execution
	' ------------------------------------------------------------
	
	Method checkToken(token:TToken, lexer:TLexer, position:Int, source:SourceFile)
		
		' Only for "Type" keywords
		'If token.kind <> TToken. Then Return
		If token.kind <> TToken.TOK_ID Or token.ToString().ToLower() <> "field" Then Return
		
		Local nextToken:TToken = lexer.GetToken(position + 1)
		
		' If next token does not start with T, complain
		If nextToken.ToString().StartsWith("m_") Then
			Local o:Offense = Offense.Create(source, Self._getMessage(nextToken))
			o.setLocationFromToken(token)
			o.setExcerpt(source.getLine(token.line - 1))
			o.setExcerptLength(5 + nextToken.ToString().Length)
			Self.addFileOffense(source, o)
		End If
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------
	
	Method _getMessage:String(fieldToken:TToken)
		Return "Field name `" + fieldToken.ToString() + "` should not start with m_, prefer just _"
	End Method
	
End Type
