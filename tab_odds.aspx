<!-- #include file="/inc/page.inc" --><%

'-- Data Formats --------------------------------------------------------------
' 0| Tote      : VIC / NSW
' 1| Mode      : W, P, X, Q, D, T, F, L (fluctuations)
' 2| Event     : Venue Code, Race No
' 3| Pool Size : WIN, PLA, ...
' 4| Dividend  : WIN, PLA, DATA_1, ..., DATA_n
' …|
' n| Dividend  : WIN, PLA, DATA_1, ..., DATA_n
'------------------------------------------------------------------------------
' 0| Tote      : VIC
' 1| Mode      : R (Running Double)
' 2| Event     : Venue Code, 1st Race No, 2nd Race No
' …|
' 5| Pool Size : WIN, PLA, RUN_DOUBLE, ...
' 6| Dividend  : WIN, PLA, NEXT_RACE_HORSE_1, ..., NEXT_RACE_HORSE_n
' …|
' n| Dividend  : WIN, PLA, NEXT_RACE_HORSE_1, ..., NEXT_RACE_HORSE_n
'------------------------------------------------------------------------------
' 0| Tote      : VIC / NSW
' 1| Mode      : V (Results & Dividends)
' 2| Event     : Venue Code, Race No
' 3| Final Pos : 1st/2nd/3rd/4th/-/-
' 4| Status    : RUN / CLR (all clear)
' …| Pay Sts   : ITR (interim) / PAY (paying), GAME_CODE
' …| Scratched : SCR, GAME_CODE, HORSE_1-HORSE_2-HORSE_n
' …| Dividend  : DIV, GAME_CODE, HORSE_1/HORSE_2/HORSE_n, PAYOUT
'------------------------------------------------------------------------------
' GAME_CODE: WIN, PLA, XCT, QIN, DUE, TRF, FFR, RDB (dcodds.ptb)
'------------------------------------------------------------------------------

Try

If Request.Form.Count = 1 Then
  Dim C() As String, R() As String = Split(Request.Form(0), vbLf)
  Dim M As Object, N As Byte, I As Byte, J As Byte, S As String, F As String, D As String = ""
  If R(0) = "VIC" Or R(0) = "NSW" Then
    C = Split(R(2), ",")

    ' Find Matched Meeting
    M = getRecord("SELECT MEETING_ID, COUNTRY, TYPE, BTK_ID FROM MEETING(nolock) WHERE DATEDIFF(hour,MEETING_DATE,GETDATE()) < 28 AND BTK_ID=" & cQS(C(0)) & " ORDER BY TRK_COND DESC")
    If M.Read() Then
      'Application(R(0) & "." & C(0) & "." & C(1) & "." & R(1)) = Now & vbLf & Request.Form(0)
      Select Case R(1)


      Case "V" ' RESULTS & DIVIDENDS Handling
        Const GL = ".. WIN PLA XCT QIN DUE TRF FFR": Dim GM As Byte
        N = C(1): C = Split(R(3), "/")
        S &= "UPDATE RUNNER SET POS=NULL WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 0 To UBound(C): If Val(C(I)) > 0 Then
          S &= "UPDATE RUNNER SET POS=" & I+1 & " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & " AND RUNNER_NO IN(" & C(I).Replace("-",",") & ")" & vbLf
        End If: Next
        S &= "UPDATE RESULTS SET " & R(0) & "=NULL WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 5 To UBound(R) - 1
          C = Split(R(I), ","): GM = InStr(GL, C(1)) \ 4
          Select Case C(0)
          Case "SCR": If GM = 1 And C(2) <> "" Then S &= "EXEC dbo.SET_RESULT " & M(0) & "," & N & ",'#','" & C(2) & "',NULL,NULL" & vbLf
          Case "DIV": If GM > 0 And C(2) <> "" Then _
            S &= "EXEC dbo.SET_RESULT " & M(0) & "," & N & ",'" & Left(C(1), 1) & "','" & _
              C(2).Replace("/","-") & "','" & R(0) & "'," & IIf(C(3) <> "", C(3), "NULL") & vbLf
          End Select
        Next %><%'= vbLf & Request.Form(0) %><%


      Case "W" ' WIN ODSS Handling
        N = C(1): C = Split(R(3), ",")
        S = "UPDATE EVENT SET " & R(0) & "_PW=" & cQS(C(0)) & " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I) & ",", ",")
          If C(0) <> "" Then S &= _
            "UPDATE RUNNER SET " & R(0) & "_TW=" & cQS(C(0)) & _
            " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & " AND RUNNER_NO=" & (I - 3) & vbLf
        Next
        'If InStr("AU,NZ", M("COUNTRY")) > 0 Then
        '  Dim FT As String = "VIC": If M("TYPE") = "G" Then FT = getResult("SELECT GTFAV FROM SYS_BETTEKK(nolock) WHERE CODE='" & M("BTK_ID") & "'",, "AUS")
        '  If FT = R(0) Then S &= "UPDATE RUNNER SET HST_TW=" & FT & "_TW WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        'End If


      Case "P" ' PLA ODSS Handling
        N = C(1): C = Split(R(3), ",")
        S = "UPDATE EVENT SET " & R(0) & "_PP=" & cQS(C(1)) & " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I) & ",", ",")
          If C(1) <> "" Then S &= _
            "UPDATE RUNNER SET " & R(0) & "_TP=" & cQS(C(1)) & _
            " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & " AND RUNNER_NO=" & (I - 3) & vbLf
        Next
        'If InStr("AU,NZ", M("COUNTRY")) > 0 Then
        '  Dim FT As String = "VIC": If M("TYPE") = "G" Then FT = getResult("SELECT GTFAV FROM SYS_BETTEKK(nolock) WHERE CODE='" & M("BTK_ID") & "'",, "AUS")
        '  If FT = R(0) Then S &= "UPDATE RUNNER SET HST_TP=" & FT.Replace("AUS", "VIC") & "_TP WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        'End If


      Case "X" ' EXACTA ODDS Handling
        N = C(1): C = Split(R(3), ","): S = ""
        S = "UPDATE EVENT SET " & R(0) & "_PX=" & cQS(C(2)) & ", " & R(0) & "_TX=[DATA] WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I), ",")
          For J = 2 To UBound(C): If C(J) <> "" Then: D &= (I - 3) & vbTab & (J - 1) & vbTab & CSng(C(J)) & vbLf: End If: Next
        Next: S = S.Replace("[DATA]", cQS(D))


      Case "Q" ' QUINELLA ODDS Handling
        N = C(1): C = Split(R(3), ",")
        S = "UPDATE EVENT SET " & R(0) & "_PQ=" & cQS(C(2)) & ", " & R(0) & "_TQ=[DATA] WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I), ",")
          For J = 2 To UBound(C): If C(J) <> "" And (I - 2) < J Then: D &= (I - 3) & vbTab & (J - 1) & vbTab & CSng(C(J)) & vbLf: End If: Next
        Next: S = S.Replace("[DATA]", cQS(D))


      Case "D" ' DUET ODDS Handling
        N = C(1): C = Split(R(3), ",")
        S = "UPDATE EVENT SET " & R(0) & "_PD=" & cQS(C(2)) & ", " & R(0) & "_TD=[DATA] WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I), ",")
          For J = 2 To UBound(C): If C(J) <> "" And (I - 2) < J Then: D &= (I - 3) & vbTab & (J - 1) & vbTab & CSng(C(J)) & vbLf: End If: Next
        Next: S = S.Replace("[DATA]", cQS(D))


      Case "T" ' TRIFECTA TRENDS Handling
        N = C(1): C = Split(R(3), ",")
        S = "UPDATE EVENT SET " & R(0) & "_PT=" & cQS(C(2)) & ", " & R(0) & "_TT=[DATA] WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I), ",")
          If UBound(C) = 4 AndAlso C(0) <> "" Then D &= (I - 3) & vbTab & Val(C(2)) & vbTab & Val(C(3)) & vbTab & Val(C(4)) & vbLf
        Next: S = S.Replace("[DATA]", cQS(D))


      Case "F" ' FIRST 4 TRENDS Handling
        N = C(1): C = Split(R(3), ",")
        S = "UPDATE EVENT SET " & R(0) & "_PF=" & cQS(C(2)) & ", " & R(0) & "_TF=[DATA] WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
        For I = 4 To UBound(R): C = Split(R(I), ",")
          If UBound(C) = 5 AndAlso C(0) <> "" Then D &= (I - 3) & vbTab & Val(C(2)) & vbTab & Val(C(3)) & vbTab & Val(C(4)) & vbTab & Val(C(5)) & vbLf
        Next: S = S.Replace("[DATA]", cQS(D))


      Case "L" ' FLUCTUATIONS Handling
        N = C(1): C = Split(R(3), ","): S = ""
        For I = 4 To UBound(R): C = Split(R(I) & ",,", ",")
          If C(2) <> "" Then S &= _
            "UPDATE RUNNER SET APN_FW=" & Val(C(2)) & ", APN_HIST=CASE APN_FW WHEN " & Val(C(2)) & " THEN APN_HIST ELSE ISNULL(APN_HIST+'|','')+'" & _
            Val(C(2)) & "' END" & " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & " AND RUNNER_NO=" & (I - 3) & vbLf
        Next


      Case "R" ' RUNNING DOUBLE ODDS Handling
        If R(0) = "VIC" Then 'And M(1) <> "HK" Then
          N = C(2): C = Split(R(5), ","): Dim H(30) As Double: For I = 0 To UBound(H): H(I) = 0: Next
          S = "UPDATE EVENT SET RDB_PW=" & cQS(C(2)) & " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
          For I = 6 To UBound(R): C = Split(R(I), ",")
            For J = 2 To UBound(C): If C(J) <> "" Then: H(J - 1) += 1 / CDbl(C(J)): End If: Next
          Next
          For I = 1 To UBound(H): If H(I) > 0 Then
            H(0) = 1 / H(I): H(0) = Math.Round(H(0), IIf(H(0) > 100, 0, IIf(H(0) > 10, 1, 2)))
            S &= "UPDATE RUNNER SET RDB_TW=" & H(0) & ", RDB_HIST=ISNULL(RDB_HIST+'|','')+'" & H(0) & "'" & _
              " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & " AND RUNNER_NO=" & I & " AND ISNULL(RDB_TW,0) <> " & H(0) & vbLf
          End If: Next
        End If


      End Select
	  If S <> "" Then
		execSQL(S) %>OK<% 
		ExecSQL("EXEC sp_DFstatus '" & R(0) & "'")
	  Else 
		%>NA<% 
	  End If
    Else
      Select Case getResult("dbo.GET_BTK_MEETING " & cQS(C(0)))
      Case 0 %>NEW<%  ' New Matching Found
      Case 1 %>ER-2<% ' No Matching BETTEKK Code
      Case 2 %>ER-3<% ' No Matched Meeting
      End Select
    End If: M.Close()

  Else %>ER-1<% End If ' Invalid Tote
Else %>ER-0<% End If   ' No Data

Catch %><%= Err.Description & vbLf & Request.Form(0) %><% End Try %>