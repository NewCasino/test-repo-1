Imports system
Imports System.Data
Imports System.Data.SqlClient

Partial Class MthRpt_aspx
    Inherits System.Web.UI.Page

    Public RCtype As String

    Sub Page_Load()

        RCtype = Request("RTY")

    End Sub

    Function RaceType(RT As String) As String
        Select Case RT
            Case "R"
                Return "Horse"
            Case "H"
                Return "Harness"
            Case "G"
                Return "Dogs"
            Case "I"
                Return "International"
        End Select

    End Function

    Function Tdate(Trddate As Integer, TMth As Integer) As String

        Try
            'Return CDate(Trddate & "/" & TMth).ToString("ddd dd")
			Return CDate(TMth & "/" & Trddate).ToString("ddd dd")   'AWS uses a mth/day format !
        Catch ex As Exception
            Return " "
        End Try

    End Function

    Function FormatBilling(x As Double) As String
        If x = 0 Then Return ""

        If x < -0.001 Then
            Return "<font class=NEG>(" & FormatNumber(Math.Abs(x)) & ")</font>"
        Else
            Return "<font class=PSV>" & FormatNumber(x) & "</font>"
        End If
    End Function

    Function FormatPercent(x As Double) As String

        If x = 0 Then Return ""

        If x < -0.001 Then
            Return "<font class=NEG>" & x & "</font>"
        Else
            Return "<font class=PSV>" & x & "</font>"
        End If
    End Function

    Public Function GetTradeReport(Rtype As String) As Double(,)

        Dim TradeData(32, 9) As Double

        'Daily totals
        For Mday As Integer = 1 To 31
            'first mth
            DailyTotals(Year(Now.AddMonths(-2)) & "-" & Month(Now.AddMonths(-2)) & "-" & Mday, TradeData(Mday, 0), TradeData(Mday, 1), TradeData(Mday, 2), Rtype)
            'Last mth
            DailyTotals(Year(Now.AddMonths(-1)) & "-" & Month(Now.AddMonths(-1)) & "-" & Mday, TradeData(Mday, 3), TradeData(Mday, 4), TradeData(Mday, 5), Rtype)
            'current
            DailyTotals(Year(Now) & "-" & Month(Now) & "-" & Mday, TradeData(Mday, 6), TradeData(Mday, 7), TradeData(Mday, 8), Rtype)
            'Monthly Totals (row 32)
            TradeData(32, 0) += TradeData(Mday, 0) : TradeData(32, 1) += TradeData(Mday, 1) '   'first
            TradeData(32, 3) += TradeData(Mday, 3) : TradeData(32, 4) += TradeData(Mday, 4) '    'Last
            TradeData(32, 6) += TradeData(Mday, 6) : TradeData(32, 7) += TradeData(Mday, 7) '    'current
        Next

        If TradeData(32, 0) > 0 Then TradeData(32, 2) = math.round(TradeData(32, 1) * (100 / TradeData(32, 0)), 1)
        If TradeData(32, 3) > 0 Then TradeData(32, 5) = math.round(TradeData(32, 4) * (100 / TradeData(32, 3)), 1)
        If TradeData(32, 6) > 0 Then TradeData(32, 8) = math.round(TradeData(32, 7) * (100 / TradeData(32, 6)), 1)

        Return TradeData

    End Function

    Function sNN(x As Object) As Boolean
        Return Not (IsDBNull(x) OrElse IsNothing(x))
    End Function

    Function sN0(x As Object) As Double
        If IsDBNull(x) OrElse IsNothing(x) Then Return 0 Else Return x
    End Function

    Sub DailyTotals(DT As String, ByRef Tval As Double, ByRef Profit As Double, ByRef Yld As Double, Rtype As String)
        Dim TA(,) As Double = {{0, 0, 0}, {0, 0, 0}}

        If Not IsDate(DT) Then Exit Sub

        Dim RM2 As DataTable = makeDataSet("SELECT MEETING_ID, TYPE, COUNTRY, VENUE FROM MEETING(nolock) " & _
         "WHERE MEETING_DATE='" & DT & "' AND COUNTRY " & If(Rtype = "I", "NOT", "") & " IN('AU','NZ') " & If(Rtype = "I", "", "AND TYPE =('" & Rtype & "')") & " ORDER BY TYPE DESC, COUNTRY, VENUE").Tables(0)  'getRecord  DataTable

        For Each RM As DataRow In RM2.Rows

            Dim TM(,) As Double = {{0, 0, 0}, {0, 0, 0}}
            Dim RV2 As DataTable = makeDataSet("SELECT TPM_HST, TPM_VIC, TPM_NSW, TPM_QLD,  TXT_VIC, TXT_NSW, TXT_QLD, " &
              "EVENT_NO, TRADER, OBSV, COMMENT, STATUS FROM EVENT(nolock) WHERE MEETING_ID=" & RM("MEETING_ID") & " ORDER BY EVENT_NO").Tables(0)   'getRecord  DataTable

            Dim RV As New DataTableReader(RV2)  'needed for GetNames
            While RV.Read

                Dim KY As String = RM("MEETING_ID") & "_" & RV("EVENT_NO")
                Dim DR As DataRow, TD(,) As Double = {{0, 0, 0}, {0, 0, 0}}
                Dim DV As DataTable = makeDataSet("SELECT * FROM RESULTS(nolock) WHERE GAME <> '#' AND " & _
                         "MEETING_ID=" & RM("MEETING_ID") & " AND EVENT_NO=" & RV("EVENT_NO")).Tables(0) '.Tables(0)  'makeDataSet DataTable
                DV.PrimaryKey = New DataColumn() {DV.Columns(2), DV.Columns(3)}

                If RV("STATUS") = "DONE" Then

                    '-- Calculate WIN-PLA Investments
                    For I As Byte = 0 To 3
                        If sNN(RV(I)) Then
                            For Each R As String In RV(I).ToString.Split(vbLf)
                                If R <> "" And Left(R, 1) <> "#" Then
                                    Dim C() As String = R.Split(vbTab)
                                    TD(0, 0) -= CDbl(C(4))
                                    TD(0, 1) += CDbl(C(7)) + CDbl(C(8))
                                    DR = DV.Rows.Find({Left(C(2), 1), C(0)})		'DV= results for VIC/NSW/QLD
                                    Try													'races with 2 winners can cause null data errors
                                        If Not IsNothing(DR) Then TD(0, 2) += Val(C(4)) * DR(Right(RV.GetName(I), 3))  	  'Getname gets tote name(from TPM_xxx col) to select result col in DR(results)
                                    Catch ex As Exception : End Try
                                End If
                            Next
                        End If
                    Next

                    '-- Calculate Exotics Investments
                    For I As Byte = 4 To 6
                        If sNN(RV(I)) Then
                            For Each R As String In RV(I).ToString.Split(vbLf)
                                If R <> "" And Left(R, 1) <> "#" Then
                                    Dim C() As String = R.Split(vbTab)
                                    TD(1, 0) -= CDbl(C(3))
                                    TD(1, 1) += CDbl(C(4)) / 100
                                    DR = DV.Rows.Find({Left(C(1), 1), C(0)})
                                    Try
                                        If Not IsNothing(DR) Then TD(1, 2) += Val(C(3)) * sN0(DR(Right(RV.GetName(I), 3))) 'races with 2 winners can cause null data errors
                                    Catch ex As Exception : End Try
                                End If
                            Next
                        End If
                    Next

                    '-- Display Total Investments, Results & Dividend
                    '-- Add Up Total per Meeting
                    TM(0, 0) += TD(0, 0) : TM(0, 1) += TD(0, 1) : TM(0, 2) += TD(0, 2)
                    TM(1, 0) += TD(1, 0) : TM(1, 1) += TD(1, 1) : TM(1, 2) += TD(1, 2)

                Else

                End If
            End While
            RV.Close()

            '-- Display Total per Meeting

            '-- Add Up Daily Total
            TA(0, 0) += TM(0, 0) : TA(0, 1) += TM(0, 1) : TA(0, 2) += TM(0, 2)
            TA(1, 0) += TM(1, 0) : TA(1, 1) += TM(1, 1) : TA(1, 2) += TM(1, 2)

        Next

        RM2.Dispose()

        Dim DlyTrade As Decimal = -(TA(0, 0) + TA(1, 0))
        Dim DlyPft As Decimal = (TA(0, 0) + TA(0, 1) + TA(0, 2) + TA(1, 0) + TA(1, 1) + TA(1, 2))

        Tval = Decimal.Round(DlyTrade, 2)
        Profit = Decimal.Round(DlyPft, 2)

        If DlyTrade > 0 Then Yld = CDbl(Decimal.Round(DlyPft * (100 / DlyTrade), 1))

    End Sub

    Function makeDataSet(SQL As String, Optional SVR As Byte = 0) As DataSet
        Dim CN As SqlConnection = Conn(SVR)
        Dim DA As New SqlDataAdapter()
        DA.SelectCommand = New SqlCommand(SQL, CN)
        Dim DS As New DataSet
        DA.Fill(DS)
        DA.Dispose()
        CN.Close()
        Return DS
    End Function

    Function Conn(Optional SVR As Byte = 0) As SqlConnection
        Dim X As New SqlConnection(ConfigurationManager.AppSettings("dbConnStr_" & SVR) & _
          " Application Name=[LUXBOOK]" & Request.ServerVariables("SCRIPT_NAME"))
        X.Open()
        Return X
    End Function

End Class