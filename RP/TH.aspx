<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim EV As Object

Sub Page_Load()
  chkSession()
  If Request("FCMD") <> "" Then 
    Ink("<script>alert('Sorry, changes will not be saved here.')</scr" & "ipt>"): Response.End
  End If
  Response.CacheControl = "public": Response.Expires = 300
  
	'Detect Manager report button click
	If Request("MR") = "MR" then	 'request.form("MR")
		EV = Secure("EV", 20)
		EV = Split(EV, "_")	
        Dim S As String = "SELECT FileData, Report_Date FROM ManagerReports WHERE Report_Date = (SELECT MEETING_DATE FROM MEETING WHERE MEETING_ID = " & EV(0) & ")"
        dim RepData  = getRecord(S)
        If RepData.Read() Then
            Dim bytes() As Byte = RepData("FileData")  
            Response.Buffer = True
            Response.Charset = ""
            Response.Cache.SetCacheability(HttpCacheability.NoCache)
            'Response.ContentType = "application/vnd.ms-word"
            Response.AddHeader("content-disposition", "attachment;filename=Manager_Report_" & RepData("Report_Date") & ".docx") 
            Response.BinaryWrite(bytes)
            Response.Flush()
            Response.End()
        End If
	end If  
	
End Sub
	
</script>
<%
If Request("DT") = "" Then

  '-- Main Layout ---------------------------------------------------------------------------------
  %>
	<!DOCTYPE html>
	<html>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<link rel="stylesheet" href="/global.css">
		<script src="/global.js"></script>
		<script>
			top.setTitle("Pari-Mutuel Market History"); VW = "/MM/PM1"; 
			function tSH( X ) { var P = X.childNodes[2], B = X.parentNode.nextSibling; 
				if( !B.innerHTML ) B.innerHTML = $W(location.pathname + "?DT=" + escape(X.childNodes[1].innerHTML)); 
				P.innerHTML = (B.style.display)? "&#9660;": "&#9658;"; 
				B.style.display = (B.style.display)? "": "none"; } 
			function cVW( X ) { VW = X.value; $("CNT").innerHTML = (VW.indexOf("/XT") < 0)? "": "<div id=C1></div><div id=C2></div>" }
		</script>
		<body><WT:Main Type="Chart_Canvas" runat=server/>

			<div id=VNT style="bottom:188px">
				<table height=100%>
					<tr height=21><td><table><td width=4><td width=33>Time<td width=62><td>Race</table>
					<tr><tr height=21>
						<th>View: <%=	Session("LVL")  %>
						<select onchange=cVW(this) style="width:150px" <%=	IIf(Session("LVL") < 10 ," "," disabled ")    %>>
						<option value="/MM/PM1">Analyst
						<option value="/MM/PM2">Trader
						<option value="/MM/PMemd">Blend WIN-PLA
						<option value="/MM/XT">PM Exotics
						<option value="/MM/PMtrd">PM Trades
						</select>
				</table>

			</div>
			<div id=VNL style="bottom:212px">
			<table><col width=40><col width=32><col width=31><col width=19><col><col width=20>
<%				Dim RM As Object = getRecord("SELECT DISTINCT MEETING_DATE FROM MEETING(nolock) ORDER BY MEETING_DATE DESC")  'This section is sensitive to chg !!
				While RM.Read() %>
					<tr class=MTD onclick=tSH(this)><%
					%><td><%= CDate(RM(0)).ToString("ddd") %><td colspan=4><%= CDate(RM(0)).ToString("dd MMM yyyy")
					%><td>&#9658;<tbody style="display:none"></tbody>
<%				End While
				RM.Close()  %>
			</table>
			</div>
			<div id=CNT></div>
		</body>
		<iframe name=vrtPOST></iframe>
		<WT:Main Type="Live_Stream" runat=server/>
	</html>
<%
Else

  '-- Meeting List of A Specific Date -------------------------------------------------------------
		Dim C As String = Session("CNTL").Replace("1","AU").Replace("2","HK,JP,MO,MY,SG,UA").Replace("3","FR,IR,UK,SW,DE,FI").Replace("4","ZA").Replace("5","US,SA,CH,AR").Replace("6","NZ").Replace(",","','")
		Dim RV As Object = getRecord("SELECT * FROM dbo.EVENT_VIEW_TH WHERE MEETING_ID IN (SELECT MEETING_ID FROM MEETING(nolock) " & _
									"WHERE MEETING_DATE='" & CDate(Secure("DT", 11)).ToString("yyy-MM-dd") & "') AND " & _
									"TYPE IN('" & Session("GAME").Replace(",","','") & "') AND COUNTRY IN('" & C & "') ORDER BY TYPE, COUNTRY, VENUE, EVENT_NO")
		Dim CV As String = ""
		While RV.Read()    %>
			<tr onclick=getEVN('<%= RV("MEETING_ID") & "_" & Right("0" & RV("EVENT_NO"), 2) %>',this,VW)>
			<td><%= sLcDt(RV("START_TIME"), "HH:mm")		%>
			<td><img src=/img/<%= RV("COUNTRY") %>.jpg><td><img src=/img/<%= RV("TYPE") %>.png>
			<td><%= CByte(RV("EVENT_NO")).ToString("00") %>
			<td><%
			If CV <> RV("COUNTRY") & RV("VENUE") Then		  %>
				<b><%= RV("VENUE") %><% CV = RV("COUNTRY") & RV("VENUE")
			Else %>
				<%= LCase(RV("VENUE")) %>
		<% 	End If %>
			<td>
	<%	End While 
		RV.Close() %>
		<tr><td colspan=6 class=SPT>
<%
End If %>