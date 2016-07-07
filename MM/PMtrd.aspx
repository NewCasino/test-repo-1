<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim EV As Object

Sub Page_Load()
  Response.CacheControl = "no-cache"
  chkSession(): EV = Secure("EV", 20)
  chkEvent(EV): MTG.EventID = EV: EV = Split(EV, "_")

  If Request("FCMD") <> "" AndAlso Session("LVL") = 0 Then
    Select Case Request("FCMD")
    Case "FINAL": execSQL("UPDATE EVENT SET STATUS='FINAL' WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
    Case "SKIP" : execSQL("UPDATE EVENT SET STATUS='SKIP'  WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
    Case "CHECK": execSQL("UPDATE EVENT SET STATUS='CHECK' WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1))
    Case "M2R": Application("EVENT_M2R_MAX") = Val(Request("M2R"))
    End Select: Response.Write("<script>parent.getEVN(parent.curVNL)</scr"&"ipt>"): Response.End
  End If
End Sub

</script><%

If Request("EV") = "" Then

  %><!DOCTYPE html><html><meta http-equiv="content-type" content="text/html; charset=UTF-8"><%
  %><link rel="stylesheet" href="/global.css"><script src="/global.js"></script><script><%
  %>top.setTitle("Pari-Mutuel Market Trades"); curVNL = "<%= Join(EV, "_") %>"; <%
  %>function Init() { getVNL('<%= Session("GAME") %>', '<%= Session("CNTL") %>'); if( curVNL ) getEVN(curVNL) } <%
  %></script><body onload=Init()><WT:Main id=VNL Type="Venue_List" runat=server/><%
  %><div id=CNT></div><iframe name=vrtPOST></iframe></body></html><%

Else

  %><WT:Main id=MTG Type="Meeting_Info" runat=server/><%

  '-- Meeting & Event Record Gathering ------------------------------------------------------------
  Dim RM As Object = getRecord("SELECT * FROM MEETING(nolock) WHERE MEETING_ID=" & EV(0)): RM.Read()
  Dim RV As Object = getRecord("SELECT TPM_HST, TPM_VIC, TPM_NSW, TPM_QLD,  TXT_HST, TXT_VIC, TXT_NSW, TXT_QLD,  STATUS " & _
    "FROM dbo.EVENT(nolock) WHERE MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)): RV.Read()
  Dim CT As String = RM("COUNTRY")
  Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME <> '#' AND MEETING_ID=" & EV(0) & " AND EVENT_NO=" & EV(1)).Tables(0)
  DV.PrimaryKey = New DataColumn() { DV.Columns(2), DV.Columns(3) }
  Dim DR As DataRow, TD(,) As Double = { {0,0}, {0,0}, {0,0} }

  '-- Calculate WIN-PLA Investments
  For I As Byte = 0 To 3: If sNN(RV(I)) Then
    For Each R As String In RV(I).ToString.Split(vbLf): If R <> "" And Left(R, 1) <> "#" Then
      Dim C() As String = R.Split(vbTab)
      TD(0, 0) -= CDbl(C(4)): TD(1, 0) += CDbl(C(7)) + CDbl(C(8))
      DR = DV.Rows.Find({Left(C(2), 1), IIf("US,SE".Contains(CT), C(0) \ 10, C(0))})
      If Not IsNothing(DR) Then TD(2, 0) += CDbl(C(4)) * sN0(DR(Right(RV.GetName(I), 3)))
    End If: Next
  End If: Next

  '-- Calculate Exotics Investments
  For I As Byte = 4 To 7: If sNN(RV(I)) Then
    For Each R As String In RV(I).ToString.Split(vbLf): If R <> "" And Left(R, 1) <> "#" Then
      Dim C() As String = R.Split(vbTab)
      TD(0, 1) -= CDbl(C(3)): TD(1, 1) += CDbl(C(4)) / 100
      DR = DV.Rows.Find({IIf(C(1) = "QPL", "D", Left(C(1), 1)), C(0)})
      If Not IsNothing(DR) Then TD(2, 1) += CDbl(C(3)) * sN0(DR(Right(RV.GetName(I), 3)))
    End If: Next
  End If: Next

  '-- Display Total Investments, Results & Dividend
  If TD(0,0) + TD(0,1) < 0 OrElse DV.Rows.Count > 1 Then
    %><div class=TPR><table cellspacing=0 cellpadding=3><%
    %><col><col width=350><col width=275><col width=275><col width=295><col><td><%

    %><td class=RDV><table class="LST FX" cellspacing=0 cellpadding=1 height=115><%
    %><col><col width=88><col width=88><col width=95><%
    %><tr height=17><th>Total<th>WIN-PLA<th>Exotics<th>Overall<%
    %><tr><td>Selections<td><%= sPNL(TD(0,0)) %><td><%= sPNL(TD(0,1)) %><td><%= sPNL(TD(0,0) + TD(0,1))
    %><tr><td>Rebates<td><%=    sPNL(TD(1,0)) %><td><%= sPNL(TD(1,1)) %><td><%= sPNL(TD(1,0) + TD(1,1))
    %><tr><td>Payout<td><%=     sPNL(TD(2,0)) %><td><%= sPNL(TD(2,1)) %><td><%= sPNL(TD(2,0) + TD(2,1))
    %><tr><td colspan=4 class=SPT><%
    If DV.Rows.Count > 1 Then
      %><tr><td class=TFN><b>Profit<td><%= sPNL(TD(0,0) + TD(1,0) + TD(2,0)) %><td><%= sPNL(TD(0,1) + TD(1,1) + TD(2,1))
                    %><td><b><%= sPNL(TD(0,0) + TD(0,1)  +  TD(1,0) + TD(1,1)  +  TD(2,0) + TD(2,1)) %><%
    Else %><tr><td class=TFN><b>Profit<td>-<td>-<td>-<% End If %></table><%

    If DV.Rows.Count > 1 Then
      %><td class=RDV><table class="LST FX" cellspacing=0 cellpadding=1 height=115><%
      %><col width=30><col><colgroup span=3 width=45></colgroup><%
      %><tr class=GPM height=17><th colspan=2>Results<th>Host<th>STAB<th>NSW<th>QLD<%
      For Each GM As String In {"WIN", "PLA"}: For Each W As DataRow In DV.Select("GAME='" & Left(GM, 1) & "'")
        %><tr><td><%= GM %><td><b><%= W("RUNNER") %><td><%= sTtP(W("HST"))
        %><td><%= sTtP(W("VIC")) %><td><%= sTtP(W("NSW")) %><td><%= sTtP(W("QLD")) %><%
      Next: Next %></table><%

      %><td class=RDV><table class="LST FX" cellspacing=0 cellpadding=1 height=115><%
      %><col width=30><col><col width=45><col width=45><col width=45><col width=45><%
      %><tr class=GPM height=17><th colspan=2>Results<th>Host<th>STAB<th>NSW<th>QLD<%
      For Each GM As String In {"QIN", "DUE"}: For Each W As DataRow In DV.Select("GAME='" & Left(GM, 1) & "'")
        %><tr><td><%= GM %><td><b><%= W("RUNNER") %><td><%= sTtP(W("HST"))
        %><td><%= sTtP(W("VIC")) %><td><%= sTtP(W("NSW")) %><td><%= sTtP(W("QLD")) %><%
      Next: Next %></table><%

      %><td class=RDV><table class="LST FX" cellspacing=0 cellpadding=1 height=115><%
      %><col width=30><col><col width=45><col width=45><col width=45><col width=45><%
      %><tr class=GPM height=17><th colspan=2>Results<th>Host<th>STAB<th>NSW<th>QLD<%
      For Each GM As String In {"XCT", "TRF", "F-F"}: For Each W As DataRow In DV.Select("GAME='" & Left(GM, 1) & "'")
        %><tr><td><%= GM %><td><b><%= W("RUNNER") %><td><%= sTtP(W("HST"))
        %><td><%= sTtP(W("VIC")) %><td><%= sTtP(W("NSW")) %><td><%= sTtP(W("QLD")) %><%
      Next: Next %></table><%
    Else %><td><td><td><% End If

    %><td></table></div><%
  End If

  '-- Administrator Comand Center -----------------------------------------------------------------
  If Session("LVL") = 0 Then
    %><style>.EDT input { padding:3px 20px }</style><%
    %><div class=EDT><form method=post target=vrtPOST autocomplete=off><input name=EV type=hidden value="<%= Join(EV, "_") %>"><%
    If 1=1 Or RV("STATUS") <> "DONE" Then
      %>Set Status <input name=FCMD type=submit value="FINAL"><input name=FCMD type=submit value="SKIP"><input name=FCMD type=submit value="CHECK"><%
      %> &nbsp; &nbsp; &nbsp; <%
    End If
    %><input name=M2R type=text value="<%= Application("EVENT_M2R_MAX") %>" style="width:35px; padding:2px; text-align:right"><%
    %><input name=FCMD type=submit value="M2R"><%
    %></form></div><%
  End If

  '-- WIN-PLA & Exotic Trades ---------------------------------------------------------------------
  %><table id=TDG class=XTC><%

  If sNS(RV(0) & RV(1) & RV(2) & RV(3)) <> "" Then
    %><td><pre style="width:310px"><%
    If sNN(RV(0)) Then %><b class=CN>HKJC WIN-PLA</b><%= sTrdTL(RV(0), False, DV, CT) %><% End If
    If sNN(RV(1)) Then %><b class=RD>STAB WIN-PLA</b><%= sTrdTL(RV(1), False, DV, CT) %><% End If
    If sNN(RV(2)) Then %><b class=BL>NSW WIN-PLA</b><%=  sTrdTL(RV(2), False, DV, CT) %><% End If
    If sNN(RV(3)) Then %><b class=GR>QLD WIN-PLA</b><%=  sTrdTL(RV(3), False, DV, CT) %><% End If
    %></pre><%
  End If

  If sNN(RV(4)) Then %><td><pre><b class=CN>HKJC Exotics</b><%= sTrdXT(RV(4), DV, "HST") %></pre><% End If
  If sNN(RV(5)) Then %><td><pre><b class=RD>STAB Exotics</b><%= sTrdXT(RV(5), DV, "VIC") %></pre><% End If
  If sNN(RV(6)) Then %><td><pre><b class=BL>NSW Exotics</b><%=  sTrdXT(RV(6), DV, "NSW") %></pre><% End If
  If sNN(RV(7)) Then %><td><pre><b class=GR>QLD Exotics</b><%=  sTrdXT(RV(7), DV, "QLD") %></pre><% End If

  %></table><%

  RV.Close(): RM.Close()

End If %>