<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Sub Page_Load()
  Dim DT As String = Request("DT"), ID As String = Left(Request("ID"), 10), RC As String = Request("RC")
  Dim R As DataRow, JS As String = "", D As String
  If IsDate(DT) And IsNumeric(RC) Then
    DT = CDate(DT).ToString("yyyy-MM-dd"): RC = Val(RC)
    Dim RH As DataTable = makeDataSet("SELECT RUNNER_NO, PM_DPP FROM RUNNER(nolock) WHERE SCR=0 AND EVENT_NO=" & RC & _
      "AND MEETING_ID IN (SELECT MEETING_ID FROM MEETING(nolock) WHERE MEETING_DATE='" & DT & "' AND BTK_ID='" & ID & "')" & _
      "ORDER BY RUNNER_NO").Tables(0)
    If RH.Rows.Count > 0 Then
      For Each R In RH.Rows
        D = sFxDiv(R(1)): If D = "" Then D = "0.00"
        JS &= ",{num:" & R(0) & ",odd:" & D & "}"
      Next
      JS = "{feed:{date:""" & DT & """,id:""" & ID & """,event:" & RC & ",odds:[" & Mid(JS, 2) & "]}}"

    Else: JS = "{feed:{error:101,desc:""Race could not be found""}}": End If
  Else  : JS = "{feed:{error:102,desc:""Invalid Parameter(s)""}}"   : End If

  Ink(JS)
End Sub

</script>