
Imports System.Data
Imports System.Data.SqlClient

Partial Class AccessLog
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        GetLoginData()
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

    Sub GetLoginData()

        Using RS As Object = getRecord("SELECT * FROM TRADER_LOG_VIEW WHERE PORTAL=0 AND DTM_IN >= '" & Now.AddDays(-2).ToString("yyyy-MM-dd") & "' ORDER BY DTM_IN DESC")
            While RS.Read()
                Dim r As New TableRow()
                Dim c As New TableCell()
                c.Controls.Add(New LiteralControl(RS("NAME")))
                r.Cells.Add(c)

                Dim c0 As New TableCell()
                c0.Controls.Add(New LiteralControl(RS("DEPT")))
                r.Cells.Add(c0)

                Dim c1 As New TableCell()
                c1.Controls.Add(New LiteralControl(sLcDt(RS("DTM_IN"), "dd MMM, HH:mm")))
                r.Cells.Add(c1)

                Dim c2 As New TableCell()
                c2.Controls.Add(New LiteralControl(sLcDt(RS("DTM_OUT"), "dd MMM, HH:mm")))
                r.Cells.Add(c2)

                USERTAB.Rows.Add(r)
            End While
        End Using

    End Sub

End Class