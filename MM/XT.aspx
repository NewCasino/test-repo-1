<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim EV As Object, VM As Boolean, QRx As DataTable
Dim XCT As DataTable, QIN As DataTable, QPL As DataTable
Dim TRF As DataTable, TRO As DataTable, FFR As DataTable
Dim TM As DateTime = Now

Sub Page_Load()
  Response.CacheControl = "no-cache"
  chkSession()
  Dim CM As String = Request("FCMD"): EV = Secure("EV", 20): VM = (Request("VM") <> "")
  If Session("QLD_CLONE") = "" Then Session("QLD_CLONE") = "QLD"

  If EV <> "" Then
    Dim VN As DataRow = makeDataSet("SELECT COUNTRY, TYPE FROM MEETING(nolock) WHERE MEETING_ID=" & Split(EV, "_")(0)).Tables(0).Rows(0)
  End If

  '-- Command Buttons Handling --------------------------------------------------------------------
  If CM <> "" And EV <> "" Then
    EV = Split(EV, "_"): Dim WC As String = " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)
    Select Case CM

    Case "Save"
      Dim S As String = "", N As Byte
      Dim CT As String = getResult("SELECT COUNTRY FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
      Dim RS As Object = getRecord("SELECT RUNNER_NO FROM RUNNER(nolock)" & WC & " AND SCR=0") ' & IIf("US,SE".Contains(CT), " AND RUNNER_NO % 10=0", ""))
      While RS.Read(): N = RS(0)
        S &= "UPDATE RUNNER SET" & _
          "  COMMENT=" & chkRN("COMMENT_" & N) & _
          ", XT_WIN="  & chkR9("XT_WIN_" & N) & ", XT_ORG=COALESCE(" & IIf(Request("UPD_OGN") = 1, "", "XT_ORG,") & chkR9("XT_WIN_" & N) & ",0)" & _
          WC & " AND  RUNNER_NO=" & N & vbLf '" & IIf("US,SE".Contains(CT), "RUNNER_NO/10=" & N/10, "RUNNER_NO=" & N) & vbLf
      End While: RS.Close()

      S &= "UPDATE EVENT SET XMD_USE='Input'" & WC & vbLf
      execSQL(S)


    Case "e VWM"     : execSQL("UPDATE RUNNER SET XT_WIN=BFR_WAP" & WC & vbLf &  "UPDATE EVENT SET XMD_USE='VWM'"    & WC)
    Case "e Clear"   : execSQL("UPDATE RUNNER SET XT_WIN=NULL, XT_PLA=NULL" & WC & vbLf & "UPDATE EVENT SET XMD_USE='Clear'" & WC)
    Case "e Origin"  : execSQL("UPDATE RUNNER SET XT_WIN=XT_ORG"  & WC & vbLf &  "UPDATE EVENT SET XMD_USE='Origin'" & WC)
    Case "e Mix 1"   : hybridMix("HMX_XT", "XT_WIN", 100, EV(0), EV(1)): execSQL("UPDATE EVENT SET XMD_USE='Mix 1'"  & WC)
    Case "e fMdl"    : execSQL("UPDATE RUNNER SET XT_WIN=PM_WIN"  & WC & vbLf &  "UPDATE EVENT SET XMD_USE='fModel'" & WC)
    Case "e RDbl"    : execSQL("UPDATE RUNNER SET XT_WIN=RDB_TW"  & WC & vbLf &  "UPDATE EVENT SET XMD_USE='RDbl'"   & WC)


    Case "Update Changes":
      execSQL("UPDATE EVENT SET" & _
        "  HMX_XTT1=" & chkR9("HMX_XTT1") & ", HMX_XTP1=" & chkR9("HMX_XTP1") & _
        ", HMX_XTT2=" & chkR9("HMX_XTT2") & ", HMX_XTP2=" & chkR9("HMX_XTP2") & _
        ", HMX_XTT3=" & chkR9("HMX_XTT3") & ", HMX_XTP3=" & chkR9("HMX_XTP3") & WC)
      Session("QLD_CLONE") = Request.Form("FCLN")

    End Select
    If CM = "Save" Or Left(CM, 2) = "e " Then: CalcPLA(EV(0), EV(1), "XT", 1.00): _CalcExotics(EV(0), EV(1)): End If
    Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>"): Response.End
  End If

  chkEvent(EV): MTG.EventID = EV: EV = Split(EV, "_")

  If IsNothing(Cache("QRx" & "_" & EV(0) & "_" & EV(1))) Then _CalcExotics(EV(0), EV(1))  'Trig QR price for Autotrade
  
  '-- Trade Buttons Handling ----------------------------------------------------------------------
  CalcExotics(EV(0), EV(1))
  If Request("FTRD") <> "" Then: CM = Request("FTRD")
    Dim TA As Boolean = (CM = "Trade ALL"), T As String, N As String, S As String = ""
    Dim RM As DataRow = getDataRow("SELECT COUNTRY, TYPE, BTK_ID, QLD_ID FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
    Dim RV As DataRow = getDataRow("SELECT * FROM dbo.EVENT_XT WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))

    If CM = "STAB" Or TA Then: T = sExotics("VIC", Nothing, RM, RV, False)
      If T <> "" Then S &= ", TXT_VIC=ISNULL(TXT_VIC,'')+" & cQS(FileTrade("VIC", RM(1), EV, RM(2), T, RM(0)) & T)
       PlaceBatchBet(T,"VIC",EV(0), EV(1), SESSION("LID"))
    End If
    If CM = "NSW"  Or TA Then: T = sExotics("NSW", Nothing, RM, RV, False)
      If T <> "" Then S &= ", TXT_NSW=ISNULL(TXT_NSW,'')+" & cQS(FileTrade("NSW", RM(1), EV, RM(2), T, RM(0)) & T)
       PlaceBatchBet(T,"NSW",EV(0), EV(1), SESSION("LID"))
    End If
    If CM = "QLD"  Or TA Then: T = sExotics("QLD", Nothing, RM, RV, False)
      If T <> "" Then S &= ", TXT_QLD=ISNULL(TXT_QLD,'')+" & cQS(FileTrade("QLD", RM(1), EV, RM(3), T, RM(0)) & T)
       PlaceBatchBet(T,"QLD",EV(0), EV(1), SESSION("LID"))
    End If
'    If CM = "USA" Then: T = sExotics("HST", Nothing, RM, RV, False)
'      If T <> "" Then S &= ", TXT_HST=ISNULL(TXT_HST,'')+" & cQS(FileTrade("HST", RM(1), EV, RM(4), T, RM(0)) & T)
'    End If
    If S <> "" Then execSQL("UPDATE EVENT SET" & Mid(S, 2) & " WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))

    Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>"): Response.End
  End If
End Sub


Function FileTrade( PL As String, ByVal TP As String, EV() As String, ID As String, TD As String, CT As String ) As String
  Dim N As String = genBatchNo("X")
  Return "#" & N & vbTab & Session("LID") & vbLf
End Function

Function OrdCNo( No() As Byte ) As Byte()
  Array.Sort(No): Return No
End Function

Sub SetCNo( ByVal No() As Byte, ByRef DR As DataRow )
  For I As Byte = 0 To 3: If I > UBound(No) Then: DR(I) = 0: Else DR(I) = No(I): End If: Next
End Sub

Function chkCNo( GM As Byte, ByRef DV As DataTable, ByRef DR As DataRow ) As Boolean
  Dim N As String = "", I As Byte = 0: While I < 4 And DR(I) > 0: N &= "-" & DR(I): I += 1: End While 
  Return Not IsNothing(DV.Rows.Find({ {"X","Q","D","T","O","F"}(GM), Mid(N, 2) }))
End Function

Function sCNo( DR As DataRow, CT As String, Optional TD As Boolean = False ) As String
  Dim S As String = "", I As Byte = 0
  While I < 4 And DR(I) > 0 
    S &= " - " &  DR(I).ToString.PadLeft(2) 
    I += 1 
  End While 
  S = Mid(S, 4)
  Return IIf(TD, S.Replace(" ", ""), S)
End Function

'Create display table for Exotics DVPs
'   Function XT_DVPs(DTdvps As DataTable) As String
'
'       If DTdvps.Rows.Count > 0 Then
'           Response.Write("<div class='XT_DVP'><table><col width=50><col width=100><col width=100><col width=100>" & _
'                           "<tr><th class=TT colspan=4> Exotic DVPs <tr height=22><th><th>Product<th>Selection<th>XT DVP")
'							
'           For Each DVPline In DTdvps.Rows
'               Response.Write("<tr><td><td>" & DVPline("XT_TYPE") & "<td>" & DVPline("SEL_NO") & "<td>" & DVPline("XT_DVP") & "</tr>")
'           Next
'           Response.Write("</table></div>")
'       End If
'
'   End Function
	
Function sExotics( B As String, ByRef DV As DataTable, ByRef RM As DataRow, ByRef RV As DataRow, RW As Boolean ) As String
  Dim GT() As String = { "Exacta", "Quinella", "Duet", "Trifecta", "Trio", "First 4" }
  Dim GM() As String = { "XCT", "QIN", "DUE", "TRF", "TRO", "F-F" }
  Dim PL() As String = { "PX", "PQ", "PD", "PT", "PO", "PF" }
  Dim D As DataRow, L As DataTable, CT As String = RM("COUNTRY"), USA As Boolean = false'"US,SE".Contains(CT)
  Dim I As Byte, J As Byte, K As Byte, E As Double, A As Double, T As Double, C() As String
  Dim TS As Double = 0, TR As Double = 0, ST As String = "", TD As New StringBuilder
  Dim TV As Single, BN As String = ICase(B, "HST","USA", "VIC","STAB", B), BQ As String = IIf(B = "QLD", Session("QLD_CLONE"), B)
  Dim TP as String = RM("TYPE")
  Dim TK As Double, XS As DataRow, XB As DataRow = getStaking(BN, 99, CT,TP)
  Dim RB As DataRow = getDataRow("SELECT XT_RB_X, XT_RB_Q, XT_RB_D, XT_RB_T, 0, XT_RB_F " & _
    "FROM SYS_MATRIX(nolock) WHERE COUNTRY='AU' AND MARKET='" & BN & "'")
    '  "FROM SYS_MATRIX(nolock) WHERE COUNTRY='" & RM("COUNTRY").Replace("NZ","AU").Replace("SE","US") & "' AND MARKET='" & BN & "'")  'TonyH 16Oct
  If Not IsNothing(RB) Then
    If B = "HST" And USA Then: GT(5) = "Superfecta": ElseIf B = "QLD" Then: GT(2) = "Any 2": End If
    If RW Then Response.Write("<div class='LST GAPb " & BQ & "'><table><col width=15><col><col width=60><col width=50><col width=60><col width=100>" & _
      "<tr><th class=TT colspan=6>" & BN & " Tote" & "<tr height=22><th colspan=2>Selection No<th>Pool<th>&Omega; %<th>Market<th>Stake")

    For I = 0 To 5: XS = getStaking(BN, I+2, CT,TP): If Not IsNothing(XS) AndAlso XS("POOL_TCK") Then
      Try
        If sNB(XS("TKO_TCK")) Then
          TK = sN0(RV(B & "_" & PL(I))): If TK > XS("TKO_AMT") Then TK = XS("TKO_AMT")
          TK = (TK * XS("TKO_PCT")) / 100
        Else: TK = XS("TKO_AMT"): End If
        If RW Then Response.Write("<tr height=25 class='TOT LNK' onclick=vCX('tb" & B & I & "')><td colspan=2>" & GT(I) & "<td>" & _
          sTtP(RV(B & "_" & PL(I))) & "<td>" & sTtP(TK) & "<td class='NM GR' colspan=2><b id=tt" & B & I & "><tr><tbody id=tb" & B & I & "><tr>")
        T = 0
        If TK > 0 Then
          K = 1: TV = IIf(sNB(XS("EXP_TCK")), 1 + XS("EXP_MIN") / 100, 0)
          Select Case I
          Case 0: L = XCT: putXQD(L, B, RV, "X")
          Case 1: L = QIN: putXQD(L, B, RV, "Q")
          Case 2: L = QPL: putXQD(L, B, RV, "D"): K = 3
          Case 3: L = TRF: Case 4: L = TRO: Case 5: L = FFR
          End Select

          For Each D In L.Select: If D(BQ) > 0 Then E = D("EMD") / D(BQ) Else E = 0
            If E >= TV Then: A = getStk((TK / (1 / D("EMD") - 1)) / K, XB): T += A: Else A = 0: End If

            If RW AndAlso (A > 0 OrElse chkCNo(I, DV, D)) Then
              Response.Write("<tr" & IIf(chkCNo(I, DV, D), " class=WNR", "") & _
                "><td class=""LR SCR""><td class=PRE>" & sCNo(D, CT) & "<td class=NM>" & sDivX(D("EMD")) & sEXP(E) & _
                "<td class=NM>" & sDivX(D(B)) & IIf(A > 0, "<td class=NM>" & FormatNumber(A), "<td>"))
            End If
            If A > 0 And I < 4 Then
              TD.Append(sCNo(D, CT, True) & vbTab & GM(I) & vbTab & FormatNumber(IIf(E > 9.99, 9.99, E)) & _
                vbTab & FormatNumber(A, 1) & vbTab & CSng(A * RB(I)) & vbTab & "ON" & vbLf)
            End If
          Next: TS += T: TR += T * RB(I)
        End If: ST &= "#tt" & B & I & ":after{content:'" & FormatNumber(T) & "'}"
      Catch: If RW Then: Response.Write("<tr><td colspan=6><b class=RD>ERROR!</b> " & Err.Description): End If: End Try

      If RW AndAlso InStr("VIC,NSW", B) > 0 AndAlso InStr("3,5", I) > 0 Then _
        Response.Write("<tr><td class='LR SCR'><td colspan=5 class='RN PRE1'>" & RV(B & "_T" & Right(PL(I), 1)))
      If RW Then Response.Write("<tr height=15 class=TOT><td colspan=6 class=BBB></tbody>")
    End If: Next

    If RW Then
      'Response.Write("<tr height=20 class='TOT LNK' onclick=vCX('tb" & B & "6')><td colspan=6>Wager Array<tr><tbody id=tb" & B & "6>" & _
      '  "<tr><tr><td class='LR SCR'><td colspan=5 class='RN PRE1'>" & TD.ToString & "<tr height=15 class=TOT><td colspan=6 class=BBB></tbody>")
      Response.Write("<tr height=25 class=TOT><td colspan=2><b>Selection Total" & _
        "<td class=NM colspan=2>" & FormatNumber(TR / 100) & "<td class=""NM BL"" colspan=2><b>" & FormatNumber(TS))
      If sNN(RV("TXT_" & B)) Then: TR = 0: TS = 0
        For Each BN In RV("TXT_" & B).Split(vbLf): If BN <> "" And Left(BN, 1) <> "#" Then
          C = BN.Split(vbTab): If UBound(C) > 4 Then: TR += CDbl(C(4)): TS += CDbl(C(3)): End If
        End If: Next
        Response.Write("<tr height=27 class=TOT><td class=TCN colspan=2>Confirmed Total" & _
          "<td class=NM colspan=2>" & FormatNumber(TR / 100) & "<td class=""NM OR"" colspan=2><b>" & FormatNumber(TS))
      End If
      Response.Write("</table><style>" & ST & "</style></div>")
    End If

  End If: Return TD.ToString
End Function


Sub putXQD( ByRef L As DataTable, B As String, ByRef RV As Object, T As String )
  If InStr("VIC,NSW", B) = 0 OrElse L.Rows.Count = 0 OrElse IsDBNull(RV(B & "_T" & T)) Then Exit Sub
  Dim C() As String, D As DataRow: T = RV(B & "_T" & T)
  For Each R As String In Split(T, vbLf): C = Split(R, vbTab): Try: D = L.Rows.Find({C(0), C(1), 0, 0}): D(B) = 1 / Val(C(2)): Catch: End Try: Next
End Sub


Sub CalcExotics( Mtg As Long, RNo As Byte )
  Dim KY As String = "_" & Mtg & "_" & RNo
  If IsNothing(Cache("XCT" & KY)) Then _CalcExotics(Mtg, RNo)
  XCT = Cache("XCT" & KY): QIN = Cache("QIN" & KY): QPL = Cache("QPL" & KY)
  TRF = Cache("TRF" & KY): TRO = Cache("TRO" & KY): FFR = Cache("FFR" & KY)
  QRx = Cache("QRx" & KY)
End Sub

Sub _CalcExotics( Mtg As Long, RNo As Byte )
  Const BT = 4
  Dim TB() As String  = { "EMD"  , "HST"  , "VIC"  , "NSW"  , "QLD"   }
  Dim MP(,) As Double = { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} }

  Dim XCT As DataTable = makeDataSet("SELECT TOP 0 N1=0, N2=0, N3=0, N4=0, EMD=0.0, HST=0.0, VIC=0.0, NSW=0.0, QLD=0.0").Tables(0)
  XCT.PrimaryKey = New DataColumn() { XCT.Columns(0), XCT.Columns(1), XCT.Columns(2), XCT.Columns(3) }
  Dim QIN As DataTable = XCT.Copy(), QPL As DataTable = XCT.Copy()
  Dim TRF As DataTable = XCT.Copy(), TRO As DataTable = XCT.Copy(), FFR As DataTable = XCT.Copy()
  Dim QRx As DataTable = makeDataSet("SELECT TOP 0 RN=0, QR2=0.0, QR3=0.0, QR4=0.0").Tables(0)
  QRx.PrimaryKey = New DataColumn() { QRx.Columns(0) }

  Dim RM As DataRow = getDataRow("SELECT COUNTRY, TYPE FROM MEETING(nolock) WHERE MEETING_ID=" & Mtg)
  Dim MT As String = ICase(RM("TYPE"), "R","RC", "G","GR", "HR")
  Dim GM As Double = getENum("DHV_" & MT & "1") / 100
  Dim DL As Double = getENum("DHV_" & MT & "2") / 100
  Dim EP As Double = getENum("DHV_" & MT & "3") / 100

  Dim I As Byte, J As Byte, T As Byte, CN() As Byte, Z(BT) As Double
  Dim DS As DataRowCollection = makeDataSet("SELECT RUNNER_NO, " & _
    "ISNULL(XT_WIN,0), 0.0, 0.0, 0.0, 0.0,  ISNULL(HST_TW,1), 0.0, 0.0, 0.0, 0.0, " & _
    "COALESCE(" & getCode("TES_VIC") & ",VIC_TW,0), 0.0, 0.0, 0.0, 0.0, " & _
    "COALESCE(" & getCode("TES_NSW") & ",NSW_TW,0), 0.0, 0.0, 0.0, 0.0, " & _
    "COALESCE(" & getCode("TES_QLD") & ",QLD_TW,0), 0.0, 0.0, 0.0, 0.0 "  & _
    "FROM RUNNER(nolock) WHERE MEETING_ID=" & Mtg & " AND EVENT_NO=" & RNo & " AND SCR=0").Tables(0).Rows
  Dim DR As DataRow, D As DataRow, E As DataRow, F As DataRow, G As DataRow

  ' Normalized to 118 Market Percentage
  If RM("COUNTRY") = "AU" Then
    For Each D In DS: For T = 2 To BT: J = T * 5: If D(1+J) > 0 Then: D(2+J) = 1 / D(1+J): MP(T, 0) += D(2+J): End If: Next: Next
    For Each D In DS: For T = 2 To BT: J = T * 5: If D(1+J) > 0 Then: D(1+J) = MP(T, 0) / (1.18 * D(2+J))    : End If: Next: Next
    MP(2, 0) = 0: MP(3, 0) = 0: MP(4, 0) = 0
  End If

  ' Calculate 2nd, 3rd & 4th Position Discounted Harville
  For Each D In DS
    For T = 0 To BT: J = T * 5: If D(1+J) > 0 Then
      D(2+J) = 1 / D(1+J): D(3+J) = D(2+J) ^ GM: D(4+J) = D(2+J) ^ DL: D(5+J) = D(2+J) ^ EP
      MP(T, 0) += D(3+J): MP(T, 1) += D(4+J): MP(T, 2) += D(5+J)
    End If: Next
  Next
  If MP(0, 0) > 0 Then
    
    ' Calculate 2nd, 3rd & 4th Position Probabilities
    For Each D In DS
      For T = 0 To BT: J = T * 5: If D(2+J) > 0 Then: D(3+J) /= MP(T, 0): D(4+J) /= MP(T, 1): D(5+J) /= MP(T, 2): End If: Next
      DR = QRx.NewRow(): DR(0) = D(0): For J = 1 To 3: DR(J) = 0: Next: QRx.Rows.Add(DR)
    Next

    For Each D In DS: For Each E In DS
      If D(0) <> E(0) Then
        For T = 0 To BT: J = T * 5: Z(T) = 0
          If D(2+J) > 0 AndAlso E(2+J) > 0 Then Z(T) = (D(2+J) * E(3+J)) / (1 - D(3+J))
        Next

        ' Exacta & Quinella
        DR = XCT.NewRow(): SetCNo({D(0), E(0)}, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: XCT.Rows.Add(DR)
        CN = OrdCNo({D(0), E(0)}): Try: DR = QIN.Rows.Find({CN(0), CN(1), 0, 0}): For T = 0 To BT: DR(TB(T)) += Z(T): Next
        Catch: DR = QIN.NewRow(): SetCNo(CN, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: QIN.Rows.Add(DR): End Try
        DR = QRx.Rows.Find({E(0)}): DR(1) += Z(0)

        For Each F In DS
          If D(0) <> F(0) AndAlso E(0) <> F(0) Then
            For T = 0 To BT: J = T * 5: Z(T) = 0
              If D(2+J) > 0 AndAlso E(2+J) > 0 AndAlso F(2+J) > 0 Then Z(T) = (D(2+J) * E(3+J) * F(4+J)) / ((1 - D(3+J)) * (1 - D(4+J) - E(4+J)))
            Next

            ' Trifecta & Trio
            DR = TRF.NewRow(): SetCNo({D(0), E(0), F(0)}, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: TRF.Rows.Add(DR)
            'CN = OrdCNo({D(0), E(0), F(0)}): Try: DR = TRO.Rows.Find({CN(0), CN(1), CN(2), 0}): For T = 0 To BT: DR(TB(T)) += Z(T): Next
            'Catch: DR = TRO.NewRow(): SetCNo(CN, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: TRO.Rows.Add(DR): End Try
            DR = QRx.Rows.Find({F(0)}): DR(2) += Z(0)

            ' Quinella Place
            For I = 1 To 3
              Select Case I: Case 1: CN = OrdCNo({D(0), E(0)}): Case 2: CN = OrdCNo({D(0), F(0)}): Case 3: CN = OrdCNo({E(0), F(0)}): End Select
              Try: DR = QPL.Rows.Find({CN(0), CN(1), 0, 0}): For T = 0 To BT: DR(TB(T)) += Z(T): Next
              Catch: DR = QPL.NewRow(): SetCNo(CN, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: QPL.Rows.Add(DR): End Try
            Next

            ' First Four
            For Each G In DS
              If D(0) <> G(0) AndAlso E(0) <> G(0) AndAlso F(0) <> G(0) Then
                For T = 0 To BT: J = T * 5: Z(T) = 0
                  If D(2+J) > 0 AndAlso E(2+J) > 0 AndAlso F(2+J) > 0 AndAlso G(2) > 0 Then _
                    Z(T) = (D(2+J) * E(3+J) * F(4+J) * G(5+J)) / ((1 - D(3+J)) * (1 - D(4+J) - E(4+J)) * (1 - D(5+J) - E(5+J) - F(5+J)))
                Next

                'If CT = "HK" Then ' Any Sequence
                '  CN = OrdCNo({D(0), E(0), F(0), G(0)})
                '  Try: DR = FFR.Rows.Find({CN(0), CN(1), CN(2), CN(3)}): For T = 0 To BT: DR(TB(T)) += Z(T): Next
                '  Catch: DR = FFR.NewRow(): SetCNo(CN, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: FFR.Rows.Add(DR): End Try
                'Else ' Exact Sequence
                  DR = FFR.NewRow(): SetCNo({D(0), E(0), F(0), G(0)}, DR): For T = 0 To BT: DR(TB(T)) = Z(T): Next: FFR.Rows.Add(DR)
                  DR = QRx.Rows.Find({G(0)}): DR(3) += Z(0)
                'End If
              End If
            Next

          End If
        Next
      End If
    Next: Next

  End If
  Cache.Insert("XCT_" & Mtg & "_" & RNo, XCT, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
  Cache.Insert("QIN_" & Mtg & "_" & RNo, QIN, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
  Cache.Insert("QPL_" & Mtg & "_" & RNo, QPL, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
  Cache.Insert("TRF_" & Mtg & "_" & RNo, TRF, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
  'Cache.Insert("TRO_" & Mtg & "_" & RNo, TRO, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
  Cache.Insert("FFR_" & Mtg & "_" & RNo, FFR, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
  Cache.Insert("QRx_" & Mtg & "_" & RNo, QRx, Nothing, Now.AddHours(2), Cache.NoSlidingExpiration)
End Sub

</script>
<%

If Request("EV") = "" Then  %>
	<!DOCTYPE html>
	<html>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<link rel="stylesheet" href="/global.css">
		<script src="/global.js"></script>
		<script>
			top.setTitle("Pari-Mutuel Exotics Market"); curVNL = "<%= Join(EV, "_") %>"; 
			function Init() { getVNL('<%= Session("GAME") %>', '<%= Session("CNTL") %>'); if( curVNL ) getEVN(curVNL) } 
			function iSV(m) { iNR("XT_WIN_", 100, m) } 
		</script>
		<body onload=Init()>
			<WT:Main Type="Chart_Canvas" runat=server/>
			<WT:Main id=VNL Type="Venue_List" runat=server/>
			<div id=CNT>
				<div id=C1></div>
				<div id=C2></div>
			</div>
			<iframe name=vrtPOST></iframe>
		</body>
	</html>
<% 
Else  %>
	<WT:Main id=MTG Type="Meeting_Info" runat=server/>
	<%
	'-- Meeting & Event Record Gathering ------------------------------------------------------------
	Dim I As Byte, QC As String = Session("QLD_CLONE")
	Dim RM As DataRow = getDataRow("SELECT * FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0))
	Dim RV As DataRow = getDataRow("SELECT * FROM dbo.EVENT_XT    WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
	Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME IN('X','Q','D','T','F') AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)).Tables(0)
	DV.PrimaryKey = New DataColumn() { DV.Columns(2), DV.Columns(3) }

	Dim CT As String = RM("COUNTRY"), TP As String = RM("TYPE"), ST As String = RV("STATUS")
	Dim AUS As Boolean = "AU,NZ".Contains(CT), USA As Boolean = False '"US,SE".Contains(CT)
	Dim MP() As Double = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  %>
	<form method=post target=vrtPOST autocomplete=off>
		<input name=EV type=hidden value="<%= Join(EV, "_") %>">
		<div class=LST>
			<table>
				<col width=28><col><col width=70><col width=20><colgroup span=15 width=42></colgroup>
				<tr>																				<!--  ' Confidence Level  -->
				<tr height=21><th rowspan=2>No<th rowspan=2>Name<th rowspan=2><u>Conf Lvl:</u><br><%= sConf(RV("CONF_LVL")) %><th colspan=7>e Model 
								<th rowspan=2>PM<br>DVP <th colspan=6>PM Dividend <th colspan=2>Betfair
				<tr height=22><th>FP<th>WIN<th>EXP<th>PLA<th>qr2<th>qr3<th>qr4 <th>RDbl<th>Host<th>STAB<th>NSW<th>QLD<th>AUS<th>VWM<th>xB1
								
<%	'-- Runner Parameters ---------------------------------------------------------------------------
	Dim BP As Byte   = getENum("PCT_PM_" & IIf(CT = "HK", "HKB", "XXB"))
	Dim EP As Byte   = getENum("PCT_PM_" & IIf(CT = "HK", "HKE", "XXE"))
	Dim KM As Byte   = getENum("KLY_MDL")
	Dim W1 As Single = getResult("SELECT MIN(HST_TP) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND HST_TP BETWEEN 1 AND 10",,1)
	Dim W2 As Single = getResult("SELECT MIN(VIC_TP) FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND VIC_TP BETWEEN 1 AND 10",,1)
	Dim EF As Single = getResult("SELECT TOP 1 XT_WIN FROM(SELECT TOP 4 * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " AND SCR=0 AND XT_WIN < 11 AND ISNULL(AUS_TW,0) < 11 ORDER BY 1)un ORDER BY 1 DESC",,0)

	Dim RS As Object = getRecord("SELECT * FROM RUNNER(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY RUNNER_NO")
	While RS.Read() %>
				<tr><%
		Dim TV As Integer, AV As Single
		Dim RN As Byte   = RS("RUNNER_NO")
		Dim EX As Double = getExp(RS("XT_WIN"), sNR(RS("PM_DVP"), RS("HST_TW")))
		Dim QR() As DataRow = QRx.Select("RN=" & RN)

    ' Runner Info
    %>
					<td class=HS><%= sRNo(CT, RN) & sHorse(RS, CT, RM("TYPE"), "PM") %>
<%  	If Not RS("SCR") Then
			If VM Then        %>
						<td><select class=CMT name=COMMENT_<%= RN %>><option><%= makeList("SELECT", "", "SYS_CODE", "RNR_CMT", "NAME", "NAME", sNS(RS("COMMENT"))) %></select>
	<%      Else        %>
						<td<%= IIf(sNS(RS("COMMENT")) = "1st Str", " class=PF", "") %>><%= sNR(RS("COMMENT"), "&nbsp;") %>
		<%  	If sN0(RS("STARTS")) > 0 Then %>
							<div class=INV>
								<span><%= RS("STARTS") %></span><b><%= RS("SPEED") %>	
							</div>
		<% 		End If
			End If      %>
						<td><%= IIf(sNN(RS("POS")), "<b>" & RS("POS"), "") %>
	<%      ' e Model		*** AndAlso (Not USA OrElse RN Mod 10 = 0)
			If VM  Then        %>
						<td class=FF><input name=XT_WIN_<%= RN %> type=text value="<%= RS("XT_WIN") %>" onkeydown="return KD(event,this)">
	<%     	Else %>
						<td class=<%= IIf(sNS(RS("COMMENT")) = "1st Str", "PF", "FF") %>><b><%= sDiv(RS("XT_WIN"), RS("XT_ORG")) %>
	<% 		End If      %>
						<%= sEXP(EX)      %>
						<td class=FF><%= sDiv(RS("XT_PLA")) %>
	<!--      ' QR2 - QR4	-->
	<%		If QR.Length = 1 Then        %>
						<td><i><%= sDiv(1 / QR(0)(1)) %></i><div class=INV><%= FormatNumber(QR(0)(1) * 100, 3) %></div>
						<td><i><%= sDiv(1 / QR(0)(2)) %></i><div class=INV><%= FormatNumber(QR(0)(2) * 100, 3) %></div>
						<td><i><%= sDiv(1 / QR(0)(3)) %></i><div class=INV><%= FormatNumber(QR(0)(3) * 100, 3) %></div>
	<%		Else %>
						<td><td><td>
		<% 	End If %>

	 <!--     ' PM Dividend Prediction      -->
						<td class=FD><b><%= sDiv(RS("PM_DVP")) %>
	<!--      ' Tote Market      -->
						<td<% If sNN(RS("RDB_HIST")) Then %> onmouseover="gRD([<%= Replace(RS("RDB_HIST"), "|", ",") %>],this)" onmouseout="gXX()"<% End If %>><%= sDiv(RS("RDB_TW"))      %>
						<td<%= IIf(sN0(RS("HST_TP")) = W1, " class=HL", "") %>>
							<%= "<b" & IIf(sN0(RS("BFR_WAP")) > 0 And sN0(RS("HST_TW")) > sN0(RS("BFR_WAP")), " class=BL", "") & ">" & sDiv(RS("HST_TW")) & "</b><div class=INV>" & sDiv(RS("HST_TP")) & "</div>" %>
						
						<td<%= IIf(sN0(RS("VIC_TP")) = W2 And CT = "SG", " class=HL", "") %>><%= sDiv(RS("VIC_TW")) & IIf(CT = "SG", "<div class=INV>" & sDiv(RS("VIC_TP")) & "</div>", "")        %>
						<td><%= sDiv(RS("NSW_TW")) %>
						<td><%= sDiv(RS("QLD_TW")) %>
						<td class=FT><%= IIf(sN0(RS("XT_WIN")) > EF And sN0(RS("AUS_TW")) > sN0(RS("XT_WIN")), "<b>", "") & sDiv(RS("AUS_TW")) %>

	 <!--     ' Betfair Market      -->
						<td><b><%= sDiv(RS("BFR_WAP")) %>
						<td><%= sDiv(RS("BFR_FW_B1")) %>
		  
	<%
		  '-- Calculate Total Market Percentage ----------------------------------------------------- -->

				MP(0) += getMkP(RS("XT_WIN")) : MP(1) += getMkP(RS("XT_PLA")) : MP(2) += getMkP(RS("PM_DVP"))
				MP(3) += getMkP(RS("RDB_TW")) : MP(4) += getMkP(RS("HST_TW"))
				MP(5) += getMkP(RS("VIC_TW")) : MP(6) += getMkP(RS("NSW_TW")) : MP(7) += getMkP(RS("QLD_TW"))
				MP(8) += getMkP(RS("AUS_TW")) : MP(9) += getMkP(RS("BFR_WAP")): MP(10) += getMkP(RS("BFR_FW_B1"))
				If QR.Length = 1 Then
					MP(11) += QR(0)(1) : MP(12) += QR(0)(2): MP(13) += QR(0)(3)
				End If

		Else %>
					<td colspan=17 class=SCR>&nbsp;
<% 		End If
	End While %>
				<tr><td colspan=19 class=SPT>
<%
  '-- Calculate Trading Amount & Payout -----------------------------------------------------------
	Dim NT As Double = 0, PY As Double = 0
	For Each B As String In {"HST", "VIC", "NSW", "QLD"}: If sNN(RV("TXT_" & B)) Then
	For Each R As String In RV("TXT_" & B).Split(vbLf): If R <> "" AndAlso Left(R, 1) <> "#" Then
		Dim C() As String = R.Split(vbTab): NT += CDbl(C(4)) / 100 - CDbl(C(3))
		If ST = "DONE" Then
			Dim W As DataRow = DV.Rows.Find({Left(C(1), 1), C(0)})
			If Not IsNothing(W) Then PY += CDbl(C(3)) * sN0(W(B))
		End If
	End If: Next
	End If: Next

  '-- Market % ------------------------------------------------------------------------------------
  %>
				<tr height=23 class=TOT><td colspan=2 class=TFN>Net Investment &#8211; Market %
					<td id=ttNET class=XPG><%= sPNL(NT) %><td><% If ST <> "DONE" Then %><div></div><% End If  %><%= sMkP(MP(0), 100)  %>
					<td><%= sMkP(MP(1), 100 * IIf(RV("STARTERS") < 8, 2, 3)) %>
			<%	For I = 11 To 13 %><%= sMkP(MP(I) * 100) %><% Next
				For I =  2 To 10 %><%= sMkP(MP(I)) %><% Next   %>

<!--  '-- Pools Size ----------------------------------------------------------------------------------  -->
				<tr height=23 class=TOT>
					<td colspan=2 class=TFN>
<%  If ST <> "DONE" Then    %>
		Pools / Matched<td class=XPG><td>
<%  Else    %>
		Net Profit - Pools / Matched<td id=ttPNL class=XPG><%= sPNL(PY + NT) %>
					<td><div></div>
<%  End If  %>
					<td colspan=3><%= sVar(RV("XMD_USE"))  %>
					<td colspan=3><td><%= sVar(RV("PDP_USE"))  %>
					<td><%= sTtP(RV("RDB_PW"))  %>
					<td><%= sTtP(RV("HST_PW"), RV("HST_PP")) %>
					<td><%= sTtP(RV("VIC_PW"), RV("VIC_PP"))    %>
					<td><%= sTtP(RV("NSW_PW"), RV("NSW_PP"))    %>
					<td><%= sTtP(RV("QLD_PW"), RV("QLD_PP"))    %>
					<td><%= sTtP(RV("AUS_PW")) %>
					<td><td><%= sTtP(RV("BFR_MW"))  %>
			</table>
		</div>

<%
  '-- Trading Parameters --------------------------------------------------------------------------
	If Not VM Then    %>
		<div class=TPR>
			<table cellspacing=0 cellpadding=3>
				<col><col width=245><col width=85><col width=105><col width=100>
	<%	If ST = "OPEN" Then %>
				<col width=90><col width=170>
	<% 	Else %>
				<col width=260>
	<% 	End If %>
				<col><td>
				
<%		' Pari-Mutuel Parameters
%>				<td class=GRP>
					<table class="LST FX" cellspacing=0 cellpadding=1>
						<col><col><col width=65><col width=50>
						<tr class=GPM><th colspan=2>e Model<th colspan=2>Hybrid %
						<tr><td><input name=FCMD type=submit value="e VWM"<%= IIf(TP = "G", " disabled", "") %>>
							<td><input name=FCMD type=submit value="e Mix 1"><%= hybridBox("HMX_XT", 1, RV)  %>
						<tr><td><input name=FCMD type=submit value="e Clear"<%= IIf(TP = "G", " disabled", "") %>>
							<td><input name=FCMD type=submit value="e fMdl"<%= IIf(TP = "G", " disabled", "") %>><%= hybridBox("HMX_XT", 2, RV)  %>
						<tr><td><input name=FCMD type=submit value="e Origin"<%= IIf(TP = "G", " disabled", "") %>>
							<td><input name=FCMD type=submit value="e RDbl"<%= IIf(TP = "G", " disabled", "") %>><%= hybridBox("HMX_XT", 3, RV)%>
					</table>
		
<%		' Alpha Parameters
%>
				<td><table class="LST FX" cellspacing=0 cellpadding=1>
					<col><col width=45>
					<tr><th colspan=2>&alpha; %
					<tr><td class=TFN>B<td><%= RV("ALP_PMB")  %>
					<tr><td class=TFN>E<td><%= RV("ALP_PME")  %>
					<tr><td colspan=2><%= (200 - sNR(RV("ALP_PMB"), 100)) & " &ndash; " & (200 - sNR(RV("ALP_PME"), 100))%>
				</table>
		
<%		' Dividend Prediction Parameters
%>
				<td><table class="LST FX" cellspacing=0 cellpadding=1>
					<col><col width=45>
					<tr><th colspan=2>PM Hybrid %
					<tr><%= shwHybridBox("DMX_PM", 1, RV)  %>
					<tr><%= shwHybridBox("DMX_PM", 2, RV)  %>
					<tr><%= shwHybridBox("DMX_PM", 3, RV)%>
				</table>
		
<%		' Other Parameters (View Only)
%>
				<td><table class="LST FX" cellspacing=0 cellpadding=1>
					<col><col width=45>
					<tr><th colspan=2>&Delta; %
					<tr><td>Mode<td><%= IIf(KM = 0, "Kelly", IIf(KM = 1, "Willy", "P.Stk"))		  %>
					<tr><td>Bet<td><%= BP  %>
					<tr><td>Eat<td><%= EP %>
				</table>
		
<%		If ST = "OPEN" Then
		  ' QLD Duplicate
%>
				<td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1>
					<tr class=GPM><th>QLD Clone
					<tr><td class=RN><input name=FCLN type=radio value="QLD" onclick="iBL()"<%= IIf(QC = "QLD", " checked", "") %> id=FCLN_1><label for=FCLN_1> none</label>
					<tr><td class=RN><input name=FCLN type=radio value="VIC" onclick="iBL()"<%= IIf(QC = "VIC", " checked", "") %> id=FCLN_2><label for=FCLN_2> STAB</label>
					<tr><td class=RN><input name=FCLN type=radio value="NSW" onclick="iBL()"<%= IIf(QC = "NSW", " checked", "") %> id=FCLN_3><label for=FCLN_3> NSW</label>
				</table>
		
<%		  ' Trade Buttons
%>
				<td class=GRP><table class="LST FX" cellspacing=0 cellpadding=1>
					<tr class=GPM><th colspan=2>Trade
					<tr><td><input name=FTRD type=submit value="STAB">
						<td><input name=FTRD type=submit value="HKJC" disabled>
					<tr><td><input name=FTRD type=submit value="NSW">
						<td><input name=FTRD type=submit value="QLD">
					<tr><td colspan=2><input name=FTRD type=submit value="Trade ALL">
				</table>
		
<%  	Else
      ' Results & Dividends
%>
				<td class="GRP RDV">
				<table class="LST FX" cellspacing=0 cellpadding=1 height=105>
	<%		If DV.Rows.Count > 0 Then			  %>
					<col width=30><col><col width=45><col width=45><col width=45>
					<tr class=GPM height=17>
						<th colspan=2>Results<th>STAB<th>NSW<th>QLD
			<%	For Each GM As String In {"XCT", "QIN", "TRF", "F-F"}
					For Each W As DataRow In DV.Select("GAME='" & Left(GM, 1) & "'")%>
						<tr>
							<td><%= GM %>
							<td><b><%= W("RUNNER") %>
							<td><%= sTtP(W("VIC")) %>
							<td><%= sTtP(W("NSW")) %>
							<td><%= sTtP(W("QLD")) %>
				<%	Next
				Next
			Else %>
						<tr><td class=BIG>Race in Progress!
		<% 	End If %>
				</table>
	
<%  	End If    %><!-- End of ST=OPEN -->

				<td>
			</table>
		</div>
		<input name=RNR_NO type=hidden value="">
		<input id=btnUPDT name=FCMD type=submit value="Update Changes" style="display:none">
<%	End If  %><!-- End of Trading Param -->

<% '-- Edit Market, Save & Status Bar --------------------------------------------------------------
%>		<div class=TED>
<%		If VM Then    %>
			<input name=UPD_OGN type=checkbox value=1> Update e Origin 
			<input type=button onclick="getEVN(curVNL)" value="Undo"><input name=FCMD type=submit onclick="iSV(0)" value="Save">
<% 		Else    %>
			<div id=divDSP><%= sLcDt(Now, "dd MMM, HH:mm.ss") %></div> 
			<input name=FCMD type=button onclick="getEVN()" value="     Edit     ">
<%		End If  %>	
		</div>
	</form>
	
<% RS.Close()  %>

<%
  Dim trades As Object = getRecord("SELECT * FROM EVENT_TRADING WHERE BET_TYPE NOT IN ('WIN', 'PLACE') AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1) & " ORDER BY JURISDICTION, DATE_CREATED,BET_TYPE")
  Dim tradeTable as New DataTable()
  tradeTable.Load(trades)
  Dim paperTrades = tradeTable.Select("PAPER_TRADE = 1")
  Dim liveTrades = tradeTable.Select("PAPER_TRADE = 0")
%>   

	<table id=TDG class=XTC>
<%  If HasTrades("VIC",tradeTable, True) Then %>
		<td><pre><b class=RD>STAB Trades (Live)</b><%= generateExoticTradeTable(liveTrades,"VIC", DV) %></pre>
<% 	End If
	If HasTrades("NSW",tradeTable, True) Then %>
		<td><pre><b class=BL>NSW Trades (Live)</b><%= generateExoticTradeTable(liveTrades,"NSW", DV) %></pre>
<% 	End If
	If HasTrades("QLD",tradeTable, True) Then %>
		<td><pre><b class=GR>QLD Trades (Live) </b><%=  generateExoticTradeTable(liveTrades,"QLD", DV)  %></pre>
<% 	End If  %>
<%  If HasTrades("VIC",tradeTable, False) Then %>
    <td><pre><b class=RD>STAB Trades (Paper)</b><%= generateExoticTradeTable(paperTrades,"VIC", DV) %></pre>
<%  End If
  If HasTrades("NSW",tradeTable, False) Then %>
    <td><pre><b class=BL>NSW Trades (Paper)</b><%= generateExoticTradeTable(paperTrades,"NSW", DV) %></pre>
<%  End If
  If HasTrades("QLD",tradeTable, False) Then %>
    <td><pre><b class=GR>QLD Trades (Paper) </b><%=  generateExoticTradeTable(paperTrades,"QLD", DV)  %></pre>
<%  End If  %>
	</table>

  <!--[ Next_Content ]-->
<%
  '-- Exotics Pool View ---------------------------------------------------------------------------
  sExotics("HST", DV, RM, RV, True)
  sExotics("VIC", DV, RM, RV, True)
  sExotics("NSW", DV, RM, RV, True)
  sExotics("QLD", DV, RM, RV, True)
'	XT_DVPs(XTPRICES)  'Luxbet exotics DVP display

  'sDuration(TM)

End If %><!--END of Request("EV")  -->