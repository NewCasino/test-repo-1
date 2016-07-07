<!-- #include file="/inc/page.inc" --><%

Select Case Request("C")
Case "M":
  Response.ContentType = "text/xml"
  %><M><% Dim X As Object = getRecord("SELECT * FROM (" & _
    "SELECT TOP 3 ID=A.MEETING_ID, RC=A.EVENT_NO, VN=B.VENUE, DT=CONVERT(varchar(10), B.MEETING_DATE, 20), " & _
    "ST='CL', QC=B.QLD_ID FROM EVENT A(nolock), MEETING B(nolock) WHERE A.MEETING_ID = B.MEETING_ID " & _
    "AND A.STATUS='CLOSED' AND B.QLD_ID IS NOT NULL ORDER BY A.START_TIME)R " & _
    "UNION ALL SELECT * FROM(" & _
    "SELECT TOP 50 ID=A.MEETING_ID, RC=A.EVENT_NO, VN=B.VENUE, DT=CONVERT(varchar(10), B.MEETING_DATE, 20), " & _
    "ST='OP', QC=B.QLD_ID FROM EVENT A(nolock), MEETING B(nolock) WHERE A.MEETING_ID = B.MEETING_ID " & _
    "AND A.STATUS='OPEN' AND B.QLD_ID IS NOT NULL AND DATEDIFF(n,GETDATE(),A.START_TIME) <= 60 ORDER BY A.START_TIME)R " & _
    "FOR XML AUTO"): While X.Read(): Response.Write(X(0)): End While: X.Close()
  %></M><%

Case "T":
  '-- Data Formats ------------------------------
  ' 0| Event     : Meeting ID, Race No
  ' 1| Pool Size : WN, PL, EX, QN, A2, TF, F4
  ' 2| Dividend  : WN, PL
  ' …|
  ' n| Dividend  : WN, PL
  '----------------------------------------------

  Try
  Dim C() As String, R() As String = Split(Request("D"), vbLf)
  Dim I As Byte, S As String, M As Object = Split(R(0), ","), N As Byte = M(1), G As String = M(2)

  M = getRecord("SELECT MEETING_ID, COUNTRY, TYPE, BTK_ID FROM MEETING(nolock) WHERE MEETING_ID=" & cQS(M(0)))
  If M.Read() Then
    C = Split(R(1), ",")
    S = "UPDATE EVENT SET" & _
      "  QLD_PW=" & cQS(C(0)) & ", QLD_PP=" & cQS(C(1)) & _
      ", QLD_PX=" & cQS(C(2)) & ", QLD_PQ=" & cQS(C(3)) & _
      ", QLD_PD=" & cQS(C(4)) & ", QLD_PT=" & cQS(C(5)) & _
      ", QLD_PF=" & cQS(C(6)) & _
      IIf(G <> "", ", CLOSE_TIME=DATEADD(hh," & (Now - DateTime.UTCNow).Hours - 10 & ",'" & G & "')", "") & _
      " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
    For I = 2 To UBound(R): C = Split(R(I), ",")
      If C(0) <> "" Then S &= _
        "UPDATE RUNNER SET QLD_TW=" & cQS(C(0)) & ", QLD_TP=" & cQS(C(1)) & _
        " WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & " AND RUNNER_NO=" & (I - 1) & vbLf
    Next
    'If InStr("AU,NZ", M("COUNTRY")) > 0 Then
    '  Dim FT As String = "VIC": If M("TYPE") = "G" Then FT = getResult("SELECT GTFAV FROM SYS_BETTEKK(nolock) WHERE CODE='" & M("BTK_ID") & "'",, "AUS")
    '  If FT = "QLD" Then S &= "UPDATE RUNNER SET HST_TW=QLD_TW WHERE MEETING_ID=" & M(0) & " AND EVENT_NO=" & N & vbLf
    'End If
    execSQL(S) %>OK<%

  Else %>ER1<% End If: M.Close()
  Catch %><%= Err.Description %><% End Try

Case Else %>ER0<%
End Select

%>