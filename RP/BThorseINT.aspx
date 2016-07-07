<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

	Dim DT As String
	Dim RType As String = "R"	'R = Thoroughbred H=Harness
	Dim AUorINT As String = " NOT "  ' AU & NZ races or Internationals 

	Sub Page_Load()
	  chkSession() 
	  DT = Secure("DT", 10)

	  'RType = Request("TYP")  'TBC feed type and county from request call ??
	  Dim CM As String = Request("FCMD")
	  If CM <> "" Then
		Select Case CM
			Case "Save"
				Dim RM As Object = getRecord("SELECT MEETING_ID FROM MEETING(nolock) " & _
				"WHERE MEETING_DATE='" & DT & "' AND COUNTRY " & AUorINT & " IN('AU','NZ') AND TYPE =('" & RType & "')")
				Dim S As String = "", KY As String
				While RM.Read()
					Dim RV As Object = getRecord("SELECT EVENT_NO FROM EVENT(nolock) WHERE MEETING_ID=" & RM(0))
					While RV.Read()
						KY = RM(0) & "_" & RV(0)
						S &= "UPDATE EVENT SET" & _
							"  TRADER="  & chkRN("TRD_" & KY) & _
							", OBSV="    & chkRN("OBS_" & KY) & _
							", COMMENT=" & chkRN("CMT_" & KY) & _
							" WHERE MEETING_ID=" & RM(0) & " AND EVENT_NO=" & RV(0) & vbLf
					End While
					RV.Close()
				End While
				RM.Close()
				execSQL(S)
		End Select
		
		Response.Write("<script>parent.getSMR(parent.curVNL)</scr"&"ipt>")
		Response.End
	  End If
	End Sub

</script>

<% If Request("DT") = "" Then  %>
  <!DOCTYPE html>
  <html>
	  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
	  <link rel="stylesheet" href="/global.css">
	  <script src="/global.js"></script>
	  <script>
		top.setTitle("Trading Report (Bet Type on Horse)"); curVNL = ""; 
	  </script>
	  <body>
		<WT:Main id=VNL Type="Date_List" runat=server/>
		<div id=CNT style="left:165px"></div>
		<iframe name=vrtPOST></iframe>
	  </body>
  </html>
<% Else
	Dim TA(,) As Double = { {0,0,0}, {0,0,0} }  %>
	<div class=MTG>
		<div class=VNU style="font-size:21px">Pari-Mutuel Market Trading Daily Report</div>
		<div class="STS ST3">BY BET TYPE (HORSE)</div>
		<div class=VD1 style="top:30px"><%= CDate(DT).ToString("dddd, dd MMMM yyyy") %></div>
		<div class=VD2>Created at: <%= sLcDt(Now, "dd MMM yyyy hh:mmtt") %></div>
	</div>

	<form method=post target=vrtPOST autocomplete=off>
		<input name=DT type=hidden value="<%= DT %>">
		<div class=LST>
			<table>
				<col width=45><col width=65><col width=120><col><col width=110><col width=80><col width=110><col width=110>
				<col width=110><col width=80><col width=110><col width=110><col width=110><col width=80><col width=110><col width=110>
					<tr>
						<th rowspan=2>Race<th rowspan=2>Trader<th rowspan=2>Observation<th rowspan=2>Comments<th colspan=4>WIN-PLA<th colspan=4>Exotics<th colspan=4>Overall
					<tr>
						<th>Trade<th>Rebate<th>Payout<th>Profit<th>Trade<th>Rebate<th>Payout<th>Profit<th>Trade<th>Rebate<th>Payout<th>Profit

				<%
				  '-- Meeting & Event Record Gathering ------------------------------------------------------------
				Dim TL() As DataRow = makeDataSet("SELECT LID FROM TRADER(nolock) WHERE OPRT=1").Tables(0).Select()
				Dim RM As Object = getRecord("SELECT MEETING_ID, TYPE, COUNTRY, VENUE FROM MEETING(nolock) " & _
					"WHERE MEETING_DATE='" & DT & "' AND COUNTRY " & AUorINT & " IN('AU','NZ') AND TYPE =('" & RType & "') ORDER BY TYPE DESC, COUNTRY, VENUE")
				While RM.Read()
					Dim TM(,) As Double = { {0,0,0}, {0,0,0} }
					Dim RV As Object = getRecord("SELECT TPM_HST, TPM_VIC, TPM_NSW, TPM_QLD,  TXT_VIC, TXT_NSW, TXT_QLD, " & 
					  "EVENT_NO, TRADER, OBSV, COMMENT, STATUS " & _
					  "FROM EVENT(nolock) WHERE MEETING_ID=" & RM("MEETING_ID") & " ORDER BY EVENT_NO")
				%>
					<tr height=28><td class="RN HS" colspan=16>
						<img class=FLG src="/img/<%= RM("COUNTRY") %>.jpg" align=absmiddle> 
						<img src="/img/<%= RM("TYPE") %>.png" align=absmiddle> &nbsp;<%= sVar(RM("VENUE"), "PTC") %>
					
				<%	While RV.Read()
						Dim KY As String = RM("MEETING_ID") & "_" & RV("EVENT_NO")
						Dim DR As DataRow, TD(,) As Double = { {0,0,0}, {0,0,0} }
						Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME <> '#' AND " & _
															"MEETING_ID=" & RM("MEETING_ID") & " AND EVENT_NO=" & RV("EVENT_NO")).Tables(0)
						DV.PrimaryKey = New DataColumn() { DV.Columns(2), DV.Columns(3) }
				%>
					<tr>
						<td class=HN><%= RV("EVENT_NO") %>
					
					<%	If RV("STATUS") = "DONE" Then        %>
							<td class=SIP>
								<select name=TRD_<%= KY %>><option>
									<% For Each TR As DataRow In TL  %>
										<option<%= Iif(sNS(RV("TRADER")) = TR(0), " selected", "") %>>
										<%= TR(0) %>
									<% Next %>
								</select>
							<td class=SIP>
								<select name=OBS_<%= KY %>>
									<option><%= makeList("SELECT", "", "SYS_ENUM", "OBSV", "NUM", "VALUE", sN0(RV("OBSV"))) %>
								</select>
							<td class=SIP>
								<input name=CMT_<%= KY %> type=text maxlength=30 value="<%= RV("COMMENT") %>">
							
							<%	'-- Calculate WIN-PLA Investments
								For I As Byte = 0 To 3
									If sNN(RV(I)) Then
										For Each R As String In RV(I).ToString.Split(vbLf)
											If R <> "" And Left(R, 1) <> "#" Then
												Dim C() As String = R.Split(vbTab)
												TD(0, 0) -= CDbl(C(4))
												TD(0, 1) += CDbl(C(7)) + CDbl(C(8))
												DR = DV.Rows.Find({Left(C(2), 1), C(0)})
												Try
												If Not IsNothing(DR) Then TD(0, 2) += Val(C(4)) * DR(Right(RV.GetName(I), 3))
												Catch : End Try  'Operator '*' is not defined for type 'Double' and type 'DBNull'.
											End If
										Next
									End If
								Next

								'-- Calculate Exotics Investments
								For I As Byte = 4 To 6
									If sNN(RV(I)) Then
										For Each R As String In RV(I).ToString.Split(vbLf)
											If R <> "" And Left(R, 1) <> "#" Then
												Dim C() As String = R.Split(vbTab)
												TD(1, 0) -= CDbl(C(3))
												TD(1, 1) += CDbl(C(4)) / 100
												DR = DV.Rows.Find({Left(C(1), 1), C(0)})
												If Not IsNothing(DR) Then TD(1, 2) += Val(C(3)) * sN0(DR(Right(RV.GetName(I), 3)))
											End If
										Next
									End If
								Next

								'-- Display Total Investments, Results & Dividend
							%>
							<td class=NM><%= FormatBilling(-TD(0,0)) %>
							<td class=NM><%= FormatBilling(TD(0,1)) %>
							<td class=NM><%= FormatBilling(TD(0,2)) %>
							<td class="FF NM"><%= FormatBilling(TD(0,0) + TD(0,1) + TD(0,2))  %>
							<td class=NM><%= FormatBilling(-TD(1,0)) %>
							<td class=NM><%= FormatBilling(TD(1,1)) %>
							<td class=NM><%= FormatBilling(TD(1,2)) %>
							<td class="FF NM"><%= FormatBilling(TD(1,0) + TD(1,1) + TD(1,2))%>
							<td class=NM><%= FormatBilling(-(TD(0,0) + TD(1,0)))        %>
							<td class=NM><%= FormatBilling(  TD(0,1) + TD(1,1) )        %>
							<td class=NM><%= FormatBilling(  TD(0,2) + TD(1,2) )        %>
							<td class="FF NM"><%= FormatBilling(TD(0,0) + TD(0,1) + TD(0,2) + TD(1,0) + TD(1,1) + TD(1,2)) %>
							
							<%	'-- Add Up Total per Meeting
								TM(0,0) += TD(0,0): TM(0,1) += TD(0,1): TM(0,2) += TD(0,2) 
								TM(1,0) += TD(1,0): TM(1,1) += TD(1,1): TM(1,2) += TD(1,2) 

						Else %>
							<td colspan=3 class=RI height=18><%= sVar(RV("STATUS"), "PTC") %>
							<td><td><td><td><td><td><td><td><td><td><td><td>
				 <% 	End If
					End While
					RV.Close()

					'-- Display Total per Meeting
				%>
					<tr>
						<td colspan=16 class=SPT>
					<tr class=TOT height=25>
						<td class=TFN colspan=4><b>Total Trades on <%= sVar(RM("VENUE"), "PTC") %>
						<td class=NM><b><%= FormatBilling(-TM(0,0)) %>
						<td class=NM><%= FormatBilling(TM(0,1)) %>
						<td class=NM><%= FormatBilling(TM(0,2)) %>
						<td class="FD NM"><b><%= FormatBilling(TM(0,0) + TM(0,1) + TM(0,2))    %>
						<td class=NM><b><%= FormatBilling(-TM(1,0)) %>
						<td class=NM><%= FormatBilling(TM(1,1)) %>
						<td class=NM><%= FormatBilling(TM(1,2)) %>
						<td class="FD NM"><b><%= FormatBilling(TM(1,0) + TM(1,1) + TM(1,2))    %>
						<td class=NM><b><%= FormatBilling(-(TM(0,0) + TM(1,0)))    %>
						<td class=NM><%=    FormatBilling(  TM(0,1) + TM(1,1) )    %>
						<td class=NM><%=    FormatBilling(  TM(0,2) + TM(1,2) )    %>
						<td class="FD NM"><b><%= FormatBilling(TM(0,0) + TM(0,1) + TM(0,2) + TM(1,0) + TM(1,1) + TM(1,2)) %>
					<tr>
						<td colspan=16 height=12 class=SCR>
				<%
					'-- Add Up Daily Total
					TA(0,0) += TM(0,0): TA(0,1) += TM(0,1): TA(0,2) += TM(0,2) 
					TA(1,0) += TM(1,0): TA(1,1) += TM(1,1): TA(1,2) += TM(1,2) 

				End While
				RM.Close()

				  '-- Display Daily Total
				%>
				  <tr height=28>
					<td class="RN HS" colspan=16>Overall Trades on <%= CDate(DT).ToString("dddd, dd MMMM yyyy") %>
				  <tr class=TOT height=27>
					  <td class=TFN colspan=4><b>Total Daily Trades by Bet Type
					  <td class=NM><b><%= FormatBilling(-TA(0,0)) %>
					  <td class=NM><%= FormatBilling(TA(0,1)) %>
					  <td class=NM><%= FormatBilling(TA(0,2)) %>
					  <td class="FT NM"><b><%= FormatBilling(TA(0,0) + TA(0,1) + TA(0,2))  %>
					  <td class=NM><b><%= FormatBilling(-TA(1,0)) %>
					  <td class=NM><%= FormatBilling(TA(1,1)) %>
					  <td class=NM><%= FormatBilling(TA(1,2)) %>
					  <td class="FT NM"><b><%= FormatBilling(TA(1,0) + TA(1,1) + TA(1,2))  %>
					  <td class=NM><b><%= FormatBilling(-(TA(0,0) + TA(1,0)))  %>
					  <td class=NM><%=    FormatBilling(  TA(0,1) + TA(1,1) )  %>
					  <td class=NM><%=    FormatBilling(  TA(0,2) + TA(1,2) )  %>
					  <td class="FT NM"><b><%= FormatBilling(TA(0,0) + TA(0,1) + TA(0,2) + TA(1,0) + TA(1,1) + TA(1,2)) %>
				  <tr>
					<td colspan=16 height=12 class=SCR>
			</table>
		</div>
		<br><br><br><br>

		<div class=EDT style="position:fixed; padding:3px 10px 5px; border-radius:7px 7px 0 0; bottom:-8px; left:45%">
			<input type=reset value="Undo">
			<input name=FCMD type=submit value="Save">

		</div>
	</form>
<%End If %>