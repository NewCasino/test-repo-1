<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Sub Page_Load()
  Try
    Dim DT As String = Left(Request("DT"), 8), RC As Byte = Val(Request("RC"))
    Dim ID As String = Left(Request("ID"), 3), PN As Byte = Val(Request("PN"))
    PageLog("DT=" & DT & ", ID=" & ID & ", RC=" & RC & ", PN=" & PN)
    DT = Left(DT, 4) & "-" & Mid(DT, 5, 2) & "-" & Right(DT, 2)
    If DT <> "" And ID <> "" And RC > 0 And PN < 9 Then
      Dim MT As Long = getResult("SELECT MEETING_ID FROM MEETING(nolock) WHERE MEETING_DATE='" & DT & "' AND UTL_ID='" & ID & "'",,0)
      If MT > 0 Then
        execSQL("UPDATE EVENT SET PULSE=" & PN & " WHERE MEETING_ID=" & MT & " AND EVENT_NO=" & RC)
        Response.Write("OK")
      Else: Response.Write("ER! Event could not be found."): End If
    Else: Response.Write("ER! Insufficient Parameters."): End If
  Catch: Response.Write("ER! " & Err.Description): End Try
End Sub

</script>