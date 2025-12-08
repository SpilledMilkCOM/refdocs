'=======================================================================================
'Author:        Parker Smart
'Created:		02/15/2004
'Purpose:       This class contains the Encrypt and Decrypt methods.
'=======================================================================================
Imports System.IO
Imports System.Security.Cryptography

Public Class cCrypto

'----==== Encrypt ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Encrypt a string.
'Input Params:
'				sToEncrypt		- String to encrypt.
'Returns:
'				Byte()			- Encrypted string.
'
Public Shared Function Encrypt(ByVal sToEncrypt As String) As Byte()
Dim textConverter	As New System.Text.ASCIIEncoding()
Dim rc2CSP			As New RC2CryptoServiceProvider()
Dim encrypted()		As Byte
Dim toEncrypt()		As Byte
Dim key()			As Byte
Dim IV()			As Byte

    Debug.WriteLine("Effective key size is " & rc2CSP.EffectiveKeySize & " bits.")

    'Create a new key and initialization vector.
    rc2CSP.GenerateKey()
    rc2CSP.GenerateIV()

    'Get the key and IV.
    key = rc2CSP.Key
    IV = rc2CSP.IV

    'Get an encryptor.
Dim encryptor As ICryptoTransform = rc2CSP.CreateEncryptor(key, IV)

    'Encrypt the data.
Dim msEncrypt As New MemoryStream()
Dim csEncrypt As New CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write)

    'Convert the data to a byte array.
    toEncrypt = textConverter.GetBytes(sToEncrypt)

    'Write all data to the crypto stream and flush it.
    csEncrypt.Write(toEncrypt, 0, toEncrypt.Length)
    csEncrypt.FlushFinalBlock()

    'Get encrypted array of bytes.
    encrypted = msEncrypt.ToArray()

	Return encrypted
End Function

'----==== Encrypt ====------------------------------------------------------------------------
'Author:		Parker Smart
'Date Created:	02/15/2004
'Purpose:		This method is used to Encrypt a string.
'Input Params:
'				abToDecrypt		- Bytes to decrypt.
'Returns:
'				Byte()			- Dencrypted string.
'
Public Shared Function Decrypt(abToDecrypt() As Byte) As Byte()
Dim rc2CSP			As RC2CryptoServiceProvider		= New RC2CryptoServiceProvider()
Dim sDecrypted		As String						= Nothing
Dim key()			As Byte							= Nothing
Dim IV()			As Byte							= Nothing
Dim fromEncrypt()	As Byte							= Nothing
Dim textConverter	As System.Text.ASCIIEncoding	= New System.Text.ASCIIEncoding()

    'This is where the message would be transmitted to a recipient
    ' who already knows your secret key. Optionally, you can
    ' also encrypt your secret key using a public key algorithm
    ' and pass it to the mesage recipient along with the RC2
    ' encrypted message.            

    'Get a decryptor that uses the same key and IV as the encryptor.
Dim decryptor As ICryptoTransform = rc2CSP.CreateDecryptor(key, IV)

    'Now decrypt the previously encrypted message using the decryptor
    ' obtained in the above step.
Dim msDecrypt As New MemoryStream(abToDecrypt)
Dim csDecrypt As New CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read)

    fromEncrypt = New Byte(abToDecrypt.Length) {}

    'Read the data out of the crypto stream.
    csDecrypt.Read(fromEncrypt, 0, fromEncrypt.Length)

    'Convert the byte array back into a string.
    sDecrypted = textConverter.GetString(fromEncrypt)

    Debug.WriteLine("Decrypted: " & sDecrypted)

	Return fromEncrypt
End Function

End Class
