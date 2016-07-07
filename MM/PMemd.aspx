<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim EV As Object
'Dim TM As DateTime = Now

Sub Page_Load()
  Response.CacheControl = "no-cache"
  chkSession()
  Dim CM As String = Request("FCMD"): EV = Secure("EV", 20)
  If Session("NSW_CLONE") = "" Then Session("NSW_CLONE") = "NSW"

  If CM <> "" And EV <> "" Then
    EV = Split(EV, "_"): Dim WC As String = " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)
    Select Case CM

    Case "f Combi+"  : Dim RV As DataRow = getDataRow("SELECT CMB_PC1, CMB_PC2 FROM EVENT(nolock)" & WC)
      CalcCombi(EV(0), EV(1), RV): hybridMix("HMX_XT", "XT_WIN", 100, EV(0), EV(1)): CalcPLA(EV(0), EV(1), "XT", 1.00)
      execSQL("UPDATE EVENT SET FMD_USE='Combi', XMD_USE='Mix 1'" & WC)
      Cache.Remove("XCT_" & EV(0) & "_" & Val(EV(1))) ' Trigger creation of Exotics Combos

    Case "f Blend"   : CalcBlend(EV(0), EV(1)): execSQL("UPDATE EVENT SET FMD_USE='Blend'"  & WC)


    Case "STAB"      : execSQL("UPDATE RUNNER SET PM_DVP=VIC_TW" & WC & vbLf &   "UPDATE EVENT SET PDP_USE = 'STAB'"  & WC)
    Case "NSW"       : execSQL("UPDATE RUNNER SET PM_DVP=NSW_TW" & WC & vbLf &   "UPDATE EVENT SET PDP_USE = 'NSW'"   & WC)
    Case "QLD"       : execSQL("UPDATE RUNNER SET PM_DVP=QLD_TW" & WC & vbLf &   "UPDATE EVENT SET PDP_USE = 'QLD'"   & WC)
    Case "Host"      : execSQL("UPDATE RUNNER SET PM_DVP=HST_TW" & WC & vbLf &   "UPDATE EVENT SET PDP_USE = 'Host'"  & WC)
    Case "DP Mix 1"  : hybridMix("DMX_PM", "PM_DVP", 118, EV(0), EV(1)): execSQL("UPDATE EVENT SET PDP_USE = 'Mix 1'" & WC)
    Case "Early Fill": execSQL("UPDATE RUNNER SET PM_DVP=PM_ORG" & WC & vbLf &   "UPDATE EVENT SET PDP_USE = 'Early'" & WC)


    Case "Update Runner"
      execSQL("UPDATE RUNNER SET PM_TICK=CASE PM_TICK WHEN 1 THEN 0 ELSE 1 END" & WC & " AND RUNNER_NO=" & chkR9("RNR_NO"))

    Case "Update Changes":
      execSQL("UPDATE EVENT SET" & _
        "  BANK_PM1=" & chkR9("BANK_PM1") & ", BANK_PM2=" & chkR9("BANK_PM2") & _
        ", BANK_PM3=" & chkR9("BANK_PM3") & ", RISK_PM="  & chkR9("RISK_PM")  & _
        ", HMX_PMT1=" & chkR9("HMX_PMT1") & ", HMX_PMP1=" & chkR9("HMX_PMP1") & _
        ", HMX_PMT2=" & chkR9("HMX_PMT2") & ", HMX_PMP2=" & chkR9("HMX_PMP2") & _
        ", HMX_PMT3=" & chkR9("HMX_PMT3") & ", HMX_PMP3=" & chkR9("HMX_PMP3") & _
        ", DMX_PMT1=" & chkR9("DMX_PMT1") & ", DMX_PMP1=" & chkR9("DMX_PMP1") & _
        ", DMX_PMT2=" & chkR9("DMX_PMT2") & ", DMX_PMP2=" & chkR9("DMX_PMP2") & _
        ", DMX_PMT3=" & chkR9("DMX_PMT3") & ", DMX_PMP3=" & chkR9("DMX_PMP3") & _
        ", ALP_PMB="  & chkR9("ALP_PMB")  & ", ALP_PME="  & chkR9("ALP_PME")  & _
        ", RDC_TPM="  & chkR9("RDC_TPM") & WC & vbLf & _
        "UPDATE RUNNER SET PM_RISK=0" & WC)
      Session("NSW_CLONE") = Request.Form("FCLN")
      Session("NPL_VIC")   = Request.Form("NPL_VIC")
      Session("NPL_NSW")   = Request.Form("NPL_NSW")
      Session("NPL_QLD")   = Request.Form("NPL_QLD")

    End Select
    If CM = "Save" Or Left(CM, 2) = "f " Then CalcPLA(EV(0), EV(1), "PM", 1.00)
    Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>"): Response.End
  End If

  chkEvent(EV): MTG.EventID = EV: EV = Split(EV, "_")
End Sub


Function FileTrade( PL As String, ByVal TP As String, EV() As String, ID As String, TD As String, Optional CT As String = "" ) As String
  Dim N As String = genBatchNo("W")
  Return "#" & N & vbTab & Session("LID") & vbLf
End Function

</script><%

If Request("EV") = "" Then

  %><!DOCTYPE html><html><meta http-equiv="content-type" content="text/html; charset=UTF-8"><%
  %><link rel="stylesheet" href="/global.css"><script src="/global.js"></script><script><%
  %>top.setTitle("Pari-Mutuel WIN-PLA Blend Market"); curVNL = "<%= Join(EV, "_") %>"; <%
  %>function Init() { getVNL('<%= Session("GAME") %>', '<%= Session("CNTL") %>'); if( curVNL ) getEVN(curVNL) } <%
  %>function iSV() { iNR("PM_WIN_", 100) } <%
  %></script><body onload=Init()><WT:Main Type="Chart_Canvas" runat=server/><%
  %><WT:Main id=VNL Type="Venue_List" runat=server/><div id=CNT></div><iframe name=vrtPOST></iframe></body></html><%

Else

  %><WT:Main id=MTG Type="Meeting_Info" runat=server/><%

  '-- Meeting & Event Record Gathering ------------------------------------------------------------
  Dim DBNow As DateTime = getResult("SELECT GETDATE()")
  Dim I As Byte, TS() As Double = {0, 0, 0, 0}, NC As String = Session("NSW_CLONE")
  Dim TT As DataRow = getDataRow("SELECT STAB='', NSW='', QLD='', USA=''")
  Dim RM As DataRow = getDataRow("SELECT * FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
  Dim RV As DataRow = getDataRow("SELECT * FROM EVENT(nolock)   WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
  Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME IN('W','P') AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)).Tables(0)
  DV.PrimaryKey = New DataColumn() { DV.Columns(2), DV.Columns(3) }

  Dim DC() As String = { "", "", "", "" }
  Dim CT As String = RM("COUNTRY"), TP As String = RM("TYPE"), ST As String = RV("STATUS")
  Dim AUS As Boolean = "AU,NZ".Contains(CT), USA As Boolean = "US,SE".Contains(CT)

  Dim AB As Double = sNR(RV("ALP_PMB"), 100) / 100, AE As Double = sNR(RV("ALP_PME"), 100) / 100
  Dim PP As Long = sN0(RV("PM_POOL")), AP As Long = IIf(USA, sN0(RV("HST_PW")) + sN0(RV("HST_PX")), sN0(RV("VIC_PW")) + sN0(RV("NSW_PW")) + sN0(RV("QLD_PW")))
  Dim MP() As Double = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

  '-- Parameters Setting --------------------------------------------------------------------------
  Dim OV As Byte = getENum("OVL_VWM")
  Dim BP As Byte = getENum("PCT_PM_" & IIf(CT = "HK", "HKB", "XXB"))
  Dim EP As Byte = getENum("PCT_PM_" & IIf(CT = "HK", "HKE", "XXE"))
  Dim KL As Byte = getENum("KLY_FRC"), KM As Byte = getENum("KLY_MDL")
  Dim RT As Byte = getENum("RDC_ST_" & CT & TP)

  Dim MX   As DataTable = makeDataSet("SELECT * FROM SYS_MATRIX(nolock) WHERE COUNTRY='" & CT.Replace("NZ","AU") & "'").Tables(0)
  Dim LV() As DataRow   = makeDataSet("SELECT * FROM SYS_LEVEL(nolock) WHERE LVL_ID IN(1,2) ORDER BY 1").Tables(0).Select() ' 0 = Bet, 1 = Eat
  Dim FS   As DataRow   = getDataRow("SELECT * FROM SYS_FVT(nolock) WHERE COUNTRY='" & CT.Replace("NZ","AU") & "' AND TYPE='" & TP & "'")
  If IsNothing(FS) Then FS = getDataRow("SELECT * FROM SYS_FVT(nolock) WHERE COUNTRY='XX' AND TYPE='X'")

  Dim FP As String = "<i class=NA>N/A</i>", BF As Double = 999
  Try: BF = MX.Select("MARKET='Betfair'")(0)("MX_FM_W"): Catch: End Try
  'If AUS AndAlso TP = "G" AndAlso sNN(RM("BTK_ID")) Then _
  '  FP = getResult("SELECT GTFAV FROM SYS_BETTEKK(nolock) WHERE CODE='" & RM("BTK_ID") & "'",,"AUS")

  ' Auto Update f Model, Div Pred & Pari-Mutuel Pool Triggering
  If Request("FTRD") <> "" OrElse PP < AP Then
    Dim WC As String = " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)
    Select Case sNS(RV("FMD_USE"))
    Case "VWM"  : execSQL("UPDATE RUNNER SET PM_WIN = BFR_WAP" & WC)
    Case "RDbl" : execSQL("UPDATE RUNNER SET PM_WIN = RDB_TW " & WC)
    Case "Mix 1": hybridMix("HMX_PM", "PM_WIN", 100, EV(0), EV(1))
    Case "Combi": CalcCombi(EV(0), EV(1), RV): hybridMix("HMX_XT", "XT_WIN", 100, EV(0), EV(1)): CalcPLA(EV(0), EV(1), "XT", 1.00)
    Case "Blend": CalcBlend(EV(0), EV(1))
    End Select
    Select Case sNS(RV("PDP_USE"))
    Case "STAB" : execSQL("UPDATE RUNNER SET PM_DVP = VIC_TW" & WC)
    Case "NSW"  : execSQL("UPDATE RUNNER SET PM_DVP = NSW_TW" & WC)
    Case "QLD"  : execSQL("UPDATE RUNNER SET PM_DVP = QLD_TW" & WC)
    Case "Host" : execSQL("UPDATE RUNNER SET PM_DVP = HST_TW" & WC)
    Case "Mix 1": hybridMix("DMX_PM", "PM_DVP", 118, EV(0), EV(1))
    Case "Early": execSQL("UPDATE RUNNER SET PM_DVP = PM_ORG" & WC)
    End Select: execSQL("UPDATE EVENT SET POOL_TIME=GETDATE(), PM_POOL=" & AP & WC)
    RV("POOL_TIME") = DBNow
  End If

  ' Auto Untick Process
  'execSQL("UPDATE RUNNER SET PM_RISK=1 WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND PM_RISK=0 AND " & _
  '  "ISNULL(PM_AMT_W, 0) * ISNULL(HST_TW, ISNULL(VIC_TW, 0)) NOT BETWEEN -" & (RV("RISK_PM") * EP * 10 + 1) & " AND " & (RV("RISK_PM") * BP * 10 - 1))

  %><form method=post target=vrtPOST autocomplete=off><input name=EV type=hidden value="<%= Join(EV, "_") %>"><%
  %><div class=LST><table><col width=28><col><col width=42><col width=64><col width=30><%
  %><col width=20><colgroup span=2 width=70></colgroup><%
  %><colgroup span=3 width=42></colgroup><col width=38><col width=40><col width=38><col width=42><col width=38><%
  %><colgroup span=17 width=42></colgroup><%
  %><tr><%
  %><tr height=21><th rowspan=2>No<th rowspan=2>Name<th rowspan=2 class=BIG>&#10003;<th rowspan=2><u>Conf Lvl</u><br><%

  ' Confidence Level
  %><%= sConf(RV("CONF_LVL"))

  %><th rowspan=2>&alpha;&beta;<th colspan=3>PM &nbsp; P & L <th colspan=3>f-ex Model<th colspan=5>Exchanges <th colspan=5>FX Dividend <th rowspan=2>PM<br>DVP <th colspan=9>PM Dividend <th colspan=2>Betfair<%
  %><tr height=22><th>FP<th>WIN<th><%= IIf(USA, "SHW", "PLA") %> <th>WIN<th>EXP<th><%= IIf(USA, "SHW", "PLA") %> <th>Bet<th>No<th>Eat<th>AVT<th>FVT<%
  %><th>BOB<th>APN<th>TAB<th>365<th>QLD <th>RDbl<th>vTRF<th>vQIN<th>vXCT<th>Host<th>STAB<th>NSW<th>QLD<th>AUS <th>VWM<th>xB1<%

  '-- Runners Parameter ---------------------------------------------------------------------------
  Dim W1 As Single = getResult("SELECT MIN(HST_TP) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND HST_TP BETWEEN 1 AND 10",,1)
  Dim W2 As Single = getResult("SELECT MIN(VIC_TP) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND VIC_TP BETWEEN 1 AND 10",,1)
  Dim EF As Single = getResult("SELECT TOP 1 XT_WIN FROM(SELECT TOP 4 * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND XT_WIN < 11 AND ISNULL(PM_DVP,0) < 11 ORDER BY 1)un ORDER BY 1 DESC",,0)
  Dim FV As DataRow = getDataRow("SELECT ISNULL(MIN(PM_ORG),0), ISNULL(MIN(HST_TW),0) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0")

  Dim RS As Object = getRecord("SELECT * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
  While RS.Read() %><tr><%
    Dim TV As Integer, AV As Single, TD(3) As Double
    Dim RN As Byte   = RS("RUNNER_NO")
    Dim EX As Double = getExp(RS("XT_WIN"), RS("PM_DVP"))
    Dim DB As Double, DE As Double, PB As Integer = 0, PE As Integer = 0, PF As Integer = 0
    Dim AM() As Double = { _
      Kelly(RS("XT_WIN"), 1, RV("BANK_PM1"), KL, 2, AB), _
      Kelly(RS("XT_WIN"), 1, RV("BANK_PM1"), KL, 2, AE)
    }

    ' Runner Info
    %><td class=HS><%= sRNo(CT, RN) & sHorse(RS, CT, TP, "PM") %><%
    If Not RS("SCR") Then

      ' Weighted PIR
      %><td><%= RS("W_PIR") %><%

      ' Confidence Level, Start & Speed
      %><td<%= ICase(sNS(RS("COMMENT")), "1st Str"," class=PF", "Data?"," class=HL", "") %>><%= sNR(RS("COMMENT"), "&nbsp;") %><%
      If sN0(RS("STARTS")) + sN0(RS("SPEED")) > 0 Then %><div class=INV><span><%=
        IIf(RS("STARTS") <= 6 AndAlso sNS(RS("COMMENT")) <> "1st Str", "<b class=xPR>" & RS("STARTS") & "</b>", RS("STARTS"))
        %></span><b <%= IIf(RS("SPEED") = 40, "class=xRD", "") %>><%= RS("SPEED") %></div><% End If

      If TP = "G" AndAlso sNN(RS("CMB_PC1")) Then %><td class=FF><%= Math.Round(RS("CMB_PC1")) & "<div class=INV>" & Math.Round(RS("CMB_PC2")) & "</div>" %><% Else %><td><% End If
      %><td><%= IIf(sNN(RS("POS")), "<b>" & RS("POS"), "") %><%

      ' PM P & L
      TD = getTradesPNL(RV, RS, TS)
      %><td><%= sPNL(TD(2)) & sINV(TD(0))
      %><td><%= sPNL(TD(3)) & sINV(TD(1)) %><%

      ' e Model
      %><td class=<%= IIf(sNS(RS("COMMENT")) = "1st Str", "PF", IIf(sN0(RS("HST_TW")) > 0 AndAlso sN0(RS("PM_ORG")) > 10 AndAlso sN0(RS("HST_TW")) < 3,"HL","FF"))
      %>><b><%= sDiv(RS("XT_WIN"), RS("PM_ORG"), sN0(RS("PM_ORG")) > 0 AndAlso sN0(RS("HST_TW")) > 0 AndAlso RS("PM_ORG") = FV(0) AndAlso RS("HST_TW") = FV(1) AndAlso FV(0) < FV(1)) %><%
      %><%= sEXP(EX)
      %><td class=FF><%= sDiv(RS("XT_PLA")) %><%

      ' Exchanges
      If sN0(RS("XT_WIN")) > 0 AndAlso sN0(RS("PM_DVP")) > 0 AndAlso sN0(RS("FX_BOB")) > 0 Then
        Dim BX As Double = RS("FX_BOB")
        DB = RS("XT_WIN") * (AB + getBias(CT, TP, RS("XT_WIN"))): DB = IIf(BX > DB, BX, DB): PB = (RS("PM_DVP") * 100) / DB
        DE = RS("XT_WIN") * AE:                        DE = IIf(BX > 0 And BX < DE, BX, DE): PE = (RS("PM_DVP") * 100) / DE
      End If
      %><td class=BET><%= IIf(DB > 0, sDiv(DB) & "<div class=INV>" & sPrc(PB) & "</div>", "-") %><%
      If Not RS("PM_RISK") Then %><td class="HN LNK" onclick=iHS(<%= RN %>)><%= sRNo(CT, RN) %><i><%= IIf(RS("PM_TICK"), "&#10003;", "&times;") %></i><% Else %><td class=HX><%= sRNo(CT, RN) %><i><b>&times;</b></i><% End If
      %><td class=EAT><%= IIf(DE > 0, sDiv(DE) & "<div class=INV>" & sPrc(PE) & "</div>", "-") %><%

      ' Average Value Ticket (AVT)
      If Math.Round(sN0(RS("PM_AMT_W")), 2) <> 0 AndAlso sNN(RS("HST_TW")) Then
        TV = (100 * (RS("PM_AMT_W") - sN0(RS("PM_DSC_W")))) / RS("PM_AMT_W")
        AV = (100 * RS("HST_TW")) / TV
      Else: TV = PB: AV = DB: End If
      %><td><%= IIf(TV <> 0, sPrc(IIf(TV < 1000, TV, 999)), "-") & IIf(AV <> 0, "<div class=INV>" & sDiv(AV) & "</div>", "") %><%

      ' Fair Value Ticket (FVT)
      If sN0(RS("XT_WIN")) > 0 AndAlso sN0(RS("VIC_TW")) > 0 Then
        PF = (RS("VIC_TW") * 100) / RS("XT_WIN")
      End If
      %><td<%= IIf(PF <> 0 AndAlso sN0(RS("XT_WIN")) < FS("MAX_MDL"), MIf(PF > (100 + FS("POS_EXP")), " class=PF", PF < (100 + FS("NEG_EXP")), " class=HL"), "")
      %>><%= IIf(PF <> 0 AndAlso sN0(RS("XT_WIN")) < FS("MAX_MDL"), sPrc(IIf(PF < 1000, PF, 999)), "-") %><%

      ' FX Dividend
      %><td class=FT><%= sDiv(RS("FX_BOB"))
      %><td<%
      If sNN(RS("APN_HIST")) Then %> onmouseover="gAP([<%= Replace(RS("APN_HIST"), "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("APN_FW"))
      %><td<% If sN0(RS("PM_ORG")) > 0 AndAlso sN0(RS("PM_ORG")) < sN0(RS("VIC_FW")) Then %> class=F2<% End If
      If sNN(RS("VIC_HIST")) Then %> onmouseover="gTB([<%= Replace(RS("VIC_HIST"), "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("VIC_FW"))
      %><td<% If sN0(RS("PM_ORG")) > 0 AndAlso sN0(RS("PM_ORG")) < sN0(RS("B1Y_FW")) Then %> class=F2<% End If
      If sNN(RS("B1Y_HIST")) Then %> onmouseover="gBT([<%= Replace(RS("B1Y_HIST"), "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("B1Y_FW"))
      %><td<% If sN0(RS("PM_ORG")) > 0 AndAlso sN0(RS("PM_ORG")) < sN0(RS("QLD_FW")) Then %> class=F2<% End If %>><%= sDiv(RS("QLD_FW")) %><%

      ' Dividend Prediction
      %><td class=FD><b><%= sDiv(RS("PM_DVP")) %><%

      ' Tote Market
      %><td<% If sNN(RS("RDB_HIST")) Then %> onmouseover="gRD([<%= Replace(RS("RDB_HIST"), "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("RDB_TW"))
      %><td<% If sNN(RS("HST_VTH"))  Then %> onmouseover="gVT([<%= Replace(RS("HST_VTH"),  "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("HST_VT"))
      %><td><%= sDiv(RS("HST_VQ"))
      %><td><%= sDiv(RS("HST_VX"))
      %><td<%= IIf(sN0(RS("HST_TP")) = W1, " class=HL", "") %>><%= "<b" & IIf(sN0(RS("BFR_WAP")) > 0 And sN0(RS("HST_TW")) > sN0(RS("BFR_WAP")), " class=BL", "") & ">" & sDiv(RS("HST_TW")) & "</b><div class=INV>" & sDiv(RS("HST_TP")) & "</div>"
      %><td<%= IIf(sN0(RS("VIC_TP")) = W2 And CT = "SG", " class=HL", "") %>><%= sDiv(RS("VIC_TW")) & "<div class=INV>" & sDiv(RS("VIC_TP")) & "</div>"
      %><td><%= sDiv(RS("NSW_TW")) & "<div class=INV>" & sDiv(RS("NSW_TP")) & "</div>"
      %><td><%= sDiv(RS("QLD_TW")) & "<div class=INV>" & sDiv(RS("QLD_TP")) & "</div>"
      %><td class=FT><%= IIf(sN0(RS("XT_WIN")) > EF And sN0(RS("AUS_TW")) > sN0(RS("XT_WIN")), "<b>", "") & sDiv(RS("AUS_TW")) %><%

      ' Betfair Market
      %><td<%= IIf(chkOverlay(RS("BFR_WAP"), PB) < -OV," class=HL", "") %>><b><%= sDiv(RS("BFR_WAP"))
      %><td<%= IIf(DB > 0 AndAlso sN0(RS("XT_WIN")) < BF AndAlso sN0(RS("BFR_FW_B1")) >= DB, " class=PF", "") %>><%= sDiv(RS("BFR_FW_B1")) %><%


      '-- Calculate Total Market Percentage -------------------------------------------------------
      If CT <> "US" OrElse RN Mod 10 = 0 Then
        MP( 0) += getMkP(RS("PM_ORG")): MP( 1) += getMkP(RS("XT_PLA")) : MP( 2) += getMkP(DB)
        MP( 3) += getMkP(DE)          : MP( 4) += getMkP(AV)           : MP( 5) += getMkP(RS("FX_BOB"))
        MP( 6) += getMkP(RS("APN_FW")): MP( 7) += getMkP(RS("VIC_FW"))
        MP( 8) += getMkP(RS("B1Y_FW")): MP( 9) += getMkP(RS("QLD_FW"))
        MP(10) += getMkP(RS("PM_DVP")): MP(11) += getMkP(RS("RDB_TW")) : MP(12) += getMkP(RS("HST_VT"))
        MP(13) += getMkP(RS("HST_VQ")): MP(14) += getMkP(RS("HST_VX")) : MP(15) += getMkP(RS("HST_TW"))
        MP(16) += getMkP(RS("VIC_TW")): MP(17) += getMkP(RS("NSW_TW")) : MP(18) += getMkP(RS("QLD_TW"))
        MP(19) += getMkP(RS("AUS_TW")): MP(20) += getMkP(RS("BFR_WAP")): MP(21) += getMkP(RS("BFR_FW_B1"))
      End If


      ' Populating Trade Data ---------------------------------------------------------------------
      If sNS(RV("CONF_LVL")) <> "E" AndAlso sN0(RS("XT_WIN")) > 0 AndAlso RS("PM_TICK") AndAlso Not RS("PM_RISK") Then

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

        If AUS AndAlso sN0(RV("BANK_PM2")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 Then ' BET Strategy 2 (TAB & Bet365 Fix Odds WIN only)
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

        If AUS AndAlso sN0(RV("BANK_PM3")) > 0 AndAlso sN0(RS("PM_ORG")) > 0 AndAlso _
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

        If sN0(RS("PM_DVP")) > 0 AndAlso sN0(RS("XT_PLA")) > 0 Then ' BET Strategy 4 (Totalisator)
          Dim BR As Boolean = False

          '-- WIN Staking
          For Each MR As DataRow In MX.Select(IIf(AUS, "SEQ < 33", "")): If MR("WIN") Then
            DB = RS("PM_DVP"): Try: Select Case MR("MARKET")
            Case "STAB": DB = RS("VIC_TW")
            Case "NSW" : DB = RS(NC & "_TW")
            Case "QLD" : DB = RS("QLD_TW")
            Case "USA" : DB = RS("PM_DVP") 'RS("HST_TW")
            End Select: Catch: End Try: DE = DB / RS("XT_WIN")

            Dim XS As DataRow = getStaking(MR("MARKET"), 0, CT,TP)
            If XS("POOL_TCK") Then
              If sNB(XS("TKO_TCK")) Then
                AV = (sN0(RV(ICase(MR("MARKET"), "USA","HST", "STAB","VIC", MR("MARKET")) & "_PW")) * XS("TKO_PCT")) / 100
              Else: AV = XS("TKO_AMT"): End If

              ' Reduced Trading Exposure (when required)
              IF sNB(RV("RDC_TPM")) Then AV = (AV * RT) / 100
              If RS("PM_WIN") < MR("RD_FM_W") Then AV /= 3

              AV = getStk(AV / (RS("XT_WIN") - 1), getStaking(MR("MARKET"), 99, CT,TP))
              If AV > XS("TKO_AMT") Then AV = XS("TKO_AMT")

              If DE < IIf(sNB(XS("EXP_TCK")), 1 + XS("EXP_MIN") / 100, 0) OrElse DB > MR("MX_DV_W") OrElse _
                 RS("XT_WIN") < MR("MN_FM_W") OrElse RS("XT_WIN") > MR("MX_FM_W") Then AV = 0
            Else
              AV = (DB - RS("XT_WIN") + 1) / (DB * RS("XT_WIN"))
              AV = Math.Round(MR("KELLY") * AV * MR("WP_BANK") / 100)
              If AV < 0 OrElse DE < MR("EXP_MIN") OrElse DE > MR("EXP_CUT") OrElse DB > MR("MX_DV_W") OrElse _
                RS("XT_WIN") < MR("MN_FM_W") OrElse RS("XT_WIN") > MR("MX_FM_W") Then AV = 0
            End If

            If AV > 0 Then
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
          End If: Next

          '-- PLA Staking
          If BR Then: For Each MR As DataRow In MX.Select("SEQ < 33"): If MR("PLA") And Session("NPL_" & IIf(MR("MARKET") = "STAB", "VIC", MR("MARKET"))) <> "1" Then
            DB = RS("VIC_TP"): Try: Select Case MR("MARKET")
            Case "STAB": DB = RS("VIC_TP")
            Case "NSW" : DB = RS(NC & "_TP")
            Case "QLD" : DB = RS("QLD_TP")
            Case "USA" : DB = RS("HST_TP")
            End Select: Catch: End Try: DE = DB / RS("XT_PLA")

            Dim XS As DataRow = getStaking(MR("MARKET"), 1, CT,TP)
            If XS("POOL_TCK") Then
              If sNB(XS("TKO_TCK")) Then
                AV = (sN0(RV(ICase(MR("MARKET"), "USA","HST", "STAB","VIC", MR("MARKET")) & "_PP")) * XS("TKO_PCT")) / 100
              Else: AV = XS("TKO_AMT"): End If

              ' Reduced Trading Exposure (when required)
              IF sNB(RV("RDC_TPM")) Then AV = (AV * RT) / 100
              If RS("PM_PLA") < MR("RD_FM_P") Then AV /= 3

              AV = getStk(AV / (RS("XT_PLA") - 1), getStaking(MR("MARKET"), 99, CT,TP))
              If AV > XS("TKO_AMT") Then AV = XS("TKO_AMT")

              If DE < IIf(sNB(XS("EXP_TCK")), 1 + XS("EXP_MIN") / 100, 0) OrElse DB > MR("MX_DV_P") OrElse _
                 RS("XT_PLA") < MR("MN_FM_P") OrElse RS("XT_PLA") > MR("MX_FM_P") Then AV = 0
            Else
              AV = (DB - RS("XT_PLA") + 1) / (DB * RS("PM_PLA"))
              AV = Math.Round(MR("KELLY") * AV * MR("WP_BANK") / 100)
              If AV < 0 OrElse DE < MR("EXP_MIN") OrElse DE > MR("EXP_CUT") OrElse DB > MR("MX_DV_P") OrElse _
                RS("XT_PLA") < MR("MN_FM_P") OrElse RS("XT_PLA") > MR("MX_FM_P") Then AV = 0
            End If

            If AV > 0 Then
              DC(3) &= RN & vbTab & RS("NAME") & vbTab & "PLA" & vbTab & FormatNumber(DE) & vbTab & Math.Round(AV, 1) & _
                vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
                vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & MR("MARKET") & vbLf

              If Request("FTRD") <> "" Then TT(MR("MARKET")) &= _
                RN & vbTab & RS("NAME") & vbTab & "PLA" & vbTab & FormatNumber(DE) & vbTab & Math.Round(AV, 1) & _
                vbTab & sDiv(DB) & vbTab & Math.Round(AV * DB) & vbTab & CSng(AV * MR("WP_RBT") / 100) & _
                vbTab & CSng(AV * MR("WP_COMM") / 100) & vbTab & "ON" & vbLf
            End If
          End If: Next: End If
        End If

      End If

    Else %><td colspan=31 class=SCR>&nbsp;<% End If
  End While: RS.Close() %><tr><td colspan=33 class=SPT><%


  '-- Trade Handling ------------------------------------------------------------------------------
  If Request("FTRD") <> "" Then
    Dim CM As String = Request("FTRD"), TA As Boolean = (CM = "Trade ALL"), TL() As Single = {0, 0, 0}, S As String = ""

    If (CM = "STAB" Or TA) And TT("STAB")    <> "" Then S &= ", TPM_VIC=ISNULL(TPM_VIC,'')+" & cQS(FileTrade("VIC", TP, EV, RM("BTK_ID"), TT("STAB"), CT) & TT("STAB"))
    If (CM = "NSW"  Or TA) And TT("NSW")     <> "" Then S &= ", TPM_NSW=ISNULL(TPM_NSW,'')+" & cQS(FileTrade("NSW", TP, EV, RM("BTK_ID"), TT("NSW"),  CT) & TT("NSW"))
    If (CM = "QLD"  Or TA) And TT("QLD")     <> "" Then S &= ", TPM_QLD=ISNULL(TPM_QLD,'')+" & cQS(FileTrade("QLD", TP, EV, RM("QLD_ID"), TT("QLD"),  CT) & TT("QLD"))
    If (CM = "USA"  Or TA) And TT("USA")     <> "" Then S &= ", TPM_HST=ISNULL(TPM_HST,'')+" & cQS(FileTrade("HST", TP, EV, RM("UTL_ID"), TT("USA"),  CT) & TT("USA"))
    If S <> "" Then execSQL("UPDATE EVENT SET " & Mid(S, 2) & " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))

    Response.Clear %><script>parent.getEVN(parent.curVNL)</script><% Response.End
  End If


  '-- Market % ------------------------------------------------------------------------------------
  %><tr height=23 class=TOT><td colspan=5 class=TFN>Net Investment &#8211; Market %<td class=PIG><% If ST <> "DONE" Then %><div></div><% End If
  %><td><%= sPNL(TS(0))
  %><td><%= sPNL(TS(1))
  %><%= sMkP(MP(0), 100)
  %><td><%= sMkP(MP(1), 100 * IIf(RV("STARTERS") < 8, 2, 3))
  %><%= sMkP(MP(2))
  %><td><%= sMkP(MP(3))
  %><%= sMkP(MP(4))
  %><td><%
  %><% For I = 5 To 21 %><%= sMkP(MP(I)) %><% Next


  '-- Pools Size ----------------------------------------------------------------------------------
  %><tr height=23 class=TOT><td colspan=5 class=TFN><%
  If ST <> "DONE" Then
    %>Pools / Matched<td colspan=3><%
  Else
    %>Net Profit &#8211; Pools / Matched<td class=PIG><div></div><%
    %><td><%= sPNL(TS(2) + TS(0))
    %><td><%= sPNL(TS(3) + TS(1)) %><%
  End If
  %><td colspan=3><%= sVar(RV("FMD_USE")) & " - " & sVar(RV("XMD_USE"))
  %><td colspan=5><%'= IIf(TP = "G", "&alpha; = " & FormatNumber(sN0(RV("CMB_PC1")) / 100) & " &nbsp; &beta; = " & FormatNumber(sN0(RV("CMB_PC2")) / 100), "")
  %><td colspan=5><td><%= sVar(RV("PDP_USE"))
  %><td><%= sTtP(RV("RDB_PW"))
  %><td><%= sTtP(RV(IIf(AUS, "NSW", "HST") & "_PT"))
  %><td><%= sTtP(RV(IIf(AUS, "NSW", "HST") & "_PQ"))
  %><td><%= sTtP(RV(IIf(AUS OrElse CT = "HK", "NSW", "HST") & "_PX"))
  %><td><%= IIf(AUS, "AUS", sTtP(RV("HST_PW"), RV("HST_PP")))
  %><td><%= sTtP(RV("VIC_PW"), RV("VIC_PP"))
  %><td><%= sTtP(RV("NSW_PW"), RV("NSW_PP"))
  %><td><%= sTtP(RV("QLD_PW"), RV("QLD_PP"))
  %><td><%= sTtP(RV("AUS_PW"))
  %><td><td><%= sTtP(RV("BFR_MW"))
  %></table></div><%


  '-- Trading Parameters --------------------------------------------------------------------------
  If True Then
    %><div class=TPR><table cellspacing=0 cellpadding=3><%
    %><col><col width=245><col width=195><col width=85><col width=245><col width=100><col width=85><col width=85><col width=150><%

    ' Speed Map
    %><td id=SMP><%
    If TP = "G" OrElse (AUS AndAlso TP = "R") Then
      %><table class="LST FX" cellspacing=0 cellpadding=1><%
      %><td id=SPD<%= IIf(TP = "G", " onclick=""vSPD(this,'SPG')""", "") %>><%
      Dim SA() As Byte = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, SG As New StringBuilder
      RS = getRecord("SELECT RUNNER_NO, BARRIER, SPEED, POS FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 ORDER BY BARRIER, RUNNER_NO")
      While RS.Read()
        Dim RN As Byte = IIf(USA, RS(0) \ 10, RS(0))
        Dim SP As Byte = sN0(RS(2)), PS As String = sN0(RS(3)): PS = MIf(PS = 1, " class=W", PS > 0 And PS < 4, " class=P", "")
        If SP > 0 Then: Select Case TP
          Case "G" %><div<%= PS %> style="top:<%= SA(SP\10) * 14 + 1 %>px; right:<%= (SP\10-1) * 45 + (SP Mod 10) * 2 %>px"><%= RN %></div><% SA(SP\10) += 1
            SG.Append("<div" & PS & " style=""top:" & (sNR(RS(1), RN) - 1) * 13 + 1 & "px; right:" & (SP - 10) * 5 & _
              "px; background-image:url(/Jersey/" & IIf(USA, "UG", "AG") & "/DG" & RN.ToString("00") & ".png)"">" & RN & "</div>")
          Case "R" %><div<%= PS %> style="bottom:<%= SA(SP - 1) * 14 + 1 %>px; right:<%= (SP - 1) * 37 + SA(SP - 1) * 5 %>px"><%= RN %></div><% SA(SP - 1) += 1
        End Select: End If
      End While: RS.Close(): If TP = "G" Then %><td id=SPG onclick="vSPD(this,'SPD')"><%= SG.ToString %><% End If
      %></table><%
    End If

    ' Pari-Mutuel Parameters
    %><td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1><col><col><col width=65><col width=50><%
      %><tr class=GPM><th colspan=2>f Model<th colspan=2>Hybrid %<%
      %><tr><td><input name=FCMD type=submit value="f VWM" disabled><%
          %><td><input name=FCMD type=submit value="f Mix 1" disabled><%
          %><%= hybridBox("HMX_PM", 1, RV)
      %><tr><td><input name=FCMD type=submit value="f Clear" disabled><%
          %><td><input name=FCMD type=submit value="f <%= IIf(TP = "G", "Combi+", "Blend") %>"><%
          %><%= hybridBox("HMX_PM", 2, RV)
      %><tr><td><input name=FCMD type=submit value="f Origin" disabled><%
          %><td><input name=FCMD type=submit value="f RDbl" disabled><%
          %><%= hybridBox("HMX_PM", 3, RV)
    %></table><%

    ' Bank & Risk Parameters
    %><td class=GRP><table class=LST cellspacing=0 cellpadding=1><col><col width=50><col width=50><col width=60><%
      %><tr class=GPM><th>#<th>Bank<th>Risk<th>WPL<% For I = 1 To 3
      %><tr><td class=TFN><%= I
      %><td><input name=BANK_PM<%= I %> type=number value="<%= RV("BANK_PM" & I) %>" maxlength=2 onfocus="iFC('Bank Roll')" onchange=cNM(this,<%= IIf(I = 3, 30, 20) %>) onblur=iBL()><%
      %><td><% If I = 1 Then %><input name=RISK_PM type=number value="<%= RV("RISK_PM") %>" maxlength=2 onfocus="iFC('Risk Amount')" onchange=cNM(this,10) onblur=iBL()><%
           ElseIf I = 2 Then %><%= RV("RISK_PM") %><u>k<% End If
      If ST = "OPEN" Or ST = "CLOSED" Then
        Dim GB As Boolean = sNB(RV("TRD_PM" & I))
        %><td<%= IIf(GB, " class=PF", "") %>><input name=FCMD type=submit value="<%= IIf(GB, "STOP", "Start") %> <%= I %>" disabled><%
      Else %><td><% End If
    Next %></table><%

    ' Alpha Parameters
    %><td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1><col><col width=50><%
      %><tr class=GPM><th colspan=2>&alpha; %<%
      %><tr><td class=TFN>B<td><input name=ALP_PMB type=number value="<%= RV("ALP_PMB") %>" maxlength=2 onfocus="iFC('Alpha Bet')" onchange=cNM(this,200,50) onblur=iBL()><%
      %><tr><td class=TFN>E<td><input name=ALP_PME type=number value="<%= RV("ALP_PME") %>" maxlength=2 onfocus="iFC('Alpha Eat')" onchange=cNM(this,160,10) onblur=iBL()><%
      %><tr><td colspan=2><%= (200 - sNR(RV("ALP_PMB"), 100)) & " &ndash; " & (200 - sNR(RV("ALP_PME"), 100))
    %></table><%

    ' Dividend Prediction Parameters
    %><td><table class="LST FX" cellspacing=0 cellpadding=1><col><col><col width=65><col width=50><%
      %><tr><th colspan=2>PM Div Pred<th colspan=2>Hybrid %<%
      %><tr><td><input name=FCMD type=submit value="STAB"><%
          %><td><input name=FCMD type=submit value="DP Mix 1"><%
          %><%= hybridBox("DMX_PM", 1, RV)
      %><tr><td><input name=FCMD type=submit value="NSW"><%
          %><td><input name=FCMD type=submit value="Host"><%
          %><%= hybridBox("DMX_PM", 2, RV)
      %><tr><td><input name=FCMD type=submit value="QLD"><%
          %><td><input name=FCMD type=submit value="Early Fill"><%
          %><%= hybridBox("DMX_PM", 3, RV)
    %></table><%

    ' Other Parameters (View Only)
    %><td><table class="LST FX" cellspacing=0 cellpadding=1><col><col width=45><%
      %><tr><th colspan=2>&Delta; %<%
      %><tr><td>Mode<td><%= ICase(KM, 0,"Kelly", 1,"Willy", 2,"P.Stk", "None")
      %><tr><td>Bet<td><%= BP
      %><tr><td>Eat<td><%= EP
    %></table><%

    ' NSW Clone
    %><td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1><%
      %><tr class=GPM><th>NSW Clone<%
    If ST = "OPEN" Then
      %><tr><td class=RN><input name=FCLN type=radio value="NSW" onclick="iBL()"<%= IIf(NC = "NSW", " checked", "") %> id=FCLN_1><label for=FCLN_1> none</label><%
      %><tr><td class=RN><input name=FCLN type=radio value="VIC" onclick="iBL()"<%= IIf(NC = "VIC", " checked", "") %> id=FCLN_2><label for=FCLN_2> VIC</label><%
      %><tr><td class=RN><input name=FCLN type=radio value="QLD" onclick="iBL()"<%= IIf(NC = "QLD", " checked", "") %> id=FCLN_3><label for=FCLN_3> QLD</label><%
    Else %><tr><td><tr><td><tr><td><% End If
    %></table><%

    ' PLA or No PLA
    %><td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1><%
      %><tr class=GPM><th>No PLA<%
    If ST = "OPEN" Then
      %><tr><td class=RN><input name=NPL_VIC type=checkbox value=1 onclick="iBL()"<%= IIf(Session("NPL_VIC") = 1, " checked", "") %> id=NPLA_1><label for=NPLA_1> STAB</label><%
      %><tr><td class=RN><input name=NPL_NSW type=checkbox value=1 onclick="iBL()"<%= IIf(Session("NPL_NSW") = 1, " checked", "") %> id=NPLA_2><label for=NPLA_2> NSW</label><%
      %><tr><td class=RN><input name=NPL_QLD type=checkbox value=1 onclick="iBL()"<%= IIf(Session("NPL_QLD") = 1, " checked", "") %> id=NPLA_3><label for=NPLA_3> QLD</label><%
    Else %><tr><td><tr><td><tr><td><% End If
    %></table><%

    ' Trade Buttons
    %><td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1><%
      %><tr class=GPM><th colspan=2>Trade<%
    If ST = "OPEN" Then
      %><tr><%
          %><td><input name=FTRD type=submit value="STAB"><%
          %><td><input name=RDC_TPM type=checkbox value=1 onclick="iBL()"<%= IIf(sNB(RV("RDC_TPM")), " checked", "") %> id=RDCT_1><label for=RDCT_1>Reduce</label><%
      %><tr><%
          %><td><input name=FTRD type=submit value="NSW"><%
          %><td><input name=FTRD type=submit value="Betfair"><%
      %><tr><%
          %><td><input name=FTRD type=submit value="QLD"><%
          %><td><input name=FTRD type=submit value="Trade ALL"><%
    Else %><tr><td><td><%= IIf(sNB(RV("RDC_TPM")), "Reduced", "") %><tr><td><td><tr><td><td><% End If
    %></table><%

    %></table></div><%
    %><input name=RNR_NO type=hidden value=""><%
    %><input id=btnUPDT name=FCMD type=submit value="Update Changes" style="display:none"><%
  End If

  '-- Edit Market, Save & Status Bar --------------------------------------------------------------
  %><div class=TED><%
  %><div id=divDSP><%= sLcDt(Now, "dd MMM, HH:mm.ss") %></div><%
  %></div></form><%


  '-- Auto Trade Handling -------------------------------------------------------------------------
  If True Then
    %><table id=TDG><%

    If DC(0).Length > 0 Then ' Trade 1
      %><td><b>Strategy 1 - Citibet</b><pre class=CTB><%= sTrdPM(DC(0), DV) %></pre><%
    End If

    If DC(1).Length > 0 Then ' Trade 2
      %><td><b>Strategy 2 - Fixed Odds</b><pre><%= sTrdTL(DC(1), True, DV, CT) %></pre><%
    End If

    If DC(2).Length > 0 Then ' Trade 3
      %><td><b>Strategy 3 - Betfair</b><pre><%= sTrdTL(DC(2), True, DV, CT) %></pre><%
    End If

    If DC(3).Length > 0 Then ' Trade 4
      %><td><b>Strategy 4 - Totalisator</b><pre><%= sTrdTL(DC(3), True, DV, CT) %></pre><%
    End If

    If sNS(RV("TPM_VIC") & RV("TPM_NSW") & RV("TPM_QLD") & RV("TPM_HST")) <> "" Then
      %><td><b>Strategy 4 - Trades</b><pre><%
      If sNN(RV("TPM_VIC")) Then %><b class=RD>STAB</b><%=    sTrdTL(RV("TPM_VIC"), False, DV, CT) %><% End If
      If sNN(RV("TPM_NSW")) Then %><b class=BL>NSW</b><%=     sTrdTL(RV("TPM_NSW"), False, DV, CT) %><% End If
      If sNN(RV("TPM_QLD")) Then %><b class=GR>QLD</b><%=     sTrdTL(RV("TPM_QLD"), False, DV, CT) %><% End If
      If CT = "HK" Then
        If sNN(RV("TPM_HST")) Then %><b class=CN>HKJC</b><%=  sTrdTL(RV("TPM_HST"), False, DV, CT) %><% End If
      Else
        If sNN(RV("TPM_HST")) Then %><b class=PK>USA</b><%=   sTrdTL(RV("TPM_HST"), False, DV, CT) %><% End If
      End If
      %></pre><%
    End If

    %></table><%
  End If

  'sDuration(TM)
End If %>