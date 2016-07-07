<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim RS As Object, I As Byte, J As Byte, K As String
Dim TB() As String  = { "STAB", "NSW", "QLD", "USA" }

Sub Page_Load()
  chkSession(7)

  If Request("FCMD") <> "" Then
    Dim S As String = ""
    RS = getRecord("SELECT MARKET, POOL_ID FROM SYS_STAKING(nolock) WHERE MARKET <> 'HKJC' AND POOL_ID < 99")
    While RS.Read(): K = RS(0) & RS(1) & "_"
      S &= "UPDATE SYS_STAKING SET" & _
        "  POOL_TCK=" & chkR9(K & "POOL_TCK", 0) & _
        ", TKO_AMT="  & chkR9(K & "TKO_AMT")     & _
        ", EXP_TCK="  & chkR9(K & "EXP_TCK" , 0) & _
        ", EXP_MIN="  & chkR9(K & "EXP_MIN")     & _
        ", TKO_TCK="  & chkR9(K & "TKO_TCK" , 0) & _
        ", TKO_PCT="  & chkR9(K & "TKO_PCT" , 0) & _
        "  WHERE MARKET='" & RS(0) & "' AND POOL_ID=" & RS(1) & vbLf
    End While: RS.Close()

    For I = 0 To 3: K = TB(I) & "_"
      S &= "UPDATE SYS_STAKING SET" & _
        "  TKO_AMT="  & chkR9(K & "CENTS", 32) & _
        ", TKO_PCT="  & chkR9(K & "ROUND",  3) & _
        ", TKO_TCK="  & chkR9(K & "MNAMT",  0) & _
        "  WHERE MARKET='" & TB(I) & "' AND POOL_ID=99" & vbLf
    Next: execSQL(S): Application.Remove("SYS_STAKING")
  End If
End Sub

</script><!DOCTYPE html><html><meta http-equiv="content-type" content="text/html; charset=UTF-8"><%
%><link rel="stylesheet" href="/global.css"><script src="/global.js"></script><%
%><script>top.setTitle("Staking Defaults")</script><%
%><body><div id=CNT style="left:15px; width:1200px"><form method=post><%

For J = 0 To 0
%><table class=STK><tr><td class=TT colspan=4><%
%><img class=FLG src="/img/<%= {"AU","US"}(J) %>.jpg"> <%=
  {"Australia","United States"}(J)
%><tr><%

For I = IIf(J = 0, 0, 3) To IIf(J = 0, 2, 3)
  Dim GT() As String = { "Win", "Place", "Exacta", "Quinella", "Duet", "Trifecta", "Trio", "First 4" }
  If I = 2 Then GT(4) = "Any 2"

  %><td><div class="LST <%= ICase(I, 0,"VIC", 3,"HST", TB(I)) %>"><table cellspacing=0><col><col width=85><col width=75><col width=75><%
  %><tr><th colspan=4 class=TT><%= TB(I) %> Tote<tr class=SML><th>Pool<th>Takeout $<th>EXP Min %<th>Takeout %<%
  RS = getRecord("SELECT * FROM SYS_STAKING(nolock) WHERE MARKET='" & TB(I) & "' AND POOL_ID < 99")
  While RS.Read(): K = RS("MARKET") & RS("POOL_ID") & "_"
    %><tr><td class=RN><input name=<%= K %>POOL_TCK type=checkbox value=1<%= IIf(sNB(RS("POOL_TCK")), " checked", "") %>> <%= IIf(sNB(RS("POOL_TCK")), "<b>", "") %><%= GT(RS("POOL_ID"))
    %><td><input name=<%= K %>TKO_AMT type=number style="width:70px" value="<%= RS("TKO_AMT") %>"><%
    %><td><input name=<%= K %>EXP_TCK type=checkbox value=1<%= IIf(sNB(RS("EXP_TCK")), " checked", "") %>><%
        %><input name=<%= K %>EXP_MIN type=number value="<%= RS("EXP_MIN") %>"><%
    %><td><input name=<%= K %>TKO_TCK type=checkbox value=1<%= IIf(sNB(RS("TKO_TCK")), " checked", "") %>><%
        %><input name=<%= K %>TKO_PCT type=number value="<%= RS("TKO_PCT") %>"><%
  End While: RS.Close()

  RS = getRecord("SELECT TKO_PCT, TKO_AMT, TKO_TCK FROM SYS_STAKING(nolock) WHERE MARKET='" & TB(I) & "' AND POOL_ID = 99"): RS.Read()
  %><tr height=50><td class="RI NRB"><% K = TB(I) & "_ROUND"
  %><input type=radio name=<%= K %> value=0<%= IIf(RS(0) = 0, " checked", "") %>> <%= IIf(RS(0) = 0, "<b>", "") %>Always round UP<%=   IIf(RS(0) = 0, "</b>", "") %><br><%
  %><input type=radio name=<%= K %> value=1<%= IIf(RS(0) = 1, " checked", "") %>> <%= IIf(RS(0) = 1, "<b>", "") %>Always round DOWN<%= IIf(RS(0) = 1, "</b>", "") %><%
  %><td class=RI colspan=3><%
  %><input type=radio name=<%= K %> value=2<%= IIf(RS(0) = 2, " checked", "") %>> <%= IIf(RS(0) = 2, "<b>", "") %>Round UP if &cent; &#8805;<%= IIf(RS(0) = 2, "</b>", "")
  %> <input type=number name=<%= TB(I) %>_CENTS value="<%= RS(1) %>" onchange=cNM(this,99,1)><br><%
  %><input type=checkbox name=<%= TB(I) %>_MNAMT value=1<%= IIf(sNB(RS(2)), " checked", "") %>> <%= IIf(sNB(RS(2)), "<b>", "") %>Maintain min. Bet of <%= IIf(I < 3, "50&cent;", "$1") %><%= IIf(RS(0) = 2, "</b>", "") %><%
  RS.Close()

  %></table></div><%
Next

%></table><%
Next

%><div class=EDT style="margin-top:15px"><input type=reset value="Undo"> <input type=submit name=FCMD value="Save"></div><%
%></form><br></div></body></html>