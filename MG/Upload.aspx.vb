Imports System.IO
Imports System.Data
Imports System.Data.SqlClient

Partial Class Upload
    Inherits System.Web.UI.Page

	Function Conn(Optional SVR As Byte = 0) As SqlConnection

        Dim X As New SqlConnection(ConfigurationManager.AppSettings("dbConnStr_" & SVR) & _
          " Application Name=[LUXBOOK]" & HttpContext.Current.Request.ServerVariables("SCRIPT_NAME"))
        X.Open()
        Return X
    End Function


	Sub ExportCSV(ByVal sender As Object, ByVal e As EventArgs)
		'
		dim Rdate as String = MRCalendar.SelectedDate.ToString("dd-MM-yyyy")
		dim SQLdate as String = MRCalendar.SelectedDate.ToString("yyyy-MM-dd")	'format from SQL db
		'default value is invalid, so use current date
		if Rdate = "01-01-0001" Then 
			Rdate = Now.ToString("dd-MM-yyyy")
			SQLdate = Now.ToString("yyyy-MM-dd")
		End if
		
		dim WkRpSts as string = GetReportData(SQLdate) 	'Get data from DB

		If WkRpSts.Length > 0 Then
			'Response.Write("<script language=""javascript"">alert('" & WkRpSts & "');</script>")
			lblMessage.Text = WkRpSts
			exit sub
        End If  
		
		'Response.ClearContent()
		Response.ContentType = "text/csv"  '"application/vnd.ms-excel"	' 
        Response.AddHeader("Content-Disposition", "attachment;filename=Weekly_Report_" & Rdate & ".csv")
		'response.write(WkRpStr)
        Response.Flush()
        Response.End()
		
	End Sub
		
	Function GetReportData(RepDate as String) as String
	    Dim RepLine As String = ""
		
		Try
			Dim S As String = "EXEC sp_GetWeeklyReport '" & RepDate & "'"    
			Using RepData As DataTable = makeDataSet(S).Tables(0) 
				'headers 
				For Each DC As DataColumn In RepData.Columns
					response.write(DC.ColumnName.ToString & ",")
				Next
				response.write(vbCrLf)
				'Data rows
				For Each DR As DataRow In RepData.Rows
					For Each DC As DataColumn In RepData.Columns
						'RepLine &= DR(DC).ToString & ","
						response.write(DR(DC).ToString & ",")
					Next
					'RepLine &= vbCrLf	'EOL
					response.write(vbCrLf)
				Next
			End Using
		Catch ex As Exception
			RepLine = "ERROR - " & ex.message
		End Try
		
		Return RepLine
		
	End Function	
	
    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As EventArgs)
        'which file to process ?
        If AUclassUpload.Hasfile Then

            lblMessage.Text = AU_CLSfile(AUclassUpload.PostedFile)
        ElseIf FileUpload1.HasFile Then
            If DateTime.Compare(MRCalendar.SelectedDate, Now) >= 0 Or MRCalendar.SelectedDate.Year < 2014 Then
                lblMessage.Text = "Invalid date selected. " & MRCalendar.SelectedDate.ToShortDateString() & " Select a past or current date ! "
            Else
                If ManagerRep_Upload(FileUpload1.PostedFile, MRCalendar.SelectedDate.ToString("yyyy-MM-dd")) Then
                    lblMessage.Text = FileUpload1.PostedFile.FileName & " uploaded for " & MRCalendar.SelectedDate.ToString("yyyy-MM-dd")
                Else
                    lblMessage.Text += "Failed"
                End If
            End If
        End If

    End Sub

    Function ManagerRep_Upload(MRFile As HttpPostedFile, MRdate As String) As Boolean

        Dim sts As Boolean = False
        If FileUpload1.PostedFile.FileName <> String.Empty Then
            Dim fs As Stream = FileUpload1.PostedFile.InputStream
            Dim br As New BinaryReader(fs)
            Dim bytes As Byte() = br.ReadBytes(fs.Length)

            'Dim Qres
            'Qres = getResult("INSERT ManagerReports VALUES ('" & Now.ToString("yyyy-MM-dd hh:mm") & "', " & bytes(bytes.Length - 1) & ") ")
            'insert the file into database
            '    Dim strQuery As String = "insert into tblFiles" _
            '    & "(Name, ContentType, Data)" _
            '    & " values (@Name, @ContentType, @Data)"
            Dim cmd As New SqlCommand("INSERT ManagerReports VALUES ( '" & MRdate & "', @Data, NULL)")
            'cmd.Parameters.Add("@Name", SqlDbType.VarChar).Value = filename
            '    cmd.Parameters.Add("@ContentType", SqlDbType.VarChar).Value _
            '    = contenttype

            cmd.Parameters.Add("@Data", SqlDbType.Binary).Value = bytes
            cmd.CommandType = CommandType.Text
            cmd.Connection = Conn()
            If cmd.ExecuteNonQuery() > 0 Then sts = True
            cmd.Connection.Close()
            cmd.Connection.Dispose()
            '    InsertUpdateData(cmd)
            '    lblMessage.ForeColor = System.Drawing.Color.Green
            '    lblMessage.Text = "File Uploaded Successfully"
            'Else
            '    lblMessage.ForeColor = System.Drawing.Color.Red
            '    lblMessage.Text = "File format not recognised." _
            '    & " Upload Image/Word/PDF/Excel formats"
        End If
        'lblMessage.Text = "done"
        Return Sts
    End Function

    Sub btnRead_Click()

        'Dim RepDate As String = "2014-12-13"
        ''Dim cmd As New SqlCommand("SELECT FileData FROM ManagerReports WHERE Report_Date = '2014-12-12 02:17:00' ")
        'Dim S As String = "SELECT FileData FROM ManagerReports WHERE Report_Date = '" & RepDate & "' "

        'Using RepData As SqlDataReader = getRecord(S)
        '    If RepData.Read() Then
        '        Dim bytes() As Byte = RepData("FileData")  'CType(dt.Rows(0)("Data"), Byte())
        '        Response.Buffer = True
        '        Response.Charset = ""
        '        Response.Cache.SetCacheability(HttpCacheability.NoCache)
        '        Response.ContentType = "application/vnd.ms-word"
        '        Response.AddHeader("content-disposition", "attachment;filename=Manager_Report_" & RepDate & ".docx") '& dt.Rows(0)("Name").ToString())
        '        Response.BinaryWrite(bytes)
        '        Response.Flush()
        '        Response.End()
        '    Else
        '        Response.Write("<script language=""javascript"">alert('No manager report found for that day.');</script>")
        '    End If


        'End Using

    End Sub

	
    Function AU_CLSfile(File As HttpPostedFile) As String

        If File.ContentLength > 0 Then
            Dim ResultStr As String = ""
            Dim Flines As String(), UpDCnt As Integer = 0
            Dim FirstRace As DateTime = Now

            ResultStr = "-=# Loading Australia Race Class Value Data #=-" & "</br>"
            'read file into memory
            Using FileSR As New StreamReader(File.InputStream)
                Flines = Split(FileSR.ReadToEnd, vbCrLf)            'split file into lines array
            End Using

            For Each line As String In Flines
                Dim CVdata() As String
                CVdata = line.Trim.Split(" ")                        ' split line into data fields array
                'Cdata 0=Time , 2=Race No, 4=Cval value
                If CVdata.Length > 4 Then                           'ignore blank lines and races without Cvals
                    'If race time before  09:00 convert to 24H late race
                    Dim STime As DateTime = DateAndTime.TimeValue(CVdata(0)).ToString("HH:mm:ss")
                    If STime < "09:00:00" Then
                        CVdata(0) = STime.AddHours(12).ToShortTimeString.ToString       'convert 12h to 24h
                    End If
                    'combine with date                                       
                    '** Dim ST = "2014-07-18 " & DateAndTime.TimeValue(CVdata(0)).ToString("HH:mm:ss")  '*****************
                    Dim ST = Now.ToString("yyyy-MM-dd") & " " & DateAndTime.TimeValue(CVdata(0)).ToString("HH:mm:ss")
                    Dim Msg As String = CVdata(0) & ": " & CVdata(1) & ": " & CVdata(2) & ": " & CVdata(3) & ": " & CVdata(4)

                    Dim Qres
                    'Qres = execSQL("EXEC sp_UpdateCval '" & ST & "', " & CVdata(2) & ", " & CVdata(4))        'Update DB with Cvals
                    Qres = getResult("EXEC sp_UpdateCval '" & ST & "', " & CVdata(2) & ", " & CVdata(4))        'Update DB with Cvals
                    'check result
                    If IsNumeric(Qres) Then
                        If Double.Parse(Qres) = Double.Parse(CVdata(4)) Then
                            Msg = ""
                            UpDCnt += 1
                        Else
                            Msg += "<>" & Qres & " Cval Mismatch : FAILED"
                            ResultStr &= Msg & "</br>"
                            'Response.Write(vbLf & "<b> "  & Msg  & "</br>" & vbcrLf)
                        End If
                    Else
                        Msg += " : FAILED"
                        ResultStr &= Msg & "</br>"

                    End If
                End If
            Next
            ResultStr &= UpDCnt & " races updated " & "</br>"
            ResultStr &= "Done..."

            Return ResultStr
        Else
            Return "Invalid file"
        End If

    End Function

	Function getResult(SQL As String, Optional SVR As Byte = 0, Optional DV As Object = "") As Object
        Dim CM As New SqlCommand(SQL, Conn(SVR)), DT As Object = CM.ExecuteScalar()
        CM.Connection.Close() : Return IIf(IsNothing(DT) OrElse IsDBNull(DT), DV, DT)
    End Function
	
	Sub execSQL(SQL As String, Optional SVR As Byte = 0, Optional WAIT As Byte = 30)
        Dim CM As New SqlCommand(SQL, Conn(SVR)) 
		CM.CommandTimeout = WAIT 
		CM.ExecuteNonQuery() 
		CM.Connection.Close()
    End Sub

	Function makeDataSet( SQL As String, Optional SVR As Byte = 0 ) As DataSet
		Dim CN As SqlConnection = Conn(SVR)
		Dim DA As New SqlDataAdapter() 
		DA.SelectCommand = New SqlCommand(SQL, CN)
		Dim DS As New DataSet 
		DA.Fill(DS) 
		DA.Dispose() 
		CN.Close() 
		Return DS
	End Function
	
End Class
