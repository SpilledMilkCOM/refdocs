'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains the members and methods to encapsulate a command line switch.
'				The class cCommandLineParserUtility will contain a list of these.
'=======================================================================================

Public Class cCommandSwitch

#Region "----==== MEMBERS (and defaults) ====------------------------------------------"
Friend Protected mAliasRef		As cCommandSwitch = Nothing
Protected mbIgnoreCase			As Boolean = True
Protected mbMultipleArguments	As Boolean = False
Protected mbNeedsArgument		As Boolean = False
Protected mbOptional			As Boolean = True
Protected mbPromptIfEmpty		As Boolean = False
Protected mbPromptInputObscured	As Boolean = False
Protected miPosition			As Integer = -1		' 0 based position on the command line.
Protected msArgument			As String = ""		' Argument value is one was provided.
Protected msBriefArgDesc		As String = ""		' Description used in the argument listing.
Protected msDescription			As String = ""		' Description for the Usage statement.
Protected msSwitch				As String = ""
#End Region

#Region "----==== CONSTRUCTORS ====----------------------------------------------------"
'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to construct a new object.
'Input Params:	NONE
'
Public Sub New()
End Sub

'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to construct a new object.
'Input Params:
'				sSwitch			- The switch value.
'				sDescription	- The verbose description of the switch.
'
Public Sub New(ByVal sSwitch As String, ByVal sDescription As String)
	Me.ClassInit(sSwitch, sDescription, "")
End Sub

'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to construct a new object.
'Input Params:
'				sSwitch			- The switch value.
'				sDescription	- The verbose description of the switch.
'				sBriefArgDesc	- The brief description of the argument.
'
Public Sub New(ByVal sSwitch As String, ByVal sDescription As String, ByVal sBriefArgDesc As String)
	Me.ClassInit(sSwitch, sDescription, sBriefArgDesc)
End Sub
#End Region

#Region "--AM--==== ACCESSORS & MUTATORS ====------------------------------------------"
#Region "--AM--==== ClassInit ====-----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to construct a new object.
'Input Params:
'				sSwitch			- The switch value.
'				sDescription	- The verbose description of the switch.
'				sBriefArgDesc	- The brief description of the argument.
'
Public Sub ClassInit(ByVal sSwitch As String, ByVal sDescription As String, Optional sBriefArgDesc As String = "")
    Me.Switch = sSwitch
    Me.Description = sDescription
    
    If (sBriefArgDesc.Length > 0) Then
        msBriefArgDesc = sBriefArgDesc
        mbNeedsArgument = True
    End If
End Sub
#End Region

#Region "--AM--==== Argument ====------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Argument member.
'Input Params:
'				sValue			- The new Argument.
'Returns:
'				String			- The current Argument
'
Public Property Argument() As String
	Get
		Return msArgument
	End Get
	Set (ByVal sValue As String)
	    msArgument = sValue
	End Set
End Property
#End Region

#Region "--AM--==== BriefArgumentDescription ====--------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Brief Argument Description member.
'Input Params:
'				sValue			- The new Brief Argument Description.
'Returns:
'				String			- The current Brief Argument Description
'
Public Property BriefArgumentDescription() As String
	Get
		Return msBriefArgDesc
	End Get
	Set (ByVal sValue As String)
	    msBriefArgDesc = sValue
	End Set
End Property
#End Region

#Region "--AM--==== Description ====---------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Switch Description member.
'Input Params:
'				sValue			- The new Switch Description.
'Returns:
'				String			- The current Switch Description
'
Public Property Description() As String
	Get
		Return msDescription
	End Get
	Set (ByVal sValue As String)
	    msDescription = sValue
	End Set
End Property
#End Region

#Region "--AM--==== IgnoreCase ====----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Ignore Case flag.
'Input Params:
'				bValue			- The new Ignore Case flag..
'Returns:
'				Boolean			- The current Ignore Case flag.
'
Public Property IgnoreCase() As Boolean
	Get
		Return mbIgnoreCase
	End Get
	Set (ByVal bValue As Boolean)
	    mbIgnoreCase = bValue
	End Set
End Property
#End Region

#Region "--AM--==== IsOptional ====----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Is Optional flag.
'Input Params:
'				bValue			- The new Is Optional flag..
'Returns:
'				Boolean			- The current Is Optional flag.
'
Public Property IsOptional() As Boolean
' Can't use Optional because it is a keyword
	Get
		Return mbOptional
	End Get
	Set (ByVal sValue As Boolean)
	    mbOptional = sValue
	End Set
End Property
#End Region

#Region "--AM--==== NeedsArgument ====-------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Needs Argument flag.
'Input Params:
'				bValue			- The new Needs Argument flag..
'Returns:
'				Boolean			- The current Needs Argument flag.
'
Public Property NeedsArgument() As Boolean
	Get
		Return mbNeedsArgument
	End Get
	Set (ByVal sValue As Boolean)
	    mbNeedsArgument = sValue
	End Set
End Property
#End Region

#Region "--AM--==== MultipleArguments ====---------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Multiple Arguments flag.
'Input Params:
'				bValue			- The new Multiple Arguments flag..
'Returns:
'				Boolean			- The current Multiple Arguments flag.
'
Public Property MultipleArguments() As Boolean
	Get
		Return mbMultipleArguments
	End Get
	Set (ByVal sValue As Boolean)
	    mbMultipleArguments = sValue
	End Set
End Property
#End Region

#Region "--AM--==== Position ====------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Position member.
'Input Params:
'				bValue			- The new Position.
'Returns:
'				Boolean			- The current Position.
'
Public Property Position() As Integer
	Get
		Return miPosition
	End Get
	Set (ByVal sValue As Integer)
	    miPosition = sValue
	End Set
End Property
#End Region

#Region "--AM--==== Prompt ====--------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Prompt flag.
'Input Params:
'				bValue			- The new Prompt flag..
'Returns:
'				Boolean			- The current Prompt flag.
'
Public Property Prompt() As Boolean
	Get
		Return mbPromptIfEmpty
	End Get
	Set (ByVal sValue As Boolean)
	    mbPromptIfEmpty = sValue
	End Set
End Property
#End Region

#Region "--AM--==== PromptInputObscured ====-------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Prompt Input Obscured flag.
'Input Params:
'				bValue			- The new Prompt Input Obscured flag..
'Returns:
'				Boolean			- The current Prompt Input Obscured flag.
'
Public Property PromptInputObscured() As Boolean
	Get
		Return mbPromptInputObscured
	End Get
	Set (ByVal sValue As Boolean)
	    mbPromptInputObscured = sValue
	End Set
End Property
#End Region

#Region "--AM--==== Switch ====--------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Get/Set the Switch Description member.
'Input Params:
'				sValue			- The new Switch option.
'Returns:
'				String			- The current Switch option
'
Public Property Switch() As String
	Get
		Return msSwitch
	End Get
	Set (ByVal sValue As String)
	    msSwitch = sValue
	End Set
End Property
#End Region

#End Region

End Class
