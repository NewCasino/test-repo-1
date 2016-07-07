<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim RS As Object, F As String, S As String

Sub Page_Load()
  chkSession(7)

  Select Case Request("FCMD")
  Case "Save"
    S = "": RS = getRecord("SELECT * FROM SYS_MATRIX(nolock) WHERE COUNTRY IN('AU','US')")
    While RS.Read(): Dim L As String = ""
      For Each F In {"WIN", "PLA"}: L &= ", " & F & "=" & IIf(Request(F & "_" & RS(0)) = "on", 1, 0): Next
      For Each F In {"WP_RBT", "WP_COMM", "EXP_MIN", "KELLY", "EXP_CUT", _
        "MN_FM_W", "RD_FM_W", "MX_FM_W", "MX_DV_W", "MN_FM_P", "RD_FM_P", "MX_FM_P", "MX_DV_P", _
        "XT_RB_X", "XT_RB_Q", "XT_RB_D", "XT_RB_T", "XT_RB_F"}
        L &= ", " & F & "=" & ChkR9(F & "_" & RS(0), 0)
      Next: S &= "UPDATE SYS_MATRIX SET " & Mid(L, 3) & " WHERE SEQ=" & RS(0) & vbLf
    End While: RS.Close(): ExecSQL(S)

  Case "Reset Bankroll"
    If Session("LVL") = 0 Then execSQL("UPDATE SYS_MATRIX SET WP_BANK=0, XT_BANK=0 WHERE COUNTRY IN('AU','US')")
  End Select
End Sub

</script><!DOCTYPE html><html><meta http-equiv="content-type" content="text/html; charset=UTF-8"><%
%><link rel="stylesheet" href="/global.css"><script src="/global.js"></script><%
%><script>top.setTitle("Variable Matrix Setting")</script><%
%><style>.LST input[type=num] { width:45px }</style><%
%><body><div id=CNT style="top:25px; left:25px; width:1450px"><form method=post><div class=LST><%
%><table cellpadding=3><col width=95><col width=30><col width=30><col width=95><%
%><colgroup span=13></colgroup><col width=95><colgroup span=5></colgroup><%
%><tr><tr><th rowspan=2 class=TT>Market<th colspan=8 class=TT>WIN-PLA Market<%
%><th colspan=4 class=TT>WIN &#402; Model Limits<th colspan=4 class=TT>PLA &#402; Model Limits<th colspan=6 class=TT>Exotics Market Rebates %<%
%><tr class=SML><th>W<th>P<th>Bankroll<th>CLRB %<th>Comm %<th>XP Min<th>Kelly %<th>XP Cut<%
%><th>&#402; Min<th>&#402; < x<th>&#402; Max<th>Max Div <th>&#402; Min<th>&#402; < x<th>&#402; Max<th>Max Div<%
%><th>Bankroll<th>XCT<th>QIN<th>DUE<th>TRF<th>F-F<%

S = "": RS = getRecord("SELECT * FROM SYS_MATRIX(nolock) WHERE COUNTRY IN ('AU','US')")
While RS.Read()
  If RS("COUNTRY") <> S Then: If S <> "" Then %><tr><td class=SPT colspan=23><% End If: S = RS("COUNTRY"): End If
  %><tr><td class=RN><img align=absmiddle class=FLG src="/img/<%= RS("COUNTRY") %>.jpg"> <%= IIf(RS("WIN") Or RS("PLA"), "<b>", "") & RS("MARKET") %><%
  For Each F In {"WIN", "PLA"} %><td><input name=<%= F & "_" & RS(0) %> type=checkbox<%= IIf(RS(F), " checked", "") %> style="margin:3px"><% Next
  %><td><%= sPNL(RS("WP_BANK")) %><%
  For Each F In {"WP_RBT", "WP_COMM", "EXP_MIN", "KELLY", "EXP_CUT", _
    "MN_FM_W", "RD_FM_W", "MX_FM_W", "MX_DV_W", "MN_FM_P", "RD_FM_P", "MX_FM_P", "MX_DV_P"}
    %><td><input name=<%= F & "_" & RS(0) %> type=num value="<%= sVar(RS(F), "NMI", 2) %>"><%
  Next

  %><td><%= sPNL(RS("XT_BANK")) %><%
  For Each F In {"XT_RB_X", "XT_RB_Q", "XT_RB_D", "XT_RB_T", "XT_RB_F"}
    %><td><input name=<%= F & "_" & RS(0) %> type=num value="<%= sVar(RS(F), "NMI", 2) %>"><%
  Next
End While: RS.Close() %></table></div><%

%><div class=EDT><input type=reset value="Undo"> <input type=submit name=FCMD value="Save"><%
If Session("LVL") = 0 Then %> <input type=submit name=FCMD value="Reset Bankroll"><% End If %></div><%
%></form></div></body></html>