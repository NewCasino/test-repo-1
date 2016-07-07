<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

	Dim RS As Object

	Sub Page_Load()
		If Session("LID") <> "" Then Server.Transfer("home.aspx")

		If Request.Form("CMD") = "Login" Then
			Dim LID As String = Request.Form("LID").ToUpper(), OK As Boolean = False
			Dim PWD As String = EncryptPasswd(Request.Form("PWD"))
			Dim GMT As String = Mid(Request.Form("GMT"), 4, 5)
			Dim RS  As Object = getRecord("SELECT * FROM TRADER(nolock) WHERE LVL <> 3 AND LID='" & LID & "' AND PWD='" & PWD & "'")
			
			If RS.Read() Then
				Dim IP As String = Request("HTTP_X_FORWARDED_FOR")
				If IP = "" Then IP = Request("REMOTE_ADDR")
				If sNN(RS("IP_LOCK")) Then
					Dim IL As String = Trim(Split(IP, ",")(0))
					OK = (InStr(RS("IP_LOCK"), IL) > 0)
				Else
					OK = True
				End If
			  
				If OK Then
					Session("LID")  = RS("LID")
					Session("ACC")  = RS("NAME")
					Session("LVL")  = RS("LVL")
					Session("LNM")  = getEnum("TRD_LVL", RS("LVL"))
					Session("GAME") = sNS(RS("GAME"))
					Session("CNTL") = sNS(RS("CNTL"))
					Session("BASE") = RS("BASE")
					Session("GMT")  = { CInt(Left(GMT, 3)), CInt(Left(GMT, 1) & Right(GMT, 2)) }
					Session("LOG")  = getResult("INSERT TRADER_LOG (LID,IP,DTM_IN,PORTAL) VALUES('" & RS("LID") & "','" & IP & "',GETDATE(),0) SELECT @@IDENTITY")
					Session("LUX")  = RS("LUX")
					Session("SUN")  = RS("SUN")
					Session("TAB")  = RS("TAB")
				Else
					MSG.innerHTML = "Access Location Denied!"
				End If
			Else  
				MSG.innerHTML = "Invalid Login ID &/ Password!"
			End If
			
			RS.Close()
			
			If OK Then
				Response.Write("<script>top.location.reload()</scr"&"ipt>")
				Response.End
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
		top.setTitle("User Authentication"); 
		function getGMT() { var T = new Date().toTimeString().split(" ")[1]; 
							$("FRM").GMT.value = T } 
	</script>

	<body onload="$('FRM').LID.focus()">
		<div id=CNT style="top:35px; left:35px; width:220px">
		<form id=FRM method=post autocomplete=off onsubmit="getGMT()">
			<table class=LST width=100% cellspacing=0 cellpadding=5>
				<col width=90><col>
				<tr>
					<td class=RN><b>Login ID  <td>
					<input type=text     name=LID style="width:100px; text-align:left">
				<tr>
					<td class=RN><b>Password  <td>
					<input type=password name=PWD style="width:100px">
			</table>
			<div  class=EDT >
				<input type=submit name=CMD value="Login"> <!-- style="background-color:#b03; color:#b03; border:0px solid #801" -->
				<input type=hidden name=GMT>
			</div>

		</form>
		<div id=MSG class=RD style="font-weight:bold; text-align:center" runat=server />
		</div>
	</body>
</html>





