<script language=VBScript runat=server>

'-- Shared Values -------------------------------------------------------------
Dim arrHMX() As String = { "", "f-Org",  "Host",   "STAB",   "NSW",    "QLD",    "VWM",     "xB1",       "APN",    "RDbl",   "AUS",    "fxES",   "fxTAB",  "fxQLD",  "BOB",    "f-Win",  "e-Org",  "DPP",    "DVP",    "vTRF",    "vQIN",   "vXCT",   "fx365" ,"xL1" , "SDP", "TOP", "LXB" , "RTG"}
Dim arrHMF() As String = { "", "PM_ORG", "HST_TW", "VIC_TW", "NSW_TW", "QLD_TW", "BFR_WAP", "BFR_FW_B1", "APN_FW", "RDB_TW", "AUS_TW", "FX_WIN", "VIC_FW", "QLD_FW", "FX_BOB", "PM_WIN", "XT_WIN", "PM_DPP", "PM_DVP", "HST_VT", "HST_VQ", "HST_VX", "B1Y_FW"  , "BFR_FW_L1" , "SDP", "TOP_FW", "LXB_FW", "CTI_FW"}

'-- Calculation Specific Related Functions ------------------------------------
Function getExp( FM As Object, DP As Object ) As Single
  If IsDBNull(FM) OrElse IsDBNull(DP) OrElse FM = 0 OrElse DP = 0 Then Return 0 Else Return DP / FM
End Function

Function getMkP( Dvdn As Object ) As Single
  If IsDBNull(Dvdn) OrElse Dvdn = 0 Then Return 0 Else Return 100 / Dvdn
End Function

Function normDiv( Dvdn As Object, MkP As Single ) As Single
  Return (Dvdn * MkP) / 100
End Function

Function chkDiv( Dvdn As Double ) As Double
  Return Math.Round(Dvdn, MIf(Dvdn >= 100, 0, Dvdn >= 10, 1, 2))
End Function

Function getStaking( Mkt As String, Pool As Byte , Country As String, RaceType As String) As DataRow
  Dim staking = makeDataSet("SELECT * FROM SYS_STAKING(nolock)").Tables(0)
  Dim IsInternational = IIf(Country = "AU", 0, 1)

  Dim R() As DataRow = staking.Select("MARKET='" & Mkt & "' AND POOL_ID=" & Pool & " AND INTERNATIONALS = " & IsInternational & " AND RACE_TYPE = '" & RaceType & "'")
  If R.Length = 0 Then Return Nothing Else Return R(0)
End Function

Function getPrice( Typ As String, FM As Object, EX As Double ) As Byte
  If IsNothing(Application("SYS_PRICE")) Then Application("SYS_PRICE") = makeDataSet("SELECT * FROM SYS_PRICE(nolock) ORDER BY TYP, TOTE").Tables(0)
  If EX = 0 OrElse IsDBNull(FM) Then Return 0
  Try: Dim X As Byte = Application("SYS_PRICE").Select("TYP='" & Typ & "' AND TOTE > " & FM)(0)("PRICE")
    If X > 0 AndAlso Typ = "BET" Then
      X += IIf(EX >= 1.3, 3, IIf(EX >= 1.2, 2, IIf(EX >= 1.1, 1, 0)))
    ElseIf X > 0 AndAlso Typ = "EAT" Then
      X -= IIf(EX <= 0.7, 3, IIf(EX <= 0.8, 2, IIf(EX <= 0.9, 1, 0)))
    End If: Return X
  Catch: Return 0: End Try
End Function

Function getStk( X As Double, ByVal MC As DataRow ) As Double
  Select Case MC("MARKET")
  Case "QLD":
    Dim C As Byte = (X * 100) Mod 100: Select Case MC("TKO_PCT")
    Case 0: X = Math.Floor(X) + IIf(C = 0, 0, 1)
    Case 1: X = Math.Floor(X)
    Case 2: X = Math.Floor(X) + IIf(C <= MC("TKO_AMT"), 0, 1)
    End Select: Return IIf(X = 0 AndAlso MC("TKO_TCK"), 1, X)
  Case Else:
    Dim C As Byte = (X * 100) Mod 100: Select Case MC("TKO_PCT")
    Case 0: X = Math.Floor(X) + IIf(C = 0, 0, IIf(C <= 50, 0.5, 1))
    Case 1: X = Math.Floor(X) + IIf(C < 50, 0, 0.5)
    Case 2: X = Math.Floor(X) + IIf(C <= MC("TKO_AMT"), 0, IIf(C <= 50 + MC("TKO_AMT"), 0.5, 1))
    End Select: Return IIf(X = 0 AndAlso MC("TKO_TCK"), 0.5, X)
  End Select
End Function


Function getBias( Cty As String, Typ As String, Dvd As Double ) As Double
  If IsNothing(Application("SYS_BIAS")) Then Application("SYS_BIAS") = makeDataSet("SELECT * FROM SYS_BIAS(nolock) ORDER BY COUNTRY, TYPE").Tables(0)
  Dim B As Double = 0, R() As DataRow = Application("SYS_BIAS").Select("COUNTRY='" & Cty & "' AND TYPE='" & Typ & "'")
  If R.Length = 0 Then R = Application("SYS_BIAS").Select("COUNTRY='XX' AND TYPE='X'")
  If     Dvd > 50.00 Then: B = R(0)(11)
  ElseIf Dvd > 25.00 Then: B = R(0)(10)
  ElseIf Dvd > 14.00 Then: B = R(0)(9)
  ElseIf Dvd > 10.00 Then: B = R(0)(8)
  ElseIf Dvd >  7.00 Then: B = R(0)(7)
  ElseIf Dvd >  5.00 Then: B = R(0)(6)
  ElseIf Dvd >  3.00 Then: B = R(0)(5)
  ElseIf Dvd >  2.00 Then: B = R(0)(4)
  ElseIf Dvd >  1.50 Then: B = R(0)(3)
  Else: B = R(0)(2): End If: Return B / 100
End Function

Function getBankRoll( Cnf_Lvl As String ) As Byte
  Return 20
  Dim B As Byte = 0
  Select Case Cnf_Lvl
  Case "0", "A": B = 5:  Case "B": B = 4:  Case "C": B = 3:  Case "D": B = 2:  Case "1", "E": B = 1
  End Select: Return B
End Function

Function HasTrades(jurisdiction as String, trades as DataTable, liveTrades as Boolean) as Boolean 
    If trades Is Nothing 
      Return False
    End If

    Return trades.Select(String.Format("JURISDICTION = '{0}' AND PAPER_TRADE = {1}", jurisdiction, IIf(liveTrades,0,1))).Count > 0
End Function

Function getRiskAmt( Cnf_Lvl As String ) As Byte
  Return 5
  Dim B As Byte = 0
  Select Case Cnf_Lvl
  Case "0", "A", "B": B = 3:  Case "C", "D": B = 2:  Case "1", "E": B = 1
  End Select: Return B
End Function

Function genBatchNo( PF As String ) As String
  Return PF & DateDiff("s", DateTime.UTCNow.ToString("yyyy-01-01"), DateTime.UTCNow).ToString("X").PadLeft(7, "0")
End Function

Function getBatchDt( BN As String ) As DateTime
  Return DateAdd("s", Convert.ToInt32(Mid(BN, 2), 16), DateTime.UTCNow.ToString("yyyy-01-01")).AddHours(Session("GMT")(0)).AddMinutes(Session("GMT")(1))
End Function

'' Calculates the bet positions 
Function getTradesPNL( ByRef RV As Object, ByRef RS As Object, ByRef TS() As Double , ByVal tradeTable as DataTable) As Double()
  Dim T As String, R As String, C() As String, TD() As Double = {0, 0, 0, 0}


   Dim runnerTrades = tradeTable.Select(String.Format("SELECTION_1='{0}' AND SUCCESS = 1",RS("RUNNER_NO")))
   For Each trade In runnerTrades

      Dim stake = CDbl(trade("BET_AMOUNT"))
      Dim rebate = CDbl(trade("REBATE")) / 100

      If trade("BET_TYPE") = "Win" Then
        Dim potentialReturn = stake * RS(trade("JURISDICTION") & "_TW")

        TD(0) += stake
        TD(2) += potentialReturn
        TS(0) +=  rebate - stake '' need to take commision into account in the future

        If sN0(RS("POS")) = 1 Then 
          TS(2) += potentialReturn 
        End If
      Else If trade("BET_TYPE") = "Place" Then
        Dim potentialReturn = stake * RS(trade("JURISDICTION") & "_TP")
        TD(1) += stake
        TD(3) += potentialReturn
        TS(1) +=  rebate - stake '' need to take commision into account in the future

        If InStr("1,2" & IIf(RV("STARTERS") >= 8, ",3", ""), sN0(RS("POS"))) > 0 Then
          TS(3) += potentialReturn
        End If
      End If
   Next

   Return TD

End Function

Function Kelly( FM As Object, DP As Object, BR As Object, KL As Object, KM As Byte, Optional AL As Double = 1 ) As Double
  If IsDBNull(FM) OrElse IsDBNull(DP) OrElse IsDBNull(BR) OrElse FM = 0 OrElse DP = 0 OrElse BR = 0 Then Return 0
  Select Case KM
  Case 0: Return (((DP / FM) - 1 + (1 / FM)) * BR * 10 * KL) / DP
  Case 1: Dim EX As Double = DP / FM: Return ((EX - 1) * BR * 10 * KL) / DP
  Case 2: If FM > 1 Then Return (BR * 10 * KL) / (FM * AL - 1) Else Return 0
  End Select
End Function

Sub chkEvent( ByRef EV As Object )
  Dim C As String = Session("CNTL").Replace("1","AU").Replace("2","HK,JP,MO,MY,SG,UA").Replace("3","FR,IR,UK,SW,DE,FI").Replace("4","ZA").Replace("5","US,SE,CH,AR,UR,CA").Replace("6","NZ").Replace(",","','")
  Dim X As String = "SELECT TOP 1 dbo.EVENT_ID(MEETING_ID, EVENT_NO) FROM dbo.EVENT_VIEW WHERE TYPE IN('" & Replace(Session("GAME"),",","','") & "') AND COUNTRY IN('" & C & "')"
  If EV = "" Then EV = getResult(X & " AND (M2R >= -90 AND STATUS='OPEN') ORDER BY START_TIME")
  If EV = "" Then EV = getResult(X & " ORDER BY START_TIME DESC")
End Sub

Function chkOverlay( A As Object, B As Object ) As Integer
  A = getMkP(A): B = getMkP(B): If A = 0 Or B = 0 Then Return 0
  Return ((A * 100) / B) - 100
End Function


Function chkLmt( Prc As Integer, Optional Pay As Object = 0 ) As Integer
  If IsDBNull(Pay) Then Pay = 0
  Return IIf(Prc < 76 OrElse (Pay > 0 And Pay < 1.5) OrElse (Prc < 90 And Pay > 20) OrElse (Prc < 82 And Pay > 9), 0, Prc)
End Function

Function getLmt( Prc As Byte, M As Byte ) As String
  Dim WL As Integer = IIf(Prc < 82, 110, IIf(Prc < 90, 240, IIf(Prc < 100, 300, 600)))
  Dim PL As Integer = IIf(Prc < 82,  30, IIf(Prc < 90,  60, IIf(Prc < 100, 100, 200)))
  Return IIf(M = 1, WL & "/0", IIf(M = 2, "0/" & PL, WL & "/" & PL))
End Function

Function chkLmtFX( X As Integer, M As Byte ) As Integer
  If M = 0 Then
    If X <  40 Then X = 0
    If X > 160 Then X = 160
  Else
    If X <  40 Then X = 40
    If X > 160 Then X = 0
  End If: Return X
End Function


Sub hybridMix( Typ As String, FldNm As String, MkPr As Double, Mtg As Long, RNo As Byte )
  Try
    Dim DR As DataRow, X As Double = 0, Y As Double = 0, T As String = Typ & "T", P As String = Typ & "P", S As String = ""
    Dim US As Boolean = false '"US,SE".Contains(getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & Mtg,,"XX"))
    Dim RV As DataRow = getDataRow("SELECT * FROM EVENT(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo)
    Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO" & IIf(US, "/10", "") & Join(arrHMF, ", ") & ", " & "HYB = 0.0 " & _
      "FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0" & IIf(US, " AND RUNNER_NO % 10=0", "")).Tables(0).Rows
    For Each DR In DS: For I = 1 To 3
      If sN0(RV(T & I)) > 0 AndAlso sN0(DR(RV(T & I))) > 0 Then DR("HYB") += RV(P & I) / DR(RV(T & I))
    Next: X += DR("HYB"): Next
    For I = 1 To 3: If sN0(RV(T & I)) > 0 AndAlso sN0(DR(RV(T & I))) > 0 Then: Y += RV(P & I): End If: Next
    Y = 0.0034828 * (X * 100 / Y) - 0.40 '0.350434 
	X = 0 
	If Double.IsInfinity(Y) Then Y = 0
    For Each DR In DS: DR("HYB") ^= Math.Exp(Y): X += DR("HYB"): Next: X = MkPr / X
    For Each DR In DS
      S &= "UPDATE RUNNER SET " & FldNm & "=" & IIf(DR("HYB") > 0, 100 / (DR("HYB") * X), 0) & _
        " WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND " & IIf(US, "(RUNNER_NO/10)=", "RUNNER_NO=") & DR(0) & vbLf
    Next: execSQL(S)
  Catch: End Try
End Sub


Sub CalcCombi( Mtg As Long, RNo As Byte, ByRef RV As DataRow )
  Dim DR As DataRow, Y As Double = 0, S As String = ""
  Dim US As Boolean = false '"US,SE".Contains(getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & Mtg,,"XX"))
  Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO, PM_ORG, " & IIf(US, "ISNULL(HST_VX,HST_VQ)", "HST_TW") & ", CMB = 0.0, " & _
    "CMB_PC1, CMB_PC2 FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0").Tables(0).Rows
  For Each DR In DS: If sN0(DR(1)) > 0 AndAlso sN0(DR(2)) > 0 Then
    DR(3) = Math.Exp( DR(4) / 100 * Math.Log(1 / DR(1)) + DR(5) / 100 * Math.Log(1 / DR(2)) ): Y += DR(3)
  Else: DR(3) = 0: End If: Next
  For Each DR In DS
    S &= "UPDATE RUNNER SET PM_WIN=" & IIf(DR(3) > 0, Y / DR(3), "NULL") & _
      " WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND RUNNER_NO=" & DR(0) & vbLf
  Next: execSQL(S)
End Sub


Sub CalcBlend( Mtg As Long, RNo As Byte )
  Dim BA As Double = getENum("BLN_PC1") / 10000, BB As Double = getENum("BLN_PC2") / 10000, BC As Double = getENum("BLN_PC3") / 10000
  Dim DR As DataRow, Y As Double = 0, S As String = ""
  Dim US As Boolean = false '"US,SE".Contains(getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & Mtg,,"XX"))
  Dim MX As Byte = getResult("SELECT HMX_PMT1 FROM EVENT(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo)
  Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO" & IIf(US, "/10", "") & ", PM_ORG, " & arrHMF(MX) & ", BLN = 0.0 " & _
    "FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0" & IIf(US, " AND RUNNER_NO % 10=0", "")).Tables(0).Rows
  For Each DR In DS: If Not IsDBNull(DR(1)) AndAlso Not IsDBNull(DR(2)) Then
    DR(3) = Math.Exp( BA * Math.Log(DR(1) * 100 - 1) + BB * Math.Log(DR(2) * 100 - 1) + BC )
    DR(3) = (100 * DR(3)) / (1 + DR(3)): Y += DR(3)
  Else: DR(3) = 0: End If: Next
  For Each DR In DS
    S &= "UPDATE RUNNER SET PM_WIN=" & IIf(DR(3) > 0, Y / DR(3), "NULL") & _
      " WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND " & IIf(US, "(RUNNER_NO/10)=", "RUNNER_NO=") & DR(0) & vbLf
  Next: execSQL(S)
End Sub


Sub CalcPoint( Mtg As Long, RNo As Byte )
  Const MAX_POINT = 50
  Dim BA As Double = getENum("BLN_PC1") / 10000, BB As Double = getENum("BLN_PC2") / 10000, BC As Double = getENum("BLN_PC3") / 10000
  Dim DR As DataRow, Y As Double = 0, S As String = ""
  Dim MX As Byte = getResult("SELECT HMX_PMT2 FROM EVENT(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo)
  Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO, ISNULL(W_PIR, 0), " & arrHMF(MX) & ", 0.0, 0.0 " & _
    "FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0").Tables(0).Rows
  For Each DR In DS: If Not IsDBNull(DR(2)) Then: DR(2) = 1 / DR(2): Y += DR(2): End If: Next
  For Each DR In DS: If Not IsDBNull(DR(2)) Then: DR(3) = DR(2) / Y: End If: Next: Y = 0
  For Each DR In DS: If Not IsDBNull(DR(2)) Then
    DR(4) = Math.Exp( BA * Math.Log(100 / DR(2) - 1) + BB * Math.Log(100 / DR(3) - 1) + BC )
    DR(4) = 100 * DR(4) / (1 + DR(4)): Y += DR(4)
  End If: Next
  For Each DR In DS: If Not IsDBNull(DR(2)) Then
    DR(1) = IIf(DR(1) > MAX_POINT, MAX_POINT, IIf(DR(1) < -MAX_POINT, -MAX_POINT, DR(1)))
    DR(4) = DR(4) / Y: DR(4) += (DR(4) * DR(1)) / 100
  End If: Next: Y = 0: For Each DR In DS: Y += DR(4): Next
  For Each DR In DS
    S &= "UPDATE RUNNER SET PM_WIN=" & IIf(DR(4) > 0, Y / DR(4), "NULL") & _
      " WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND RUNNER_NO=" & DR(0) & vbLf
  Next: execSQL(S)
End Sub


Sub CalcPLA( Mtg As Long, RNo As Byte, Md As String, MkPr As Double )
  Dim MT As String = ICase(getResult("SELECT TYPE FROM MEETING(nolock) WHERE MEETING_ID=" & Mtg), "R","RC", "G","GR", "HR")
  Dim GM As Double = getENum("DHV_" & MT & "1") / 100
  Dim DL As Double = getENum("DHV_" & MT & "2") / 100
  Dim I As Byte, J As Byte, T1 As Double = 0, T2 As Double = 0, S As String = ""
  Dim US As Boolean = false '"US,SE".Contains(getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & Mtg,,"XX"))
  Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO" & IIf(US, "/10", "") & ", ISNULL(" & Md & "_WIN, 0), 0.0, 0.0, 0.0 " & _
    "FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0" & IIf(US, " AND RUNNER_NO % 10=0", "")).Tables(0).Rows
  Dim LS As Boolean = getResult("SELECT CASE WHEN ISNULL(FX_STARTERS, 0) > STARTERS AND ISNULL(FX_STARTERS, STARTERS) >= 8 " & _
    "AND STARTERS < 8 THEN 1 ELSE 0 END FROM EVENT(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo)
  Dim D As DataRow, E As DataRow, F As DataRow
  If DS.Count < 8 And Not LS Then
    For Each D In DS: If D(1) > 0 Then: D(2) = 1 / D(1): D(3) = D(2) ^ GM: T1 += D(3): End If: Next
    If T1 > 0 Then
      For Each D In DS: D(1) = 0: If D(2) > 0 Then: D(3) /= T1: End If: Next
      For Each D In DS: For Each E In DS
        If D(2) > 0 AndAlso E(2) > 0 AndAlso D(0) <> E(0) Then
          Dim Z As Double = (D(2) * E(3)) / (1 - D(3)): D(1) += Z: E(1) += Z
        End If
      Next: Next:  T1 = 0: For Each D In DS: T1 += D(1): Next
      For Each D In DS: If D(1) > 0 Then: D(1) = T1 / (D(1) * 2 * MkPr): End If: Next
    End If
  Else
    For Each D In DS: If D(1) > 0 Then: D(2) = 1 / D(1): D(3) = D(2) ^ GM: D(4) = D(2) ^ DL: T1 += D(3): T2 += D(4): End If: Next
    If T1 > 0 Then
      For Each D In DS: D(1) = 0: If D(2) > 0 Then: D(3) /= T1: D(4) /= T2: End If: Next
      For Each D In DS: For Each E In DS: For Each F In DS
        If D(2) > 0 AndAlso E(2) > 0 AndAlso F(2) > 0 AndAlso D(0) <> E(0) AndAlso D(0) <> F(0) AndAlso E(0) <> F(0) Then
          Dim Z As Double = (D(2) * E(3) * F(4)) / ((1 - D(3)) * (1 - D(4) - E(4)))
          D(1) += Z: E(1) += Z: F(1) += Z
        End If
      Next: Next: Next:  T1 = 0: For Each D In DS: T1 += D(1): Next
      For Each D In DS: If D(1) > 0 Then: D(1) = T1 / (D(1) * 3 * MkPr): End If: Next
    End If
  End If
  If T1 > 0 Then: For Each D In DS
    S &= "UPDATE RUNNER SET " & Md & "_PLA=" & IIf(D(1) = 0, "NULL", IIf(D(1) < 1.02, 1.02, D(1))) & _
      " WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND " & IIf(US, "(RUNNER_NO/10)=", "RUNNER_NO=") & D(0) & vbLf
  Next: execSQL(S): End If
End Sub


Sub CalcTEZ( Mtg As Long, RNo As Byte )
  Const GM = 0.8: Dim I As Byte, S() As Double = { 0, 0, 0 }, T1 As Double = 0, T2 As Double = 0, Q As String = ""
  Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO, ISNULL(FX_WIN, 0), 0.0 " & _
    "FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0").Tables(0).Rows
  For Each DR In DS: If DR(1) > 0 Then: DR(1) = 1 / DR(1): DR(2) = DR(1) ^ GM: T1 += DR(1): T2 += DR(2): End If: Next
  If T1 > 0 Then
    For Each DR In DS: If DR(1) > 0 Then: DR(2) /= T2: End If: Next
    For Each D1 In DS: For Each D2 In DS
      If D1(1) > 0 AndAlso D2(1) > 0 AndAlso D1(0) <> D2(0) Then
        Dim X As Byte = D1(0) Mod 2, Y As Byte = D2(0) Mod 2, Z As Double = (D1(1) * D2(2)) / (1 - D1(2))
        S(IIf(X = 1 And Y = 1, 1, IIf(X = 0 And Y = 0, 2, 0))) += Z
      End If
    Next: Next: T1 = S(0) + S(1) + S(2)
    For I = 0 To 2: S(I) = T1 / (S(I) * 1.10): If S(I) > 26 Then: S(I) = 26: End If: Next
  End If
  For I = 0 To 2
    Q &= "UPDATE SPINNER SET EZ_DIV=" & fixTEZ(S(I)) & _
      " WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND GROUP_NO=" & I & vbLf
  Next: execSQL(Q)
End Sub

Function chkTEZ( x As Byte, y As Byte ) As Byte
  If x = 0 And y = 0 Then: Return 99: End If:  x = x Mod 2: y = y Mod 2
  Return IIf(x = 1 And y = 1, 0, IIf(x = 0 And y = 0, 1, 2))
End Function

Function fixTEZ( x As Single ) As Single
  If x < 5 Then: x *= 20: x = Math.Round(x): Return x / 20: Else: Return Math.Round(x, 1): End If
End Function


Sub getCitibet( ByRef RM As DataRow, ByRef RV As DataRow )
  Try: If sNN(RM("QLD_ID")) Then
    Dim X As New XmlDocument, N As XmlNode, S As String = ""
    X.Load(APDS_API & "odds.aspx?DT=" & CDate(RM("MEETING_DATE")).ToString("yyyy-MM-dd") & "&QC=" & RM("QLD_ID") & "&RC=" & RV("EVENT_NO"))
    If xVL(X, "ERROR") = "" Then
      For Each N In X.SelectNodes("/FEED/ODDS"): S &= ",(" & xAT(N, "RNR_NO") & "," & cQS(xAT(N, "CTB_BW")) & "," & cQS(xAT(N, "CTB_EW")) & _
        "," & cQS(xAT(N, "CTB_BL").Replace(vbTab,"|").Replace(vbLf,"~")) & "," & cQS(xAT(N, "CTB_EL").Replace(vbTab,"|").Replace(vbLf,"~")) & ")"
      Next: execSQL("UPDATE RUNNER SET CTB_BW=x.A, CTB_EW=x.B, CTB_BW_LST=x.C, CTB_EW_LST=x.D FROM(VALUES" & Mid(S, 2) & _
        ")x(N,A,B,C,D) WHERE MEETING_ID=" & RM("MEETING_ID") & " AND EVENT_NO=" & RV("EVENT_NO") & " AND RUNNER_NO=x.N")
    End If
  End If: Catch: End Try
End Sub


public Sub PlaceBatchBet(Byval batchBet as String,jurisdiction as string , meetingId as Integer, eventNumber as Integer, trader as String)
  Dim oXMLHTTP
  Dim oStream
  Dim currentPage = "http://" & Request.ServerVariables("SERVER_NAME") &"/Luxbook.MVC/api/trade/batch"
  Dim querystringFormat = "?batchBet={0}&jurisdiction={1}&meetingId={2}&eventNumber={3}&trader={4}"
  oXMLHTTP = CreateObject("MSXML2.XMLHTTP.3.0")

  oXMLHTTP.Open("GET", currentPage & String.Format(querystringFormat,batchBet.Replace(vBLf,"\n").Replace(vbTab,"\t"),jurisdiction,meetingId,eventNumber, trader) , False)
  oXMLHTTP.Send
End Sub

'-- Display & Other Related Functions -----------------------------------------
Sub chkSession( Optional MaxLvl As Byte = 10 )
  If Session("LID") = "" Then
    Response.Write("<ScRIpT>top.location.reload()</ScR"&"IpT>"): Response.End
  ElseIf Session("LVL") > MaxLvl Then
    Response.Write("<script>top.setTitle(""Sorry, No Access Rights!"")</scr"&"ipt>"): Response.End
  End If
End Sub

Function hybridBox( Fld As String, Idx As Byte, ByRef RS As Object ) As String
  Dim S As String, T As String = Fld & "T" & Idx, P As String = Fld & "P" & Idx
  S = "<td><select name=" & T & " onfocus=""iFC('Mixer Tote')"" onblur=iBL()>"
  For J = 0 To UBound(arrHMX): S &= "<option value=" & J & IIf(J = sN0(RS(T)), " selected", "") & ">" & arrHMX(J): Next
  Return S & "</select><td><input name=" & P & " type=number value=" & sN0(RS(P)) & _
    " onfocus=""iFC('Mixer %')"" onchange=cNM(this,100) onblur=iBL()>"
End Function

Function shwHybridBox( Fld As String, Idx As Byte, ByRef RS As Object ) As String
  Dim T As String = Fld & "T" & Idx, P As String = Fld & "P" & Idx
  Return "<td>" & arrHMX(sN0(RS(T))) & "<td>" & sN0(RS(P))
End Function


Function sConf( x As Object ) As String
  If Not IsDBNull(x) Then Return "<b class='BIG " & getCode("CONF_LVL", x).Replace(": ", "'>") & "</b>" Else Return "-"
End Function

Function sRNo( CT As String, RN As Byte ) As String
  'If CT = "US" Then Return (RN \ 10) & IIf(RN Mod 10 > 0, Chr(64 + RN Mod 10), "") Else Return RN
  Return RN    'Disabled US Run No changes
End Function

Function OLDsHorse( RS As Object, CT As String, TP As String, MD As String ) As String
  Dim JS As String = "": TP = CT & "-" & TP
  If     InStr("AU-G NZ-G"          , TP) > 0 Then: JS = "<SLK_AG='DG" & CByte(RS("RUNNER_NO")).ToString("00") & ".png'>"
  'ElseIf InStr("US-G"               , TP) > 0 Then: JS = "<SLK_UG='DG" & CByte(RS("RUNNER_NO") \ 10).ToString("00") & ".png'>"
  ElseIf InStr("AU-R AU-H NZ-H NZ-R", TP) > 0 AndAlso Not IsDBNull(RS("JERSEY")) Then: JS = "<SLK_SR='" & RS("JERSEY") & "'>": End If
  Return "<td class=""RI" & IIf(RS("SCR"), " S", "") & """>" & JS & _
    "<b>" & RS("NAME").ToString.ToUpper & "</b>" & IIf(sN0(RS("BARRIER")) = 0, "", " (" & RS("BARRIER") & ")") & _
    "<div>" & RS("JOCKEY").ToString.ToUpper & IIf(IsDBNull(RS("HANDICAP")), "", " (" & RS("HANDICAP") & ")") & _
    IIf(IsDBNull(RS("JOCKEY")) Or IsDBNull(RS("TRAINER")), "", " - ") & RS("TRAINER").ToString.ToUpper & _
    IIf(IsDBNull(RS("JOCKEY")) And IsDBNull(RS("TRAINER")), "NA", "") & "</div>" & _
    IIf(Session("LVL") < 2 And (Not IsDBNull(RS(MD & "_PAT_B")) Or Not IsDBNull(RS(MD & "_PAT_E"))), _
      "<p><i class=S" & RS(MD & "_PAT_B") & "></i><i class=S" & RS(MD & "_PAT_E") & "></i></p>", "")
End Function

Function sHorse( RS As Object, CT As String, TP As String, MD As String ,Optional HighlightNumber As Integer? = Nothing, Optional IsEditMode As Boolean? = False) As String

  Dim Alerted as String = ""
  Dim JS As String = ""
  TP = CT & "-" & TP
	
	If HighlightNumber.HasValue() Then
		If HighlightNumber.Value.ToString() = RS("RUNNER_NO") Then
			Alerted = "<img src=""/img/exclamation.png""/>"
		End If
	End If

	
	If     InStr("AU-G NZ-G"          , TP) > 0 Then
		JS = "<SLK_AG='DG" & CByte(RS("RUNNER_NO")).ToString("00") & ".png'>"
	ElseIf  TP= "UK-G"  AndAlso Not IsDBNull(RS("BARRIER"))  Then 
		JS = "<SLK_UG='DG" & CByte(RS("BARRIER")).ToString("00") & ".png'>"
	'ElseIf InStr("AU-R AU-H NZ-H NZ-R", TP) > 0 AndAlso Not IsDBNull(RS("JERSEY")) Then
	ElseIf Not IsDBNull(RS("JERSEY")) Then
		JS = "<SLK_SR='" & RS("JERSEY") & "'>"
	End If
  
  Dim scratchingTimestamp as String = ""

  If Not IsDbNull(RS("SCR_TIMESTAMP")) Then
    scratchingTimestamp = DateTime.Parse(RS("SCR_TIMESTAMP")).ToString("dd/MM hh:mm:ss tt")
  End If 

  Dim Resp as String =  ""
  If IsEditMode = True then
	  Dim ScrClass = IIf(RS("SCR"), " scratched", "")
	  '' assign selected runner data items to html attribute for later use
	  Resp =  "<td class=""context-menu-one RI" & ScrClass &  
			IIf(RS("SCR"), If(RS("SCRATCH") = 2, " LS", (If(RS("SCRATCH") = 3, " MS", " S"))), " ") & 
			""" data-attrs=""" & RS("NAME").ToString.ToUpper & ":" &
			RS("MEETING_ID").ToString.ToUpper & ":" &
			RS("EVENT_NO").ToString.ToUpper & ":" &
			RS("RUNNER_NO").ToString.ToUpper & ":" &
			RS("TAB_PROP").ToString.ToUpper & 
			""">" 
	  Else
		Resp =  "<td class=""RI" & 
			IIf(RS("SCR"), If(RS("SCRATCH") = 2, " LS", (If(RS("SCRATCH") = 3, " MS", " S"))), " ") & """>" 
	  End If
  Return Resp & JS &    
		"<b>" & RS("NAME").ToString.ToUpper & "</b>"  & 
		IIf(sN0(RS("BARRIER")) = 0, "", " (" & RS("BARRIER") & ")")  &  Alerted &
		" " & scratchingTimestamp & 
		"<div>"  & 
		RS("JOCKEY").ToString.ToUpper  & 
		IIf(IsDBNull(RS("HANDICAP")), "", " (" & RS("HANDICAP") & ")")  & 
		IIf(IsDBNull(RS("JOCKEY")) Or IsDBNull(RS("TRAINER")), "", " - ")  & 
		RS("TRAINER").ToString.ToUpper  & 
		IIf(IsDBNull(RS("JOCKEY")) And IsDBNull(RS("TRAINER")), "NA", "")  &
		"</div>"  & 
		IIf(Session("LVL") < 2 And (Not IsDBNull(RS(MD & "_PAT_B")) Or Not IsDBNull(RS(MD & "_PAT_E"))), "<p><i class=S"  & 
			RS(MD & "_PAT_B")  & 
			"></i><i class=S"  & 
			RS(MD & "_PAT_E")  & 
			"></i></p>", "")
End Function

Function sPNL( x As Object, Optional p As Boolean = False ) As String
  If IsDBNull(x) OrElse x = 0 Then: Return "-"
  ElseIf x > 0 Then: Return "<span class=GR>$"  & FormatNumber( x, 0) & "</span>"
  ElseIf p     Then: Return "<span class=BL>$"  & FormatNumber(-x, 0) & "</span>"
  Else             : Return "<span class=RD>($" & FormatNumber(-x, 0) & ")</span>": End If
End Function

Function sINV( x As Object ) As String
  If Not IsDBNull(x) Then
    If     x > 0 Then: Return "<div class=INV>-" & FormatNumber( x, 0) & "</div>"
    ElseIf x < 0 Then: Return "<div class=INV>+" & FormatNumber(-x, 0) & "</div>": End If
  End If
End Function

Function sEXP( x As Double ) As String
  If x > 9.99 Then x = 9.99
  Return "<td class=""" & MIf(x < 1.06, "FF", x < 1.3, "PD", x < 1.6, "PE", "PF") & _
    IIf(x = 0, "", IIf(x >= 1.06, " GR", " RD")) & """>" & IIf(x = 0, "", sVar(x, "NUM", IIf(x >= 10, 1, 2)))
End Function

Function getNumberString(target as Object) as String

  If IsDbNull(target)
    Return Nothing
  End IF

  Return target
End Function

Function sDiv( x As Object, Optional y As Object = Nothing, Optional yH As Boolean = False ) As String
  Dim S As String = ""
  If Not IsDBNull(x) AndAlso Not Double.IsInfinity(x) Then
    x = IIf(Session("BASE") = 1, x, x * 5): If x > 999 Then x = 999
    S &= FormatNumber(x, MIf(x >= 100, 0, x >= 10, 1, 2))
  End If
  If Not IsNothing(y) AndAlso Not IsDBNull(y) AndAlso Not Double.IsInfinity(y) Then
    y = IIf(Session("BASE") = 1, y, y * 5): If y > 999 Then y = 999
    S &= IIf(S = "", "-", "") & "<div class=" & IIf(yH, "IVH", "INV") & ">" & _
      FormatNumber(y, MIf(y >= 100, 0, y >= 10, 1, 2)) & "</div>"
  End If: Return S
End Function

Function sDivX( x As Object ) As String
  If Not IsDBNull(x) AndAlso Not Double.IsInfinity(x) Then
    x = IIf(Session("BASE") = 1, 1 / x,  2 / x): If x > 99999 Then x = 99999
    Return FormatNumber(x, MIf(x >= 1000, 0, x >= 10, 1, 2))
  End If
End Function

Function generatePricingColumnTote(RS as Object, Tote as String,  PriceChanges as Dictionary(Of String, List(Of DataRow)),  CloseTime as String, Optional ScratchingsJavascript as String  = "[]")
    Dim PriceChange as List(Of DataRow) 
    Dim cssClass = ""
    PriceChange = GetPriceChangesForRunner(PriceChanges,RS("RUNNER_NO"))
     If CloseTime <> "" Then
      CloseTime = DateTime.Parse(CloseTime).ToString("s")
    End If
    
    Dim Html = "<td class=""" & cssClass & """  onmouseover=""drawPriceHistory(" & GetPriceChangeValueArray(PriceChange,Tote, "_TW") & "," & GetPriceChangeTimelineArray(PriceChange, Tote, "_TW") & "," & ScratchingsJavascript & ",this,'" & CloseTime & "')"" onmouseout=""gXX()"">" & sDiv(RS(Tote & "_TW"), RS(Tote & "_TP"))

    Return Html

End Function

Function sDivF( RS As Object, RP As DataRow, F As String, Optional G As String = "" , Optional PriceChanges as Dictionary(Of String, List(Of DataRow)) = Nothing, Optional ScratchingsJavascript as String  = "[]", Optional CloseTime as String = Nothing, Optional cssClass as String = Nothing, Optional ColumnPostFix as String = "_FW") As String
  Dim x As Object = RS(F & ColumnPostFix), S As String
  Dim y As Object 
  If RS.Table.Columns.Contains(F & "_FWF") then
    y = RS(F & "_FWF")
  End If

  If Not IsDBNull(x) AndAlso Not Double.IsInfinity(x) Then
    y = sN0(y): x = IIf(Session("BASE") = 1, x,  x * 5): If x > 999 Then x = 999


    Dim PriceChange as List(Of DataRow) 
    PriceChange = GetPriceChangesForRunner(PriceChanges, RS("RUNNER_NO"))
    
    If CloseTime <> "" Then
      CloseTime = DateTime.Parse(CloseTime).ToString("s")
    End If
    
    ' when SDP > xL1 should go red, 
    ' when >xB1, <xL 1 should go orange, 
    ' underline when firming inside last 5 mins
    ' = BOB has a blue dot
    ' =WOW has red dot '

    S = "<td class='FXD " & cssClass  & IIf(y > 0 And x < y, " FMR", "") & _
      IIf(x > 0 AndAlso x = sN0(RS("FX_BOB")), " BOB", "") & _
      IIf(x > 0 AndAlso x = sN0(RS("FX_WOW")), " WOW", "") & _
      IIf(x > 0 AndAlso sN0(RS("BFR_FW_L1")) > 0 AndAlso x >= sN0(RS("BFR_FW_L1")), " HL2", _
      IIf(x > 0 AndAlso sN0(RS("BFR_FW_B1")) > 0 AndAlso x >  sN0(RS("BFR_FW_B1")) AndAlso RP("BFR_MP_B1") < getENum("XB1_MKP"), " HL1", "")) & "'"
    If G <> "" AndAlso sNN(GetPriceChangeValueArray(PriceChange,F,ColumnPostFix)) Then S &= " onmouseover=""drawPriceHistory(" & GetPriceChangeValueArray(PriceChange,F,ColumnPostFix) & "," & GetPriceChangeTimelineArray(PriceChange, F,ColumnPostFix) & "," & ScratchingsJavascript & ",this,'" & CloseTime & "')"" onmouseout=""gXX()"""
    Return S & ">" & FormatNumber(x, MIf(x >= 100, 0, x >= 10, 1, 2))
  Else: Return "<td class='" & cssClass & "' >": End If
End Function

Function GetPriceChangesForRunners(PriceChanges as DataTable, PriceChangeDictionary as Dictionary(Of String, List(Of DataRow))) as Dictionary(Of String, List(Of DataRow))
  If PriceChanges Is Nothing Then
      Return PriceChangeDictionary
    End If

    For Each PriceChange in PriceChanges.Rows       
        PriceChangeDictionary(PriceChange("RUNNER_NO")).Add(PriceChange)      
    Next

    Return PriceChangeDictionary
End Function 

Function GetPriceChangesForRunner(PriceChanges As Dictionary(Of String, List(Of DataRow)), RunnerNumber as String) as List(Of DataRow)

    If PriceChanges Is Nothing Then
      Return Nothing
    End If

    If PriceChanges.ContainsKey(RunnerNumber) Then
      Return PriceChanges(RunnerNumber)
    End If

    Return Nothing
End Function

Function GetScratchings(RunnerRow As Object)
 return RunnerRow("SCR_TIMESTAMP")
End Function

Function GetPriceChangeValueArray(PriceChanges as List(Of DataRow), AgencyName as String, Optional ColumnPostFix as String = "_FW")
  

  Dim Changes As New List(Of String)
  If PriceChanges Is Nothing OrElse PriceChanges.Count = 0 Then
    Return "[]"
  End If

  For Each PriceChange in PriceChanges 
  
    Dim ColumnName as String = AgencyName & ColumnPostFix
    If PriceChange.Table.Columns.Contains(ColumnName) AndAlso Not IsDbNull(PriceChange(ColumnName)) Then
      Changes.Add(PriceChange(ColumnName))
    End If
  Next

  return String.Format("[{0}]",String.Join(",",Changes.ToArray()))
End Function

Function GetPriceChangeTimelineArray(PriceChanges as List(Of DataRow), AgencyName as String, Optional ColumnPostFix As String = "_FW")
  Dim Changes As New List(Of String)

  If PriceChanges Is Nothing Then
    Return "[]"
  End If

  For Each PriceChange in PriceChanges 
  
    Dim ColumnName as String = AgencyName & ColumnPostFix
    If PriceChange.Table.Columns.Contains(ColumnName) AndAlso Not IsDbNull(PriceChange(ColumnName)) Then
      Changes.Add("'" & DateTime.Parse(PriceChange("DATE_CREATED")).ToString("s") & "'")
    End If
  Next

  return String.Format("[{0}]",String.Join(",",Changes.ToArray()))
  
End Function

Function sEZDiv( x As Object ) As String
  If Not IsDBNull(x) AndAlso Not Double.IsInfinity(x) Then Return FormatNumber(x, IIf(x >= 100, 0, IIf(x >= 10, 1, 2))) Else Return "-"
End Function

Function sFxDiv( x As Object ) As String
  If Not IsDBNull(x) AndAlso Not Double.IsInfinity(x) Then
    x = Math.Floor(x * 100)
	
    If x = 0 Then : x = 0
    ElseIf x <= 101 Then : x = 101 
    ElseIf x <= 110 Then : x = x
    ElseIf x <=   130 Then: x -= (x Mod   2)
    ElseIf x <=   250 Then: x -= (x Mod   5)
    ElseIf x <=   270 Then: x -= (x Mod  10)
    ElseIf x <    275 Then: x = 270
    ElseIf x <    280 Then: x = 275
    ElseIf x <=   400 Then: x -= (x Mod  10)
    ElseIf x <=   500 Then: x -= (x Mod  20)
    ElseIf x <=  1000 Then: x -= (x Mod  50)
    ElseIf x <=  2100 Then: x -= (x Mod 100)
    ElseIf x <   2600 Then: x =  2100
    ElseIf x <   3100 Then: x =  2600
    ElseIf x <   4100 Then: x =  3100
    ElseIf x <   5100 Then: x =  4100
    ElseIf x <   6100 Then: x =  5100
    ElseIf x <   6700 Then: x =  6100
    ElseIf x <   8100 Then: x =  6700
    ElseIf x <  10100 Then: x =  8100
    ElseIf x <  15100 Then: x = 10100
    ElseIf x <  20100 Then: x = 15100
    ElseIf x <  25100 Then: x = 20100
    ElseIf x <  30100 Then: x = 25100
    ElseIf x <  33100 Then: x = 30100
    ElseIf x <  40100 Then: x = 33100
    ElseIf x <  50100 Then: x = 40100
    ElseIf x < 100100 Then: x = 50100
    Else:  x = 100100: End If
    x = IIf(Session("BASE") = 1, x, x * 5) / 100
    Return FormatNumber(x, IIf(x >= 100, 0, IIf(x >= 10, 1, 2)))
  Else: Return "": End If
End Function

Function sAmt( x As Double ) As String
  If Double.IsInfinity(x) Then Return "-"
  Return IIf(Session("BASE") = 1, "<u>$</u>" & FormatNumber(x, 0), FormatNumber(x / 5, 0))
End Function

Function sPrc( x As Object ) As String
  If IsDBNull(x) OrElse x = 0 Then Return "-"
  Return IIf(Session("BASE") = 1, X, FormatNumber(x / 20, 2))
End Function

Function sLmt( x As Integer ) As String
  Return IIf(Session("BASE") = 1, x, CSng(x) / 2)
End Function

Function sMkP( x As Double, Optional y As Integer = 0 ) As String
  Return "<td" & IIf(y > 0 And (x > 0 And Math.Round(x, 1) <> y), " class=HL", "") & ">" & IIf(x = 0, "<i class=NA>-</i>", FormatNumber(x, IIf(x > 999.9, 0, 1)))
End Function

Function sPulse( P As Byte, N As Byte, T As String ) As String
  If P = N Then Return "<td class=P" & N & ">" & T Else Return "<td>" & T
End Function


Function sTtP( x As Object, Optional y As Object = Nothing ) As String
  Dim W As String, P As String
  If IsDBNull(x) OrElse x = 0 Then: W = "<i class=NA>-</i>"
  ElseIf x >= 10000000 Then: W = FormatNumber(x / 1000000, 1) & "<u>m</u>"
  ElseIf x >= 1000000  Then: W = FormatNumber(x / 1000000, 2) & "<u>m</u>"
  ElseIf x >= 100000   Then: W = FormatNumber(x / 1000   , 0) & "<u>k</u>"
  ElseIf x >= 10000    Then: W = FormatNumber(x / 1000   , 1) & "<u>k</u>"
  Else W = FormatNumber(x, IIf(x < 10, 2, IIf(x < 100, 1, 0))): End If
  If IsNothing(y) OrElse IsDBNull(y) OrElse y = 0 Then
  ElseIf y >= 10000000 Then: P = FormatNumber(y / 1000000, 1) & "m"
  ElseIf y >= 1000000  Then: P = FormatNumber(y / 1000000, 2) & "m"
  ElseIf y >= 100000   Then: P = FormatNumber(y / 1000   , 0) & "k"
  ElseIf y >= 10000    Then: P = FormatNumber(y / 1000   , 1) & "k"
  Else P = FormatNumber(y, IIf(y < 10, 2, IIf(y < 100, 1, 0))): End If
  Return W & IIf(P = "", "", "<div class=INV>" & P & "</div>")
End Function


Function sTrdPM( x As String, ByRef DV As DataTable ) As String
  Dim R As String, C() As String, W As Boolean
  Dim S As String = "<table class=ODR><col width=28><col width=18><col><col><col width=30><col width=57>" & _
    "<tr class=HD><th>To<th>No<th>WIN<th>PLA<th>%<th>Limit"
  For Each R In Left(x, x.length - 1).Split(vbLf): C = R.Split(vbTab)
    S &= "<tr" & IIf(IsNothing(DV.Rows.Find({"W", C(1)})), IIf(IsNothing(DV.Rows.Find({"P", C(1)})), "", _
      " class=PCR"), " class=WNR") & ">" & IIf(C(0) = "BET", "<td class='CT BL'>Bet", "<td class='CT PK'>Eat") & _
      "<th class=CT>" & C(1) & "<td>" & IIf(C(2) = 0, "-", C(2)) & "<td>" & IIf(C(3) = 0, "-", C(3)) & "<td>" & C(4) & "<td class=CT>" & C(5)
  Next: Return S & "</table>"
End Function

Function sTrdFX( x As String ) As String
  Dim I As Integer, R As Object = x.Split(vbLf), C As Object
  Dim S As String = "<table class=ODR><col width=30><col width=22><col><col><col width=35>"
  For I = 0 To UBound(R) - 1: Try: C = R(I).Split(vbTab)
    S &= "<tr>" & IIf(C(0) = "BET", "<th class=BL>Bet", "<th class=PK>Eat") & _
      "<td><b>" & C(1) & "<td>" & IIf(C(2) = 0, "-", C(2)) & "<td>" & IIf(C(3) = 0, "-", C(3)) & "<td>" & C(4)
    Catch: S &= "<tr><td colspan=5><b class=OR>ERR!</b> [" & R(I).Replace(vbTab,"-") & "] " & Err.Description: End Try
  Next: Return S & "</table>"
End Function

Function sTrdEZ( x As String ) As String
  Dim I As Integer, R As Object = x.Split(vbLf), C As Object
  Dim S As String = "<table class=ODR><col width=55><col><col width=50>"
  For I = 0 To UBound(R) - 1: C = R(I).Split(vbTab)
    S &= "<tr>" & IIf(C(0) = "O", "<th class=BL>Odd", IIf(C(0) = "E", "<th class=GR>Even", "<th class=OR>Mixed")) & "<td>" & C(1) & "<td>" & C(2)
  Next: Return S & "</table>"
End Function


Function FormatEmpty( X As Object, Optional L As Byte = 2 ) As String
  If CStr(X) = "" Then: Return "": ElseIf CDbl(X) = 0 Then: Return "-": Else: Return FormatNumber(CDbl(X), L): End If
End Function

Function sTrdTL( x As String, p As Boolean, ByRef DV As DataTable, Optional CT As String = "AU" ) As String
  Dim R As String, C() As String, W As Boolean, S As New StringBuilder
  S.Append("<table class=ODR style=""margin-bottom:5px""><col width=25>" & _
    "<col width=35><col width=30><col width=60><col width=40><col width=70><col>" & _
    "<tr class=HD><th>No<th>Typ<th>Exp<th>Stake<th>Odds<th>Return<th>" & IIf(p, "Pool", "Sts"))
  For Each R In Left(x, x.length - 1).Split(vbLf)
    If Left(R, 1) <> "#" Then
      C = R.Split(vbTab): W = Not IsNothing(DV.Rows.Find({Left(C(2), 1),  C(0)  }))  ' IIf(CT = "US", Val(C(0)) \ 10, C(0))
      S.Append("<tr" & IIf(W, " class=" & IIf(C(2) = "WIN", "WNR", "PCR"), "") & "><th class=CT>" & sRNo(CT, C(0)) & _
        "<td class='CT " & IIf(C(2) = "WIN", "BL", "CN") & "'>" & C(2) & "<td>" & C(3) & _
        "<td>" & FormatEmpty(C(4), 1) & "<td>" & C(5) & "<td>" & FormatEmpty(C(6), 0) & "<td class=CT>" & C(9))
    Else: S.Append("<tr class=BN><th colspan=5>" & R & "<td colspan=2>" & getBatchDt(Mid(R, 2, 8)).ToString("HH:mm.ss")): End If
  Next: Return S.ToString & "</table>"
End Function


Function generateNewTradeTable( trades() As DataRow, jurisdiction as String, p As Boolean, ByRef DV As DataTable, Optional CT As String = "AU") As String
  Dim R As String, C() As String, W As Boolean, S As New StringBuilder
  S.Append("<table class=ODR style=""margin-bottom:5px""><col width=25>" & _
    "<col width=35><col width=30><col width=60><col width=40><col width=70><col>" & _
    "<tr class=HD><th>No<th>Typ<th>Exp<th>Stake<th>Odds<th>Return<th>" & IIf(p, "Pool", "Sts"))

 
 Dim rowBuilder as New StringBuilder
 Dim LastBatch as DateTime
 For Each trade in trades 
    Dim BetAmount = Decimal.Parse(trade("BET_AMOUNT"))
    Dim Price = Decimal.Parse(trade("EXPECTED_PRICE"))
    Dim Success = IIf(trade("SUCCESS") = "1", "ON", "OFF")
    Dim WinningBet = Not IsNothing(DV.Rows.Find({Left(trade("BET_TYPE"),1),trade("SELECTION_1")}))
    Dim paperStatus = ""
     If trade("PAPER_TRADE") = True Then
        paperStatus  = " (PAPER)"
        Success = "PAPER"
     End If

     If trade("JURISDICTION") <> jurisdiction Or trade("BET_TYPE") <> "Win"  Then
       Continue For
     End If
     If trade("DATE_CREATED") <>  LastBatch  Then
        S.Append("<tr class=BN><th colspan=5>" & trade("SOURCE") & paperStatus & "<td colspan=2>" & DateTime.Parse(trade("DATE_CREATED")).ToString("HH:mm.ss"))
        LastBatch  = trade("DATE_CREATED")
      End If
     

          S.Append("<tr" & IIf(WinningBet, " class=" & IIf(trade("BET_TYPE") = "Win", "WNR", "PCR"), "") & "><th class=CT>" & sRNo(CT, trade("SELECTION_1")) & _
        "<td class='CT " & IIf(trade("BET_TYPE") = "Win", "BL", "CN") & "'>" & trade("BET_TYPE") & "<td>" & trade("EXPECTATION") & _
        "<td>" & FormatEmpty(trade("BET_AMOUNT"), 1) & "<td>" & trade("EXPECTED_PRICE") & "<td>" & FormatEmpty(BetAmount * Price, 0) & "<td class=CT>" & Success)   

 Next
  
  Return S.ToString & "</table>"

End Function

Function generateExoticTradeTable(trades() as DataRow, jurisdiction as String, ByRef DV as DataTable)

  
  Dim I As Integer, R As String, C() As String, G As String, W As DataRow, S As New StringBuilder

  Dim currentBatch as string
  Dim currentTrader as string
  Dim currentBetType as String

  S.Append("<table class=ODR><col width=80><col width=35><col width=50><col width=40><col width=50><col>" & _
      "<tr class=HD><th>Bets<th>Typ<th>Stake<th>Exp<th>CLRB &cent;<th>Sts")


  For Each trade in trades 
      If trade("JURISDICTION") <> jurisdiction
        Continue For
      End If

      Dim tradeTime = DateTime.Parse(trade("DATE_CREATED")).ToString("HH:mm.ss")
      If currentBatch <> tradeTime Then
        currentBatch  = tradeTime
        currentTrader = trade("SOURCE")
        S.Append("<tr class=BN><th colspan=6>" & currentTrader  & " " & currentBatch)
      End If

      Dim BetAmount = Decimal.Parse(trade("BET_AMOUNT"))
      Dim Price = Decimal.Parse(trade("EXPECTED_PRICE"))
      Dim Success = IIf(trade("SUCCESS") = "1", "ON", "OFF")
      Dim WinningBet = Not IsNothing(DV.Rows.Find({Left(trade("BET_TYPE"),1),trade("SELECTION_1")}))
      Dim WinningBetRow = DV.Rows.Find({Left(trade("BET_TYPE"),1),trade("SELECTION_1")})
      Dim tradeBetType = codifyBetType(trade("BET_TYPE"))
      Dim Expectation = trade("EXPECTATION")
      Dim tradeReturn = trade("RETURN")
      Dim Rebate = trade("REBATE")

      If trade("PAPER_TRADE") = "1" Then
        Success = "PAPER"
      End If

      If currentBetType <> tradeBetType Then
        S.Append("<tr height=5>")
        currentBetType = tradeBetType
      End If

      If Not WinningBet Then
         S.Append("<tr><th class=CT>" & trade("SELECTION_1") & _
           "<td class='CT " & getBetTypeCssClass(trade("BET_TYPE")) & "'>" & tradeBetType & _
           "<td>" & BetAmount & "<td>" & FormatNumber(Expectation) & "<td>" & FormatEmpty(Rebate) & "<td class=CT>" & Success)
      Else
          S.Append("<tr class=WNR><th class=CT>" & trade("SELECTION_1") & _
            "<td class='CT " & getBetTypeCssClass(trade("BET_TYPE")) & "'>" & tradeBetType & _
            "<td>" & BetAmount & "<td class=RD>" & FormatNumber(Expectation) & "<td>" & sPNL(tradeReturn) & "<td class=CT>" & Success)
      End If
  Next

    Return S.ToString & "</table>"
End Function

Function codifyBetType(betType as String) as String
  Select Case  betType 
    Case "Quinella"
      Return "QIN"
    Case "Trifecta"
      Return "TRF"
    Case "Exacta"
      Return "XCT"    
    Case Else
      Return betType
    End Select
End Function

Function getBetTypeCssClass(betType as String) as String
 Select Case  betType 
    Case "Quinella"
      Return "BL"
    Case "Trifecta"
      Return "GR"
    Case "Exacta"
      Return "PK"
    Case "Duet"
      Return "CN"
    Case Else
      Return betType
    End Select
End Function

Function getTradesByJurisdiction(trades as DataTable) as Dictionary(Of String, Integer)
  Dim result as New Dictionary(Of String, Integer)
  For Each trade in trades.Rows 
    Dim jurisdiction = trade("JURISDICTION")

    If Not result.ContainsKey(jurisdiction) Then
      result(jurisdiction) = 0
    End If

    result(jurisdiction) = result(jurisdiction) + 1
  Next

  return result
End Function

Function sTrdXT( x As String, ByRef DV As DataTable, TB As String, Optional CT As String = "AU" ) As String
  Dim I As Integer, R As String, C() As String, G As String, W As DataRow, S As New StringBuilder
  S.Append("<table class=ODR><col width=80><col width=35><col width=50><col width=40><col width=50><col>" & _
    "<tr class=HD><th>Bets<th>Typ<th>Stake<th>Exp<th>CLRB &cent;<th>Sts")
  For Each R In Left(x, x.length - 1).Split(vbLf)
    If Left(R, 1) <> "#" Then
      C = R.Split(vbTab): W = DV.Rows.Find({Left(C(1), 1), C(0)})
      If G <> C(1) Then: If G <> "" Then: S.Append("<tr height=5>"): End If: G = C(1): End If
      If IsNothing(W) Then
        S.Append("<tr><th class=CT>" & C(0) & _
          "<td class='CT " & ICase(Left(C(1),1), "X","PK", "Q","BL", "D","CN", "T","GR", "F","PR") & "'>" & C(1) & _
          "<td>" & C(3) & "<td>" & C(2) & "<td>" & FormatEmpty(C(4)) & "<td class=CT>" & C(5))
      Else
        S.Append("<tr class=WNR><th class=CT>" & C(0) & _
          "<td class='CT " & ICase(Left(C(1),1), "X","PK", "Q","BL", "D","CN", "T","GR", "F","PR") & "'>" & C(1) & _
          "<td>" & C(3) & "<td class=RD>" & sDiv(W(TB)) & "<td>" & sPNL(Val(C(3)) * sN0(W(TB))) & "<td class=CT>" & C(5))
      End If
    Else: S.Append("<tr class=BN><th colspan=4>" & R & "<td colspan=2>" & getBatchDt(Mid(R, 2, 8)).ToString("HH:mm.ss")): G = "": End If
  Next: Return S.ToString & "</table>"
End Function

Function sTrdCB( x As Object ) As String
  If IsDBNull(x) Then Return ""
  Dim S As String = "", I As Byte = 0
  For Each R As String In x.Split("~"): If R <> "" Then
    If Val(R.Split("|")(2)) > 0 Then: S &= "~" & R: I += 1: If I > 10 Then: Exit For: End If: End If
  End If: Next: Return Mid(S, 2)
End Function



'Creates Feed status indicator lights
Function FSI_Check()
        Dim FSI_HTML As String = ""
        'Dim S As String = "select LX_SYS , DATEDIFF (minute,TS, GETDATE()) AS TSDIFF from SYS_STATUS WHERE DATEDIFF (minute,TS, GETDATE()) > 1"
		Dim S As String = "EXEC sp_DF_GetStatus"

        Using FSIstsVals As DataTable = makeDataSet(S).Tables(0)
            For Each DR As DataRow In FSIstsVals.Rows
                Dim FSItxt As String, FSItitle As String, FSIcolor as string = "RED"

                Select Case DR("LX_SYS")
                    Case "DRO1"
                        FSItxt = "D1" : FSItitle = "DRO sub 3Hr"
                    Case "DRO2"
                        If DR("TSDIFF") < 10 Then Continue For
                        FSItxt = "D2" : FSItitle = "DRO 3Hr+"
                    Case "WIFT"
                        FSItxt = "W" : FSItitle = "WIFT"
						If DR("Status") = "SnapShot" AndAlso DR("TSDIFF") < 2 Then
                            FSIcolor = "ORANGE" : FSItitle = "WIFT Restarting"
                        End If
                    Case "LXP1"
                        FSItxt = "X1" : FSItitle = "SDP Gen"
                    Case "LXP2"
						If DR("TSDIFF") < 3 Then Continue For
                        FSItxt = "X2" : FSItitle = "SDP Gen 3hr+"
                    Case "BFR"
                        FSItxt = "BF" : FSItitle = "Betfair"
                    Case "WISE"
						If DR("TSDIFF") < 5 Then Continue For
                        FSItxt = "WP" : FSItitle = "Lux Betstream"
                    Case "DVP"
                        FSItxt = "DV" : FSItitle = "LUX DVP"
                    Case "LSP"
                        FSItxt = "LS" : FSItitle = "Lsports"
					Case "SHA"
                       FSItxt = "SH" : FSItitle = "TAB SHA"
					Case "SUNWISE"
                       FSItxt = "SB" : FSItitle = "SUN Betstream"
					Case "SUN"
                       FSItxt = "SUN" : FSItitle = "SUN DVP"
					Case "TABDVP"
                       FSItxt = "TAB" : FSItitle = "TAB DVP"
					Case "PPG"
                        FSItxt = "PPG" : FSItitle = "PPG Odds"
          Case "TOP_SPORTS"
                        FSItxt = "TOP" : FSItitle = "TopSports"
          Case "TRADER"
                        FSItxt = "TRD" : FSItitle = "Auto Trader"
          Case "PAA"
                        If (DateTime.Now.Hour >= 17 Or DateTime.Now.Hour <= 9) and DR("TSDIFF") > 15 Then
							FSItxt = "PA" : FSItitle = "PA UK"
							If DateTime.Now.Hour = 17 Or DateTime.Now.Hour = 9 Then FSIcolor = "ORANGE"
						Else
							Continue For
						End If
          Case "TRUSS"
                        FSItxt = "TRS" : FSItitle = "Truss (UBet/QLD Totes)"
					Case Else

                        FSItxt = "?" : FSItitle = DR("LX_SYS") : FSIcolor = "ORANGE"
                End Select

                FSI_HTML += "<Button title = """ & FSItitle & """ style=""background-color:" & FSIcolor & ";"" runat=""server"" disabled>" & FSItxt & "</Button> "
            Next
        End Using

        Return FSI_HTML
End Function


'-----------------------------DYNAMIC COLUMN LAYOUT------------
'Available Col codes are defined in SYS_CODE table (Type = MKR_COL)
'Load user column layout 
Function CheckColLayout(Id As String)  As String()

		Dim Cols() as string = GetColList(Id) 
		Session("PriceCols") = Cols
		return Cols

End Function

'Read User defined price column layout from DB
Function GetColList(Id As String) As String()

	Dim DBColList As DataRow = getDataRow("SELECT  TOP(1) *  FROM ( SELECT * FROM TRADER_LAYOUT WHERE LID = '" & Id & "' UNION SELECT * FROM TRADER_LAYOUT WHERE LID = 'LUXBET' ) Q1")
	Dim ColList As New ArrayList

	For DBcolCnt = 1 To DBColList.ItemArray.Count - 1
		If Not IsDBNull(DBColList.Item(DBcolCnt)) Then
			ColList.Add(DBColList.Item(DBcolCnt))
		End If
	Next

	Dim Colstr(ColList.Count - 1) As String
	ColList.CopyTo(Colstr, 0)

	Return Colstr
End Function

'Set number of Dynamic cols
Function usrNumCols(ColList() As String) As String
	Dim colHTML As String = ""

	Dim ColCnt As Integer = ColList.Length + 1 
    colHTML = "<colgroup span=" & ColCnt & "></colgroup>"

	Return colHTML
End Function

'Column Header HTML - Sets col title & Image
Function UsrColHeader(ColList() As String,Country as String) As String

    Dim paCountries as String() = { "UK", "IR", "ZA"}
        Dim headerHTML As String = ""
        Dim count as Integer = 0
        For Each Col As String In ColList
          '  Dim cssClass =  IIf(count Mod 2 = 1, "style=""background:-webkit-linear-gradient(#ddd, #fff); color: #000;""", "style=""background:-webkit-linear-gradient(#a6a6a6, #f2f2f2); color: #000;""")
          Dim cssClass = ""
            Dim Img As String = Col
            If ("xB1 xL1 VWM TMC LPT").Contains(Col) Then Img = "betfair"
            If ("RDBL vTRF vQIN vXCT").Contains(Col) Then Img = "TAB"
			if Col = "SDP" Then Img = "DVP": Col = "LUX<br>SDP"
      if Col = "RAW_SDP" Then Img = "DVP": Col = "Raw<br>SDP"
			if Col = "TAB" Then  Col = "TAB<br>SDP"
			if Col = "SUN" Then  Col = "SUN<br>SDP"
      if Col = "APN" AndAlso paCountries.Contains(Country) Then Col = "PA" : Img = "PA"

			if Col = "VIC" Then  Col = "TABFO" ':cssClass = "style='background:#008542;'"
            Img = "<img src='/img/" & Img & ".png'>"

			'No col image
            If ("AUS BLK").Contains(Col) Then Img = ""
      if Col = "CTI" Then Col = "RTG" : Img = ""
      if Col = "CTI_EAT" Then Col ="RTG<br>Eat" : Img = ""
      if Col = "CTI_BET" Then Col ="RTG<br>Bet" : Img = "" 
			if Col = "BLK" Then Col = "-"
      if Col = "LUX_ROLL" Then Col = "Lux<br>SDP<br>Rolls" : Img = ""
      if Col = "TAB_ROLL" Then Col = "TAB<br>SDP<br>Rolls" : Img = ""
      if Col = "SUN_ROLL" Then Col = "SUN<br>SDP<br>Rolls" : Img = ""
      if Col = "SDP_MIN_LUX" Then Col = "Lux<br>SDP<br>Min" : Img = ""
      if Col = "SDP_MAX_LUX" Then Col = "Lux<br>SDP<br>Max" : Img = ""
      if Col = "SDP_MIN_TAB" Then Col = "TAB<br>SDP<br>Min" : Img = ""
      if Col = "SDP_MAX_TAB" Then Col = "TAB<br>SDP<br>Max" : Img = ""
      if Col = "SDP_MIN_SUN" Then Col = "SUN<br>SDP<br>Min" : Img = ""
      if Col = "SDP_MAX_SUN" Then Col = "SUN<br>SDP<br>Max" : Img = ""
      if Col = "SDP_MIN_MASTER" Then Col = "Master<br>SDP<br>Min" : Img = ""
      if Col = "SDP_MAX_MASTER" Then Col = "Master<br>SDP<br>Max" : Img = ""
      if Col = "LUX_SDP_PLACE" Then Col = "LUX<br>Place<br>SDP" : Img = "" 
      if Col = "SUN_SDP_PLACE" Then Col = "SUN<br>Place<br>SDP" : Img = ""
      if Col = "TAB_SDP_PLACE" Then Col = "TAB<br>Place<br>SDP" : Img = ""
      if Col = "LUX_PLACE_ROLL" Then Col = "LUX<br>Place<br>Rolls" : Img = ""
      if Col = "TAB_PLACE_ROLL" Then Col = "TAB<br>Place<br>Rolls" : Img = ""
      if Col = "SUN_PLACE_ROLL" Then Col = "SUN<br>Place<br>Rolls" : Img = ""
      if Col = "MASTER_PLACE_ROLL" Then Col = "Master<br>Place<br>Rolls" : Img = ""
      if Col = "MASTER_ROLL" Then Col = "Master<br>Rolls" : Img = ""
      if Col = "SDP_MIN_MASTER" Then Col = "Master<br>SDP<br>Min" : Img = ""
      if Col = "SDP_MAX_MASTER" Then Col = "Master<br>SDP<br>Max" : Img = ""
            headerHTML &= "<th " & cssClass & ">" & Img & "<br>" & Col & vbCrLf

          count = count + 1
        Next

        Return headerHTML
End Function

'Price column HTML
Function UsrPriceCols(ColList() As String , RS As Object, RP As DataRow, PriceChangeDictionary as  Dictionary(Of String, List(Of DataRow)) , ScratchingJavascript as String, CloseTime as String, CT as string, SCR as Boolean)  As String
	Dim PriceCols As String = ""
	Dim count as Integer = 9			' first 9 columns
	For Each Col As String In ColList
        'Dim cssClass =  IIf(count Mod 2 = 0, "odd", "even")
        Dim cssClass = ""
        Select Case Col
            Case "APN"
				PriceCols &= If(CT = "AU", sDivF(RS, RP, "APN", "AP", PriceChangeDictionary,ScratchingJavascript,CloseTime,cssClass)   ,  sDivF(RS, RP, "PAA", "AP", PriceChangeDictionary,ScratchingJavascript,CloseTime, cssClass)) 
			Case "LXB", "QLD", "VIC", "B1Y", "LAD", "IAS", "SPB", "UNI", "TOP", "EZY" , "NZL", "CTI"
				if Col = "VIC" Then  cssClass = cssClass & " TAB"
				PriceCols &= sDivF(RS, RP, Col, "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,cssClass)
            Case "CTI"
                PriceCols &= sDivF(RS, RP, Col, "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"bold") 
            Case "xB1"
                PriceCols &= "<td class=""BET " & cssClass & """>" & sDiv(RS("BFR_FW_B1")) & GenerateSubscript(RS, "BFR_FP_B1", true)
            Case "xL1"
                PriceCols &= "<td class=""EAT " & cssClass & """>" & sDiv(RS("BFR_FW_L1")) & GenerateSubscript(RS, "BFR_FP_L1", true)

            Case "VWM"
                PriceCols &= "<td class=""" & cssClass & """><b>" & sDiv(RS("BFR_WAP"))
            Case "TMC", "LPT"
                PriceCols &= "<td class=""" & cssClass & """>" & sTtP(RS("BFR_" & Col)) & GenerateSubscript(RS, "BFR_" & Col & "_FP", true)
            Case "AUS"
               PriceCols &= "<td class=""FV " & cssClass & """>" & sDiv(RS("AUS_TW"))
            Case "STAB", "NSW", "QLDT"
                Col = If(Col = "STAB", "VIC", Col)
                Col = If(Col = "QLDT", "QLD", Col)

                PriceCols &= generatePricingColumnTote(RS,Col, PriceChangeDictionary, CloseTime, ScratchingJavascript) 

            Case "RDBL"
                PriceCols &= "<td  class='FV " & cssClass & "' " & If(IsDBNull(RS("RDB_HIST")), "", XTgraph(RS("RDB_HIST"))) & ">" & sDiv(RS("RDB_TW"))
            Case "vTRF", "vQIN", "vXCT"
                Col = Col.Substring(0, 2)
                PriceCols &= "<td class=""FV "  & cssClass & """ " & If(IsDBNull(RS("HST_" & Col & "H")), "", XTgraph(RS("HST_" & Col & "H"))) & ">" & sDiv(RS("HST_" & Col))
			Case "SDP"				
         PriceCols &= sDivF(RS, RP, "LUX_SDP", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "") 
      Case "RAW_SDP"
         PriceCols &= sDivF(RS, RP, "SDP", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "") 
			Case "DVP"
				PriceCols &= "<td class='" & cssClass & "''><b>" & If (Session("LVL") = 10,"" , sFxDiv(RS("PM_DPP"))) & "</b><div class=SML>" & If (Session("LVL") = 10,"" ,sFxDiv(RS("PM_DVP"))) & "</div>"
      
			Case "TAB"
				PriceCols &= sDivF(RS, RP, Col & "_SDP", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "") 
      Case "SUN"
        PriceCols &= sDivF(RS, RP, Col & "_SDP", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "") & GenerateSubscript(RS, Col & "_SDP_ORIGINAL", true)
			Case "BLK"
                PriceCols &= "<td class='" & cssClass & "''>"
      Case "CTI_BET"
              PriceCols &= "<td class='" & cssClass & "''>" & sDiv(RS("CTI_BET"))
      Case "CTI_EAT"
              PriceCols &= "<td class='" & cssClass & "''>" & sDiv(RS("CTI_EAT"))
      Case "LUX_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "SDP_ADJ") & "</td>"
      Case "SUN_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "SDP_ADJ_SUN") & "</td>"
      Case "MASTER_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "SDP_ADJ_MASTER") & "</td>"            
      Case "TAB_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "SDP_ADJ_TAB") & "</td>"
      Case "SDP_MAX_LUX"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MAX", "Max") & "</td>"
      Case "SDP_MIN_LUX"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MIN", "Min") & "</td>"
      Case "SDP_MAX_MASTER"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MAX_MASTER", "Max") & "</td>"
      Case "SDP_MIN_MASTER"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MIN_MASTER", "Min") & "</td>"
      Case "SDP_MAX_SUN"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MAX_SUN", "Max") & "</td>"
      Case "SDP_MIN_SUN"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MIN_SUN", "Min") & "</td>"
      Case "SDP_MAX_TAB"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MAX_TAB", "Max") & "</td>"
      Case "SDP_MIN_TAB"
          PriceCols &= "<td class='" & cssClass & "''>" & GenerateSdpBoundaryTextbox(RS, "SDP_MIN_TAB", "Min") & "</td>"         
      Case "LUX_SDP_PLACE"
          PriceCols &= sDivF(RS, RP, "LUX_SDP_PLACE", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "")
      Case "SUN_SDP_PLACE"
          PriceCols &= sDivF(RS, RP, "SUN_SDP_PLACE", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "") 
      Case "TAB_SDP_PLACE"
          PriceCols &= sDivF(RS, RP, "TAB_SDP_PLACE", "TB", PriceChangeDictionary,ScratchingJavascript,CloseTime,"luxbook-grey bold", "")   
      Case "LUX_PLACE_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "PLACE_SDP_ADJ_LUX") & "</td>"
    Case "SUN_PLACE_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "PLACE_SDP_ADJ_SUN") & "</td>"            
      Case "TAB_PLACE_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "PLACE_SDP_ADJ_TAB") & "</td>"
      Case "MASTER_PLACE_ROLL"
            PriceCols &= "<td class='" & cssClass & "''>" & GenerateRollDropdown(RS, "PLACE_SDP_ADJ_MASTER") & "</td>"
			Case Else
			    PriceCols &= "<td class='" & cssClass & "''>"
        End Select

      count = count + 1
	Next

	If Not SCR then
		Return PriceCols
	End If
	Return "<td class=scrCols colspan='" & count & "'>&nbsp;</td>"

End Function

Function GenerateSubscript(runnerRow as Object, columnName as String, showIfPresent as Boolean) as String
  Dim price = runnerRow(columnName)

  If showIfPresent AndAlso (IsDbNull(price) )
      Return ""
  End If

  return String.Format("<div class='INV'>{0}</div>", price)
End Function

Function GenerateSdpBoundaryTextbox(runnerRow as Object, boundaryColumn as String, placeholder as String) as String
  Dim result as New StringBuilder

  result.AppendFormat("<input type='text' value='{0}' placeholder='" & placeholder & "' onfocus='pauseTimer();'  onblur=""updateBoundary(this,{1},{2},{3}, '{4}');getEVN(curVNL); resumeTimer();"" />", runnerRow(boundaryColumn), runnerRow("MEETING_ID"), runnerRow("EVENT_NO"), runnerRow("RUNNER_NO"), boundaryColumn)

  Return result.ToString()

End Function

Function GenerateRollDropdown(runnerRow as Object, rollColumn as string) as String

  Dim result as New StringBuilder
  Dim selectedColor = GetRollBackgroundColour(runnerRow(rollColumn))

  result.AppendFormat("<select  onfocus='pauseTimer();' onchange=""updateRoll(this,'{0}',{1},{2},{3}); getEVN(curVNL); resumeTimer();"" style=' "& selectedColor & "'>", rollColumn, runnerRow("MEETING_ID"), runnerRow("EVENT_NO"), runnerRow("RUNNER_NO"))

  For roll as Integer = -5 to 5
    Dim background = GetRollBackgroundColour(roll)
    If runnerRow(rollColumn) = roll.ToString() Then
      result.AppendFormat("<option value='{0}' selected='selected' style='background-color: white; color: black;'>{0}</option>", roll)
    Else 
      result.AppendFormat("<option value='{0}' style='background-color: white; color: black;'>{0}</option>", roll)
    End If
  Next


  result.append("</select>")

  return result.ToString()


End Function

Function GetRollBackgroundColour(roll as Integer) as String
    Select Case roll
      Case 2
        Return "background-color:#FAAC58; color:black;"
      Case 3, 4,  5
        Return "background-color:#FE2E64; color:white;"
      Case 1
        Return "background-color:#ffff99; color:black;"
      Case -1
        Return "background-color:#6a7787; color:white;"
      Case -2
        Return "background-color:#6A5ACD; color:white;"
      Case -3, -4 , -5
        Return "background-color:#8A2BE2; color:white;"
      Case Else
        Return "background-color: white; color:black;"      
    End Select
  
End Function

'Column market% total. I values links to MktPerc array in PM1
Function ColMktPer(ColList() As String, MktPer() As Double) As String
	Dim MktPHTML As String = ""

	For Each Col As String In ColList
		Dim I As Byte

		Select Case Col
			Case "APN" : I = 4		'Incs APN & PAA
			Case "LXB" : I = 5
			Case "QLD" : I = 6
			Case "B1Y" : I = 7
			Case "LAD" : I = 8
			Case "IAS" : I = 9
			Case "SPB" : I = 10
			Case "UNI" : I = 11
			Case "TOP" : I = 12
			Case "EZY" : I = 13
			Case "NZL" : I = 31

			Case "VIC" : I = 19

			Case "xB1" : I = 15
			Case "xL1" : I = 16
			Case "VWM" : I = 17

			Case "STAB" : I = 20
			Case "NSW" : I = 21
			Case "QLDT" : I = 22

			Case "AUS" : I = 23
			Case "RDBL" : I = 24


			Case "vTRF" : I = 25
			Case "vQIN" : I = 26
			Case "vXCT" : I = 27
			
			Case "SDP" : I = 28
			Case "DVP" : I = 29
			Case "SUN" : I = 14	
			Case "TAB" : I = 18
      Case "LUX_ROLL" : I = 32
      CASE "TAB_ROLL" : I = 33
      CASE "LUX_SDP_PLACE" : I = 35
      CASE "SUN_SDP_PLACE" : I = 36
      CASE "TAB_SDP_PLACE" : I = 37
			Case Else
				MktPHTML &= "<td>"
				Continue For
		End Select

		MktPHTML &= sMkP(MktPer(I))
	Next

	Return MktPHTML
End Function

'column Pool size value
Function ColPools(ColList() As String, RV As DataRow, CT As String,MktPer() As Double ) As String

	Dim PoolHTML As String = ""


	For Each Col As String In ColList
		Select Case Col

                Case "TMC" : PoolHTML &= "<td>" & sTtP(RV("BFR_MW"))
                Case "STAB" : PoolHTML &= "<td>" & sTtP(RV("VIC_PW"), RV("VIC_PP"))
                Case "QLDT" : PoolHTML &= "<td>" & sTtP(RV("QLD_PW"), RV("QLD_PP"))

                Case "AUS" : PoolHTML &= "<td>" & sTtP(RV("AUS_PW"))
                Case "RDBL" : PoolHTML &= "<td>" & sTtP(RV("RDB_PW"))
                Case "NSW" : PoolHTML &= "<td>" & sTtP(RV("NSW_PW"), RV("NSW_PP"))

                Case "vTRF" : PoolHTML &= "<td>" & sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PT"))
                Case "vQIN" : PoolHTML &= "<td>" & sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PQ"))
                Case "vXCT" : PoolHTML &= "<td>" & sTtP(RV(IIf(CT = "AU", "NSW", "VIC") & "_PX"))
                Case "SDP"  : PoolHTML &= sMkP(MktPer(34))
			Case Else
				PoolHTML &= "<td>"
				Continue For
		End Select
	Next

	Return PoolHTML
End Function

'Popup graph used on Exotics
Function XTgraph (Hist as string )
	
	If sNN(Hist)  Then 
		Return " onmouseover=""gVT([" & Replace(HIST, "|", ",") & "],this)"" onmouseout=""gXX()"""
	Else
		Return ""
	End If
	
End Function
'----------------------------------------------------


Function PlacePayDropdown(eventData as DataRow, productName as String) as String
  Dim html = "<select id='pays_place_{1}' onfocus='pauseTimer();'  onblur=""updatePlacePays(this,{2},{3},'{1}');getEVN(curVNL); resumeTimer();""><option></option>{0}</select>"

  Dim optionList = ""


  Dim selection = eventData(productName & "_PLACE_PAYS")

  If IsDbNull(selection) Then
    selection = "0"
  End If

  For I = 2 To 3
      If selection = I.ToString()
        optionList &= String.Format("<option selected>{0}</option>", I)
      Else
        optionList &= String.Format("<option>{0}</option>", I)
      End If
  Next

  return String.Format(html, optionList,productName, eventData("MEETING_ID"), eventData("EVENT_NO"))

End Function
</script>