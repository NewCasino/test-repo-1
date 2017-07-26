'--
' *****************************************************************************************
' * logger.vb
' *
' * @description luxbet rubix-racing logger class
' *
' * @package auth
' * @author deboerr
' * @version v0.01a
' * @date 30/11/2016
' *
' * @copyright Copyright © Tabcorp Pty Ltd. All rights reserved. http://www.tabcorp.com.au/
' * @license This code Is copyrighted And Is the exclusive property of Tabcorp Pty Ltd. It may Not be used, copied Or redistributed without the written permission of Tabcorp.
' *
' *****************************************************************************************
' --
Option Strict On

Imports System
Imports System.IO
Imports Microsoft.VisualBasic

Public Class Logger

    Public Shared Sub LogToFile(ByVal sData As String, Optional ByVal sFilename As String = "logger.log")

       	For i as Integer = 1 To 10
	       	Try  
		        Using sw As StreamWriter = New StreamWriter(HttpRuntime.AppDomainAppPath & sFilename, True)
			        sw.WriteLine(DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") & " " & sData)
			        sw.Flush()
		        	sw.Close()
		        	Exit For
		        End Using
		    Catch
		    	System.Threading.Thread.Sleep(100)
	        End Try
	    Next

    End Sub

End Class
