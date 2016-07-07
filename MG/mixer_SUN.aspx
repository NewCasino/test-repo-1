<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim RS As Object, DBcol As String, N As String, S As String

Sub Page_Load()
  chkSession(7)
  Select Case Request("FCMD")
  Case "Save"
    S = ""
	RS = getRecord("SELECT * FROM SYS_MIXER_SUN")
    While RS.Read()
		N = ""
		For I = 6 To 32 
			DBcol = RS.GetName(I)
			N &= ", " & DBcol & "=" & chkR9(DBcol & "_" & RS(0))
		Next:
		S &= "UPDATE SYS_MIXER_SUN SET" & Mid(N, 2) & " WHERE ROW_ID=" & RS(0) & vbLf
    End While 
	RS.Close() 
	
	execSQL(S)
  End Select
End Sub

</script>
<!DOCTYPE html>
<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="/global.css">
	<script src="/global.js"></script>
	<script>
		top.setTitle("Price Blend SUNbet Setting"); 
		function CT( X ) { cNM(X, 100); X = X.parentNode.parentNode; var i, j = 0; 
		for( i = 4; i < 30; i++ ) j += toNum(X.childNodes[i].childNodes[0].value); 
		X.childNodes[30].innerHTML = j; 
		}
	</script>
	
	<body>
		<div id=CNT class=WD>
			<form method=post>
				<%
				RS = getRecord("SELECT * FROM SYS_MIXER_SUN ORDER BY TYPE DESC, (CASE REGION WHEN 'M' THEN 0 WHEN 'P' THEN 1 ELSE 2 END), VENUE, RANK, CONF_LVL")
				Dim MOF As Boolean = RS.Read, T As String, G As String, R As Byte, I As Byte, BlendTotal As Integer
				While MOF
					T = RS("TYPE")  %>
					<div class="LST GAP">
						  <table cellpadding=3>
							  <col width=55><col><col width=50><col width=50><colgroup span=28 width=53></colgroup>
							  <tr>
								<td colspan=32 class="FT RN MED"><img src="/img/<%= T %>.png"> <%= ICase(T, "R","Thoroughbred", "H","Harness", "G","Greyhound") %>
							  <tr>
							  <tr>
								<th class=TT>Rgn<th class=TT>Venue<th class=TT>Rank<th class=TT>Conf<th colspan=14 class=TT>FX Dividend
								<th colspan=2 class=TT>Betfair<th colspan=10 class=TT>PM Dividend<th colspan=2>
						<%  While MOF AndAlso T = RS("TYPE")
								If MOF Then
									If G <> RS("REGION") Then %>
										<tr class=SML>
											<th colspan=4>
											<th>BOB<th>WOW
											<th>PAA<th>NZ<th>TAB<th>QLD<th>365<th>LAD<th>IAS<th>SPB<th>PAL<th>UNI<th>TOP<th>EZY
											<th>VWM<th>xB1
											<th>AUS<th>STAB<th>NSW<th>QLD<th>RDbl<th>vTRF<th>vQIN<th>vXCT<th>PGI<th class=FRB>Host
											<th>Total<th>SUN %
								<%	ElseIf R <> RS("RANK") Then %>
										<tr><td colspan=32 class=SCR>
							<% 		End If
								End If
								G = RS("REGION")
								R = RS("RANK")
								BlendTotal = 0	%>
								<!-- Section below is sensitive to change, which may cause NULL values in blend & corrupt the DVP calc  -->
								<tr><td><b><%= RS("REGION") %><td><%= sNR(RS("VENUE"), "- ALL -") %><td><%= RS("RANK") %><td class=FD><%= RS("CONF_LVL") %><%
								For I = 6 To 31 
									DBcol = RS.GetName(I) 
									BlendTotal += sN0(RS(I))	%>
								  <td class="SIP<%= IIf(I >= 20 And I <= 21, " FF", "") %>"><input type=number name=<%= DBcol %>_<%= RS("ROW_ID") %> value=<%= sN0(RS(I)) %> onchange=CT(this)><%
								Next %>
								<td class=FF><%= BlendTotal %><td class=SIP><input type=number name="SUN_PCT_<%= RS("ROW_ID") %>" value=<%= sN0(RS("SUN_PCT")) %>><%
								MOF = RS.Read
							End While %>
						  </table>
					  </div>

					  <div class=EDT>
						<input type=reset value="Undo"> 
						<input type=submit name=FCMD value="Save">
					</div>
		<%		End While
				RS.Close	%>
			</form>
		</div>
	</body>
</html>