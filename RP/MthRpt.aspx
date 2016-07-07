<%@ page language="VB" CodeFile="MthRpt_vb.aspx.vb" Inherits="MthRpt_aspx" %>
<script language=VBScript runat=server>

</script>	
	
<html>
	  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
	  <link rel="stylesheet" href="/global.css">
	  <script src="/global.js"></script>
	  <script>
		top.setTitle("Monthly Trade Report "); 
	  </script>
	<head>
		<title></title>
	</head>
	<body>
		
		<br>
		<div class=MTG>
			<div class=VNU style="font-size:21px">Pari-Mutuel Market Monthly Trading Report</div>
			<div class="STS ST3">BY BET TYPE (<%= RaceType(RCTYPE) %>)</div>
			<div class=VD1 style="top:30px"><%= CDate(Now).ToString("dddd, dd MMMM yyyy") %></div>
			<div class=VD2>Created at: <%= CDate(Now).ToString("dd MMM yyyy hh:mmtt") %></div>
		</div>
		
		<form runat="server">
		<% Dim TradeData as double(,)  = GetTradeReport(RCTYPE) %>
		  
			<div class=LST>
				<table>
					<col width=100><col width=100><col width=100><col width=100>
					<col width=100><col width=100><col width=100><col width=100>
					<col width=100><col width=100><col width=100><col width=100>
					
					<tr>
						<th colspan=4><h3><%= CDate( Now.AddMonths(-2)).ToString("MMMM yyyy") %></h3>
						<th colspan=4><h3><%= CDate( Now.AddMonths(-1)).ToString("MMMM yyyy") %></h3>
						<th colspan=4><h3><%= CDate(Now).ToString("MMMM yyyy") %></h3>
					<tr>
						<th>Date<th>Trade<th>Profit<th>Yield %<th>Date<th>Trade<th>Profit<th>Yield %<th>Date<th>Trade<th>Profit<th>Yield %
					<!-- each row of data (31 days) -->
					<% For DateCnt as integer = 1 to 31 %>
					<tr>
						<!-- -2mth -->
						<td class=HN><%=  Tdate(DateCnt , Now.Month - 2 ) %>
						<td class=NM><%= FormatBilling(TradeData(DateCnt, 0)) %>
						<td class=NM><%= FormatBilling(TradeData(DateCnt, 1)) %>
						<td class=NMC><%= FormatPercent(TradeData(DateCnt, 2)) %>
						<!-- last mth -->
						<td class=HN><%= Tdate(DateCnt , Now.Month - 1 ) %><!-- %'  Try : CDate( DateCnt & "/" & Now.Month - 1 ).ToString("ddd dd") : Catch : End Try% -->
						<td class=NM><%= FormatBilling(TradeData(DateCnt, 3)) %>
						<td class=NM><%= FormatBilling(TradeData(DateCnt, 4)) %>
						<td class=NMC><%= FormatPercent(TradeData(DateCnt, 5)) %>
						<!-- current mth -->
						<td class=HN><%=  Tdate(DateCnt , Now.Month  ) %>
						<td class=NM><%= FormatBilling(TradeData(DateCnt, 6)) %>
						<td class=NM><%= FormatBilling(TradeData(DateCnt, 7)) %>
						<td class=NMC><%= FormatPercent(TradeData(DateCnt, 8)) %>
					<% next %>
					<tr>
						<td colspan=12 class=SPT>
					<tr class=TOT height=25>
						<td class=TFN><b>Monthly Totals</b>
						<td class=NM><b>$ <%= FormatBilling(TradeData(32, 0)) %></b>
						<td class=NM><b>$ <%= FormatBilling(TradeData(32, 1)) %></b>
						<td class=NMC><b><%= FormatPercent(TradeData(32, 2)) %>%</b>
						<td>
						<!-- -->
						<td class=NM><b>$ <%= FormatBilling(TradeData(32, 3)) %></b>
						<td class=NM><b>$ <%= FormatBilling(TradeData(32, 4)) %></b>
						<td class=NMC><b><%= FormatPercent(TradeData(32, 5)) %>%</b>
						<td>
						<!-- -->
						<td class=NM><b>$ <%= FormatBilling(TradeData(32, 6)) %></b>
						<td class=NM><b>$ <%= FormatBilling(TradeData(32, 7)) %></b>
						<td class=NMC><b><%= FormatPercent(TradeData(32, 8)) %>%</b>

					<tr>
						<td colspan=12 height=12 class=SCR>	
				</table>
			</div>
		</form>
	</body>
</html>

