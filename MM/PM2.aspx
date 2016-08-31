<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim EV As Object, VM As Boolean
'Dim TM As DateTime = Now

Sub Page_Load()
  Response.CacheControl = "no-cache"
  chkSession()
  Dim CM As String = Request("FCMD"): EV = Secure("EV", 20): VM = (Request("VM") <> "")

  If CM <> "" And EV <> "" Then
    EV = Split(EV, "_"): Dim WC As String = " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)
    Select Case CM

    Case "Save"
      Dim S As String = "", N As Byte
      Dim CT As String = getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
      Dim RS As Object = getRecord("SELECT RUNNER_NO FROM RUNNER(nolock)" & WC & " AND SCR=0") '& IIf("US,SE".Contains(CT), " AND RUNNER_NO % 10=0", ""))
      While RS.Read(): N = RS(0)
        S &= "UPDATE RUNNER SET" & _
          "  REMARK=" & chkRN("REMARK_" & N) & _
          ", PM_WIN="  & chkR9("PM_WIN_" & N) & ", PM_ORG=COALESCE(" & IIf(Request("UPD_OGN") = 1, "", "PM_ORG,") & chkR9("PM_WIN_" & N) & ",0)" & _
          WC & " AND RUNNER_NO=" & N & vbLf
      End While: RS.Close()
      S &= "UPDATE EVENT SET FMD_USE='Input'" & WC & vbLf
      execSQL(S)


    Case "f VWM"     : execSQL("UPDATE RUNNER SET PM_WIN=BFR_WAP" & WC & vbLf &  "UPDATE EVENT SET FMD_USE='VWM'"    & WC)
    Case "f Clear"   : execSQL("UPDATE RUNNER SET PM_WIN=NULL, PM_PLA=NULL" & WC & vbLf & "UPDATE EVENT SET FMD_USE='Clear'" & WC)
    Case "f Origin"  : execSQL("UPDATE RUNNER SET PM_WIN=PM_ORG"  & WC & vbLf &  "UPDATE EVENT SET FMD_USE='Origin'" & WC)
    Case "f RDbl"    : execSQL("UPDATE RUNNER SET PM_WIN=RDB_TW"  & WC & vbLf &  "UPDATE EVENT SET FMD_USE='RDbl'"   & WC)
    Case "f Mix 1"   : hybridMix("HMX_PM", "PM_WIN", 100, EV(0), EV(1)): execSQL("UPDATE EVENT SET FMD_USE='Mix 1'"  & WC)

    Case "f Combi+"  : Dim RV As DataRow = getDataRow("SELECT CMB_PC1, CMB_PC2 FROM EVENT(nolock)" & WC)
      CalcCombi(EV(0), EV(1), RV): hybridMix("HMX_XT", "XT_WIN", 100, EV(0), EV(1)): CalcPLA(EV(0), EV(1), "XT", 1.00)
      execSQL("UPDATE EVENT SET FMD_USE='Combi', XMD_USE='Mix 1'" & WC)
      Cache.Remove("XCT_" & EV(0) & "_" & Val(EV(1))) ' Trigger creation of Exotics Combos

    Case "f Blend"   : CalcBlend(EV(0), EV(1))                         : execSQL("UPDATE EVENT SET FMD_USE='Blend'"  & WC)
    Case "f Point"   : CalcPoint(EV(0), EV(1))                         : execSQL("UPDATE EVENT SET FMD_USE='Point'"  & WC)


    Case "Update Changes":
      execSQL("UPDATE EVENT SET" & _
        "  HMX_PMT1=" & chkR9("HMX_PMT1") & ", HMX_PMP1=" & chkR9("HMX_PMP1") & _
        ", HMX_PMT2=" & chkR9("HMX_PMT2") & ", HMX_PMP2=" & chkR9("HMX_PMP2") & _
        ", HMX_PMT3=" & chkR9("HMX_PMT3") & ", HMX_PMP3=" & chkR9("HMX_PMP3") & _
        ", RDC_TPM="  & chkR9("RDC_TPM") & WC)
    Case "Stop Trade":
    	execSQL("UPDATE RUNNER SET PM_TICK= 0 " & WC )
    Case "Start Trade"
    	execSQL("UPDATE RUNNER SET PM_TICK= 1 " & WC )
    Case Else
    	If CM.StartsWith("PM_TICK_") Then
    		Dim parameters = CM.Split("_")

    		Dim runner = parameters(2)
    		Dim tick = parameters(3)

    		execSQL("UPDATE RUNNER SET PM_TICK=" & tick & " " & WC & " AND RUNNER_NO = " & runner)
    	End If
    End Select
    If CM = "Save" Or Left(CM, 2) = "f " Then CalcPLA(EV(0), EV(1), "PM", 1.00)
    Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>"): Response.End
  End If

  chkEvent(EV): MTG.EventID = EV: EV = Split(EV, "_")
End Sub


Function FileTrade( PL As String, ByVal TP As String, EV() As String, ID As String, TD As String, CT As String ) As String
  Dim N As String = genBatchNo("W")
  Return "#" & N & vbTab & Session("LID") & vbLf
End Function

</script>
<%
If Request("EV") = "" Then  %>
	<!DOCTYPE html>
	<html>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<link rel="stylesheet" href="/global.css">
				<script src="/js/moment.min.js"> </script>
		<script src="/js/jquery.min.js"> </script>
		<script src="/global.js"></script>

		<script>
			top.setTitle("Market Trader"); curVNL = "<%= Join(EV, "_") %>"; 
			function Init() { getVNL('<%= Session("GAME") %>', '<%= Session("CNTL") %>'); if( curVNL ) getEVN(curVNL); setInterval("iTM()", 1005); tvSZ(1) } 
			function iSV(m) { iNR("PM_WIN_", 100, m) } 
			function iTM() { var X = $("tdPLTM"); if(X && X.innerHTML) X.innerHTML = toNum(X.innerHTML) + 1 }
		</script>
		<body onload=Init()>
			<WT:Main Type="Chart_Canvas" runat=server/>
			<WT:Main id=VNL Type="Venue_List" runat=server/>
			<div id=CNT></div>
			<iframe name=vrtPOST></iframe>
			<WT:Main Type="Live_Stream" runat=server/>
			<div id=CBL style="top:-750px"></div>
		</body>
	</html>
<%	
Else  %>
	<WT:Main id=MTG Type="Meeting_Info" runat=server/>
	<%
	'-- Meeting & Event Record Gathering ------------------------------------------------------------
	Dim DBNow As DateTime = getResult("SELECT GETDATE()")
	Dim I As Byte, TS() As Double = {0, 0, 0, 0}, NC As String = Session("NSW_CLONE")
	Dim TT As DataRow = getDataRow("SELECT STAB='', NSW='', QLD='', USA=''")
	Dim RM As DataRow = getDataRow("SELECT * FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
	Dim RV As DataRow = getDataRow("SELECT * FROM dbo.EVENT_PM    WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
	Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME IN('W','P') AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)).Tables(0)
	DV.PrimaryKey = New DataColumn() { DV.Columns(2), DV.Columns(3) }
	Dim CloseTime as String = sNS(RV("CLOSE_TIME"))

	Dim DC() As String = { "", "", "", "" }
	Dim CT As String = RM("COUNTRY"), TP As String = RM("TYPE"), ST As String = RV("STATUS"), EventCnt as Byte = RM("EVENTS")
	Dim AUS As Boolean = "AU,NZ".Contains(CT), USA As Boolean = false '"US,SE".Contains(CT)

	Dim AB As Double = sNR(RV("ALP_PMB"), 100) / 100, AE As Double = sNR(RV("ALP_PME"), 100) / 100
	Dim PP As Long = sN0(RV("PM_POOL")), AP As Long =  sN0(RV("VIC_PW")) + sN0(RV("NSW_PW")) + sN0(RV("QLD_PW")) 'IIf(USA, sN0(RV("HST_PW")) + sN0(RV("HST_PX")), sN0(RV("VIC_PW")) + sN0(RV("NSW_PW")) + sN0(RV("QLD_PW")))
	Dim MP() As Double = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

	Dim trades As Object = getRecord("SELECT * FROM EVENT_TRADING WHERE BET_TYPE = 'WIN' AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY JURISDICTION, DATE_CREATED")
	Dim tradeTable as New DataTable()

	tradeTable.Load(trades)
	'getCitibet(RM, RV)

	'-- Parameters Setting --------------------------------------------------------------------------
	Dim OV As Byte = getENum("OVL_VWM")
	Dim BP As Byte = getENum("PCT_PM_" & IIf(CT = "HK", "HKB", "XXB"))
	Dim EP As Byte = getENum("PCT_PM_" & IIf(CT = "HK", "HKE", "XXE"))
	Dim KL As Byte = getENum("KLY_FRC"), KM As Byte = getENum("KLY_MDL")
	Dim RT As Byte = getENum("RDC_ST_" & CT & TP)

	Dim MX   As DataTable = makeDataSet("SELECT * FROM SYS_MATRIX(nolock)").Tables(0)  ' WHERE COUNTRY='" & CT.Replace("NZ","AU") & "'"
	Dim LV() As DataRow   = makeDataSet("SELECT * FROM SYS_LEVEL(nolock) WHERE LVL_ID IN(1,2) ORDER BY 1").Tables(0).Select() ' 0 = Bet, 1 = Eat
	Dim PriceChanges As DataTable = makeDataSet(String.Format("exec sp_runnerhistory_get {0},{1}", EV(0), EV(1) )).Tables(0)
	Dim FP As String = "<i class=NA>N/A</i>", BF As Double = 999
	Try: BF = MX.Select("MARKET='Betfair'")(0)("MX_FM_W"): Catch: End Try

	' Auto Update f Model, Div Pred & Pari-Mutuel Pool Triggering
	If Not VM And PP < AP Then
		Dim WC As String = " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)
		Select Case sNS(RV("FMD_USE"))
			Case "VWM"  : execSQL("UPDATE RUNNER SET PM_WIN = BFR_WAP" & WC)
			Case "RDbl" : execSQL("UPDATE RUNNER SET PM_WIN = RDB_TW " & WC)
			Case "Mix 1": hybridMix("HMX_PM", "PM_WIN", 100, EV(0), EV(1))
			Case "Combi": CalcCombi(EV(0), EV(1), RV): hybridMix("HMX_XT", "XT_WIN", 100, EV(0), EV(1)): CalcPLA(EV(0), EV(1), "XT", 1.00)
			Case "Blend": CalcBlend(EV(0), EV(1))
			Case "Point": CalcPoint(EV(0), EV(1))
		End Select 
		'execSQL("UPDATE EVENT SET POOL_TIME=GETDATE(), PM_POOL=" & AP & WC)
		execSQL("UPDATE EVENT SET PM_POOL=" & AP & WC)
		execSQL("UPDATE EVENT SET POOL_TIME=GETDATE()" & WC)
		RV("POOL_TIME") = DBNow
	End If
	%>
	<form method=post target=vrtPOST autocomplete=off>
		<input name=EV type=hidden value="<%= Join(EV, "_") %>">
		<div class=LST>
			<table>
				<col width=50><col width=28><col><col width=50><col width=20><col width=36><col width=60><col width=60><col width=30><!-- ' No - Alpha Beta  -->
				<colgroup span=2 width=70></colgroup>	<!-- ' PM P&L -->
				<colgroup span=3 width=36></colgroup>	<!-- '  fModel  -->
				<colgroup span=9 width=36></colgroup>	<!-- ' FX Dividend  -->
				<colgroup span=13 width=36></colgroup>	<!-- ' Betfair & PM Dividend  -->
				<colgroup span=3 width=38></colgroup>	<!--  ' Citibet  -->
				<tr>
				<tr height=21>
				<th rowspan=2>Trade
				<th rowspan=2>No<th rowspan=2>Name<th rowspan=2>Comments<th rowspan=2>FP<th rowspan=2 class=BIG>&#10003;<th rowspan=2><u>Conf Lvl</u><br>
				<!-- ' Confidence Level  -->
				<%= sConf(RV("CONF_LVL")) %><th rowspan=2>---
				<th rowspan=2>&alpha;&beta; <th colspan=2>PM &nbsp; P & L <th colspan=3>f Model <th colspan=9>FX Dividend <th colspan=3>Betfair<th colspan=10>PM Dividend<th colspan=3>RTG
				<tr height=22>
				
				<th>WIN<th>PLA<th>WIN<th>EXP<th>PLA  <th>BOB<th>WOW<th>APN<th>TAB<th>QLD<th>365<th>LAD<!--th>UNI  -->
				<th>TOP<th>LXB
				<th>VWM<th>xB1<th>LPT
				<th>AUS<th>STAB<th>NSW<th>QLD<th>RDbl<th>vTRF<th>vQIN<th>vXCT<th>PGI<th>SDP
				<th>ABO<th>Bet<th>Eat
	
<%	'-- Runners Parameter ---------------------------------------------------------------------------
	Dim W1 As Single = getResult("SELECT MIN(HST_TP) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND HST_TP BETWEEN 1 AND 10",,1)
	Dim W2 As Single = getResult("SELECT MIN(VIC_TP) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND VIC_TP BETWEEN 1 AND 10",,1)
	Dim EF As Single = getResult("SELECT TOP 1 PM_WIN FROM(SELECT TOP 4 * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND PM_WIN < 11 AND ISNULL(PM_DVP,0) < 11 ORDER BY 1)un ORDER BY 1 DESC",,0)
	Dim FV As DataRow = getDataRow("SELECT ISNULL(MIN(PM_ORG),0), ISNULL(MIN(HST_TW),0) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0")
	
	' Pre-Iteration Market Price
	Dim RP As DataRow = getDataRow("SELECT BFR_MP_B1 = SUM(CASE WHEN BFR_FW_B1 > 0 THEN 100 / BFR_FW_B1 ELSE 0 END) " & _
	"FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
	
	'Dim RS As Object = getRecord("SELECT * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
	'Dim RS As Object = getRecord("SELECT * FROM VW_RUNNER_PRICES WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
	Dim Scratchings as New List(Of String)
	Dim RunnerPrices As Object = getRecord("SELECT * FROM VW_RUNNER_PRICES WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
	Dim RunnerTable as New DataTable()
 	Dim PriceChangeDictionary as New Dictionary(Of String, List(Of DataRow))
		  RunnerTable.Load(RunnerPrices)

			For Each Runner in RunnerTable.Rows
				PriceChangeDictionary(Runner("RUNNER_NO")) = New List(Of DataRow)
				If Runner("SCR") Then
					Scratchings.Add(String.Format("new scratching({0} , '{1}')",Runner("RUNNER_NO"), Runner("SCR_TIMESTAMP")))
				End If
			Next
			
		 PriceChangeDictionary = GetPriceChangesForRunners(PriceChanges, PriceChangeDictionary)
		 Dim ScratchingJavascript as String = String.Format("[{0}]", String.Join(",",Scratchings))


	For Each RS in RunnerTable.Rows %>
				<tr>
<%		Dim TV As Integer, AV As Single, TD(3) As Double
		Dim RN As Byte   = RS("RUNNER_NO")
		Dim EX As Double = getExp(RS("PM_WIN"), RS("BFR_FW_B1"))
		Dim DB As Double, DE As Double, PB As Integer = 0, PE As Integer = 0, PF As Integer = 0
		Dim AM() As Double = { _
		  Kelly(RS("PM_WIN"), 1, RV("BANK_PM1"), KL, 2, AB), _
		  Kelly(RS("PM_WIN"), 1, RV("BANK_PM1"), KL, 2, AE)
		}    %>				
		<!-- ' Runner Info   -->

					<td class=HS>
					<% If Not RS("SCR") Then %>
						<% If RS("PM_TICK") = "1" Then %>
							<button type="submit" style="background-color:red; color: white;" name=FCMD value="PM_TICK_<%= RS("RUNNER_NO") %>_0">Stop</button>
						<% Else %>
							<button type="submit" style="background-color: green; color:white;" name=FCMD value="PM_TICK_<%= RS("RUNNER_NO") %>_1">Start</button>
						<% End If %>
					<% End If %>

					<td class=HS><%= sRNo(CT, RN) & sHorse(RS, CT, TP, "PM", Nothing) %>
	<%	If Not RS("SCR") Then
		  ' Runner Comments
			If VM Then        %>
					<td><input type=text style="width:110px" name=REMARK_<%= RN %> value="<%= RS("REMARK") %>">
		<%  Else %>		
					<td><%= RS("REMARK") %>
		<%  End If%>
					<!--      ' Finishing Position     -->
					<td><%= IIf(sNN(RS("POS")), "<b>" & RS("POS"), "") %>

					<!--      ' WISE Counter      -->
					<td><font color="red"><%= RS("WISE_NO") %></font> 
					<div class=INV>
						<span>
							<font color="green"><%= If(RS("WISE_DF_NO")>0, RS("WISE_DF_NO"), "" ) %></font>
						</span>
						<font color="blue"><%= If(RS("RES_COUNT")>0, RS("RES_COUNT"), "" ) %></font>
					</div>
					<!--      ' Confidence Level, Start & Speed       -->
					<td<%= ICase(sNS(RS("COMMENT")), "1st Str"," class=PF", "Data?"," class=HL", "") %>><%= sNR(RS("COMMENT"), "&nbsp;") %>
					<%  If sN0(RS("STARTS")) + sN0(RS("SPEED")) > 0 Then %>
						<div class=INV>
							<span><%=   IIf(RS("STARTS") <= 6 AndAlso sNS(RS("COMMENT")) <> "1st Str", "<b class=xPR>" & RS("STARTS") & "</b>", RS("STARTS"))        %>
							</span>
							<b <%= IIf(RS("SPEED") = 40, "class=xRD", "") %>><%= RS("SPEED") %>
						</div>
					<% End If %>
					<!--td onmouseover="gRD([< %= Replace(RS("SDP_HIST"),  "|", ",") % >],this)" onmouseout="gXX()">< %= RS("SDP") & "<div class=INV>" & RS("S_SDP") & "</div>" % -->
					<td>

					<%' Alpha Beta
					If TP = "G" AndAlso sNN(RS("CMB_PC1")) Then %>
						<td class=FF><%= Math.Round(RS("CMB_PC1")) & "<div class=INV>" & Math.Round(RS("CMB_PC2")) & "</div>" %>
					<% Else %>
						<td>
					<% End If

					' PM P & L
					TD = getTradesPNL(RV, RS, TS, tradeTable)  %>
					<td><%= sPNL(TD(2)) & sINV(TD(0)) %>
					<td><%= sPNL(TD(3)) & sINV(TD(1)) %>
					
					<%  ' f Model
					If VM  Then  					%>
						<td class=FF><input name=PM_WIN_<%= RN %> type=text value="<%= RS("PM_WIN") %>" onkeydown="return KD(event,this)"><%
					Else					%>
						<td class=<%= IIf(sNS(RS("COMMENT")) = "1st Str", "PF", IIf(sN0(RS("HST_TW")) > 0 AndAlso sN0(RS("PM_ORG")) > 10 AndAlso sN0(RS("HST_TW")) < 3,"HL","FF"))	%>>
							<b><%= sDiv(RS("PM_WIN"), RS("PM_ORG"), sN0(RS("PM_ORG")) > 0 AndAlso sN0(RS("HST_TW")) > 0 AndAlso RS("PM_ORG") = FV(0) AndAlso RS("HST_TW") = FV(1) AndAlso FV(0) < FV(1)) %>
				<%	End If      %>
				<%= sEXP(EX)      %> 
					<td class=FF><%= sDiv(RS("PM_PLA")) %>
					
				<!--      ' FX Dividend      -->
					<td class=FT><%= sDiv(RS("FX_BOB"))      %>
					<td class=FW><%= sDiv(RS("FX_WOW"))      %>
					<%= sDivF(RS, RP, "APN", "AP", PriceChangeDictionary,ScratchingJavascript,CloseTime)      %>
					<%= sDivF(RS, RP, "VIC", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime)      %>
					<%= sDivF(RS, RP, "QLD", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime)      %>
					<%= sDivF(RS, RP, "B1Y", "BT", PriceChangeDictionary,ScratchingJavascript,CloseTime)%>
					<%= sDivF(RS, RP, "LAD", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime)      %>
					<!-- %= sDivF(RS, RP, "UNI", PriceChangeDictionary,ScratchingJavascript,CloseTime)      % -->
					<%= sDivF(RS, RP, "TOP", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime)      %>
					<%= sDivF(RS, RP, "LXB", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime) %>
	  
					<!--      ' Betfair Market      -->
					<td<%= IIf(chkOverlay(RS("BFR_WAP"), PB) < -OV," class=HL", "") %>><b><%= sDiv(RS("BFR_WAP"))      %>
					<td<%= IIf(DB > 0 AndAlso sN0(RS("PM_WIN")) < BF AndAlso sN0(RS("BFR_FW_B1")) >= DB, " class=PF", "") %>><%= sDiv(RS("BFR_FW_B1")) %>
					<td class=SML><%= sTtP(RS("BFR_LPT")) %>
					
					<!--		' Tote Market						-->
					<td class=FV><%= IIf(sN0(RS("PM_WIN")) > EF And sN0(RS("AUS_TW")) > sN0(RS("PM_WIN")), "<b>", "") & sDiv(RS("AUS_TW"))%>
					<td<%= IIf(sN0(RS("VIC_TP")) = W2 And CT = "SG", " class=HL", "") %>><%= sDiv(RS("VIC_TW")) & "<div class=INV>" & sDiv(RS("VIC_TP")) & "</div>"%>
					<td><%= sDiv(RS("NSW_TW"), RS("NSW_TP"))%>
					<td><%= sDiv(RS("QLD_TW"), RS("QLD_TP"))%>
					<td class=FV<% If sNN(RS("RDB_HIST"))  Then %> onmouseover="gRD([<%= Replace(RS("RDB_HIST"),  "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("RDB_TW"))%>
					<td class=FV<% If sNN(RS("HST_VTH"))  Then %> onmouseover="gVT([<%= Replace(RS("HST_VTH"),  "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("HST_VT"))%>
					<td class=FV<% If sNN(RS("HST_VQH"))  Then %> onmouseover="gVT([<%= Replace(RS("HST_VQH"),  "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("HST_VQ"))%>
					<td class=FV<% If sNN(RS("HST_VXH"))  Then %> onmouseover="gVT([<%= Replace(RS("HST_VXH"),  "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("HST_VX"))%>
					<td class=FV>
					<td<%= IIf(sN0(RS("HST_TP")) = W1, " class=HL", "") %>><%= "<b" & IIf(sN0(RS("BFR_WAP")) > 0 And sN0(RS("HST_TW")) > sN0(RS("BFR_WAP")), " class=BL", "") & ">" & sFxDiv(RS("SDP")) & "</b><div class=INV>" & sDiv(RS("HST_TP")) & "</div>" %>
					
					<!--      ' Citibet Market					-->
					<td onmouseover="tCB('<%= sTrdCB(RS("CTB_BW_LST")) %>',0,this)" onmouseout="tXX()"><%=  RS("CTI_FW")	%>
					<td onmouseover="tCB('<%= sTrdCB(RS("CTB_BW_LST")) %>',0,this)" onmouseout="tXX()"><%= RS("CTI_BET")		%>
					<td onmouseover="tCB('<%= sTrdCB(RS("CTB_EW_LST")) %>',1,this)" onmouseout="tXX()"<%= IIf(sN0(RS("CTI_EAT")) = 76, IIf(sN0(RS("HST_TW")) <= 24, _
						" class=RD", " class=OR"), MIf(sN0(RS("CTI_EAT")) >= 90, " class=PF", sN0(RS("CTI_EAT")) >= 88, " class=PD", "")) %>><%=  RS("CTI_EAT")  %>			
<%
		  '-- Calculate Total Market Percentage -------------------------------------------------------
		  'If Not USA OrElse RN Mod 10 = 0 Then
			' f Model
			MP(12) += getMkP(RS("PM_WIN")) : MP(13) += getMkP(RS("PM_PLA"))
			' FX Dividend
			MP( 0) += getMkP(RS("FX_BOB")) : MP( 1) += getMkP(RS("FX_WOW")) : MP( 2) += getMkP(RS("APN_FW"))
			MP( 3) += getMkP(RS("VIC_FW")) : MP( 4) += getMkP(RS("QLD_FW")) : MP( 5) += getMkP(RS("B1Y_FW"))
			MP( 6) += getMkP(RS("LAD_FW")) ': MP( 7) += getMkP(RS("UNI_FW"))  
			MP( 7) += getMkP(RS("TOP_FW"))
			MP( 8) += getMkP(RS("LXB_FW"))
			' Betfair
			MP(19) += getMkP(RS("BFR_WAP")): MP(20) += getMkP(RS("BFR_FW_B1"))
			' PM Dividend
			MP(21) += getMkP(RS("AUS_TW")) : MP(22) += getMkP(RS("VIC_TW")) : MP(23) += getMkP(RS("NSW_TW"))
			MP(24) += getMkP(RS("QLD_TW")) : MP(25) += getMkP(RS("RDB_TW")) : MP(26) += getMkP(RS("HST_VT"))
			MP(27) += getMkP(RS("HST_VQ")) : MP(28) += getMkP(RS("HST_VX")) : MP(29) += getMkP(RS("HST_VT"))
			MP(30) += getMkP(RS("SDP")) : MP( 9) += 0'getMkP(RS("S_SDP"))
		  'End If
%>
<%
		  ' Populating Trade Data ---------------------------------------------------------------------
		  If sNS(RV("CONF_LVL")) <> "E" AndAlso sN0(RS("PM_WIN")) > 0 AndAlso RS("PM_TICK") AndAlso Not RS("PM_RISK") Then

			If AM(0) >= 1 Then ' BET Strategy 1 (Exchange WIN Only)
			  For I = 0 To 0
				AV = Math.Round((AM(0) * LV(0)(I + 1)) / 100): TV = chkLmt(PB + I, RS("PM_DVP"))
				If AV > 500 Then: AV = 500: End If: If TV > 90 Then TV = 90
				If AV > 0 And TV > 0 And TV < 91 Then DC(0) &= "BET" & vbTab & RN & vbTab & AV & vbTab & 0 & vbTab & TV & vbTab & getLmt(TV, 1) & vbLf
			  Next
			End If

			If AM(1) >= 1 Then ' EAT Strategy 1 (Exchange WIN Only)
			  For I = 0 To 0
				AV = Math.Round((AM(1) * LV(1)(3 - I)) / 100): TV = chkLmt(PE + I)
				If AV > 0 And TV > 0 Then DC(0) &= "EAT" & vbTab & RN & vbTab & AV & vbTab & 0 & vbTab & TV & vbTab & getLmt(TV, 1) & vbLf
			  Next
			End If

			'If AUS AndAlso sN0(RV("BANK_PM2")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 Then ' BET Strategy 2 (TAB & Bet365 Fix Odds WIN only)
			If sN0(RV("BANK_PM2")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 Then ' BET Strategy 2 (TAB & Bet365 Fix Odds WIN only)
			  Dim FM(,) As String = { {"VIC_FW","TAB"}, {"B1Y_FW","365"} }
			  For I = 0 To 1
				Dim MR As DataRow = MX.Select("MARKET='fx" & FM(I, 1) & "'")(0)
				If MR("WIN") AndAlso sN0(RS(FM(I, 0))) > 0 Then
				  DB = RS(FM(I, 0)): DE = DB / RS("PM_ORG")
				  AV = RV("BANK_PM2") * 100 / (RS("PM_ORG") - 1): If RS("PM_ORG") < MR("RD_FM_W") Then AV /= 3
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

			'If AUS AndAlso 
			If sN0(RV("BANK_PM3")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 AndAlso _
						  sN0(RS("BFR_FW_B1")) > 0 Then ' BET Strategy 3 (Betfair WIN-PLA)
			  Dim MR As DataRow = MX.Select("MARKET='Betfair'")(0)
			  If MR("WIN") Then
				DB = RS("BFR_FW_B1"): DE = DB / RS("PM_ORG")
				AV = RV("BANK_PM3") * 100 / (RS("PM_ORG") - 1): If RS("PM_ORG") < MR("RD_FM_W") Then AV /= 3
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

			If sN0(RS("PM_DVP")) > 0 AndAlso sN0(RS("PM_PLA")) > 0 Then ' BET Strategy 4 (Totalisator)
			  Dim BR As Boolean = False

			  '-- WIN Staking
			  For Each MR As DataRow In MX.Select("SEQ < 33") 'IIf(AUS, "SEQ < 33", "")) 
				   If MR("WIN") Then
						DB = RS("PM_DVP") 
						Try 
							Select Case MR("MARKET")
								Case "STAB": DB = RS("VIC_TW")
								Case "NSW" : DB = RS("NSW_TW")
								Case "QLD" : DB = RS("QLD_TW")
								'Case "USA" : DB = RS("PM_DVP") 'RS("HST_TW")
							End Select 
						Catch: End Try 
						DE = DB / RS("PM_WIN")

						Dim XS As DataRow = getStaking(MR("MARKET"), 0, CT,TP)
						If XS("POOL_TCK") Then
						  If sNB(XS("TKO_TCK")) Then
							AV = (sN0(RV(ICase(MR("MARKET"), "USA","HST", "STAB","VIC", MR("MARKET")) & "_PW")) * XS("TKO_PCT")) / 100
						  Else: AV = XS("TKO_AMT"): End If

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

						If XS("POOL_TCK") And AV > 0 Then
						  'If USA Then AV = Math.Ceiling(AV)
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
									Case "NSW" : DB = RS("NSW_TP")
									Case "QLD" : DB = RS("QLD_TP")
									'Case "USA" : DB = RS("HST_TP")
								End Select 
							Catch: End Try 
							DE = DB / RS("PM_PLA")

							Dim XS As DataRow = getStaking(MR("MARKET"), 1, CT,TP)
							If XS("POOL_TCK") Then
							  If sNB(XS("TKO_TCK")) Then
								AV = (sN0(RV(ICase(MR("MARKET"), "USA","HST", "STAB","VIC", MR("MARKET")) & "_PP")) * XS("TKO_PCT")) / 100
							  Else: AV = XS("TKO_AMT"): End If

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

							If XS("POOL_TCK") And AV > 0 Then
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

		Else %>
					<td colspan=36 class=SCR>&nbsp;
<% 		End If
	Next %>
				<tr>
					<td colspan=38 class=SPT>
<%
  '-- Trade Handling ------------------------------------------------------------------------------
	If Request("FTRD") <> "" Then
		Dim CM As String = Request("FTRD"), TA As Boolean = (CM = "Trade ALL"), TL() As Single = {0, 0, 0}, S As String = ""

		'' modify this to take the bet strings, and actually trade them and save them. Perhaps secret json call to MVC?
		If (CM = "STAB" Or TA) And TT("STAB")    <> "" Then
			S &= ", TPM_VIC=ISNULL(TPM_VIC,'')+" & cQS(FileTrade("VIC", TP, EV, RM("BTK_ID"), TT("STAB"), CT) & TT("STAB"))			
		End If

		If (CM = "NSW"  Or TA) And TT("NSW")     <> "" Then 
			S &= ", TPM_NSW=ISNULL(TPM_NSW,'')+" & cQS(FileTrade("NSW", TP, EV, RM("BTK_ID"), TT("NSW"),  CT) & TT("NSW"))			
		End If

		If (CM = "QLD"  Or TA) And TT("QLD")     <> "" Then 
			S &= ", TPM_QLD=ISNULL(TPM_QLD,'')+" & cQS(FileTrade("QLD", TP, EV, RM("QLD_ID"), TT("QLD"),  CT) & TT("QLD"))			
		End If

		'If (CM = "USA"  Or TA) And TT("USA")     <> "" Then S &= ", TPM_HST=ISNULL(TPM_HST,'')+" & cQS(FileTrade("HST", TP, EV, RM("UTL_ID"), TT("USA"),  CT) & TT("USA"))
		If S <> "" Then execSQL("UPDATE EVENT SET " & Mid(S, 2) & " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))

		Response.Clear %>
		<!--<script>parent.getEVN(parent.curVNL)</script> -->
		<script> 
		console.log(" <%= TT("STAB") %>");
		console.log(" <%= TT("NSW") %>");
		console.log(" <%= TT("QLD") %>");

		</script>
		<% Response.End
	End If	%>

  <!--'-- Market % ---------------------------------------------------------------------------------- -->
				
				<tr height=23 class=TOT>
					<td colspan=8 class=TFN>Net Investment &#8211; Market %<td class=PIG>
					<% If ST <> "DONE" Then %>
						<div></div>
					<% End If  %>
					<td><%= sPNL(TS(0)) %>
					<td><%= sPNL(TS(1)) %><%= sMkP(MP(12), 100)	%>
					<td><%= sMkP(MP(13), 100 * IIf(RV("STARTERS") < 8, 2, 3)) %>
				<%	For I =  0 To  8 %>
						<%= sMkP(MP(I)) %>
					<% Next %>
					<%= sMkP(MP(19)) %>
					<%= sMkP(MP(20)) %>
					<td>
				<%	For I = 21 To 30 %>
						<%= sMkP(MP(I)) %>
					<% Next				%>
					<!--td --><%= sMkP(MP(9)) %><td><td>
					
<!--  '-- Pools Size -------------------------------------------------------------------------------- -->
				<tr height=23 class=TOT><td colspan=8 class=TFN>
				<%  If ST <> "DONE" Then   %>
					Pools / Matched
					<%	If Not VM AndAlso USA AndAlso ST = "OPEN" AndAlso sNN(RV("POOL_TIME")) Then
							Dim PT As Integer = DateDiff("s", RV("POOL_TIME"), DBNow), PC As Byte = IIf(PT > 63, 63, PT) * 4 %>
							<td colspan=3 id=tdPLTM style="color:rgb(<%= PC %>,<%= 252 - PC %>,0)"><%= PT %>
					<%	Else %>
							<td colspan=3>
					<%  End If
					Else	%>
						Net Profit &#8211; Pools / Matched<td class=PIG><div></div>
						<td><%= sPNL(TS(2) + TS(0))		%>
						<td><%= sPNL(TS(3) + TS(1)) %>
				<%	End If  %>
					<td colspan=3><%= sVar(RV("FMD_USE"))  %>
					<td colspan=9>
					<td>
					<td><%= sTtP(RV("BFR_MW")) %>
					<td>
					<td><%= sTtP(RV("AUS_PW"))	%>
					<td><%= sTtP(RV("VIC_PW"), RV("VIC_PP"))	%>
					<td><%= sTtP(RV("NSW_PW"), RV("NSW_PP"))	%>
					<td><%= sTtP(RV("QLD_PW"), RV("QLD_PP"))	%>
					<td><%= sTtP(RV("RDB_PW"))	%>
					<td><%= sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PT"))	%>
					<td><%= sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PQ"))	%>
					<td><%= sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PX"))	%>
					<td><%= sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PT"))	%>
					<td><%= sTtP(RV("HST_PW"), RV("HST_PP"))	%>
					<td>
					<td><td>

			</table>
		</div>

  <!-- Trading Parameters ------------------------------------------------------------------------ -->
<%  If Not VM Then    %>
		<div class=TPR>
			<table cellspacing=0 cellpadding=3>
				<col><col><col width=245><col width=195><col width=85><col width=100><col width=150>
			
			<!--   ' Speed Map    -->
				<td id=SMP>
				<%  If AUS AndAlso TP = "R" Then      %>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<td id=SPD<%= IIf(TP = "G", " onclick=""vSPD(this,'SPG')""", "") %>><%
						  Dim SA() As Byte = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, SG As New StringBuilder
						 Dim RS = getRecord("SELECT RUNNER_NO, BARRIER, SPEED, POS FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 ORDER BY BARRIER, RUNNER_NO")
						  While RS.Read()
							Dim RN As Byte = RS(0)
							Dim SP As Byte = sN0(RS(2)), PS As String = sN0(RS(3)): PS = MIf(PS = 1, " class=W", PS > 0 And PS < 4, " class=P", "")
							If SP > 0 Then 
								Select Case TP
									Case "G" %><div<%= PS %> style="top:<%= SA(SP\10) * 14 + 1 %>px; right:<%= (SP\10-1) * 45 + (SP Mod 10) * 2 %>px"><%= RN %></div><% SA(SP\10) += 1
										SG.Append("<div" & PS & " style=""top:" & (sNR(RS(1), RN) - 1) * 13 + 1 & "px; right:" & (SP - 10) * 5 & _
										  "px; background-image:url(/Jersey/" &  "AG" & "/DG" & RN.ToString("00") & ".png)"">" & RN & "</div>")
									Case "R" %><div<%= PS %> style="bottom:<%= SA(SP - 1) * 22 + 1 %>px; right:<%= (SP - 1) * 32 + SA(SP - 1) * 5 %>px"><%= RN %></div><% SA(SP - 1) += 1
								End Select 
							End If
						  End While: 
						  RS.Close(): 
						  If TP = "G" Then %><td id=SPG onclick="vSPD(this,'SPD')"><%= SG.ToString %><% End If      %>
					</table>
				<%    End If  %>

    <!--  ' Race Comments  -->
				<td>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<tr><th>Race Comments<tr height=115>
						<td valign=top class=RI><%= sNS(RV("REMARK")).Replace(vbCrLf, "<br>") %>
					</table>

    <!--  ' Pari-Mutuel Parameters  -->
				<td class=GRP>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<col><col><col width=65><col width=50>
						<tr class=GPM>
							<th colspan=2>f Model<th colspan=2>Hybrid %
						<tr>
							<td><input name=FCMD type=submit value="f RDbl">
							<td><input name=FCMD type=submit value="f <%= IIf(TP = "G", "Combi+", "Blend") %>">
							<%= hybridBox("HMX_PM", 1, RV)      %>
						<tr>
							<td><input name=FCMD type=submit value="f Clear">
							<td><input name=FCMD type=submit value="f Point">
							<%= hybridBox("HMX_PM", 2, RV)      %>
						<tr>
							<td><input name=FCMD type=submit value="f Origin">
							<td><input name=FCMD type=submit value="f Mix 1">
							<%= hybridBox("HMX_PM", 3, RV)    %>
					</table>
					
	<!--    ' Bank & Risk Parameters    -->
				<td class=GRP>
					<table class=LST cellspacing=0 cellpadding=1>
						<col><col width=50><col width=50><col width=60>
						<tr class=GPM><th>#<th>Bank<th>Risk<th>WPL
						<% For I = 1 To 3      %>
						<tr>
							<td class=TFN><%= I      %>
							<td><input name=BANK_PM<%= I %> type=number value="<%= RV("BANK_PM" & I) %>" maxlength=2 onfocus="iFC('Bank Roll')" onchange=cNM(this,<%= IIf(I = 3, 30, 20) %>) onblur=iBL() disabled>
							<td><% If I = 1 Then %>
									<input name=RISK_PM type=number value="<%= RV("RISK_PM") %>" maxlength=2 onfocus="iFC('Risk Amount')" onchange=cNM(this,10) onblur=iBL() disabled>
								<% ElseIf I = 2 Then %>
									<%= RV("RISK_PM") %><u>k
								<% End If
								   If ST = "OPEN" Or ST = "CLOSED" Then
									 Dim GB As Boolean = sNB(RV("TRD_PM" & I)) %>
									 <td<%= IIf(GB, " class=PF", "") %>><input name=FCMD type=submit value="<%= IIf(GB, "STOP", "Start") %> <%= I %>" disabled><%
								   Else %>
									 <td>
								<% End If
						Next %>
						</table>

	<!--    ' Alpha Parameters       -->
				<td class=GRP>
					<table class="LST FX" cellspacing=0 cellpadding=1><col><col width=50>
						<tr class=GPM>
							<th colspan=2>&alpha; %
						<tr>
							<td class=TFN>B
							<td><input name=ALP_PMB type=number value="<%= RV("ALP_PMB") %>" maxlength=2 onfocus="iFC('Alpha Bet')" onchange=cNM(this,200,50) onblur=iBL() disabled>
						<tr>
							<td class=TFN>E
							<td><input name=ALP_PME type=number value="<%= RV("ALP_PME") %>" maxlength=2 onfocus="iFC('Alpha Eat')" onchange=cNM(this,160,10) onblur=iBL() disabled>
						<tr>
							<td colspan=2><%= (200 - sNR(RV("ALP_PMB"), 100)) & " &ndash; " & (200 - sNR(RV("ALP_PME"), 100))    %>
					</table>
					
	<!--    ' Other Parameters (View Only)    -->
				<td>
					<table class="LST FX" cellspacing=0 cellpadding=1><col><col width=45>
						<tr>
							<th colspan=2>&Delta; %
						<tr>
							<td>Mode
							<td><%= ICase(KM, 0,"Kelly", 1,"Willy", 2,"P.Stk", "None")      %>
						<tr>
							<td>Bet
							<td><%= BP      %>
						<tr>
							<td>Eat
							<td><%= EP    %>
					</table>
					
	<!--    ' Trade Buttons    %-->
				<td class=GRP>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<tr class=GPM>
						<th colspan=2>Trade
					<%  If ST = "OPEN" Then      %>
					<%  Dim tradeParams = String.Format("'{0}','{1}','{2}'",  EV(0), EV(1), SESSION("LID")) %>
							<tr>
								<td><input name=FTRD type=button onclick="trade(<%= tradeParams  %>,'Stab',parent)" value="STAB">
								<td><input name=RDC_TPM type=checkbox value=1 onclick="iBL()"<%= IIf(sNB(RV("RDC_TPM")), " checked", "") %> id=RDCT_1><label for=RDCT_1>Reduce</label>
							<tr>
								<td><input name=FTRD type=button onclick="trade(<%= tradeParams  %>,'NSW',parent)" value="NSW">
								<td><input name=FTRD type=button onclick="trade(<%= tradeParams  %>,'Betfair', parent)" value="Betfair">
							<tr>
								<td><input name=FTRD type=button onclick="trade(<%= tradeParams  %>, 'Qld', parent)" value="QLD">
								<td><input name=FTRD type=button onclick="trade(<%= tradeParams  %>, 'TradeAll', parent)" value="Trade ALL">
							<tr>
								<td><input name=FCMD type=submit onclick="getEVN()" value="Stop Trade">
								<td><input name=FCMD type=submit onclick="getEVN()" value="Start Trade">
					<%  Else %>
							<tr>
								<td>
								<td><%= IIf(sNB(RV("RDC_TPM")), "Reduced", "") %>
							<tr><td><td>
							<tr><td><td>
					<%  End If    %>
					</table>
			</table>
		</div>
		
		<input name=RNR_NO type=hidden value="">
		<input id=btnUPDT name=FCMD type=submit value="Update Changes" style="display:none">
<%  End If			%>

<!--  '-- Edit Market, Save & Status Bar --------------------------------------------------------------  -->
		<div class=TED>
			<%  If VM Then    %>
				<input name=UPD_OGN type=checkbox value=1> Update f Origin 
				<input type=button onclick="getEVN(curVNL)" value="Undo"><input name=FCMD type=submit onclick="iSV(<%= IIf(USA, 1, 0) %>)" value="Save">
			<%	Else    %>
				<div id=divDSP><%= sLcDt(Now, "dd MMM, HH:mm.ss") %></div>
				<input name=FCMD type=button onclick="getEVN()" value="     Edit     ">
			<%  End If  %>
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



    <!--'-- Auto Trade Handling ------------------------------------------------------------------------->
<%	If Not VM And  (Session("LVL") < 2 OrElse Session("LVL") = 5) Then 		%>
		<table id=TDG>
			<%
			If DC(0).Length > 0 Then   %>		 <!--' Trade 1   -->
			  
				<td><b>Strategy 1 - Asia</b><pre class=CTB><%= sTrdPM(DC(0), DV) %></pre><%
			End If

			If DC(1).Length > 0 Then   %>		 <!--' Trade 2   -->
			  
				<td><b>Strategy 2 - Fixed Odds</b><pre><%= sTrdTL(DC(1), True, DV, CT) %></pre><%
			End If

			If DC(2).Length > 0 Then   %>		 <!--' Trade 3   -->
			  
				<td><b>Strategy 3 - Betfair</b><pre><%= sTrdTL(DC(2), True, DV, CT) %></pre><%
			End If

			If DC(3).Length > 0 Then  %>		 <!--' Trade 4   -->
				<td><b>Strategy 4 - Totalisator</b><pre><%= sTrdTL(DC(3), True, DV, CT) %></pre><%
			End If
  		  
		  Dim paperTrades = tradeTable.Select("PAPER_TRADE = 1")
		  Dim liveTrades = tradeTable.Select("PAPER_TRADE = 0")

			If liveTrades.Count > 0 Then			  %>
				<td><b>Strategy 4 - Trades</b><pre><%
					  If HasTrades("VIC",tradeTable, True) Then %><b class=RD>STAB</b><%=  generateNewTradeTable(liveTrades, "VIC", False, DV, CT)  %><% End If
					  If HasTrades("NSW",tradeTable, True) Then %><b class=BL>NSW</b><%=     generateNewTradeTable(liveTrades, "NSW", False, DV, CT) %><% End If
					  If HasTrades("QLD",tradeTable, True) Then %><b class=GR>QLD</b><%=     generateNewTradeTable(liveTrades, "QLD", False, DV, CT) %><% End If
				  
					If CT = "ZZ" Then  'CT = "HK" - Section to be removed !!
						If sNN(RV("TPM_HST")) Then %><b class=PK>USA</b><% End If
					End If	 %>
					</pre><%
			End If		

			If paperTrades.Count > 0 Then			  %>
				<td><b>Strategy 4 - Paper Trades</b><pre><%
					  If HasTrades("VIC",tradeTable, False) Then %><b class=RD>STAB</b><%=  generateNewTradeTable(paperTrades, "VIC", False, DV, CT)  %><% End If
					  If HasTrades("NSW",tradeTable, False) Then %><b class=BL>NSW</b><%=     generateNewTradeTable(paperTrades, "NSW", False, DV, CT) %><% End If
					  If HasTrades("QLD",tradeTable, False) Then %><b class=GR>QLD</b><%=     generateNewTradeTable(paperTrades, "QLD", False, DV, CT) %><% End If
				  
					If CT = "ZZ" Then  'CT = "HK" - Section to be removed !!
						If sNN(RV("TPM_HST")) Then %><b class=PK>USA</b><% End If
					End If	 %>
					</pre><%
			End If	%>
		</table>
<%	End If

  'sDuration(TM)
End If %>



