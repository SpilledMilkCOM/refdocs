'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains methods to help with date/string manipulation.
'=======================================================================================

Public Class cDateUtility

#Region "------==== ParseJulianDate ====-----------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to parse a Julian date in the format "0YYDDD".
'Input Params:
'				sDate		- Julian date to parse.
'Returns:
'				Date		- The parsed date.
'
Public Function ParseJulianDate(ByVal sDate As String) As Date
Dim iYear			As Int32
Dim sYear			As String
Dim sDays			As String
Dim dtResult		As DateTime = Nothing
Const JULIAN_DIGITS	As Int32 = 3

    If (Len(sDate) >= JULIAN_DIGITS) Then
		'The days should be three digits.
        sDays = sDate.Substring(sDate.Length() - JULIAN_DIGITS, sDate.Length - 2)	'Mid$(pDate, 3, Len(pDate) - 2)

		'The year will be the first part of the string.
        sYear = sDate.Substring(0, sDate.Length() - JULIAN_DIGITS)		'Mid$(pDate, 1, 2)

		' Probably should use the 30/70 rule for this.

		If (sYear.Length < 4)
		Dim iShifter As Int32 = System.Convert.ToInt32(System.Math.Pow(10, sYear.Length))

		' The "\" is INTEGER division (like Div in VB), this is different from the "/" normal
		' divisor which will round.

			iYear = (DateTime.Now.Year \ iShifter) * iShifter + System.Convert.ToInt32(sYear)
		Else
			iYear = System.Convert.ToInt32(sYear)
		End If

		dtResult = New DateTime(iYear, 1, 1)
        dtResult = dtResult.AddDays(CInt(sDays) - 1)
    End If

    Return dtResult
End Function
#End Region

#Region "------==== BeginOfMonth ====--------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to calculate the first of the month.
'Input Params:
'				dtDate				- Base date.
'Returns:
'				System.DateTime		- The parsed date.
'
Public Function BeginOfMonth(dtDate As System.DateTime) As System.DateTime
	Return New System.DateTime(dtDate.Year(), dtDate.Month(), 1)		' 1st of the current month.
End Function
#End Region

#Region "------==== EndOfMonth ====----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to calculate the end of the month.
'Input Params:
'				dtDate				- Base date.
'Returns:
'				System.DateTime		- The parsed date.
'
Public Function EndOfMonth(dtDate As System.DateTime) As System.DateTime
	Return Me.NextBeginMonth(dtDate).AddDays(-1)
End Function
#End Region

#Region "------==== NextBeginMonth ====---------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to calculate the following first of the month.
'Input Params:
'				dtDate				- Base date.
'Returns:
'				System.DateTime		- The parsed date.
'
Public Function NextBeginMonth(dtDate As System.DateTime) As System.DateTime
Dim dtResult	As DateTime = Me.BeginOfMonth(dtDate).AddDays(32)

	Return New DateTime(dtResult.Year(), dtResult.Month(), 1)			' 1st of the NEXT month.
End Function
#End Region

#Region "------==== PreviousEndOfMonth ====---------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to calculate the previous end of the month.
'Input Params:
'				dtDate				- Base date.
'Returns:
'				System.DateTime		- The parsed date.
'
Public Function PreviousEndOfMonth(dtDate As System.DateTime) As System.DateTime

	Return Me.BeginOfMonth(dtDate).AddDays(-1)
End Function
#End Region

End Class
