<script language=VBScript runat=server>

'-- Database Related Functions ------------------------------------------------
Function Conn( Optional SVR As Byte = 0 ) As SqlConnection
  Dim X As New SqlConnection(ConfigurationManager.AppSettings("dbConnStr_" & SVR) & _
    " Application Name=[LUXBOOK]" & Request.ServerVariables("SCRIPT_NAME")): X.Open(): Return X
End Function


Sub execSQL( SQL As String, Optional SVR As Byte = 0, Optional WAIT As Byte = 30 )
  Dim CM As New SqlCommand(SQL, Conn(SVR)): CM.CommandTimeout = WAIT: CM.ExecuteNonQuery(): CM.Connection.Close()
End Sub

Function trySQL( SQL As String, Optional SVR As Byte = 0, Optional WAIT As Byte = 30, Optional MSG As String = "" ) As Boolean
  Dim CM As New SqlCommand(SQL, Conn(SVR)), OK As Boolean = False, I As Byte = 0: CM.CommandTimeout = WAIT
  Do: Try: I += 1: CM.ExecuteNonQuery(): OK = True: Catch: Thread.Sleep(1000): End Try: Loop Until OK Or I >= 3
  CM.Connection.Close(): If Not OK And MSG <> "" Then: Ink(MSG): End If: Return OK
End Function

Function runSQL( SQL As String, Optional SVR As Byte = 0, Optional WAIT As Byte = 30 ) As Thread
  Dim P() As Object = { SQL, SVR, WAIT }, T As New Thread(AddressOf _runSQL): T.Start(P): Return T
End Function

Sub _runSQL( P As Object )
  Dim CM As New SqlCommand(P(0), Conn(P(1))): CM.CommandTimeout = P(2): CM.ExecuteNonQuery(): CM.Connection.Close()
End Sub


Function getRecord( SQL As String, Optional SVR As Byte = 0 ) As SqlDataReader
  Return New SqlCommand(SQL, Conn(SVR)).ExecuteReader(CommandBehavior.CloseConnection)
End Function

Function getResult( SQL As String, Optional SVR As Byte = 0, Optional DV As Object = "" ) As Object
  Dim CM As New SqlCommand(SQL, Conn(SVR)), DT As Object = CM.ExecuteScalar()
  CM.Connection.Close(): Return IIf(IsNothing(DT) OrElse IsDBNull(DT), DV, DT)
End Function

Function makeDataSet( SQL As String, Optional SVR As Byte = 0 ) As DataSet
  Dim CN As SqlConnection = Conn(SVR)
  Dim DA As New SqlDataAdapter(): DA.SelectCommand = New SqlCommand(SQL, CN)
  Dim DS As New DataSet: DA.Fill(DS): DA.Dispose(): CN.Close(): Return DS
End Function

Function getDataRow( SQL As String, Optional SVR As Byte = 0 ) As Object
  Dim DT As DataTable = makeDataSet(SQL, SVR).Tables(0)
  If DT.Rows.Count > 0 Then Return DT.Rows(0) Else Return Nothing
End Function


Function makeList( TYP As String, NM As String, TBL As String, CTP As String, FLD As String, DSP As String, SLT As String, Optional EVN As String = "" ) As String
  If IsNothing(Application(TBL)) Then Application(TBL) = makeDataSet("SELECT * FROM " & TBL & "(nolock) ORDER BY 2").Tables(0)
  Dim RS As DataRow() = Application(TBL).Select("TYPE='" & CTP & "'")
  Dim R As DataRow, VL As String, S As String = ""
  Select Case UCase(TYP)
  Case "SELECT"
    For Each R In RS: VL = R(FLD)
      S &= "<option value='" & VL & "'" & IIf(VL = SLT, " selected", "") & ">" & R(DSP)
    Next
  Case "MULTISELECT"
    For Each R In RS: VL = R(FLD)
      S &= "<option value='" & VL & "'" & IIf(InStr(vbCrLf & SLT & vbCrLf, vbCrLf & VL & vbCrLf) > 0, " selected", "") & ">" & R(DSP)
    Next
  Case "RADIO", "CHECKBOX", "RADIO LINE", "CHECKBOX LINE"
    For Each R In RS: VL = R(FLD)
      S &= "<br><input type=" & Split(TYP," ")(0) & " name=" & NM & " " & EVN & _
        "value='" & VL & "'" & IIf(InStr(SLT, VL) > 0, " checked", "") & ">" & R(DSP)
    Next: S = Mid(S, 5): If Right(TYP, 4) = "LINE" Then S = Replace(S, "<br>", " &nbsp;")
  Case Else: S = "Unknown List Type!"
  End Select: Return S
End Function



'--- Form Request Related Function --------------------------------------------
Function chkRN( byVal x As String ) As String
  If Trim(Request(x)) = "" Then Return "NULL" _
  Else Return "'" & Trim(Replace(Request(x), "'", "''")) & "'"
End Function

Function chkRU( byVal x As String ) As String
  If Trim(Request(x)) = "" Then Return "NULL" _
  Else Return "N'" & Trim(Replace(Request(x), "'", "''")) & "'"
End Function

Function chkR9( x As String, Optional y As String = "NULL" ) As String
  x = Trim(Request(x)): If IsNumeric(x) Then Return Val(x) Else Return y
End Function

Function Secure( RV As String, Optional SZ As Integer = 0 ) As String
  If Request(RV) = "" Then Return ""
  Select Case SZ
  Case 0   : If IsNumeric(Request(RV)) Then Return Request(RV) Else Return ""
  Case Else:
    Dim SCL As object = Split("INSERT UPDATE DELETE TRUNCATE DROP --", " ")
    Dim I As Byte, S As String = Request(RV)
    For I = 0 To UBound(SCL): S = Replace(S, SCL(I), "",,, vbTextCompare): Next
    Return Replace(Replace(Left(S, SZ), "'", "''"), "<", "&lt;")
  End Select
End Function

Function cQS( X As String, Optional CN As Boolean = True ) As String
  If X = "" Then Return "NULL"
  If CN AndAlso IsNumeric(X) Then Return Val(X) Else Return "'" & Replace(X, "'", "''") & "'"
End Function



'-- General Application Functions ---------------------------------------------
Function getCode( Typ As String, Optional Code As String = "" ) As String
  If IsNothing(Application("SYS_CODE")) Then Application("SYS_CODE") = makeDataSet("SELECT * FROM SYS_CODE(nolock) ORDER BY CODE").Tables(0)
  Dim R() As DataRow = Application("SYS_CODE").Select("TYPE='" & Typ & "'" & IIf(Code <> "", " AND CODE='" & Code & "'", ""))
  If R.Length = 0 Then Return Code Else Return R(0)(IIf(Code <> "", "NAME", "CODE"))
End Function

Function getENum( Typ As String, Optional Num As Integer = -1) As Object
  If IsNothing(Application("SYS_ENUM")) Then Application("SYS_ENUM") = makeDataSet("SELECT * FROM SYS_ENUM(nolock) ORDER BY NUM").Tables(0)
  Dim R() As DataRow = Application("SYS_ENUM").Select("TYPE='" & Typ & "'" & IIf(Num < 0, "", " AND NUM=" & Num))
  If R.Length = 0 Then Return 0 Else Return R(0)(IIf(Num < 0, "NUM", "VALUE"))
End Function

Sub SendEmail( body As String )
  Try: Dim R As String, E As New SmtpClient, M As New MailMessage
  Dim F() As String = ConfigurationManager.AppSettings("EML_FRM").Split("|")
  Dim T() As String = ConfigurationManager.AppSettings("EML_LST").Split(";")
  M.From = New MailAddress(F(1), F(0)): M.BodyEncoding = New System.Text.UTF8Encoding: M.IsBodyHtml = True
  For Each R In T: Dim P() As String = R.Trim.Split("|"): M.To.Add(New MailAddress(P(1), P(0))): Next
  M.Subject = ConfigurationManager.AppSettings("EML_SBJ"): M.Body = body: E.Timeout = 15000: E.Send(M)
  Catch: Response.Write("ERROR: Email! " & Err.Description): End Try
End Sub

Sub FileText( F As String, T As String )
  If Not F.Contains(":\") Then F = Server.MapPath(F)
  File.WriteAllText(F & ".writing", T): File.Move(F & ".writing", F)
End Sub

Function HexDate( DT As DateTime ) As String
  Return DateDiff("s", "1970-01-01", DT).ToString("X")
End Function

Function DateHex( HX As String ) As DateTime
  Return DateAdd("s", Convert.ToInt32(HX, 16), "1970-01-01")
End Function

Function EncryptPasswd( S As String ) As String
  Return FormsAuthentication.HashPasswordForStoringInConfigFile(S, "SHA1")
End Function

Function strEncode( X As String ) As String
  Return Convert.ToBase64String(Encoding.ASCII.GetBytes(X))
End Function

Function strDecode( X As String ) As String
  Return Encoding.ASCII.GetString(Convert.FromBase64String(X))
End Function

Function postWeb( URL As String, DATA As String ) As String
  Try: Dim W As New WebClient(): W.Headers("Content-Type") = "application/x-www-form-urlencoded"
  Return W.UploadString(URL, DATA): Catch: Return "SVR_ERR": End Try
End Function

Function getWeb(URL As String) As String
  Try: Dim RQ As HttpWebRequest = WebRequest.Create(URL) : RQ.AutomaticDecompression = True
  Dim RP As HttpWebResponse = RQ.GetResponse(), DS As Stream = RP.GetResponseStream(), SR As New StreamReader(DS), RS As String = SR.ReadToEnd()
  SR.Close(): DS.Close(): RP.Close(): Return RS: Catch: Return "SVR_ERR": End Try
End Function

Function MIf(ByVal ParamArray C() As Object) As Object 
  Dim L As Byte = C.Length, I As Byte = 1
  While I < L: If CBool(C(I - 1)) Then: Return C(I): End If: I += 2: End While
  Return IIf(L Mod 2 = 1, C(L - 1), Nothing)
End Function

Function ICase(K As Object, ByVal ParamArray C() As Object) As Object
  Dim L As Byte = C.Length, I As Byte = 1
  While I < L: If K = C(I - 1) Then: Return C(I): End If: I += 2: End While
  Return IIf(L Mod 2 = 1, C(L - 1), Nothing)
End Function

Function xAT( N As XmlNode, A As String, Optional D As String = "" ) As String
  Try: Return N.Attributes(A).InnerText: Catch: Return D: End Try
End Function

Function xVL( N As XmlNode, K As String, Optional D As String = "" ) As String
  Try: Return N(K).InnerText: Catch: Return D: End Try
End Function

Function sNR( x As Object, r As Object ) As Object
  If IsDBNull(x) OrElse IsNothing(x) Then Return r Else Return x
End Function

Function sN0( x As Object ) As Double
  If IsDBNull(x) OrElse IsNothing(x) Then Return 0 Else Return x
End Function

Function sNS( x As Object ) As String
  If IsDBNull(x) OrElse IsNothing(x) Then Return "" Else Return x
End Function

Function sNB( x As Object ) As Boolean
  If IsDBNull(x) OrElse IsNothing(x) Then Return False Else Return x
End Function

Function sNN( x As Object ) As Boolean
  Return Not( IsDBNull(x) OrElse IsNothing(x) )
End Function

Function FormatBilling( x As Double ) As String
  If x < -0.001 Then: Return "<font class=NEG>(" & FormatNumber( Math.Abs(x) ) & ")</font>"
  Else: Return "<font class=PSV>" & FormatNumber( x ) & "</font>": End If
End Function

Function sLcDt( DT As Object, F As String ) As String
  If IsDBNull(DT) OrElse IsNothing(DT) Then Return ""
  If IsNothing(Session("GMT")) Then Return CDate(DT).ToString(F) Else _
    Return CDate(DT).ToUniversalTime.AddHours(Session("GMT")(0)).AddMinutes(Session("GMT")(1)).ToString(F)
End Function

Function sVar( x As Object, Optional m As String = "", Optional l As Integer = 0 ) As String
  Select Case VarType( x )
  Case vbEmpty, vbNull:
    If l = -1 Then
      Return ""
    Else
      Select Case UCase(m)
      Case "TXT", "NMI": Return ""
      Case "NUM", "CUR": Return "<i class=NA>-</i>"
      Case Else : Return "<i class=NA>N/A</i>"
      End Select
    End If

  Case vbDate:
    Dim y As DateTime = Convert.ToDateTime(x)
    Select Case UCase(m)
    Case "SDT": Return y.ToString("dd MMM")
    Case "MDT": Return y.ToString("ddd, dd MMM")
    Case "LDT": Return y.ToString("ddd, dd MMM yyyy")
    Case "DTM": Return y.ToString("dd MMM HH:mm")
    Case "FDT": Return y.ToString("ddd, dd MMM yyyy hh:mm tt")
    Case "DTS": Return y.ToString("dd MMM yyyy HH:mm:ss.fff")
    Case "TME": Return y.ToString("hh:mm tt")
    Case Else : Return y.ToString("dd MMM yyyy")
    End Select

  Case vbByte, vbInteger, vbLong, vbSingle, vbDouble, vbCurrency, vbDecimal:
    If Double.IsInfinity(x) Then Return "-"
    Select Case UCase(m)
    Case "NUM", "NMI": Return FormatNumber(x, l)
    Case "CUR": Return FormatCurrency(x, l)
    Case Else : Return x
    End Select

  Case Else:
    If Len(x) = 0 Then Return IIf(UCase(m) = "TXT", "", "<i class=NA>N/A</i>")
    Select Case UCase(m)
    Case "EML": Return "<a href='mailto:" & x & "'>" & x & "</a>"
    Case "PTC": Return StrConv(x, vbProperCase)
    Case Else : Return IIf( l = 0, x, IIf( Len(x) <= l, x, "<span title=""" & x & """>" & Left(x, l) & "&#0133;</span>" ) )
    End Select

  End Select
End Function

Sub Ink( x As String )
  Response.Write(x)
End Sub

Sub Ink( w As Boolean, x As String )
  If w Then Response.Write(x)
End Sub

Sub PageLog( Optional x As String = "" )
  Dim S As String = Now.ToString("yyyy-MM-dd HH:mm:ss") & vbTab & Request.UserHostAddress & vbTab & Request.HttpMethod & vbTab & Request.Path
  Dim P As String = ICase(Request.HttpMethod, "GET", Request.QueryString.ToString, "POST", Request.Form.ToString, "")
  File.AppendAllText(Server.MapPath("/SIRIUS.log"), S & vbTab & IIf(P = "", x, P) & vbCrLf)
End Sub

Sub sDuration( TM As DateTime, Optional NW As DateTime = Nothing )
  If NW = Nothing Then NW = Now
  Response.Write("<p class=DBG><b>&Delta;t</b> = " & FormatNumber((NW - TM).TotalMilliSeconds) & " ms</p>")
End Sub

</script>