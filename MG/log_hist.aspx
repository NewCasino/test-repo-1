<!-- #include file="/inc/page.inc" --><%

chkSession(5)

%></script><!DOCTYPE html><html><meta http-equiv="content-type" content="text/html; charset=UTF-8"><%
%><link rel="stylesheet" href="/global.css"><script src="/global.js"></script><%
%><script>top.setTitle("Access Log")</script><%
%><body><div id=CNT style="top:25px; left:25px; width:400px"><div class=LST><table cellpadding=3><%
%><col><col width=110><col width=110><tr><th>Name<th>Login<th>Logout<%

Dim RS As Object = getRecord("SELECT * FROM TRADER_LOG_VIEW WHERE PORTAL=0 AND DTM_IN >= '" & Now.AddDays(-2).ToString("yyyy-MM-dd") & "' ORDER BY DTM_IN DESC")
While RS.Read() %><tr><%
  %><td><%= RS("NAME")
  %><td><%= sLcDt(RS("DTM_IN"), "dd MMM, HH:mm")
  %><td><%= sLcDt(RS("DTM_OUT"), "dd MMM, HH:mm") %><%
End While: RS.Close()



%></table></div><br></div></body></html>