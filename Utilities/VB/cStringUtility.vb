'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains methods to help with string manipulation.
'=======================================================================================

Public Class cStringUtility

#Region "------==== CONSTANTS ====-----------------------------------------------------"
Public Const gAttrDelim		As String = "="
Public Const gCr			As String = Chr(13)
Public Const gLf			As String = Chr(10)
Public Const gCrLf			As String = gCr + gLf
Public Const gDelimeter		As String = ";"
Public Const gQuote			As String = """"
Public Const gSpace			As String = Chr(32)
Public Const gTab			As String = Chr(8)
#End Region

#Region "------==== BuildSQLProcedureCall ====-----------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to parse list of arguments and construct a SQL statement.
'Input Params:
'				sProcedureName		- Julian date to parse.
'				aParams()			- The variable argument list.
'Returns:
'				String				- The SQL statement to execute.
'
Shared Public Function BuildSQLProcedureCall(sProcedureName As String, ParamArray aParams() As Object) As String
Dim sbSQL       As System.Text.StringBuilder	= New System.Text.StringBuilder("exec ", 1024)
Dim iArgIndex   As Integer	= 0
Dim sType		As String	= Nothing
Dim oCurrent	As Object	= Nothing
Const sDBO		As String	= "dbo."

On Error GoTo Produce_Error
    
    If (sProcedureName.ToLower().Substring(0, sDBO.Length) <> sDBO) Then
        sbSQL.Append(sDBO & sProcedureName & " ")
	Else
		sbSQL.Append(sProcedureName & " ")
    End If

    For iArgIndex = 0 To UBound(aParams)
		oCurrent = aParams(iArgIndex)
		sType = oCurrent.GetType().ToString()

        If (iArgIndex <> 0) Then
            sbSQL.Append(",")
        End If

        Select Case (sType)
        Case "System.Boolean"
            If (System.Convert.ToBoolean(oCurrent)) Then
                sbSQL.Append("1")
            Else
                sbSQL.Append("0")
            End If

        Case "System.DateTime"
            sbSQL.Append("'" & oCurrent.ToString() & "'")

        Case "System.Char", "System.String", "System.Text.StringBuilder"
			sbSQL.Append("'" & oCurrent.ToString().Replace("'", "''") & "'")
            'sbSQL.Append("'" & oCurrent.ToString() & "'")

        Case Else
            sbSQL.Append(oCurrent.ToString())
        End Select
    Next

    Return sbSQL.ToString()

Produce_Error:
    Call Err.Raise(Err.Number, "_5280Solutions.Shared.Utility.cStringUtility.BuildSQLProcedureCall" & Err.Source, Err.Description)
End Function
#End Region

#Region "------==== CountTokens ====---------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to count the tokens on a command line.
'Input Params:
'				sSearch		- String to parse.
'Returns:
'				Integer		- The number of tokens.
'Note:			Me.GetToken() takes into account whether the token is double quoted and
'				treats it as one token.
'
Public Function CountTokens(ByVal sSearch As String) As Integer
Dim iCount As Integer
Dim sToken As String

    If (Len(sSearch) > 0) Then
        sToken = Me.GetToken(sSearch, sSearch)
        iCount = iCount + 1
        Do While (sSearch <> "")
            sToken = Me.GetToken(sSearch, sSearch)
            iCount = iCount + 1
        Loop
    End If
    
    Return iCount
End Function
#End Region

#Region "------==== FormatPhone ====---------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to formata a 10 or 7 digit phone number.
'Input Params:
'				sPhone		- String to parse.
'Returns:
'				String		- Formatted phone number.
'
Public Function FormatPhone(ByVal sPhone As String) As String
Dim sResult As String = ""

	If (sPhone.Length = 10) Then
	' Peel off the area code.
		sResult = "(" + sPhone.Substring(0,3) + ") "
		sPhone = sPhone.Substring(3)
	End If

	If (sPhone.Length = 7) Then
		sResult &= sPhone.Substring(0, 3) + "-" + sPhone.Substring(3)
	Else
		Throw New cException("Phone must be 7 or 10 characters.")
	End If

	Return sResult
End Function
#End Region

#Region "------==== GetToken ====------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve a token (quoted or not) from a search string
'				and also return the remaining string.  (LISP - CAR/CDR)
'Input Params:
'				sSearch		- String to parse.
'				sRemaining	- Remaining string without the returned token.
'Returns:
'				String		- A token.
'Note:			This takes into account whether the token is double quoted and
'				treats it as one token.
'
Public Function GetToken(ByVal sSearch As String, ByRef sRemaining As String) As String
Dim token		As String = ""
Dim spacePos	As Integer = 0
Dim quotePos	As Integer = 0

' Look for spaces and or quotes.

    sSearch = sSearch.Trim()

    quotePos = sSearch.IndexOf(gQuote)
    
    If (quotePos = 0 And sSearch.Length > 1) Then
    ' Scan for the next quote and treat that as a token.
        quotePos = sSearch.IndexOf(gQuote, 1)
        If (quotePos >= 0) Then
			quotePos	+= 1
            token		= sSearch.Substring(0, quotePos)		'Left$(sSearch, quotePos)
            sRemaining	= sSearch.Substring(quotePos)			'Right$(sSearch, Len(sSearch) - quotePos)
        Else
        ' The whole string was "quoted....
            token		= sSearch
            sRemaining	= ""
        End If
    Else
        spacePos = sSearch.IndexOf(gSpace)
    
        If (spacePos >= 0) Then
            token		= sSearch.Substring(0, spacePos)	'Left$(sSearch, spacePos - 1)
            sRemaining	= sSearch.Substring(spacePos)	'Right$(sSearch, Len(sSearch) - spacePos)
        Else
            ' Nothing was found.
            token = sSearch
            sRemaining = ""
        End If
    End If

	Return token
End Function
#End Region

#Region "------==== ReplaceAttributeValue ====-----------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to count the tokens on a command line.
'Input Params:
'				sString		- String to parse.
'				sAttribute	- Attribute to vind.
'				sValue		- Value to replace.
'Returns:
'				String		- The parsed string.
'
Public Function ReplaceAttributeValue(ByVal sString As String, ByVal sAttribute As String, ByVal sValue As String) As String
Dim result			As String = sString
Dim pos				As Integer = result.IndexOf(sAttribute & gAttrDelim)

	If (pos >= 0 _
	And (pos = 0 _
		Or (result.Substring(pos - gDelimeter.Length, gDelimeter.Length) = gDelimeter))) _
	Then
	Dim pos2		As Integer = result.IndexOf(gDelimeter, pos)

		pos += sAttribute.Length + gAttrDelim.Length
		result = sString.Substring(pos) & sValue

		If (pos2 > pos) Then
			result &= sString.Substring(pos2, sString.Length - pos2)
		End If
	End If

	return result
End Function
#End Region

#Region "------==== Split ====---------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to split up the tokens into an Array List.
'Input Params:
'				sSearch							- String to parse.
'Returns:
'				System.Collections.ArrayList	- The number of tokens.
'Note:			Me.GetToken() takes into account whether the token is double quoted and
'				treats it as one token.
'
Public Function Split(ByVal sSearch As String) As System.Collections.ArrayList
Dim tokens		As System.Collections.ArrayList = New System.Collections.ArrayList()

    Do While (sSearch <> "")
		tokens.Add(Me.GetToken(sSearch, sSearch))
    Loop

    Return tokens
End Function
#End Region

End Class
