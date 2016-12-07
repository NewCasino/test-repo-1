<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim EV As Object, VM As Boolean , RiskProf as Object , SCR_RunnerNo as Byte
Dim paActive as Boolean = False

'Dim TM As DateTime = Now
Dim ColList as object

Sub Page_Load()
	Response.CacheControl = "no-cache"
	chkSession()
	Dim CM As String = Request("FCMD")
	EV = Secure("EV", 20)
	VM = (Request("VM") <> "")

	'Get Dyn col list
	If (Session("PriceCols") is nothing)  Then Session("PriceCols") = CheckColLayout(Session("LID"))
	ColList =  Session("PriceCols")  
	
	If CM <> "" And EV <> "" Then
		EV = Split(EV, "_")
		Dim WC As String = " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)
		Select Case CM

		Case "Save"
			Dim S As String = "", N As Byte
			Dim CT As String = getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
			Dim RS As Object = getRecord("SELECT RUNNER_NO FROM RUNNER(nolock)" & WC & " AND SCR=0")
			Dim ConfLVL as string = getResult("SELECT CONF_LVL FROM EVENT " & WC )
			While RS.Read()
				N = RS(0)
				S &= "UPDATE RUNNER SET" & _
				  If (sNS(ConfLVL) = "", " SKY_PD_T",  " PPDVP") & "=" & chkR9("fblend_" & N) & _	
				  ",  COMMENT=" & chkRN("COMMENT_" & N) & _
				  ", PM_TICK=" & IIf(Request("PM_TICK_" & N) = 1, 1, 0) & _
				  ", PM_RISK=0" & _
				  WC & " AND RUNNER_NO=" & N & vbLf
			End While
			RS.Close()
			S &= "UPDATE EVENT_TAB SET" & _
				"  REMARK=" & chkRN("REMARK") & _
				", REGION=" & chkRN("REGION") & _
				", RANK="   & chkR9("RANK")   & _
                ", MA_TICK="   & If(Request("MATick") = 1, 1, 0)   & _
                ", MA_TICK_SUN="   & If(Request("MATickSun") = 1, 1, 0)   & 
                ", MA_TICK_TAB="   & If(Request("MATickTab") = 1, 1, 0)   & 
                ", MA_TARGET= " & Request("MATarget") & " " & _
				WC & vbLf
			execSQL(S)

		Case "Update Runner"
			execSQL("UPDATE RUNNER SET PM_TICK=CASE PM_TICK WHEN 1 THEN 0 ELSE 1 END" & WC & " AND RUNNER_NO=" & chkR9("RNR_NO"))

		End Select

		Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>")
		Response.End
	End If
	
	'Detect Manager report button click
	If Request("MR") = "MR" then	 
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
	
	'Manual scratch button
	if Request("SCR") <> "" AND EV <> "" Then
		Dim LuxID() = Split(EV, "_")
		SCR_RunnerNo = Request("SCR")
		execSQL("UPDATE  RUNNER SET SCR=1, SCRATCH=3, SCR_TIMESTAMP = getdate() WHERE MEETING_ID = " & LuxID(0) & " AND EVENT_NO=" & LuxID(1) & " AND RUNNER_NO=" & SCR_RunnerNo)
	End If
	
	'Hide/show scratchings
	If Request("HS") = "Hide Scratch" OR Request("HS") = "Show Scratch" then
		Session("ShowScr") = If(Session("ShowScr") = 1, 0, 1)
		Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>")
		Response.End
	End If
	
	'detect Risk profile filter button change
	If Request("RKP") <> "" then
		RiskProf = Request("RKP")
	Else
		RiskProf = ""
	End if
	
	chkEvent(EV)
	MTG.EventID = EV
	EV = Split(EV, "_")
End Sub

Function GetLiabVWM(RunNo As Integer)

	dim RunLbVWM as Double
    RunLbVWM = getResult("EXEC sp_GetRunLBVWM " & EV(0) & "," & EV(1) & "," & RunNo & ",'" & RiskProf & "'," & Session("LUX") & "," & Session("SUN") & "," & Session("TAB")  ,,0)
	
	Return RunLbVWM		
End Function

Function GetLiabilitys(BetType As string, RunNo As Integer)    

	dim Run_Liab as Double
	Run_Liab = getResult("EXEC sp_GetRunLiability " & EV(0) & "," & EV(1) & "," & RunNo & ",'" & BetType & "','" & RiskProf & "'," & Session("LUX") & "," & Session("SUN") & "," & Session("TAB")  ,,0)
	if Run_Liab <> 0 then 
		Return if (Run_Liab < 0 , "<Div class=RD>" &  FormatNumber(Run_Liab,0,,TriState.UseDefault) & "</Div>", "<Div class=GR>" &  FormatNumber(Run_Liab,0,,TriState.UseDefault) & "</Div>")		'set colour of text
	'ELSE
		'Return "-"
	End if
End Function

Function GetLiabTotal(BetType As string) 

	dim Tot_Liab as Double
	Tot_Liab = getResult("EXEC sp_GetTotalLiability " & EV(0) & "," & EV(1) & ",'" & BetType & "','" & RiskProf & "'," & Session("LUX") & "," & Session("SUN") & "," & Session("TAB"),,0)
	if Tot_Liab <> 0 then Return FormatNumber(Tot_Liab,0,,TriState.UseDefault)

End Function

</script>
<%If Request("EV") = "" Then  %>
	 <%
        '' If we are targeting a race to show, then load all the side bars and go straight to the race we ant
        If Request("TargetRace") <> "" Then
            EV = Split(Request("TargetRace"),"_")
        End If

		Dim HighlightNo as String = Request("HighlightNo")

    %>
	<!DOCTYPE html>
	<html>
		<head>
			<style>
				html {
	       			overflow-y: scroll;
				}
			</style>
			<meta http-equiv="content-type" content="text/html; charset=UTF-8">
			<link rel="stylesheet" href="/global.css">
			<script src="/js/moment.min.js"> </script>
			<script src="//ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script> 		
			<script src="/global.js"></script>
			<script>
				top.setTitle("Market Maker"); curVNL = "<%= Join(EV, "_") %><%=  IIf(HighlightNo = "", "", "&HighlightNo=" & HighlightNo) %>"
				function Init() { 
					getVNL('<%= Session("GAME") %>', '<%= Session("CNTL") %>'); if( curVNL ) getEVN(curVNL); setInterval("iTM()", 1005); tvSZ(1) 
				} 
				function iSV(m) { iNR("PM_WIN_", 100, m) } 
				function iTM() { var X = $("tdPLTM"); if(X && X.innerHTML) X.innerHTML = toNum(X.innerHTML) + 1 } 
				function RunScr(RunNo) {if (confirm('Confirm you want to scratch runner ' + RunNo + ' ?') == true) {getEVN(curVNL + '&SCR=' + RunNo)}}
			</script>
			
		</head>
		<body onload=Init()>
			<WT:Main Type="Chart_Canvas" runat=server/>
			<WT:Main id=VNL Type="Venue_List" runat=server/>
			<div id=CNT></div>
			<iframe name=vrtPOST></iframe>
			<WT:Main Type="Live_Stream" runat=server/>
 
	
		</body>
	</html>
<%Else  %>
	<WT:Main id=MTG Type="Meeting_Info" runat=server/>
	
	<%'-- Meeting & Event Record Gathering ------------------------------------------------------------
	Dim DBNow As DateTime = getResult("SELECT GETDATE()")
	Dim I As Byte, TS() As Double = {0, 0, 0, 0}, NC As String = Session("NSW_CLONE")
	Dim TT As DataRow = getDataRow("SELECT STAB='', NSW='', QLD='', USA=''")
	Dim RM As DataRow = getDataRow("SELECT * FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
	Dim RV As DataRow = getDataRow("SELECT * FROM dbo.EVENT_PM    WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
	Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME IN('W','P') AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)).Tables(0)
	DV.PrimaryKey = New DataColumn() { DV.Columns(2), DV.Columns(3) }


	Dim DC() As String = { "", "", "", "" }
	Dim CT As String = RM("COUNTRY"), TP As String = RM("TYPE"), ST As String = RV("STATUS"), EventCnt as Byte = RM("EVENTS")
	Dim AUS As Boolean = "AU,NZ".Contains(CT), USA As Boolean = FALSE ' "US,SE".Contains(CT)

	Dim CloseTime as String = sNS(RV("CLOSE_TIME"))
	Dim AB As Double = sNR(RV("ALP_PMB"), 100) / 100, AE As Double = sNR(RV("ALP_PME"), 100) / 100
	Dim PP As Long = sN0(RV("PM_POOL")), AP As Long = IIf(USA, sN0(RV("HST_PW")) + sN0(RV("HST_PX")), sN0(RV("VIC_PW")) + sN0(RV("NSW_PW")) + sN0(RV("QLD_PW")))
	Dim MktPer() As Double = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 , 0, 0,0,0,0,0 , 0, 0}

	Dim Limit as string = getResult("SELECT Limit FROM SYS_MIXER WHERE TYPE = '" & RM("TYPE") & "' AND REGION = '" & RV("REGION") & "' AND RANK = " & RV("RANK") & " AND CONF_LVL = '" &  RV("CONF_LVL") & "'")
	'video replay ID		' "2014/10/20141028GAWG09"
	Dim VidTrkCode as string = getResult("EXEC sp_GetVidcode @VENUE = '" & RM("VENUE") & "' , @COUNTRY = '" & CT & "', @Type = " & TP)  
	Dim RcNo as string = EV(1).ToString 
	Dim videoID as string =  CDate(RM("MEETING_DATE")).ToString("yyyy") & "/" & CDate(RM("MEETING_DATE")).ToString("MM") & "/" & CDate(RM("MEETING_DATE")).ToString("yyyyMMdd") & VidTrkCode & if(TP= "H", "T",TP) & If(RcNo.Length = 1, "0" & RcNo, RcNo) ' Rno 
	
	'-- Parameters Setting --------------------------------------------------------------------------
	Dim OV As Byte = getENum("OVL_VWM")
	Dim BP As Byte = getENum("PCT_PM_" & IIf(CT = "HK", "HKB", "XXB"))
	Dim EP As Byte = getENum("PCT_PM_" & IIf(CT = "HK", "HKE", "XXE"))
	Dim KL As Byte = getENum("KLY_FRC")
	Dim RT As Byte = getENum("RDC_ST_" & CT & TP)

	Dim MX   As DataTable = makeDataSet("SELECT * FROM SYS_MATRIX(nolock) WHERE COUNTRY='" & CT.Replace("NZ","AU") & "'").Tables(0)
	Dim LV() As DataRow   = makeDataSet("SELECT * FROM SYS_LEVEL(nolock) WHERE LVL_ID IN(1,2) ORDER BY 1").Tables(0).Select() ' 0 = Bet, 1 = Eat

	Dim MATarget = IIf(IsDbnull(RV("MA_TARGET")), 135, RV("MA_TARGET"))

	'getCitibet(RM, RV)
	
	
	%>
	<script type="Text/javascript">
		var scratchings  = [];

	</script>	


	<form method=post target=vrtPOST id="maker-form" onsubmit="return validateMa(document);" autocomplete=off>
	  <input name=EV type=hidden value="<%= Join(EV, "_") %>">

	  <div class=LST>
		<table>
			<col width=34>	<!-- No -->
		<%If VM Then        %>
			<col width=22></col>
		<% End If %>
			<col   width=350><col width=20><col width=25><col width=45>		<!-- 'Name-FP-tick-Form-Expos  <col width=45>-->
			<col width=50><col width=36><!-- Risk  -->	<!--colgroup span=1 width=50></colgroup-->
			<colgroup span=4 width=36></colgroup>
			
			<!-- Add Dynamic Cols to table-->
			<%= usrNumCols(ColList)  %>

				<tr height=88>
					<th>No</th>
					<%If VM Then        %>
					<th>
					<input type="checkbox" class="pm_tick_master" id="toggleAllTicks" checked="checked" onclick="toggleTicks(this)"/>
					</th>
					<% End If %>
					<th><br>Name<br>
					<input  id="SCRBTN" name=HS type=submit  value="<%= If(Session("ShowScr"),"Show Scratch","Hide Scratch") %>">
					<th>FP<th class=BIG>&#10003;<th>Form<!-- th>Max<br>Expos<br>$ -->
					
					<th>Risk<br>$<th>Risk<br>VWM
					<th>MA
					<br><label title="Luxbet MA" ><input type="checkbox" class="MA_tick" name="MATick"  value=1  <%= If(RV("MA_TICK"),"checked='checked'","") %> <%= If(VM,"","disabled") %>/> L</label>
					<br><label title="SunBets MA" ><input type="checkbox" class="MA_tick" name="MATickSun" value=1  <%= If(RV("MA_TICK_SUN"),"checked='checked'","") %> <%= If(VM,"","disabled") %>/> S</label>
					<br><label title="TAB MA" ><input type="checkbox" class="MA_tick" name="MATickTab" value=1  <%= If(RV("MA_TICK_TAB"),"checked='checked'","") %> <%= If(VM,"","disabled") %>/> T</label>
                    <th>&fnof;
					<th>BOB<th>WOW
					
					<!-- Dynamic Col Headers ----------------------- -->
					<%= UsrColHeader(ColList, CT)  %>
					<th>No

		  
		  <%'-- Runners Parameter ---------------------------------------------------------------------------
		  Dim MeetingId = EV(0)
		  Dim EventNo = EV(1)
		  Dim Scratchings as New List(Of String)
		
		  
		  ' Pre-Iteration Market Price
		  Dim RP As DataRow = getDataRow("SELECT BFR_MP_B1 = SUM(CASE WHEN BFR_FW_B1 > 0 THEN 100 / BFR_FW_B1 ELSE 0 END) " & _
			"FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))

		  'Dim RS As Object = getRecord("SELECT * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
		  Dim RunnerPrices As Object = getRecord("SELECT * FROM VW_RUNNER_PRICES WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
		  Dim RunnerTable as New DataTable()
		  Dim PriceChangeDictionary as New Dictionary(Of String, List(Of DataRow))

		  RunnerTable.Load(RunnerPrices)


			For Each Runner in RunnerTable.Rows

				If getNumberString(Runner("PAA_FW")) IsNot Nothing  Then
					paActive = True
				End If

				PriceChangeDictionary(Runner("RUNNER_NO")) = New List(Of DataRow)
				If Runner("SCR") Then
					Scratchings.Add(String.Format("new scratching({0} , '{1}')",Runner("RUNNER_NO"), Runner("SCR_TIMESTAMP")))
				End If
			Next

			Dim PriceChanges As DataTable = makeDataSet(String.Format("exec sp_runnerhistory_get {0},{1}", EV(0), EV(1) )).Tables(0)
		 	
		 	PriceChangeDictionary = GetPriceChangesForRunners(PriceChanges, PriceChangeDictionary)

		 	Dim ScratchingJavascript as String = String.Format("[{0}]", String.Join(",",Scratchings))

		  
		  For Each RS in RunnerTable.Rows %>		 
		  <tr <%= If (RS("SCR") AND Session("ShowScr"),  " class=HIDESCR"  ," class=""runner-row"" " ) %> >
		<%  Dim TV As Integer, AV As Single, TD(3) As Double
			Dim RN As Byte   = RS("RUNNER_NO")
			Dim EX As Double = getExp(RS("PM_WIN"), RS("PM_DVP"))
			Dim DB As Double, DE As Double, PB As Integer = 0, PE As Integer = 0, PF As Integer = 0
			Dim AM() As Double = { _
			  Kelly(RS("PM_WIN"), 1, RV("BANK_PM1"), KL, 2, AB), _
			  Kelly(RS("PM_WIN"), 1, RV("BANK_PM1"), KL, 2, AE)    }	%>
			  
			<!-- ' Runner Info  display ---------------------------------------------------------------------------------------------->    
			<td class=HS>
			<!-- Show the tick to enable/disable trades -->
 			<%If VM Then        %>
				<%= sRNo(CT, RN) %>
 				<td>

				<i><input class="pm_tick" name=PM_TICK_<%= RN %> type=checkbox value=1<%= IIf(RS("PM_TICK"), " checked", "") %>></i>
				</td>
				<%= sHorse(RS, CT, TP, "PM",Request("HighlightNo"))   %>
			<% Else %>
			<%= sRNo(CT, RN) & sHorse(RS, CT, TP, "PM",Request("HighlightNo"))     %> 

			<% End If %>
			<% 'Not scratched
			If Not RS("SCR") Then   %>
			  
			  <!-- ' Finishing Position  --> 
			  <td><%= IIf(sNN(RS("POS")), "<b>" & RS("POS"), "") %> 
			  
			  <!--      ' WISE Counter      -->
			  <td><font color="<%= if( (CT = "AU" And TP = "R"), "red","green" ) %>"><%= if( (CT = "AU" And TP = "R"), RS("WISE_NO"), (If(RS("GHI_COUNT")>0, RS("GHI_COUNT"), "" )) ) %></font> 
					<div class=INV>
						<span>
							<font color="green"><%= If(RS("WISE_DF_NO")>0, RS("WISE_DF_NO"), "" ) %></font>
						</span>
						<font color="blue"><%= If(RS("RES_COUNT")>0, RS("RES_COUNT"), "" ) %></font>
					</div>
			  
			<%  ' Confidence Level, Start & Speed
			  If VM Then  %>
				<td>
					<select class=CMT name=COMMENT_<%= RN %>>
						<option><%= makeList("SELECT", "", "SYS_CODE", "RNR_CMT", "NAME", "NAME", sNS(RS("COMMENT"))) %>
					</select>
			<% Else        %>
				<td<%= ICase(sNS(RS("COMMENT")), "1st Str"," class=PF", "Data?"," class=HL", "") %>><%= sNR(RS("COMMENT"), "&nbsp;") %>
					<div class=INV>
						<span>
							<%= RS("SKY_RT_V") %>
						</span>
						<%= RS("SPEED") %>
				  </div>
			<% End If %>

			 <!--  Risk    -->
			<% If Session("LVL") = 10 Then %>
				<td><td><td>		<!--  Hide from Media user -->
			<% Else %>
				<!-- td  class=SML>< %= sTtP(RS("MAX_EXPOS")) % -->
				<td class=FF><%= GetLiabilitys("WIN",RN)  & "<div class=RKSML>" & GetLiabilitys("PLACE",RN) & "</div>" %>
				<td  class=SML><b><%= sDiv(GetLiabVWM(RN)) %><!--  VWM -->
			<% End If %>  
			  
			  <!--     'f price blend value   --> <% 
			  If VM Then        %>
				<td><input tabindex=<%=RN %> class=FBLD name=fblend_<%= RN %> value=<%= If (sNS(RV("CONF_LVL")) = "", RS("SKY_PD_T"),  RS("PPDVP")) %>><%
			  Else        %>				
			  	<td><%= If (sNS(RV("CONF_LVL")) = "", sDiv(RS("SKY_PD_T")),  sDiv(RS("PPDVP")))  %><%
			  End If    %>
			  <td>
			  			  
			  <!--' FX Dividend   -->
			  <td class=FT><%= sDiv(RS("FX_BOB"))      %>
			  <td class=FW><%= sDiv(RS("FX_WOW"))      %>
			  
			  <!-- -------- Dynamic columns -------------------- -->
			  <%= UsrPriceCols(ColList, RS, RP, PriceChangeDictionary,ScratchingJavascript,CloseTime, CT)  			  %>
				  
			  <!-- Num col edit -->
			  <%If VM Then        %>
				<td class=HX><%= RN %> 
				<input id=RNSCR type=button onclick="RunScr(<%= RN %>)"  value="SCR" >
			 <%Else %>
				<td class="HN"><%= RN %>
			 <%End If   %>
			 
			  <% '-- Calculate Total Market Percentage -------------------------------------------------------
				'LBVWM
				MktPer( 30) += getMkP(GetLiabVWM(RN))
				'f blend
				MktPer( 0) += If(sNS(RV("CONF_LVL")) = "", getMkP(RS("SKY_PD_T")) ,  getMkP(RS("PPDVP")))   ' getMkP(RS("SKY_PD_T"))  
				MktPer(  1 ) += 0'getMkP(RS("SKY_RT_T"))
				
				MktPer( 2) += getMkP(RS("FX_BOB"))  
				MktPer( 3) += getMkP(RS("FX_WOW")) 
				' FX Dividend
				MktPer( 4) += If(CT = "AU", getMkP(RS("APN_FW")) ,  getMkP(RS("PAA_FW")))
				MktPer( 5) += getMkP(RS("LXB_FW")) 				
				MktPer(  6) += getMkP(RS("QLD_FW"))
				MktPer( 7) += getMkP(RS("B1Y_FW")) : 
				MktPer( 8) += getMkP(RS("LAD_FW")) 
				MktPer(  9) += getMkP(RS("IAS_FW"))
				MktPer( 10) += getMkP(RS("SPB_FW")) 
				MktPer( 11) += getMkP(RS("UNI_FW"))
				MktPer( 12) += getMkP(RS("TOP_FW")) : 
				MktPer( 13) += getMkP(RS("EZY_FW"))
				MktPer( 31) += getMkP(RS("NZL_FW"))
				
				' Lux Price & Betfair
				MktPer( 15) += getMkP(RS("BFR_FW_B1")) 
				MktPer( 16) += getMkP(RS("BFR_FW_L1"))  
				MktPer( 17) += getMkP(RS("BFR_WAP"))
				
				MktPer( 19) += getMkP(RS("VIC_FW")) 
				' PM Dividend
				MktPer( 20) += getMkP(RS("VIC_TW")) 
				MktPer( 21) += getMkP(RS("NSW_TW"))
				MktPer( 22) += getMkP(RS("QLD_TW"))
				MktPer( 23) += getMkP(RS("AUS_TW")) 
				MktPer( 24) += getMkP(RS("RDB_TW")) 
				MktPer( 25) += getMkP(RS("HST_VT"))
				MktPer( 26) += getMkP(RS("HST_VQ")) 
				MktPer( 27) += getMkP(RS("HST_VX"))
				' DVP
				MktPer( 28) += getMkP(RS("SDP")) '' RAW SDP market %
				MktPer( 29) += getMkP(RS("PM_DPP"))
				MktPer( 14) += getMkP(RS("SUN_SDP"))
				MktPer( 18) += getMkP(RS("TAB_SDP"))

				' Rolls '
				MktPer(32) += RS("SDP_ADJ")
				MktPer(33) += RS("SDP_ADJ_TAB")

				'' Actual Lux SDP Market %
				MktPer(34) += getMkP(RS("LUX_SDP"))

				'' lux sdp place market %
				MktPer(35) += getMkP(RS("LUX_SDP_PLACE"))
				'' sun sdp place market %
				MktPer(36) += getMkP(RS("SUN_SDP_PLACE"))
				'' tab sdp place market %
				MktPer(37) += getMkP(RS("TAB_SDP_PLACE"))

%>
<%
			  ' Populating Trade Data --------------------------------------------------------------------- 
			  If sNS(RV("CONF_LVL")) <> "E" AndAlso sN0(RS("PM_WIN")) > 0 AndAlso RS("PM_TICK") AndAlso Not RS("PM_RISK") Then

				' BET Strategy 1 (Exchange WIN Only)
				If AM(0) >= 1 Then 
				  For I = 0 To 0
					AV = Math.Round((AM(0) * LV(0)(I + 1)) / 100): TV = chkLmt(PB + I, RS("PM_DVP"))
					If AV > 500 Then: AV = 500: End If
					If TV > 90 Then TV = 90
					If AV > 0 And TV > 0 And TV < 91 Then 
						DC(0) &= "BET" & vbTab & RN & vbTab & AV & vbTab & 0 & vbTab & TV & vbTab & getLmt(TV, 1) & vbLf
					End If
				  Next
				End If

				' EAT Strategy 1 (Exchange WIN Only)
				If AM(1) >= 1 Then 
				  For I = 0 To 0
					AV = Math.Round((AM(1) * LV(1)(3 - I)) / 100)
					TV = chkLmt(PE + I)
					If AV > 0 And TV > 0 Then 
						DC(0) &= "EAT" & vbTab & RN & vbTab & AV & vbTab & 0 & vbTab & TV & vbTab & getLmt(TV, 1) & vbLf
					End If
				  Next
				End If

				
				' BET Strategy 2 (TAB & Bet365 Fix Odds WIN only)
				If AUS AndAlso sN0(RV("BANK_PM2")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 Then 
				  Dim FM(,) As String = { {"VIC_FW","TAB"}, {"B1Y_FW","365"} }
				  For I = 0 To 1
					Dim MR As DataRow = MX.Select("MARKET='fx" & FM(I, 1) & "'")(0)
					If MR("WIN") AndAlso sN0(RS(FM(I, 0))) > 0 Then
					  DB = RS(FM(I, 0)) 
					  DE = DB / RS("PM_ORG")
					  AV = RV("BANK_PM2") * 100 / (RS("PM_ORG") - 1)
					  If RS("PM_ORG") < MR("RD_FM_W") Then AV /= 3
					  If sN0(RS("FX_BOB")) - DB > 1.00 OrElse _
						DE < MR("EXP_MIN") OrElse DE > MR("EXP_CUT") OrElse DB > MR("MX_DV_W") OrElse _
						RS("PM_ORG") < MR("MN_FM_W") OrElse RS("PM_ORG") > MR("MX_FM_W") Then AV = 0
						
					  If AV > 0 Then: AV = Math.Ceiling(AV)
						DC(1) &= RN & vbTab & RS("NAME") & vbTab & "WIN" & vbTab & FormatNumber(DE) & vbTab & AV & _
						  vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & vbTab & vbTab & FM(I, 1) & vbLf
					  End If
					End If
				  Next
				End If

				
				' BET Strategy 3 (Betfair WIN-PLA)
				If AUS AndAlso sN0(RV("BANK_PM3")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 AndAlso  sN0(RS("BFR_FW_B1")) > 0 Then 
				  Dim MR As DataRow = MX.Select("MARKET='Betfair'")(0)
				  If MR("WIN") Then
					DB = RS("BFR_FW_B1")
					DE = DB / RS("PM_ORG")
					AV = RV("BANK_PM3") * 100 / (RS("PM_ORG") - 1)
					If RS("PM_ORG") < MR("RD_FM_W") Then AV /= 3
					If sN0(RS("FX_BOB")) - DB > 1.00 OrElse _
					  DE < MR("EXP_MIN") OrElse DE > MR("EXP_CUT") OrElse DB > MR("MX_DV_W") OrElse _
					  RS("PM_ORG") < MR("MN_FM_W") OrElse RS("PM_ORG") > MR("MX_FM_W") Then AV = 0
					  
					If AV > 0 Then: AV = Math.Ceiling(AV)
					  DC(2) &= RN & vbTab & RS("BFR_ID") & vbTab & "WIN" & vbTab & FormatNumber(DE) & vbTab & AV & _
						vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
						vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & "BFX" & vbLf
					End If
				  End If
				End If

				
				' BET Strategy 4 (Totalisator)
				If sN0(RS("PM_DVP")) > 0 AndAlso sN0(RS("PM_PLA")) > 0 Then 
				  Dim BR As Boolean = False

				  '-- WIN Staking
				  For Each MR As DataRow In MX.Select(IIf(AUS, "SEQ < 33", ""))
					If MR("WIN") Then
						DB = RS("PM_DVP")
						Try
							Select Case MR("MARKET")
								Case "STAB": DB = RS("VIC_TW")
								Case "NSW" : DB = RS("NSW_TW")
								Case "QLD" : DB = RS("QLD_TW")
								Case "USA" : DB = RS("PM_DVP") 'RS("HST_TW")
							End Select
						Catch: End Try
						DE = DB / RS("PM_WIN")

						Dim XS As DataRow = getStaking(MR("MARKET"), 0, CT,TP)
						If XS("POOL_TCK") Then
							  If sNB(XS("TKO_TCK")) Then
								AV = (sN0(RV(ICase(MR("MARKET"), "USA","HST", "STAB","VIC", MR("MARKET")) & "_PW")) * XS("TKO_PCT")) / 100
							  Else
								AV = XS("TKO_AMT")
							  End If

							  ' Reduced Trading Exposure (when required)
							  IF sNB(RV("RDC_TPM")) Then AV = (AV * RT) / 100
							  If RS("PM_WIN") < MR("RD_FM_W") Then AV /= 3

							  AV = getStk(AV / (RS("PM_WIN") - 1), getStaking(MR("MARKET"), 99, CT,TP))
							  If AV > XS("TKO_AMT") Then AV = XS("TKO_AMT")

							  If DE < IIf(sNB(XS("EXP_TCK")), 1 + XS("EXP_MIN") / 100, 0) OrElse DB > MR("MX_DV_W") OrElse _
								 RS("PM_WIN") < MR("MN_FM_W") OrElse RS("PM_WIN") > MR("MX_FM_W") Then AV = 0
						Else
							  AV = (DB - RS("PM_WIN") + 1) / (DB * RS("PM_WIN"))
							  AV = Math.Round(MR("KELLY") * AV * MR("WP_BANK") / 100)
							  If AV < 0 OrElse DE < MR("EXP_MIN") OrElse DE > MR("EXP_CUT") OrElse DB > MR("MX_DV_W") OrElse _
								RS("PM_WIN") < MR("MN_FM_W") OrElse RS("PM_WIN") > MR("MX_FM_W") Then AV = 0
						End If

						If AV > 0 AndAlso XS("POOL_TCK") Then
							  If USA Then AV = Math.Ceiling(AV)
							  BR = True
							  
							  DC(3) &= RN & vbTab & RS("NAME") & vbTab & "WIN" & vbTab & FormatNumber(DE) & vbTab & Math.Round(AV, 1) & _
								vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
								vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & MR("MARKET") & vbLf

							  If Request("FTRD") <> "" Then TT(MR("MARKET")) &= _
								RN & vbTab & RS("NAME") & vbTab & "WIN" & vbTab & FormatNumber(DE) & vbTab & Math.Round(AV, 1) & _
								vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
								vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & "ON" & vbLf
						End If
					End If
				  Next

				  '-- PLA Staking
				  If BR Then
					  For Each MR As DataRow In MX.Select("SEQ < 33")
						  If MR("PLA") And Session("NPL_" & IIf(MR("MARKET") = "STAB", "VIC", MR("MARKET"))) <> "1" Then
							DB = RS("VIC_TP")
							Try
								Select Case MR("MARKET")
									Case "STAB": DB = RS("VIC_TP")
									Case "NSW" : DB = RS(NC & "_TP")
									Case "QLD" : DB = RS("QLD_TP")
									Case "USA" : DB = RS("HST_TP")
								End Select
							Catch: End Try
							DE = DB / RS("PM_PLA")

							Dim XS As DataRow = getStaking(MR("MARKET"), 1, CT,TP)
							If XS("POOL_TCK") Then
							  If sNB(XS("TKO_TCK")) Then
								AV = (sN0(RV(ICase(MR("MARKET"), "USA","HST", "STAB","VIC", MR("MARKET")) & "_PP")) * XS("TKO_PCT")) / 100
							  Else
								AV = XS("TKO_AMT")
							  End If

							  ' Reduced Trading Exposure (when required)
							  IF sNB(RV("RDC_TPM")) Then AV = (AV * RT) / 100
							  If RS("PM_PLA") < MR("RD_FM_P") Then AV /= 3

							  AV = getStk(AV / (RS("PM_PLA") - 1), getStaking(MR("MARKET"), 99, CT,TP))
							  If AV > XS("TKO_AMT") Then AV = XS("TKO_AMT")

							  If DE < IIf(sNB(XS("EXP_TCK")), 1 + XS("EXP_MIN") / 100, 0) OrElse DB > MR("MX_DV_P") OrElse _
								 RS("PM_PLA") < MR("MN_FM_P") OrElse RS("PM_PLA") > MR("MX_FM_P") Then AV = 0
							Else
							  AV = (DB - RS("PM_PLA") + 1) / (DB * RS("PM_PLA"))
							  AV = Math.Round(MR("KELLY") * AV * MR("WP_BANK") / 100)
							  If AV < 0 OrElse DE < MR("EXP_MIN") OrElse DE > MR("EXP_CUT") OrElse DB > MR("MX_DV_P") OrElse _
								RS("PM_PLA") < MR("MN_FM_P") OrElse RS("PM_PLA") > MR("MX_FM_P") Then AV = 0
							End If

							If AV > 0 AndAlso XS("POOL_TCK") Then
							  DC(3) &= RN & vbTab & RS("NAME") & vbTab & "PLA" & vbTab & FormatNumber(DE) & vbTab & Math.Round(AV, 1) & _
								vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
								vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & MR("MARKET") & vbLf

							  If Request("FTRD") <> "" Then TT(MR("MARKET")) &= _
								RN & vbTab & RS("NAME") & vbTab & "PLA" & vbTab & FormatNumber(DE) & vbTab & Math.Round(AV, 1) & _
								vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
								vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & "ON" & vbLf
							End If
						  End If
					  Next
				  End If
				End If

			  End If

			Else 	 
			%><!--  scratched  --> 
				<!-- blank first 9 -->
				<td colspan=<%= 9 + ColList.Length + 1 %> class=SCR>&nbsp;
		 <% End If
		  Next%>
	  
		  <tr><!-- blank first 11 -->
			<td colspan=<%= 11 + ColList.Length + 1 %> class=SPT>
	  
		<!-- Market % ------------------------------------------------------------------------------------  -->
		  <tr height=23 class=TOT>
			  <td colspan=6 class=TFN>Market %
				<%= sMkP(MktPer(30)) %>		<!-- Liab VWM  -->
				  <%  For I = 0 To 3  %>
					<%= sMkP(MktPer(I)) %>		<!-- MA to WOW -->
				  <% Next  %>
				  
				<%=  ColMktPer(ColList ,MktPer)  %>
				  
			  <td> <!-- Last No Col= blank -->
		<!--'-- Pools Size ---------------------------------------------------------------------------------->  
		  <tr height=23 class=TOT><td colspan=5 class=TFN>Pools Size
			<% If Session("LVL") < 10 Then %>	
				<td><%= GetLiabTotal  ("WIN")  & "<div class=RKSML>" & GetLiabTotal("PLACE") & "</div>"  %>
			<%	Else 	 %>
				<td>	<!-- Hide from Media User-->
			<% End If %>
		      <td>

		      <% If Vm Then %>
		      <td>
		      <td>
    			<input type="text" name="MATarget" tabindex="100" id="MATarget" value="<%= MATarget %>" title="MA target market %">%</td>
		      <% Else %>
		      <td>

		      <% End If %>
			  <td colspan=3>  <!-- risk - WOW  -->
			  
			  <!-- Dyn Pool Sizes (Max 26 Cols)  ----------------------------->
			  <%=  ColPools(ColList, RV, CT, MktPer) %>
			  <td><!-- No col -->
	  
		</table>
	  </div>
	  
	  <!--'-- Risk filter buttons --------------------------------------------------------------------------> 
	  <div class=RISKFTR>
		<table  cellspacing=0 cellpadding=3>
			<col width=100><col width=80><col width=80><col width=80><col width=80><col width=80><col width=80><col width=80><col width=80><col width=80><col width=80><col width=80><col>
			<td> Risk Profile 
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL)"  value="ALL"  <%= if(RiskProf = ""," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=Normal')"  value="Normal" <%= if(RiskProf = "Normal"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=Restricted')"  value="Restricted"  <%= if(RiskProf = "Restricted"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=WISE')"  value="WISE"  <%= if(RiskProf = "WISE"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=HARD')"  value="HARD"  <%= if(RiskProf = "HARD"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=Watch')"  value="Watch"  <%= if(RiskProf = "Watch"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=VIP soft')"  value="VIP soft"  <%= if(RiskProf = "VIP soft"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=Square')"  value="Square"  <%= if(RiskProf = "Square"," id=SEL", "") %> >
			<td><input name=RKPBTN type=button onclick="getEVN(curVNL + '&RKP=BetBack')"  value="BetBack"  <%= if(RiskProf = "BetBack"," id=SEL", "") %> >
			<td>
		</table>
	  </div>	  

	  <!--'-- Trading Parameters -------------------------------------------------------------------------->    
		<div class=TPR>
			<table cellspacing=0 cellpadding=3>
				<col><col><col width=350><col width=100><col width=310>
				
				<!--    ' Speed Map    -->
				<td id=SMP <%= IIf(CT="AU" AndAlso TP = "R", " style=""width:450px""", "") %>>
				<% If Not VM AndAlso (CT="AU" AndAlso TP = "R") Then      %>
					<table class="LST FX" cellspacing=0 cellpadding=1><%      %>
						<td id=SPD<%= IIf(TP = "G", " onclick=""vSPD(this,'SPG')""", "") %>>
					 <%  Dim SA() As Byte = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, SG As New StringBuilder
						 Dim RS as Object = getRecord("SELECT RUNNER_NO, BARRIER, SPEED, POS, SCR_TIMESTAMP FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 ORDER BY BARRIER, RUNNER_NO")
						 While RS.Read()
							Dim RN As Byte = RS(0) 
							Dim SP As Byte = sN0(RS(2)), PS As String = sN0(RS(3))
							PS = MIf(PS = 1, " class=W", PS > 0 And PS < 4, " class=P", "")
							If SP > 0 Then 
								Select Case TP
								  Case "G" %>
									<div<%= PS %> style="top:<%= SA(SP\10) * 14 + 1 %>px; right:<%= (SP\10-1) * 45 + (SP Mod 10) * 2 %>px"><%= RN %></div>
									<% SA(SP\10) += 1
									SG.Append("<div" & PS & " style=""top:" & (sNR(RS(1), RN) - 1) * 13 + 1 & "px; right:" & (SP - 10) * 5 & _
									  "px; background-image:url(/Jersey/" & IIf(USA, "UG", "AG") & "/DG" & RN.ToString("00") & ".png)"">" & RN & "</div>")
									  
								  Case "R" %>
									<div<%= PS %> style="bottom:<%= SA(SP - 1) * 22 + 1 %>px; right:<%= (SP - 1) * 32 + SA(SP - 1) * 5 %>px"><%= RN %></div>
									<% SA(SP - 1) += 1
								  Case "X" %>
									<div<%= PS %> style="bottom:<%= SA(SP - 1) * 14 + 1 %>px; right:<%= (SP - 1) * 37 + SA(SP - 1) * 5 %>px"><%= RN %></div>
									<% SA(SP - 1) += 1
								End Select 
							End If
						  End While
						  RS.Close()
						  If TP = "G" Then %>
							<td id=SPG onclick="vSPD(this,'SPD')"><%= SG.ToString %>
						  <% End If      %>
					</table>
				<%  End If		%>

				<!--' Race Comments    -->
				<td>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<tr><th>Race Comments
						<tr height=115>
						<% If  Session("LVL") < 10 Then 
							If VM Then        %>
								<td class=SIP><textarea name=REMARK><%= RV("REMARK") %></textarea><%
							Else        %>
								<td valign=top class=RI><%= sNS(RV("REMARK")).Replace(vbCrLf, "<br>") %><%
							End If
						End If    %>
					</table>			
				<!-- Race notifications -->
				<td>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<tr><th>Race Notifications
						<tr height=115>
						<% If  Session("LVL") < 10 Then %>							
								<td valign=top class=RI><div class="RI" style="overflow-y:scroll; max-height: 115px" ><%= sNS(RV("NOTIFICATIONS")).Replace(vbCrLf, "<br>") %></div><%
						End If    %>
					</table>
				</td>
				<!--    ' Region, Rank & Conf Lvl    -->
				<td>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<col><col>
						<tr><th colspan=2>Base<%
						If VM Then          %>
							<tr>
								<td colspan=2><select name=REGION><%= makeList("SELECT", "", "SYS_CODE", "REGION", "CODE", "NAME", sNS(RV("REGION"))) %></select>
							<tr>
								<td>Rank
								<td><select name=RANK><%= makeList("SELECT", "", "SYS_CODE", "RANK", "CODE", "CODE", sNS(RV("RANK"))) %></select><%
						Else       %>
							<tr>
								<td colspan=2><b><%= getCode("REGION", sNR(RV("REGION"), "-"))  %>
							<tr>
								<td>Rank
								<td><b><%= sNR(RV("RANK"), "-") %><%
						End If        %>
						<tr>
							<td>Conf
							<td><%= sConf(RV("CONF_LVL")) %>
						<tr>
							<td>Limit
							<td class=LMT><%= Limit %> K
					</table>
				<!-- <td> -->


			</table>
		</div>
		<div class="race-settings">
	<table>
			<tr>
<td>
<table class="FX" cellspacing=0 cellpadding=1>
	<tr>
		<td>
			<b>Lux Place Pays</b>
			<%= PlacePayDropdown(RV,"LUX") %>

			<b>TAB Place Pays</b>
			<%= PlacePayDropdown(RV,"TAB") %>

			<b>SunBets Place Pays</b>
			<%= PlacePayDropdown(RV,"SUN") %>
		</td></tr>
</table></td>
</tr>
			</table>
	</div>
	  
		<input name=RNR_NO type=hidden value="">
		<input id=btnUPDT name=FCMD type=submit value="Update Changes" style="display:none">
		
		<!--  '-- Edit Market, Save & Status Bar -------------------------------------------------------------->
		<div class=TED><%
			If VM Then	%>
				<input name=UPD_OGN type=checkbox value=1> Update f Origin 
				<input type=button onclick="getEVN(curVNL)" value="Undo">
				<input name=FCMD type=submit onclick="iSV(<%= IIf(USA, 1, 0) %>); " value="Save"><%
			Else	%>
				<div id=divDSP><%= sLcDt(Now, "dd MMM, HH:mm.ss") %></div> 
				<input name=FCMD type=button  <%= IIf(Session("LVL") < 10, "", " disabled ") %> onclick="getEVN()" value="     Edit     ">
				<input name=MR type=submit  value="MR"  >
				<input name=FCMD type=button onclick="tvReplay( '<%= videoID %>' )" value="VID"><%				
			End If  %>
		</div>
		<!--  Add Race No selection buttons -->
		<div  class=RACEBTN>
			<% For EvNo = 1 To EventCnt %>
				<input type=button onclick="getEVN('<%= EV(0) & "_" & EvNo %>',this)" value="<%= EvNo %>" <%= iif(EvNo = Val(trim(EV(1)))," id=BTNACT", "") %>>
			<% Next  %>
		</div>
		<!-- FSI lights-->
		<div class=FSI >  
			<%= FSI_Check %>
		</div>		
	</form>

	<%'-- Auto Trade Handling -------------------------------------------------------------------------
	If Not VM and (Session("LVL") < 2 OrElse Session("LVL") = 5) Then		%>
		<table id=TDG><%

		
		If DC(0).Length > 0 Then 	%><!--' Trade 1		-->  
			<td>
				<b>Strategy 1 - Citibet</b>
				<pre class=CTB><%= sTrdPM(DC(0), DV) %></pre><%
		End If

		If DC(1).Length > 0 Then 	%><!--' Trade 2		  -->
			<td>
				<b>Strategy 2 - Fixed Odds</b>
				<pre><%= sTrdTL(DC(1), True, DV, CT) %></pre><%
		End If

		If DC(2).Length > 0 Then 	%><!--' Trade 3		  -->
			<td>
				<b>Strategy 3 - Betfair</b>
				<pre><%= sTrdTL(DC(2), True, DV, CT) %></pre><%
		End If

		If DC(3).Length > 0 Then 	%><!--' Trade 4		  -->
			<td>
				<b>Strategy 4 - Totalisator</b>
				<pre><%= sTrdTL(DC(3), True, DV, CT) %></pre><%
		End If

		  Dim trades As Object = getRecord("SELECT * FROM EVENT_TRADING WHERE BET_TYPE = 'WIN' AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY JURISDICTION, DATE_CREATED")
		  Dim tradeTable as New DataTable()

		  tradeTable.Load(trades)
		  Dim paperTrades = tradeTable.Select("PAPER_TRADE = 1")
		  Dim liveTrades = tradeTable.Select("PAPER_TRADE = 0")

			If liveTrades.Count > 0 Then			  %>
				<td><b>Strategy 4 - Trades</b><pre><%
					  If HasTrades("VIC",tradeTable,True) Then %><b class=RD>STAB</b><%=  generateNewTradeTable(liveTrades, "VIC", False, DV, CT)  %><% End If
					  If HasTrades("NSW",tradeTable,True) Then %><b class=BL>NSW</b><%=     generateNewTradeTable(liveTrades, "NSW", False, DV, CT) %><% End If
					  If HasTrades("QLD",tradeTable,True) Then %><b class=GR>QLD</b><%=     generateNewTradeTable(liveTrades, "QLD", False, DV, CT) %><% End If
				  
					If CT = "ZZ" Then  'CT = "HK" - Section to be removed !!
						If sNN(RV("TPM_HST")) Then %><b class=PK>USA</b><% End If
					End If	 %>
					</pre><%
			End If		

			If paperTrades.Count > 0 Then			  %>
				<td><b>Strategy 4 - Paper Trades</b><pre><%
					  If HasTrades("VIC",tradeTable,False) Then %><b class=RD>STAB</b><%=  generateNewTradeTable(paperTrades, "VIC", False, DV, CT)  %><% End If
					  If HasTrades("NSW",tradeTable,False) Then %><b class=BL>NSW</b><%=     generateNewTradeTable(paperTrades, "NSW", False, DV, CT) %><% End If
					  If HasTrades("QLD",tradeTable,False) Then %><b class=GR>QLD</b><%=     generateNewTradeTable(paperTrades, "QLD", False, DV, CT) %><% End If
				  
					If CT = "ZZ" Then  'CT = "HK" - Section to be removed !!
						If sNN(RV("TPM_HST")) Then %><b class=PK>USA</b><% End If
					End If	 %>
					</pre><%
			End If		


			%>
		</table><%
	End If
	
  'sDuration(TM)
End If %>

