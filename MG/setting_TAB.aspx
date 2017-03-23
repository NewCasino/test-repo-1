<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim RS As Object

Sub Page_Load()
	chkSession(7)

	If Request("FCMD") <> "" Then
		Dim S As String = "", L As String
		
		Select case Request("FCMD")
		Case "Save"
			RS = getRecord("SELECT TYPE FROM SYS_CODE_TAB WHERE TYPE LIKE 'TES_[VNQ]%'")
			While RS.Read
				S &= "UPDATE SYS_CODE_TAB SET CODE=" & chkRN(RS(0)) & " WHERE TYPE='" & RS(0) & "'" & vbLf
			End While
			RS.Close

			RS = getRecord("SELECT TYPE FROM SYS_ENUM_TAB  WHERE TYPE NOT IN('DISC','TRD_LVL','OBSV','MTG_ID') AND TYPE NOT LIKE 'FXP_%'")
			While RS.Read
				If chkR9(RS(0)) <> "NULL" Then
					S &= "UPDATE SYS_ENUM_TAB SET NUM=" & chkR9(RS(0)) & IIf("CMB, WIS BLN MKT".Contains(Left(RS(0), 3)), " * 100", "") & " WHERE TYPE='" & RS(0) & "'" & vbLf
				End If
			End While
			RS.Close

			RS = getRecord("SELECT LVL_ID FROM SYS_LEVEL_TAB  ORDER BY LVL_ID")
			While RS.Read
				L = ""
				For I = 1 To 11
					L &= ", LVL_" & I & "=" & ChkR9("LVL_" & RS(0) & "_" & I)
				Next
				S &= "UPDATE SYS_LEVEL_TAB SET" & Mid(L, 2) & " WHERE LVL_ID=" & RS(0) & vbLf
			End While
			RS.Close

			RS = getRecord("SELECT COUNTRY, TYPE FROM SYS_BIAS_TAB  ORDER BY COUNTRY, TYPE")
			While RS.Read
				L = ""
				For I = 1 To 10
					L &= ", LSB_" & I & "=" & ChkR9("LSB_" & RS(0) & RS(1) & "_" & I)
				Next
				S &= "UPDATE SYS_BIAS_TAB SET" & Mid(L, 2) & " WHERE COUNTRY='" & RS(0) & "' AND TYPE='" & RS(1) & "'" & vbLf
			End While
			RS.Close

			RS = getRecord("SELECT COUNTRY, TYPE FROM SYS_FVT_TAB  ORDER BY COUNTRY, TYPE")
			While RS.Read
				L = RS(0) & RS(1)
				S &= "UPDATE SYS_FVT_TAB SET MAX_MDL=" & ChkR9("MXM_" & L) & _
					", POS_EXP=" & ChkR9("PSX_" & L) & ", NEG_EXP=" & ChkR9("NGX_" & L) & _
					" WHERE COUNTRY='" & RS(0) & "' AND TYPE='" & RS(1) & "'" & vbLf
			End While
			RS.Close
			
		Case "Update"
						
			RS = getRecord("SELECT ROW_ID FROM SYS_WISE_TAB  ORDER BY CUST_ID, REGION")
			While RS.Read
				L = ""
				For I = 1 To 11
					'response.write(ChkR9("WLVL_" & I & "_" & RS(0))) '"WLVL_" & I & "_" & RS(0))
					L &= ", CHK_" & I & "=" & ChkR9("WLVL_" & I & "_" & RS(0))
				Next
				S &= "UPDATE SYS_WISE_TAB SET " & Mid(L, 2) & " WHERE ROW_ID=" & RS(0) & vbLf
			End While
			RS.Close
		
		Case "New"											'Add new Customer to WISE table
			If ChkR9("NEWID") <> "NULL" THEN
				S &= "INSERT SYS_WISE_TAB (CUST_ID,REGION) VALUES (" & ChkR9("NEWID") & ",'M')" & vbLf
				S &= "INSERT SYS_WISE_TAB (CUST_ID,REGION) VALUES (" & ChkR9("NEWID") & ",NULL)" & vbLf
			ELSE
				response.write ("Missing New Customer ID !!")
				exit sub
			End If
			
		End Select

		'response.write(s)
		execSQL(S)
		Application.Remove("SYS_CODE_TAB")
		Application.Remove("SYS_ENUM_TAB")
		Application.Remove("SYS_BIAS_TAB")
	End If

End Sub

</script>

<!DOCTYPE html>
<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="/global.css">
	<script src="/global.js"></script>
	<script>top.setTitle("Parameter Settings - TAB")</script>
	<style>#WIP input { width:45px; text-align:right }</style>
	
	<body>
		<div id=CNT style="top:25px; left:25px; width:1100px">
			<form method=post>
				<table width=1100 cellpadding=0>
					<td valign=top rowspan=3 width=210>

					<%' Disc. Harville
					%>
					<div class=LST>
						<table cellspacing=0>
							<col width=40><col><col width=60>
							<tr><th colspan=3 class=TT>Disc. Harville %<%
							RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE LIKE 'DHV%' ORDER BY TYPE")
							While RS.Read  %>
								<tr><% 
								If Right(RS(0), 1) = 1 Then %>
									<td rowspan=3<%= IIf(Left(RS(2),1) = "R", " class=LR", "") %>><img src="/img/<%= Left(RS(2),1) %>.png"><% 
								End If  %>
									<td class=RN><%= Mid(RS(2), 4) %>
									<td><input name=<%= RS(0) %> type=number value=<%= RS(1) %>><%
							End While
							RS.Close %>
						</table>
					</div>

					<%' Trade %
					%>
					<div class="LST GAP">
						<table>
							<col width=40><col><col width=60><tr><th colspan=3 class=TT>Trade %<%
							RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE LIKE 'PCT%' ORDER BY TYPE")
							While RS.Read  %>
								<tr><% 
								If Right(RS(0), 3) = "HKB" Then %>
									<td rowspan=4<%= IIf(Left(RS(2), 2) = "PM", " class=LR", "") %>><b><%= Left(RS(2), 2) %><% 
								End If  %>
									<td class=RN><%= Mid(RS(2), 5) %>
									<td><input name=<%= RS(0) %> type=number value=<%= RS(1) %>><%
							End While
							RS.Close %>
						</table>
					</div>

					<td width=15><td valign=top width=175>

					<%' Reduced Staking %
					%>
					<div class=LST>
						<table>
							<col><col width=60><tr><th colspan=2 class=TT>Reduced Staking %<%
							RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE LIKE 'RDC_ST_%' ORDER BY TYPE")
							While RS.Read		%>
								<tr>
									<td><img align=absmiddle class=FLG src="/img/<%= Mid(RS(0), 8, 2) %>.jpg"> <img align=absmiddle src="/img/<%= Right(RS(0), 1) %>.png">
									<td><input name=<%= RS(0) %> type=number value=<%= RS(1) %>><% 
							End While
							RS.Close %>
						</table>
					</div>

					<%' Other %
					%>
					<div class="LST GAP" id=WIP>
						<table>
							<col width=40><col><col width=65>
							<tr><th colspan=3 class=TT>Other %<%
								RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE LIKE 'CMB_%' OR TYPE LIKE 'BLN_%' ORDER BY LEFT(TYPE,3) DESC, TYPE")
								While RS.Read  %>
								<tr><% 
									If Right(RS(0), 1) = 1 Then %>
										<td rowspan=<%= IIf(Left(RS(0),3)="CMB", 2, 3) %>><img src="/img/<%= Left(RS(2), 1) %>.png"><% 
									End If  %>
										<td><%= Mid(RS(2), 5) %><td><input name=<%= RS(0) %> type=text value=<%= FormatNumber(RS(1) / 100) %>><% 
								End While
								RS.Close	%>
							<tr>
								<td colspan=3 class=SPT><%
								RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE IN('MRR_MTP','MRR_PC1','MRR_PC2') ORDER BY TYPE")
								While RS.Read  %>
									<tr><% 
									If RS(0) = "MRR_MTP" Then %>
										<td rowspan=3><img class=FLG src="/img/AU.jpg"><br><img src="/img/R.png"><% 
									End If  %>
										<td><%= RS(2) %><td><input name=<%= RS(0) %> type=number value=<%= RS(1) %>><% 
								End While
								RS.Close	%>
							<tr>
								<td colspan=3 class=SPT><%
								RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE IN('1ST_UP_G','OVL_VWM','XB1_MKP','DVP_SKW','DVP_SKW_RP','DVP_SKW_RC','DVP_SKW_G','DVP_SKW_H','CFLA_SKW','CFLB_SKW','CFLC_SKW','CFLD_SKW' ) ORDER BY VALUE")
								While RS.Read  %>
									<tr>
										<td colspan=2><%= RS(2) %>
										<td><input name=<%= RS(0) %> type=number value=<%= RS(1) %>><% 
								End While
								RS.Close    %>
							<tr>
								<td colspan=3 class=SPT><%
								RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE IN( 'MKTPCT_R', 'MKTPCT_H', 'MKTPCT_G' ,'WISECL_A',  'WISECL_B', 'WISECL_C',  'WISECL_D')")
								While RS.Read  %>
									<tr>
										<td colspan=2><%= RS(2) %>
										<td><input name=<%= RS(0) %> type=number  step='0.01' value=<%= FormatNumber(RS(1) / 100)  %>><% 
								End While
								RS.Close    %>

						</table>
					</div>

					<%' Kelly Formula
					%>
					<div class="LST GAP">
						<table>
							<col><col width=60><tr><th colspan=2 class=TT>Kelly Formula<%
							RS = getRecord("SELECT * FROM SYS_ENUM_TAB  WHERE TYPE LIKE 'KLY%' ORDER BY TYPE")
								While RS.Read%>
									<tr>
										<td class=RN><%= RS(2) %><td><input name=<%= RS(0) %> type=number value=<%= RS(1) %>><% 
								End While
							RS.Close %>
						</table>
					</div>

					<td width=15><td valign=top>

					<%' Trade Distribution Level
					%>
					<div class=LST>
						<table>
							<col width=35><col width=45><colgroup span=11>
							<tr><th colspan=13 class=TT>Trade Distribution Level
							<%
							RS = getRecord("SELECT * FROM SYS_LEVEL_TAB  ORDER BY LVL_ID")
							While RS.Read  %>
								<tr>
								<% If RS(0) Mod 2 = 1 Then %>
									<td rowspan=2<%= IIf(RS(0) = 3, " class=LR", "") %>><b><%= {"PM", "", "FX"}(RS(0)-1) %><% 
								End If  %>
								<td><b><%= {"Eat", "Bet"}(RS(0) Mod 2) %><%
								For I = 1 To 11 %>
									<td>
									<% If sNN(RS(I)) Then %>
										<input name=LVL_<%= RS(0) %>_<%= I %> type=number value=<%= RS(I) %>><% 
									End If
								Next
							End While
							RS.Close %>
						</table>
					</div>

					<%' Long Shot Bias
					%>
					<div class="LST GAP">
						<table>
							<col width=80><colgroup span=10>
							<tr><th colspan=11 class=TT>Long Shot Bias Level
							<tr>
							<tr height=18 class="GY SML"><th>Meeting<th>1 - 1.5<th>1.5 - 2<th>2 - 3<th>3 - 5<th>5 - 7<th>7 - 10<th>10 - 14<th>14 - 25<th>25 - 50<th>> 50
							<%
							RS = getRecord("SELECT * FROM SYS_BIAS_TAB  ORDER BY CASE COUNTRY WHEN 'XX' THEN 1 ELSE 0 END, COUNTRY, TYPE")
							While RS.Read			%>
								<tr>
								<% If RS(0) <> "XX" Then %>
									<td><img align=absmiddle class=FLG src="/img/<%= RS(0) %>.jpg"> <img align=absmiddle src="/img/<%= RS(1) %>.png">
								<% Else %>
									<td><b>Default<% 
								End If
								For I = 1 To 10 %>
									<td>
									<% If sNN(RS(I)) Then %>
										<input name=LSB_<%= RS(0) %><%= RS(1) %>_<%= I %> type=number value=<%= RS(I+1) %>><% 
									End If
								Next
							End While
							RS.Close %>
						</table>
					</div>

					<%' Fair Value Ticket Setting
					%>
					<div class="LST GAP" style="width:350px">
						<table>
							<col width=80><colgroup span=3>
							<tr><th colspan=4 class=TT>Fair Value Ticket
							<tr><tr height=18 class="GY SML"><th>Meeting<th>Max fModel<th>+ EXP<th>- EXP
							<%
							RS = getRecord("SELECT * FROM SYS_FVT_TAB  ORDER BY CASE COUNTRY WHEN 'XX' THEN 1 ELSE 0 END, COUNTRY, TYPE")
							While RS.Read		  %>
								<tr>
								<% If RS(0) <> "XX" Then %>
									<td><img align=absmiddle class=FLG src="/img/<%= RS(0) %>.jpg"> <img align=absmiddle src="/img/<%= RS(1) %>.png">
								<% Else %>
									<td><b>Default<% 
								End If		  %>
								<td><input name=MXM_<%= RS(0) %><%= RS(1) %> type=number value=<%= RS("MAX_MDL") %>>
								<td><input name=PSX_<%= RS(0) %><%= RS(1) %> type=number value=<%= RS("POS_EXP") %>>
								<td><input name=NGX_<%= RS(0) %><%= RS(1) %> type=number value=<%= RS("NEG_EXP") %>><%
							End While
							RS.Close %>
						</table>
					</div>

					<%	' Trifecta Estimate Source
					%>
					<div class="LST GAP" style="width:270px">
						<table><col><col width=190><tr><th colspan=2 class=TT>Trifecta Estimate Source
						<%	RS = getRecord("SELECT * FROM SYS_CODE_TAB WHERE TYPE LIKE 'TES_[VNQ]%' ORDER BY CHARINDEX(LEFT(NAME,1),'VNQ')")
						While RS.Read		  %>
						  <tr>
							<td><%= RS(2) %>
							<td><select name=<%= RS(0) %> style="width:92%"><%= makeList("SELECT", "", "SYS_CODE_TAB", "TES_LST", "CODE", "NAME", RS(1)) %></select> <%
						End While
						RS.Close %>
						</table>
					</div>
					
				</table>
				
				<div class=EDT>
					<input type=reset value="Undo"> 
					<input type=submit name=FCMD value="Save">
				</div>

			</form>
		</div>
		
		<!--  WISE	-->
		<% IF Session("LVL") = 5 OR Session("LVL") = 0 Then %>
			<form  method=post>
				<div id=CNT style="top:25px; left:1125px">
							
							<div class=LST>
								<table>
									<col width=60><col width=30><colgroup span=11>
									<tr><th colspan=13 class=TT>WISE Table
									<tr>
									<tr height=18 class="GY SML"><th>ID<th>Reg<th>1<th>2<th>3<th>4<th>5<th>6<th>7<th>8<th>9<th>10<th>11
									<%
									RS = getRecord("SELECT * FROM SYS_WISE_TAB  ORDER BY CUST_ID, REGION")
									While RS.Read  %>
										<tr>
											<td><b><%= RS(1) %>
											<td><b><%= RS(2) %>
											<% For I = 3 To 13 %>
												<td><input name=WLVL_<%= I-2 %>_<%= RS(0) %> value=<%= RS(I) %> >
											<%Next
									End While
									RS.Close %>
								</table>
							</div>
				<div class=EDT>
					<input type=reset value="Undo"> 
					<input type=submit name=FCMD value="Update">
					<input type=submit name=FCMD value="New">
					<input type="text" name=NEWID placeholder="New ID" size="3" >
				</div>			
				</div>
			</form>
		<% End If %>
	</body>
</html>