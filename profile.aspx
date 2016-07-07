<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

	Dim RS As Object

	Sub Page_Load()
		chkSession()

		If Request.Form("CMD") = "Update" Then
			execSQL("UPDATE TRADER SET " & _
			"NAME=" & chkRN("DNM")  & ", " & _
			"GAME=" & chkRN("GAME") & ", " & _
			"CNTL=" & chkRN("CNTL") & ", " & _
			"BASE=" & chkR9("BASE") & "  " & _
			", LUX=" & If( Trim(Request("LUX")) = "", 0,1 ) & "  " & _
			", SUN=" & If( Trim(Request("SUN")) = "", 0,1 ) & "  " & _
			", TAB=" & If( Trim(Request("TAB")) = "", 0,1 ) & "  " & _
			"WHERE LID='" & Session("LID") & "'")

			Dim PWD As String = Request.Form("PWD"), PW1 As String = Request.Form("PW1"), PW2 As String = Request.Form("PW2") 

			If PWD <> "" And PW1 <> "" And PW2 <> "" And (PW1 = PW2) Then
				If getResult("SELECT PWD FROM TRADER(nolock) WHERE LID='" & Session("LID") & "'") = EncryptPasswd(PWD) Then
					execSQL("UPDATE TRADER SET PWD='" & EncryptPasswd(PW1) & "' WHERE LID='" & Session("LID") & "'")
					MSG.innerHTML = "<font class=GR>New Password has been saved!</font>"
				Else
					MSG.innerHTML = "<font class=RD>Invalid Old Password. Password remains!</font>"
				End If
			Else
				MSG.innerHTML = "<font class=GR>Profile & Settings has been updated!</font>"
			End If
		End If
	End Sub

</script>

<!DOCTYPE html>
<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="/global.css">
	<script src="/global.js"></script>
	<script>
		top.setTitle("My Profile & Settings"); 
		
		function F( f ) { if( !f.DNM.value ) { alert("Display Name can not be empty!"); return false } 
		  if( f.PWD.value && !(f.PW1.value || f.PW2.value) ) { alert("New Password must be entered!"); return false } 
		  if( !f.PWD.value && (f.PW1.value || f.PW2.value) ) { alert("Old Password must be supplied!"); return false } 
		  if( (f.PW1.value || f.PW2.value) ) { 
			if( f.PW1.value != f.PW2.value ) { alert("New Password does not matched!"); return false } 
			if( f.PW1.value.length < 5 ) { alert("New Password must be at least 5 characters!"); return false } } return true; }
	</script>
	
	<body>
		<div id=CNT style="top:30px; left:30px; width:580px">
			<% 	RS = getRecord("SELECT * FROM TRADER(nolock) WHERE LID='" & Session("LID") & "'")
			If RS.Read() Then
				Session("GAME") = sNS(RS("GAME"))
				Session("CNTL") = sNS(RS("CNTL"))
				Session("BASE") = RS("BASE")			  %>
				<form method=post onsubmit="return F(this)" autocomplete=off>
					<table cellspacing=5>
						<td valign=top>
						<table class=LST cellspacing=0 cellpadding=5>
							<col width=140><col>
							<tr><th colspan=2 class=TT>Account Profile
							<tr><td class=RN><b>Login ID <td><b><%= Session("LID")  %>
							<tr><td class=RN><b>Level Group <td><%= Session("LNM")  %>
							<tr><td class=RN><b>Display Name<td><input type=text name=DNM style="width:120px" value="<%= RS("NAME") %>">
							<tr><td class=RN><b>Old Password    <td><input type=password name=PWD style="width:120px">
							<tr><td class=RN><b>New Password
							<div style="padding-top:12px">Re-type Password</div>
							<td><input type=password name=PW1 style="width:120px"><br><input type=password name=PW2 style="width:120px">
						</table>

						<td valign=top>
						<table class=LST cellspacing=0 cellpadding=5>
							<col width=100><col width=180>
							<tr><th colspan=2 class=TT>Personal Settings
							<tr><td class=RN><b>Game Type<td class=RN><%= makeList("CHECKBOX LINE", "GAME", "SYS_CODE", "GAME", "CODE", "NAME", sNS(RS("GAME")))  %>
							<tr><td class=RN><b>Continent<td class=RN><%= makeList("CHECKBOX", "CNTL", "SYS_CODE", "CONTINENT", "CODE", "NAME", sNS(RS("CNTL")))  %>
							<tr><td class=RN><b>View Mode<td class=RN><%= makeList("RADIO", "BASE", "SYS_CODE", "VIEW_MODE", "CODE", "NAME", RS("BASE"))  %>
							<tr><td class=RN><b>System<td class=RN>
								<input type="CHECKBOX" name="LUX" value="1" <%= If(RS("LUX"), " checked", "")  %>>Luxbet<br>
								<input type="CHECKBOX" name="SUN" value="2"  <%= If(RS("SUN"), " checked", "")  %>>SUNbet<br>
								<input type="CHECKBOX" name="TAB" value="3"  <%= If(RS("TAB"), " checked", "")  %>>Tab<br>
						</table>
					</table>
					<div class=EDT>
						<input type=submit name=CMD value="Update">
					</div>
				</form>
				<div id=MSG style="font-weight:bold; text-align:center" runat=server />

		  <% End If
			RS.Close()	%>
			<p><!--  User list for senior Managers-->
			<%	If Session("LVL") < 2    %>
			<table class=LST cellspacing=0 cellpadding=5>
							<col width=200><col width=180><col width=190>
							<tr><th colspan=3 class=TT>Luxbook Users
							<tr><td><b>Name<td><b>Access Level<td><b>Dept
							<%  RS = getRecord("SELECT NAME,VALUE,DEPT,  * FROM TRADER t INNER JOIN SYS_ENUM ON LVL = NUM WHERE TYPE = 'TRD_LVL' AND NAME <> 'NEW USER' ORDER BY LVL, t.DEPT, t.NAME")
								While RS.Read() %>
								<tr><td class=RN><%= RS("NAME") %><td><%= RS("VALUE") %><td><%= RS("DEPT") %>
							<%	End While
								RS.Close()	%>
			</table>
			<%	End If    %>
			<p> 
		</div>
	</body>
</html>
