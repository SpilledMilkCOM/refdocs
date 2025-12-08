'=======================================================================================
'Author:        Parker Smart
'Created:		04/01/2004
'Purpose:       This class contains methods to help with dealing with elapsed time.
'=======================================================================================
Public Class cElapsedTime
	Inherits Object

#Region "------==== CONSTANTS ====-----------------------------------------------------"
Private ReadOnly msPADDING_CHAR As Char						= System.Convert.ToChar("0")
#End Region

#Region "-------=== MEMBERS ===--------------------------------------------------------"
Protected mbAutoUpdate		As Boolean = True
Protected mdtCurrent		As System.DateTime
Protected mdtStarted		As System.DateTime
Protected miCurrent			As Int32 = 0
Protected miMaxCount		As Int32 = 0
#End Region

Public Sub New ()
	Me.Start
End Sub

#Region "-------=== PROPERTIES ===-----------------------------------------------------"
#Region "-------=== AutoUpdate ===-----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to Get/Set the Auto Update flag.
'Input Params:
'				bValue		- The new Auto Update flag.
'Returns:
'				Boolean		- The current Auto Update flag.
'
Property AutoUpdate As Boolean
	Get
		Return mbAutoUpdate
	End Get
	Set (bValue As Boolean)
		mbAutoUpdate = bValue
	End Set
End Property
#End Region

#Region "-------=== Current ===--------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to Get/Set the Current Item.
'Input Params:
'				iValue		- The new Current Item.
'Returns:
'				Int32		- The current Current Item.
'
Property Current As Int32
	Get
		Return miCurrent
	End Get
	Set (iValue As Int32)
		miCurrent = iValue
	End Set
End Property
#End Region

#Region "-------=== Elapsed ===--------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to Get/Set the Elapsed TimeSpan.
'Returns:
'				System.TimeSpan		- The current Elapsed TimeSpan.
'
ReadOnly Property Elapsed As System.TimeSpan
	Get
		If (mbAutoUpdate) Then
			mdtCurrent = System.DateTime.Now
		End If
		Return mdtCurrent.Subtract(mdtStarted)
	End Get
End Property
#End Region

#Region "-------=== ItemsPerSecond ===-------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to calculate Items Per Second.
'Returns:
'				Double		- The current Items Per Second.
'
ReadOnly Property ItemsPerSecond As Double
	Get
	Dim diff	As System.TimeSpan	= Me.Elapsed
	Dim dResult As Double			= 0

		If (diff.Ticks > 0 AndAlso miCurrent > 0)
		Dim iSeconds As Double = System.Convert.ToDouble(System.DateTime.Now.Subtract(mdtStarted).Ticks) / System.TimeSpan.TicksPerSecond

			dResult = System.Convert.ToDouble(miCurrent) / iSeconds
		End If
		Return dResult
	End Get
End Property
#End Region

#Region "-------=== Max ===------------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to Get/Set the Max Items.
'Input Params:
'				iValue		- The new Max Items.
'Returns:
'				Int32		- The current Max Items.
'
Property Max As Int32
	Get
		Return miMaxCount
	End Get
	Set (iValue As Int32)
		miMaxCount = iValue
	End Set
End Property
#End Region

#Region "-------=== Remaining ===------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to calculate ESTIMATED Remaining time.
'Returns:
'				Double		- ESTIMATED Remaining time.
'
ReadOnly Property Remaining As System.TimeSpan
	Get
		If (miCurrent <> 0) Then
		Dim diff As System.TimeSpan = Me.Elapsed

			Return New System.TimeSpan(System.Convert.ToInt64( _
						System.Convert.ToDouble(diff.Ticks) * miMaxCount / miCurrent) - diff.Ticks)
		End If
		Return New System.TimeSpan(0)
	End Get
End Property
#End Region

#Region "-------=== Started ===--------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to Get/Set the Started DateTime.
'Input Params:
'				dtValue				- The new Started DateTime.
'Returns:
'				System.DateTime		- The current Started DateTime.
'
Property Started As System.DateTime
	Get
		Return mdtStarted
	End Get
	Set (dtValue As System.DateTime)
		mdtStarted = dtValue
	End Set
End Property
#End Region

#End Region

#Region "-------=== METHODS ===--------------------------------------------------------"
#Region "-------=== Start ===----------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to mark the time started.
'Input Params:	NONE
'
Public Sub Start()
	mdtStarted = System.DateTime.Now
	mdtCurrent = mdtStarted
End Sub
#End Region

#Region "-------=== Stop ===-----------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	06/40/2004
'Purpose:		This method is used to mark the time started.
'Input Params:	NONE
'
'NOTE:	Brackets are around Stop because it is a keyword.
'
Public Sub [Stop]()
	Me.AutoUpdate = False
	Me.Update()
End Sub
#End Region

#Region "-------=== FormatRemaining ===------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to return a formatted remaining time.
'Input Params:	NONE
'Returns:
'				String		- The formatted remaining time.
'
Public Function FormatRemaining() As String
Dim sResult		As String = "(~ ??:??:??)"
	If (miCurrent <> 0) Then
	Dim diff	As System.TimeSpan = Me.Remaining

		sResult = "(~ " & diff.Hours.ToString().PadLeft(2, msPADDING_CHAR) _
							& ":" & diff.Minutes.ToString().PadLeft(2, msPADDING_CHAR) _
							& ":" & diff.Seconds.ToString().PadLeft(2, msPADDING_CHAR) _
							& ")"
	End If

	Return sResult
End Function
#End Region

#Region "-------=== ToString ===-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to return a formatted elapsed time.
'Input Params:	NONE
'Returns:
'				String		- The formatted elapsed time.
'
Public Overrides Function ToString() As String
Dim diff	As System.TimeSpan = Me.Elapsed

	Return diff.Hours.ToString().PadLeft(2, msPADDING_CHAR) _
						& ":" & diff.Minutes.ToString().PadLeft(2, msPADDING_CHAR) _
						& ":" & diff.Seconds.ToString().PadLeft(2, msPADDING_CHAR) _
						& "." & diff.Milliseconds.ToString().PadLeft(3, msPADDING_CHAR)
End Function
#End Region

#Region "-------=== Update ===---------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	04/01/2004
'Purpose:		This method is used to refresh the current timestamp.
'Input Params:	NONE
'
Public Sub Update()
	mdtCurrent = System.DateTime.Now
End Sub
#End Region

#End Region		' METHODS

End Class
