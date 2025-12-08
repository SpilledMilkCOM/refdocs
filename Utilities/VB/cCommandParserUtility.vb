'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains the members and methods to parse command line arguments
'				based on switches that are defined by the client code.
'=======================================================================================

Imports _5280Solutions

Public Class cCommandParserUtility
#Region "----==== CONSTANTS ====-------------------------------------------------------"
Private Const msCLASS_NAME			As String = "CutlCommandParserUtility"
Private Const msHELP_DESCRIPTION	As String = "Print this Usage statement"
Private Const miMAX_PADDING			As Integer = 20
#End Region

#Region "----==== MEMBERS (and defaults) ====------------------------------------------"
Protected msAppName					As String = ""
Protected msCommand					As String = ""
Protected mbDefaultSwitchesAdded	As Boolean = False
Protected mclsStringUtil			As New Utility.cStringUtility
Protected mclsSwitches				As New System.Collections.Hashtable				' A collection of Utility.cCommandSwitch
Protected malTokens					As System.Collections.ArrayList = Nothing		' Could be a System.Collections.Specialized.StringCollection
Protected mbValidated				As Boolean = False
#End Region

'----==== New ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to construct a new object.
'Input Params:
'				sAppName		- Application Name to display in the USAGE statement.
'
Public Sub New(ByVal sAppName As String)
	msAppName	= sAppName
    msCommand	= System.Environment.CommandLine
    malTokens	= mclsStringUtil.Split(msCommand)
End Sub

#Region "----==== METHODS ====---------------------------------------------------------"
#Region "----==== AddDefaultSwitches ====----------------------------------------------"
'----==== AddDefaultSwitches ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Add the default switches for any command line application.
'Input Params:	NONE
'
Public Overridable Sub AddDefaultSwitches()
Dim clsSwitch As Utility.cCommandSwitch = Nothing

' This was added here instead of the constructor because I wanted to throw an
' error if the Usage statement was an option.

	If (Not mbDefaultSwitchesAdded) Then
	' These are optional but are needed.

		mbDefaultSwitchesAdded = True	' We don't want the stack to explode (infinite recursion is BAD).

		clsSwitch = New Utility.cCommandSwitch("?", msHELP_DESCRIPTION)
		Me.AddSwitch(clsSwitch)

		' Add the Alias 'help'
		Me.AddSwitch(New Utility.cCommandSwitch("help", msHELP_DESCRIPTION), clsSwitch)
	End If
End Sub
#End Region

#Region "----==== AddSwitch ====-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to add a switch to the list of known switches.
'Input Params:
'				clsSwitch			- The switch to add.
'
Public Sub AddSwitch(clsSwitch As Utility.cCommandSwitch)
	Me.AddSwitch(clsSwitch, Nothing)
End Sub

'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to add a switch to the list of known switches.
'Input Params:
'				clsSwitch			- The switch to add.
'				clsReferenceSwitch	- The switch's ALIAS.
'
Public Sub AddSwitch(clsSwitch As Utility.cCommandSwitch, clsReferenceSwitch As Utility.cCommandSwitch)
	If (Not mbDefaultSwitchesAdded) Then
		Me.AddDefaultSwitches()
	End If

' Moved the validation stuff out of here because you can't validate until ALL the switches have been added.

	If (Not clsSwitch Is Nothing) Then
	Dim switchStr As String = clsSwitch.Switch

		switchStr = clsSwitch.Switch
		clsSwitch.mAliasRef = clsReferenceSwitch
		Call mclsSwitches.Add(switchStr, clsSwitch)
	End If

End Sub
#End Region

#Region "----==== AliasList ====-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to return a list of aliases for a given switch.
'Input Params:
'				clsSwitch			- The switch to add.
'				clsReferenceSwitch	- The switch's ALIAS.
'
Protected Function AliasList (clsSwitch As Utility.cCommandSwitch) As String
Dim iter		As System.Collections.IDictionaryEnumerator = mclsSwitches.GetEnumerator()
Dim sResult		As String = ""

	Do While (iter.MoveNext())
	Dim clsSwitchCurrent	As Utility.cCommandSwitch = DirectCast(iter.Value(), Utility.cCommandSwitch)

		If (Not clsSwitchCurrent Is Nothing _
		AndAlso clsSwitchCurrent.mAliasRef Is clsSwitch) Then
			If (sResult.Length > 0) Then
				sResult &= "|"
			End If
			sResult &= clsSwitchCurrent.Switch
		End If
	Loop

	If (sResult.Length > 0) Then
		sResult = "[" & sResult & "]"
	End If

	return sResult
End Function
#End Region

#Region "----==== FindSwitchPostion ====-----------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to find a switch's ordinal position on the command line.
'Input Params:
'				sSwitch				- The switch to lookup.
'Returns:
'				Int32				- The position found (-1 on failure)
'
Protected Function FindSwitchPostion(ByVal sSwitch As String) As Int32
Dim iResult		As Int32 = -1
Dim idx			As Int32 = 0

	For idx = 0 To malTokens.Count - 1
		If ("/" & sSwitch = DirectCast(malTokens(idx), String) _
		Or "-" & sSwitch = DirectCast(malTokens(idx), String)) Then
			iResult = idx
			Exit For
		End If
	Next idx

	Return iResult
End Function
#End Region

#Region "----==== GetArgument ====-----------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve a switch's argument if it exists.
'Input Params:
'				sSwitch				- The switch to lookup.
'Returns:
'				String				- The argument
'
Public Function GetArgument(ByVal sSwitch As String) As String
Dim sResult		As String = ""
Dim clsSwitch	As Utility.cCommandSwitch = Me.GetSwitchDefinition(sSwitch)

	Me.ValidateSwitches()

    If (Not clsSwitch Is Nothing) Then
        sResult = clsSwitch.Argument
    End If

	Return sResult
End Function
#End Region

#Region "----==== GetArgumentUnquoted ====---------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve a switch's argument if it exists and
'				remove the double quotes if quoted.
'Input Params:
'				sSwitch			- The switch to lookup.
'Returns:
'				String			- The argument (unquoted)
'
Public Function GetArgumentUnquoted(ByVal sSwitch As String) As String
Dim sResult		As String = Me.GetArgument(sSwitch)

	Return sResult.Trim(CChar(""""))
End Function
#End Region

#Region "----==== GetArgumentList ====-------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve the argument list for a given switch
'Input Params:
'				sSwitch			- The switch to lookup.
'Returns:
'				System.Collections.ArrayList		- The arguments
'
Public Function GetArgumentList(ByVal sSwitch As String) As System.Collections.ArrayList
Dim alResult	As System.Collections.ArrayList		= New System.Collections.ArrayList()
Dim clsSwitch	As Utility.cCommandSwitch			= Me.GetSwitch(sSwitch)
Dim idx			As Integer							= 0

'!!! Might want to use a StringCollection since it's more efficient.

	Me.ValidateSwitches()

	' Find the switch sToken.  Grab all the other tokens until a switch is found.
	If (Not clsSwitch Is Nothing AndAlso clsSwitch.Position >= 0) Then
		For idx = clsSwitch.Position + 1 To malTokens.Count - 1
			If (Not Me.IsDefined(DirectCast(malTokens(idx), String))) Then
				alResult.Add(malTokens(idx))
			End If
		Next idx
	End If

	Return alResult		' Return an empty list for now.
End Function
#End Region

#Region "----==== GetSwitch ====-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve a switch object based on its switch string.
'Input Params:
'				clsSwitch					- The switch to lookup.
'Returns:
'				Utility.cCommandSwitch		- The switch object
'
Private Function GetSwitch(ByVal sSwitch As String) As Utility.cCommandSwitch
Dim clsSwitch	As Utility.cCommandSwitch

    clsSwitch = DirectCast(mclsSwitches(sSwitch), Utility.cCommandSwitch)
	Return clsSwitch
End Function
#End Region

#Region "----==== GetSwitchDefinition ====---------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve a switch object based on its switch string.
'				This also takes into consideration a switch's ALIAS.
'Input Params:
'				clsSwitch					- The switch to lookup.
'Returns:
'				Utility.cCommandSwitch		- The switch object
'
Private Function GetSwitchDefinition(ByVal sSwitch As String) As Utility.cCommandSwitch
Dim clsSwitch	As Utility.cCommandSwitch = Me.GetSwitch(sSwitch)

	If (Not clsSwitch Is Nothing AndAlso Not clsSwitch.mAliasRef Is Nothing) Then
		clsSwitch = clsSwitch.mAliasRef
	End If

	If (Not clsSwitch Is Nothing AndAlso clsSwitch.Position < 0) Then
		clsSwitch = Nothing		' Not found
	End If

	Return clsSwitch
End Function
#End Region

#Region "----==== HasSwitch ====-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to validate if a switch exists.
'Input Params:
'				clsSwitch		- The switch to lookup.
'Returns:
'				Boolean			- True if the switch exists
'
Public Function HasSwitch(ByVal sSwitch As String) As Boolean
Dim bResult		As Boolean = False
Dim clsSwitch	As Utility.cCommandSwitch = Me.GetSwitchDefinition(sSwitch)

    If (Not clsSwitch Is Nothing AndAlso clsSwitch.Position >= 0) Then
	' The switch is defined and exists on the command line.
        bResult = True
    End If

	Return bResult
End Function
#End Region

#Region "----==== IsDefined ====-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to validate if a switch was defined.
'Input Params:
'				clsSwitch		- The switch to lookup.
'Returns:
'				Boolean			- True if the switch exists
'Note:			A switch can be defined, but may not be supplied by the client
'				Use the above method to check for existance of a switch provided on the command line
Protected Function IsDefined(ByVal pSwitch As String) As Boolean
Dim bResult		As Boolean = False
Dim clsSwitch	As Utility.cCommandSwitch = Me.GetSwitchDefinition(pSwitch)

    If (Not clsSwitch Is Nothing) Then
	' The switch is defined
        bResult = True
    End If

	Return bResult
End Function
#End Region

#Region "----==== ReadLine ====--------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve input from the user (like a password)
'Input Params:
'				bPromptInputObscured	- A flag to prompt or not.
'Returns:
'				String					- The input from the user.
'Note:			NOT IMPLEMENTED YET.
'
Public Function ReadLine(bPromptInputObscured As Boolean) As String
Dim sResult		As String = ""

	If (bPromptInputObscured) Then
	Dim buffer()	As Char = Nothing
	Dim theChar		As Integer = 0

		ReDim buffer(0)		' Only want one character.

		'theChar = System.Console.In.Peek()
		theChar = System.Console.In.ReadBlock(buffer, 0, 1)

		Do While (theChar <> 13)	' While NOT newline
			System.Console.Out.Write(System.Convert.ToChar(8))
			System.Console.Out.Write(System.Convert.ToChar("*"))

			If (theChar = 8) Then	' Backspace.
			Else
				sResult &= System.Convert.ToString(buffer(0))
			End If
			theChar = System.Console.In.ReadBlock(buffer, 0, 1)
		Loop
	Else
		sResult = System.Console.ReadLine()
	End If

	return sResult
End Function
#End Region

#Region "----==== Usage ====-----------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to display the USAGE statement for a given command.
'				It will also display an error exception if provided.
'Input Params:
'				clsException			- The exception to display
'Returns:
'				String					- The entire usage statement.
'
Public Function Usage(Optional clsException As Utility.cException = Nothing) As String
Dim theUsage	As String = ""
Dim iter		As System.Collections.IDictionaryEnumerator = mclsSwitches.GetEnumerator()
Dim iPadding		As Int32 = 0

	If (Not clsException Is Nothing) Then
		theUsage &= clsException.Message & vbCrLf & vbCrLf
	End If

    theUsage &= "Usage " & msAppName & ": "

' Loop through the options...

	Do While (iter.MoveNext())
	Dim clsSwitch	As Utility.cCommandSwitch = DirectCast(iter.Value(), Utility.cCommandSwitch)

		If (clsSwitch.mAliasRef Is Nothing) Then
			If (clsSwitch.IsOptional) Then
				theUsage &= "["
			End If

			theUsage &= "/" & clsSwitch.Switch

			If (clsSwitch.BriefArgumentDescription.Length > 0) Then
				theUsage &= " <" & clsSwitch.BriefArgumentDescription & ">"
			End If

			If (clsSwitch.IsOptional) Then
				theUsage &= "]"
			End If

			theUsage &= " "
		End If
	Loop

	theUsage &= vbCrLf & vbCrLf

' Calculate the iPadding (max of option plus aliases)...
	iter = mclsSwitches.GetEnumerator()

	Do While (iter.MoveNext())
	Dim clsSwitch	As Utility.cCommandSwitch = DirectCast(iter.Value(), Utility.cCommandSwitch)

		If (Not clsSwitch Is Nothing And clsSwitch.mAliasRef Is Nothing) Then
		Dim switches		As String = clsSwitch.Switch & Me.AliasList(clsSwitch)

			If (iPadding < switches.Length And switches.Length <= miMAX_PADDING) Then
				iPadding = switches.Length
			End If
		End If
	Loop

' Loop through the options to print the detail...
	iter = mclsSwitches.GetEnumerator()

	Do While (iter.MoveNext())
	Dim clsSwitch	As Utility.cCommandSwitch = DirectCast(iter.Value(), Utility.cCommandSwitch)

		If (clsSwitch.mAliasRef Is Nothing) Then
		Dim switches		As String = clsSwitch.Switch & Me.AliasList(clsSwitch)

			theUsage &= "    " & switches.PadRight(iPadding + 5) & clsSwitch.Description & vbCrLf
		End If
	Loop

    Return theUsage
End Function
#End Region

#Region "----==== ValidateSwitches ====------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to validate the actual command line based on the
'				definitions of the switches.  Such as if a switch requires an argument
'				then this argument is validated otherwise and exception is thrown.
'Input Params:
'				clsException			- The exception to display
'Returns:
'				String					- The entire usage statement.
'
Public Sub ValidateSwitches()

	If (Not mbValidated) Then
	Dim iter			As System.Collections.IDictionaryEnumerator = mclsSwitches.GetEnumerator()

	' Loop through all of the defined switches and aliases to find them on the command line.

		Do While (iter.MoveNext())
		Dim clsSwitch	As Utility.cCommandSwitch = DirectCast(iter.Value(), Utility.cCommandSwitch)

			If (Not clsSwitch Is Nothing) Then
				clsSwitch.Position = Me.FindSwitchPostion(clsSwitch.Switch)

				If (clsSwitch.NeedsArgument) Then
				' Look at the NEXT token and make sure that it's NOT a switch.

					If (clsSwitch.Position + 1 <= malTokens.Count - 1) Then
					Dim sToken As String = malTokens(clsSwitch.Position + 1).ToString()

					' If the next argument is a switch then throw an error.

						If (sToken.Length > 0 AndAlso Not Me.IsDefined(sToken.Substring(1))) Then
							clsSwitch.Argument = DirectCast(malTokens(clsSwitch.Position + 1), String)
						ElseIf (clsSwitch.Prompt) Then
							System.Console.Write(clsSwitch.BriefArgumentDescription & ": ")
							clsSwitch.Argument = Me.ReadLine(clsSwitch.PromptInputObscured)
						End If
					End If

					If (clsSwitch.Argument.Length = 0) Then
						Throw New Utility.cException("The switch '" & clsSwitch.Switch & "' requires an argument.")
					End If
				End If

				If (Not clsSwitch.mAliasRef Is Nothing) Then
					If (clsSwitch.mAliasRef.Position >= 0 And clsSwitch.Position >= 0) Then
						Throw New Utility.cException("Cannot have two switches with the same meaning: '" & clsSwitch.Switch & "' and '" & clsSwitch.mAliasRef.Switch & "'.")
					Else
					' Store the argument in the reference so it can be referenced too so the main definition can be used.
						clsSwitch.mAliasRef.Argument = clsSwitch.Argument
					End If
				End If
			End If
		Loop

		If (Me.HasSwitch("?") OrElse Me.HasSwitch("help")) Then
			Throw New Utility.cException("Display Help Message...")
		End If

		' Check for require switches.

		Do While (iter.MoveNext())
		Dim clsSwitch	As Utility.cCommandSwitch = DirectCast(iter.Value(), Utility.cCommandSwitch)

			If (Not clsSwitch.IsOptional And clsSwitch.Position = -1) Then
				Throw New Utility.cException("The required switch /" & clsSwitch.Switch & " was not found.")
			End If
		Loop

		' Look for invalid switches.

	Dim tokenIter As System.Collections.IEnumerator = malTokens.GetEnumerator()

		Do While (tokenIter.MoveNext())
		Dim sToken	As String = DirectCast(tokenIter.Current(), String)

			If (sToken.Length() > 1 _
			AndAlso sToken.Length() < 8 _
			AndAlso (sToken.Substring(0, 1) = "/" _
					OrElse sToken.Substring(0, 1) = "-") _
			AndAlso Not Me.IsDefined(sToken.Substring(1))) _
			Then
			' This sToken looks like a switch and yet it is not defined.
				Throw New Utility.cException("The switch '" & sToken & "' was not defined.")
			End If
		Loop

		mbValidated = True
	End If
End Sub
#End Region

#End Region

End Class
