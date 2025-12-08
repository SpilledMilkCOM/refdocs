'==================================================================================================
' Author:       Parker Smart
' Date:         06/27/2004
' Purpose:      This class attempts to mimic the functionality of the old Windows registry using
'               an XML document.
'
'==================================================================================================
Public Class cRegistry
    Inherits Object
    
Protected msFileName        As String

Public Sub New()
End Sub

Public Sub New(ByVal sFileName As String)
	Me.FileName = sFileName
End Sub

Public Property FileName () As String
    Get
        Return msFileName
    End Get
    Set (ByVal sFileName As String)
        msFileName = sFileName
    End Set
End Property

Public Function GetString (ByVal sKey As String, ByVal sDefault As String) As String
Dim sResult         As String = sDefault
Dim clsNodeList     As System.Xml.XmlNodeList
Dim clsXMLDocument  As System.Xml.XmlDocument

    Try
        clsXMLDocument  = New System.Xml.XmlDocument()
        
        Me.LoadDocument(clsXMLDocument)
        
        clsNodeList = clsXMLDocument.GetElementsByTagName(sKey)
        
        If (Not clsNodeList Is Nothing AndAlso clsNodeList.Count = 1) Then
            sResult = clsNodeList(0).InnerText
        End If
    Catch clsException As System.Xml.XmlException
        Throw clsException
    End Try
    
    Return sResult
End Function

Public Sub LoadDocument(clsXMLDocument As System.Xml.XmlDocument)
Dim clsXMLReader    As System.Xml.XmlTextReader

    clsXMLReader    = New System.Xml.XmlTextReader(msFileName)
    clsXMLReader.Read()
    clsXMLDocument.Load(clsXMLReader)
    clsXMLReader.Close()
End Sub

Public Sub SetString(ByVal sKey As String, ByVal sValue As String)
Dim clsNodeList     As System.Xml.XmlNodeList
Dim clsXMLDocument  As System.Xml.XmlDocument

    clsXMLDocument  = New System.Xml.XmlDocument()

    Me.LoadDocument(clsXMLDocument)
    
    clsNodeList = clsXMLDocument.GetElementsByTagName(sKey)
    
    If (Not clsNodeList Is Nothing AndAlso clsNodeList.Count = 1) Then
        clsNodeList(0).InnerText = sValue
    End If

    clsXMLDocument.Save(msFileName)
End Sub

End Class
