'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains methods to help with directory manipulation.
'=======================================================================================

Public Class cDirectoryUtility

Public Const gDefaultDirectory		As String = "C:\"

#Region "------==== EnsureDirectory ====-----------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to make sure the directory has a separator character at the end.
'Input Params:
'				sDirectory		- Directory to validate.
'Returns:
'				String			- The parsed directory.
'
Public Function EnsureDirectory(ByVal sDirectory As String) As String
Dim result		As String = sDirectory
    
    If (result.Length > 0) Then
        If (result.Substring(result.Length - 1, 1) <> System.IO.Path.DirectorySeparatorChar) Then
            result &= System.IO.Path.DirectorySeparatorChar
        End If
    End If

	Return result
End Function
#End Region

#Region "------==== GetLastInPath ====-------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve the directory or file name in the given path.
'Input Params:
'				sPath		- Directory to validate.
'Returns:
'				String			- The parsed directory.
'
Public Function GetLastInPath(ByVal sPath As String) As String
Dim result		As String = ""
Dim pos			As Integer
' Could use Path.GetFileName() if a full path to a file is given.

    pos = sPath.LastIndexOf(System.IO.Path.DirectorySeparatorChar)

    If (pos > 0) Then
		pos += System.Convert.ToString(System.IO.Path.DirectorySeparatorChar).Length		' Skip over the Separator
        result = sPath.Substring(pos, sPath.Length - pos)
    End If

	Return result
End Function
#End Region

#Region "------==== GetPath ====-------------------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to retrieve the directory the given path.
'Input Params:
'				sPath		- Directory to validate.
'Returns:
'				String			- The parsed directory.
'
Public Function GetPath(ByVal sPath As String) As String
	Return System.IO.Path.GetDirectoryName(sPath)
End Function
#End Region

#Region "------==== FindValidDirectory ====--------------------------------------------"
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to find a valid directory within the path given.
'Input Params:
'				sPath		- Directory to validate.
'Returns:
'				String			- The parsed directory.
'
Public Function FindValidDirectory(ByVal sDirectory As String) As String
Dim theDirectory    As String
'Dim pos             As Integer

    theDirectory = sDirectory

'    Do While (Dir$(theDirectory) = "")
'        pos = InStrRev(theDirectory, gPathSeparator)
'        If (pos >= 1) Then
'            theDirectory = Left$(theDirectory, pos - 1)
'        Else
'            theDirectory = gDefaultDirectory
'            Exit Do
'        End If
'    Loop

    Return theDirectory
End Function
#End Region

End Class
