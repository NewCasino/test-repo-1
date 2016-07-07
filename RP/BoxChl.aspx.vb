Imports System.Data
Imports System.Data.SqlClient

Partial Class BoxChl
    Inherits System.Web.UI.Page

    Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

        GetBoxChlData()
        GetBoxChlDataLXB()

    End Sub

    Sub GetBoxChlData()

        Using RS As Object = getRecord("SELECT  VENUE , BOX_1, BOX_2, BOX_3, BOX_4, BOX_5, BOX_6, BOX_7, BOX_8 FROM Box_Chl b INNER JOIN Meeting m ON b.MEETING_ID = m.MEETING_ID  ORDER BY m.VENUE ")

            While RS.Read()
                Dim r As New TableRow()
                Dim c As New TableCell()
                c.Controls.Add(New LiteralControl(RS("VENUE")))
                c.ColumnSpan = 2
                r.Cells.Add(c)

                For BoxCol = 1 To 8
                    Dim cX As New TableCell()
                    cX.Controls.Add(New LiteralControl(RS("BOX_" & BoxCol)))
                    r.Cells.Add(cX)
                Next

                TableBox.Rows.Add(r)
            End While
        End Using

    End Sub


    Sub GetBoxChlDataLXB()

        Using RS As Object = getRecord("SELECT  VENUE , BOX_1_LXB, BOX_2_LXB, BOX_3_LXB, BOX_4_LXB, BOX_5_LXB, BOX_6_LXB, BOX_7_LXB, BOX_8_LXB FROM Box_Chl b INNER JOIN Meeting m ON b.MEETING_ID = m.MEETING_ID  ORDER BY m.VENUE ")

            While RS.Read()
                Dim r As New TableRow()
                Dim c As New TableCell()
                c.Controls.Add(New LiteralControl(RS("VENUE")))
                c.ColumnSpan = 2
                r.Cells.Add(c)

                For BoxCol = 1 To 8
                    Dim cX As New TableCell()
                    cX.Controls.Add(New LiteralControl(RS("BOX_" & BoxCol & "_LXB")))
                    r.Cells.Add(cX)
                Next

                TableLXB.Rows.Add(r)
            End While
        End Using

    End Sub

    Function Conn(Optional SVR As Byte = 0) As SqlConnection
        Dim X As New SqlConnection(ConfigurationManager.AppSettings("dbConnStr_" & SVR) & _
          " Application Name=[LUXBOOK]" & HttpContext.Current.Request.ServerVariables("SCRIPT_NAME"))

        X.Open()

        Return X

    End Function

    Function getRecord(SQL As String, Optional SVR As Byte = 0) As SqlDataReader
        Return New SqlCommand(SQL, Conn(SVR)).ExecuteReader(CommandBehavior.CloseConnection)
    End Function

    Function sLcDt(DT As Object, F As String) As String

        If IsDBNull(DT) OrElse IsNothing(DT) Then Return ""
        If IsNothing(Session("GMT")) Then Return CDate(DT).ToString(F) Else _
          Return CDate(DT).ToUniversalTime.AddHours(Session("GMT")(0)).AddMinutes(Session("GMT")(1)).ToString(F)

    End Function

End Class
