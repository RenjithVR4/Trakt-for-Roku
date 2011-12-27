
function breakDownAndParse(in as String) as String
	length = len(in)
	current = 0
	parsedString$ = ""
	
	while current < length
		parsedString$ = parsedString$ + SimpleJSONBitParser(Mid(in, current, 5000))
		current = current + 5000
	end while
	return parsedString$

end function
Function SimpleJSONBitParser( jsonString As String ) As String
    ' setup "null" variable
    null = invalid
    
    regex = CreateObject( "roRegex", Chr(34) + "([a-zA-Z0-9_\-\s]*)" + Chr(34) + "\:", "i" )
    regexSpace = CreateObject( "roRegex", "[\s]", "i" )
    regexQuote = CreateObject( "roRegex", "\\" + Chr(34), "i" )

    ' Replace escaped quotes
    jsonString = regexQuote.ReplaceAll( jsonString, Chr(34) + " + Chr(34) + " + Chr(34) )
    
    jsonMatches = regex.Match( jsonString )
    iLoop = 0
    While jsonMatches.Count() > 1
        ' strip spaces from key
        key = regexSpace.ReplaceAll( jsonMatches[ 1 ], "" )
        jsonString = regex.Replace( jsonString, key + ":" )
        jsonMatches = regex.Match( jsonString )

        ' break out if we're stuck in a loop
        iLoop = iLoop + 1
        If iLoop > 5001 Then
            Exit While
        End If
    End While

    'jsonObject = CreateObject("roString")
    ' Eval the BrightScript formatted JSON string
   ' Eval( "jsonObject = " + jsonString )
    Return jsonString
End Function

Function simpleJSONParser( jsonString As String ) As Object
        q = chr(34)

        beforeKey  = "[,{]"
        keyFiller  = "[^:]*?"
        keyNospace = "[-_\w\d]+"
        valueStart = "[" +q+ "\d\[{]|true|false|null"
        reReplaceKeySpaces = "("+beforeKey+")\s*"+q+"("+keyFiller+")("+keyNospace+")\s+("+keyNospace+")\s*"+q+"\s*:\s*(" + valueStart + ")"

        regexKeyUnquote = CreateObject( "roRegex", q + "([a-zA-Z0-9_\-\s]*)" + q + "\:", "i" )
        regexKeyUnspace = CreateObject( "roRegex", reReplaceKeySpaces, "i" )
        regexQuote = CreateObject( "roRegex", "\\" + q, "i" )

        ' setup "null" variable
        null = invalid

        ' Replace escaped quotes
        jsonString = regexQuote.ReplaceAll( jsonString, q + " + q + " + q )

        while regexKeyUnspace.isMatch( jsonString )
                jsonString = regexKeyUnspace.ReplaceAll( jsonString, "\1"+q+"\2\3\4"+q+": \5" )
        end while

        jsonString = regexKeyUnquote.ReplaceAll( jsonString, "\1:" )

        jsonObject = invalid
        ' Eval the BrightScript formatted JSON string
        Eval( "jsonObject = " + jsonString )
        Return jsonObject
End Function


Function SimpleJSONBuilder( jsonArray As Object ) As String
    Return SimpleJSONAssociativeArray( jsonArray )
End Function


Function SimpleJSONAssociativeArray( jsonArray As Object ) As String
    jsonString = "{"
    
    For Each key in jsonArray
        jsonString = jsonString + Chr(34) + key + Chr(34) + ":"
        value = jsonArray[ key ]
        
        If Type( value ) = "roString" Then
            jsonString = jsonString + Chr(34) + value + Chr(34)
        else  If Type( value ) = "String" Then
            jsonString = jsonString + Chr(34) + value + Chr(34)
        Else If Type( value ) = "roInt" Or Type( value ) = "roFloat" Then
            jsonString = jsonString + value.ToStr()
        Else If Type( value ) = "roBoolean" Then
            jsonString = jsonString + IIf( value, "true", "false" )
        Else If Type( value ) = "roArray" Then
            jsonString = jsonString + SimpleJSONArray( value )
        Else If Type( value ) = "roAssociativeArray" Then
            jsonString = jsonString + SimpleJSONBuilder( value )
        End If
        jsonString = jsonString + ","
    Next
    If Right( jsonString, 1 ) = "," Then
        jsonString = Left( jsonString, Len( jsonString ) - 1 )
    End If
    
    jsonString = jsonString + "}"
    Return jsonString
End Function


Function SimpleJSONArray( jsonArray As Object ) As String
    jsonString = "["
    
    For Each value in jsonArray
        If Type( value ) = "roString" Then
            jsonString = jsonString + Chr(34) + value + Chr(34)
        Else If Type( value ) = "roInt" Or Type( value ) = "roFloat" Then
            jsonString = jsonString + value.ToStr()
        Else If Type( value ) = "roBoolean" Then
            jsonString = jsonString + IIf( value, "true", "false" )
        Else If Type( value ) = "roArray" Then
            jsonString = jsonString + SimpleJSONArray( value )
        Else If Type( value ) = "roAssociativeArray" Then
            jsonString = jsonString + SimpleJSONAssociativeArray( value )
        End If
        jsonString = jsonString + ","
    Next
    If Right( jsonString, 1 ) = "," Then
        jsonString = Left( jsonString, Len( jsonString ) - 1 )
    End If
    
    jsonString = jsonString + "]"
    Return jsonString
End Function

Function IIf( Condition, Result1, Result2 )
    If Condition Then
        Return Result1
    Else
        Return Result2
    End If
End Function
