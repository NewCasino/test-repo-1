<%@ OutputCache Duration=5 VaryByParam="*" %>
<!-- #include file="/inc/page.inc" --><%

Response.ContentType = "text/plain"

'If IsNothing(Application("EVENT_M2R_MAX")) Then Application("EVENT_M2R_MAX") = 60
Application("EVENT_M2R_MAX") = 8*60
Dim RS As Object = getRecord("SELECT * FROM dbo.EVENT_VIEW WHERE M2R >= -" & Application("EVENT_M2R_MAX") & _
  " OR STATUS NOT IN('DONE','SKIP','ABANDONED') ORDER BY M2R")
'Dim RS As Object = getRecord("SELECT * FROM dbo.EVENT_VIEW WHERE TYPE='G' AND (M2R >= -600" & _
'  " OR STATUS NOT IN('DONE','SKIP','ABANDONED')) ORDER BY M2R")

While RS.Read() %><%=

  RS("COUNTRY") & vbTab & RS("TYPE") & vbTab & RS("MEETING_ID") & vbTab & _
  HexDate(CDate(RS("START_TIME")).ToUniversalTime) & vbTab & _
  RS("EVENT_NO").ToString.PadLeft(2, "0") & vbTab & _
  sVar(RS("VENUE") , "PTC") & vbTab & _
  sVar(RS("STATUS"), "PTC") & vbTab & _
  IIf(RS("M2R") > 99, 99, IIf(RS("M2R") < -99, -99, RS("M2R"))) & vbTab  & _
  RS("NOLXB") & vbTab  & _
  RS("FX_COUNT") & vbTab  & _
  vbLf %><%
  
End While: RS.Close() %>