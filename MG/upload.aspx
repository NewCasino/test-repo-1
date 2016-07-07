<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Upload.aspx.vb" Inherits="Upload"  %>

<!DOCTYPE html>
<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="/global.css">
	<script src="/global.js"></script>
	<script>top.setTitle("Upload Data")</script>
	
	<body>
		<div id=CNT style="top:30px; left:30px; width:600px">
			<form method=post enctype="multipart/form-data" runat="server">
				<div class=LST>
					<table cellspacing=0 cellpadding=6>
						<col width=110><col><col width=170>
						<tr>
							<th><th>File Names<th>Date

						<tr title="Australia Class Values">
							<td class=WRP><img class=FLG src="/img/AU.jpg"> <img src="/img/R.png"><b>Upload AUS Class
							<td><asp:FileUpload ID="AUclassUpload" runat="server" />
							<td>
							
						<tr title="Daily Manager Report">
							<td class=WRP><img src="/img/logo.png" height="18" width="50"><p><b>Manager Report Upload
							<td><asp:FileUpload ID="FileUpload1" runat="server" />
							<td><asp:Calendar ID="MRCalendar" runat="server"><TodayDayStyle BackColor="#00ff00" /> </asp:Calendar>
						<tr>
							<td title="Weekly Report" class=WRP><b>Download Weekly Report
							<td><asp:Button id="btnWKREP" Text="Download" runat="server"  OnClick="ExportCSV"/>  
							<td>Select report end date above
						<tr>
							<td colspan=3><asp:Label ID="lblMessage" runat="server" Text="-"  Font-Names = "Arial"></asp:Label>
					</table>
				</div>

				<div class=EDT>
					<input type=reset value="Clear">
					<asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
				</div>
			</form>
		</div>
	</body>
</html>

