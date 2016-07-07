<!-- #include file="/inc/page.inc" -->
<script language=VBScript runat=server>

Dim RS As Object

Sub Page_Load()
	'chkSession(7)

	If Request("FCMD") <> "" Then
		Dim S As String = "", L As String
		
		Select case Request("FCMD")
		Case "Save"
			execSQL("IF NOT EXISTS(SELECT * FROM TRADER_LAYOUT WHERE LID = '" & Session("LID") & "') INSERT TRADER_LAYOUT (LID) VALUES ('" & Session("LID") & "')")
			
			L = ""
			For I = 1 To 30
				Dim ColVal as String = ConvStr("COL_" & I )
				'response.write(", COL_" & I & "=" & ConvStr("COL_" & I ) )  
				L &= ", COL_" & I & "=" & ColVal  'ConvStr("COL_" & I )
			Next
			S &= "UPDATE TRADER_LAYOUT SET " & Mid(L, 2) & " WHERE LID='" & Session("LID") & "'" & vbLf			
			
		End Select

		'response.write( vbcrLf & s & vbcrLf	)
		execSQL(S)
		'update active column layout
		Session("PriceCols") = CheckColLayout(Session("LID"))
	End If

End Sub

Function ConvStr( byVal x As String ) As String
	  If Trim(Request(x)) = "" OR Trim(Request(x)) = "NULL" Then 
		Return "NULL" 
	  Else 
		Return "'" & Trim(Replace(Request(x), "'", "''")) & "'"
	  End If
End Function	

Function GetColOptions( SLT As String ) As String

	If IsNothing(Application("MKR_COLS")) Then Application("MKR_COLS") = makeDataSet("SELECT * FROM SYS_CODE WHERE TYPE = 'MKR_COL' ORDER BY Name").Tables(0)
	Dim RS As DataRow() = Application("MKR_COLS").Select("TYPE='MKR_COL'")
	Dim R As DataRow, VL As String, S As String = ""

    For Each R In RS
		VL = R("CODE")
		S &= "<option value='" & VL & "'" & IIf(VL = SLT, " selected", "") & ">" & R("NAME")
    Next

  Return S
End Function
	
</script>

<!DOCTYPE html>
<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="/global.css">
	<script src="/global.js"></script>
	<script>top.setTitle("Maker Page Column Layout")</script>
	<style>#WIP input { width:45px; text-align:right }</style>
	
	<body>
		<div id=CNT style="top:25px; left:25px">
			<form method=post>
				
				<div class=LST>
				<table>
					<col width=60><colgroup span=15>
					<tr><th colspan=16 class=TT>Maker Page Column List
					<tr>
					<tr height=20 class="GY SML"><th>ID
					<% For I = 1 To 15 %>
						<th><%= I %>
					<%Next %>
					<%
					RS = getRecord("SELECT  TOP(1) *  FROM ( SELECT * FROM TRADER_LAYOUT WHERE LID = '" & Session("LID") & "' UNION SELECT * FROM TRADER_LAYOUT WHERE LID = 'LUXBET' ) Q1")
					While RS.Read  %>
						<tr>
							<td><b><%= Session("LID") %>
							<% For I = 1 To 15 %>
								<td><select name='COL_<%= I %>' style="width:92%"><%= GetColOptions(If(IsDBNull(RS(I)) ,"NULL" , RS(I))) 	%></select>
							<%Next %>
						<tr height=20 class="GY SML"><th>
							<% For I = 16 To 30 %>
								<th><%= I %>
							<%Next %>
						<tr>
							<td>
							<% For I = 16 To 30 %>
								<td><select name='COL_<%= I %>' style="width:92%"><%= GetColOptions(If(IsDBNull(RS(I)) ,"NULL" , RS(I)))  %></select>
							<%Next
					End While
					RS.Close %>
				</table>
				</div>
				<div class=EDT>
					<input type=reset value="Undo"> 
					<input type=submit name=FCMD value="Save">
				</div>

			</form>
		</div>

	</body>
</html>