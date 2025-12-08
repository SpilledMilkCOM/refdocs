'=======================================================================================
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This class is used to wrap a the System.Exception
'=======================================================================================
Public Class cException
	Inherits System.Exception

Protected Shared mIsConsoleApp	As Boolean = False

Protected ReadOnly miMessageType	As Int32 = -1
Protected ReadOnly msMessage		As String = ""
    
'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is needed to construct a new object with a known message.
'Input Params:
'				sMessage			The message of the exception
'
Public Sub New (ByVal sMessage As String)
	msMessage = Me.GetType().ToString() & " - " & sMessage
End Sub

'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is needed to construct a new object with a known message.
'Input Params:
'				iMessageType		The type of the exception
'				sMessage			The message of the exception
'
Public Sub New (ByVal iMessageType As Int32, ByVal sMessage As String)
	miMessageType	= iMessageType
	msMessage		= Me.GetType().ToString() & " - " & sMessage
End Sub

'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is needed to construct a new object with a known message.
'Input Params:
'				objThrowingObject	The object that threw this exception
'				sMessage			The message of the exception
'
Public Sub New (objThrowingObject As Object, ByVal sMessage As String)
	msMessage = Me.GetType().ToString() & " thrown in " & objThrowingObject.GetType().ToString() & sMessage
End Sub

'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is needed to construct a new object with a known message.
'Input Params:
'				objThrowingObject	The object that threw this exception
'				iMessageType		The type of the exception
'				sMessage			The message of the exception
'
Public Sub New (objThrowingObject As Object, ByVal iMessageType As Int32, ByVal sMessage As String)
	miMessageType	= iMessageType
	msMessage		= Me.GetType().ToString() & " thrown in " & objThrowingObject.GetType().ToString() & sMessage
End Sub

'----==== Message ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is needed to retrieve the Message member.
'Input Params:	NONE
'Returns:		String			- The exception message
'
Public Overrides ReadOnly Property Message() As String
	Get
		Return msMessage
	End Get
End Property

'----==== MessageType ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is needed to retrieve the Message Type member.
'Input Params:	NONE
'Returns:		Int32			- The exception type
'
Public ReadOnly Property MessageType() As Int32
	Get
		Return miMessageType
	End Get
End Property

'----==== HandleError ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	11/30/2003
'Purpose:		This method is used to handle the message.
'Input Params:	NONE
'
Public Sub HandleError()
	If (mIsConsoleApp) Then
		System.Console.Out.WriteLine(msMessage)
	Else
		'System.Windows.Forms.MessageBox.Show
	End If
End Sub

End Class
