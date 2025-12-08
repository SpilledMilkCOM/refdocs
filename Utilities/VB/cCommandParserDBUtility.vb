'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains the default command line arguments for database switches.
'Note:			All of the "real" code is in the parent.
'=======================================================================================

Public Class cCommandParserDBUtility
	Inherits cCommandParserUtility

#Region "----==== CONSTRUCTOR ====-----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to construct a new object.
'Input Params:
'				sAppName		- Application Name to display in the USAGE statement.
'
Public Sub New(ByVal sAppName As String)
	MyBase.New(sAppName)
End Sub
#End Region

#Region "----==== AddConnectionAttribute ====------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Add a connection attribute to a connection string.
'Input Params:
'				sConnectionString		- Connection String to which to concatenate.
'				sSwitch					- The switch to lookup (for validation).
'				sAttribute				- The value to assign.
'
Private Sub AddConnectionAttribute(ByRef sConnectionString As String, ByVal sSwitch As String, ByVal sAttribute As String)
Dim sArgument As String = Me.GetArgument(sSwitch)

	If (sArgument.Length > 0) Then
		If (sConnectionString.Length > 0) Then
			sConnectionString &= ";"
		End If

		sConnectionString &= sAttribute & "=" & sArgument
	End If
End Sub
#End Region

#Region "----==== AddDefaultSwitches ====------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Add all of the defined switches to handle the database connection.
'Input Params:	NONE
'
Public Overrides Sub AddDefaultSwitches()
Dim clsSwitch	As cCommandSwitch = Nothing

	If (Not mbDefaultSwitchesAdded) Then
		MyBase.AddDefaultSwitches()

		clsSwitch = New cCommandSwitch("d", "Name of the database on the Server", "Database")
		clsSwitch.IsOptional = True
		Me.AddSwitch(clsSwitch)

		clsSwitch = New cCommandSwitch("s", "Name of the Server", "Server")
		clsSwitch.IsOptional = True
		Me.AddSwitch(clsSwitch)

		clsSwitch = New cCommandSwitch("n", "Data Source Name", "DSN")
		clsSwitch.IsOptional = True
		Me.AddSwitch(clsSwitch)

		clsSwitch = New cCommandSwitch("u", "Database authentication user", "UserName")
		Me.AddSwitch(clsSwitch)

		clsSwitch = New cCommandSwitch("p", "Password of user", "Password")
		clsSwitch.Prompt = True
		'clsSwitch.PromptInputObscured = True		' Not supported yet.
		Me.AddSwitch(clsSwitch)

		clsSwitch = New cCommandSwitch("w", "Use Windows Authentication", "")
		Me.AddSwitch(clsSwitch)
	End If
End Sub
#End Region

#Region "----==== ConnectionString ====------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to GET the connection string based on the command line switches.
'Input Params:	NONE
'Returns:
'				String			- Connetion String
'
'NOTE:		This will handle the generic case (either SQL or DSN)
'
Public ReadOnly Property ConnectionString() As String
	Get
	Dim sResult		As String = ""

        Me.AddDefaultSwitches()
        Me.ValidateSwitches()

		Me.AddConnectionAttribute(sResult, "s", "SERVER")
		Me.AddConnectionAttribute(sResult, "d", "DATABASE")
		Me.AddConnectionAttribute(sResult, "n", "DSN")
		Me.AddConnectionAttribute(sResult, "u", "UID")
		Me.AddConnectionAttribute(sResult, "p", "PWD")

		Return sResult
	End Get
End Property
#End Region

#Region "----==== ConnectionStringSQLServer ====---------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to GET the connection string based on the command line switches.
'Input Params:	NONE
'Returns:
'				String			- Connetion String
'
'NOTE:		This will handle the generic case (either SQL or DSN)
'
Public ReadOnly Property ConnectionStringSQLServer() As String
	Get
	Dim sResult		As String = ""

        Me.AddDefaultSwitches()
        Me.ValidateSwitches()

		Me.AddConnectionAttribute(sResult, "s", "SERVER")
		Me.AddConnectionAttribute(sResult, "d", "DATABASE")
		Me.AddConnectionAttribute(sResult, "u", "UID")
		Me.AddConnectionAttribute(sResult, "p", "PWD")

		Return sResult
	End Get
End Property
#End Region

#Region "----==== ConnectionStringODBC ====--------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to GET the connection string based on the command line switches.
'Input Params:	NONE
'Returns:
'				String			- Connetion String
'
'NOTE:		This will handle the generic case (either SQL or DSN)
'
Public ReadOnly Property ConnectionStringODBC() As String
	Get
	Dim sResult		As String = ""

        Me.AddDefaultSwitches()
        Me.ValidateSwitches()

		Me.AddConnectionAttribute(sResult, "n", "DSN")
		Me.AddConnectionAttribute(sResult, "u", "UID")
		Me.AddConnectionAttribute(sResult, "p", "PWD")

		Return sResult
	End Get
End Property
#End Region
End Class
