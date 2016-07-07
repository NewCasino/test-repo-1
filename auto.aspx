<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Sub Page_Load()
  Dim PG As String = Request("PAGE")
  If PG <> "" Then
    PG = "/" & Replace(PG, ".", "/") & ".aspx"
    Session("LID") = "AUTO": Session("LVL") = 0: Session("BASE") = 1
    Session("CNTL") = "1,2,3,4,5,6": Session("GMT") = {8, 0}
    Server.Transfer(PG)
  End If
End Sub

</script>