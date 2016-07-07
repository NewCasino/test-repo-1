<!DOCTYPE html>
<html>
	<head>
		
		<title>Rubix Racing</title>
		<meta name="viewport" content="width=device-width, initial-scale=0.6, maximum-scale=1.0, user-scalable=yes">
		<link rel="stylesheet" href="/global.css">
			<script src="/js//moment.min.js"> </script>
			<script src="/js/jquery.min.js"> </script>

		<script src="/global.js"></script>
		<!--script type="text/javascript" src="/jwplayer/jwplayer.js"></script-->
		<script>
			function setTitle( x ) { var y = $("TTL"); 
									if( y ) y.innerHTML = x + ""; 
									else setTimeout("setTitle('" + x + "')", 15); } 
			function GO(x, y) { DTL.location.replace(x + ".aspx" + (y ? "?" + y : "")) }
			// This function is meant to be used with new MVC pages
			function MVC(url, parameters) { DTL.location.replace(url + (parameters ? "?" + parameters : "")); }
			function G2( x, y ) { setTitle(x); 
									DTL.location.replace("http://" + y) } 
			<%If Session("LID") <> "" Then %>
				function HB() { x = $W("_hbeat.aspx"); 
								if( !x ) top.location.reload();
				    //setTimeout("HB()", 60000);
				}; 
			<% End If%>
				
		</script>
	</head>

	<body<%= IIf(Session("LID") <> "", " onload=""setTimeout('HB()', 60000)""", "") %>>
		<div id=DTL>
			<iframe name=DTL src="login.aspx"></iframe>
		</div>

		<ul id=MNU>
		<% If Session("LID") <> "" Then  %>
		
			<li onclick="">Market
			<ul>
				<li onclick="GO('MM/PM1')">Maker
				<% If Session("LVL") < 7 Then%>
				<li onclick="GO('MM/PM2')">Trader
				<li onclick="GO('MM/XT')">PM Exotics
				<li onclick="GO('MM/PMtrd')">PM Trades
				<li onclick="MVC('Luxbook.MVC/Liability/Index')"/> Liability monitor
				<%	End If    %>
                <li onclick="MVC('Luxbook.MVC/Alerts/Index')">Alerts
				<li onclick="GO('MM/MV')">Movement
				<%	If Session("LVL") = 10    %>
					<li onclick="GO('RP/TH')">Trade History</li>  <!-- Media user only-->
				<% End If%>	
			</ul>
			</li>

			<%	If Session("LVL") < 10    %>
				<li onclick="">Live Reports
				<ul>
					<%	If Session("LVL") < 8    %>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Greyhounds')">Dogs - By Type</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Pool','RaceType=Greyhounds')">Dogs - By Pool</li>
					<hr>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Races')">Horses - By Type</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Harness')">Trots - By Type</li>
					<hr>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Races&InternationalsOnly=true')">Horses(Int)- By Type</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Harness&InternationalsOnly=true')">Trots(Int)- By Type</li>
					<hr>				
					<li onclick="GO('RP/TH')">Trade History</li>
					<hr>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=Races')">Monthly - Horse</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=Harness')">Monthly - Harness</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=Greyhounds')">Monthly - Dogs</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=7&InternationalsOnly=true')">Monthly - Int.</li>
					<hr>
					<%	End If    %>
					<li onclick="GO('RP/BoxChl')">Box Challenge</li> 
				</ul>
				</li>
				<%	If Session("LVL") < 8    %>
				<li onclick="">Paper Reports
				<ul>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Greyhounds&PaperTrades=true')">Dogs - By Type</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Pool','RaceType=Greyhounds&PaperTrades=true')">Dogs - By Pool</li>
					<hr>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Races&PaperTrades=true')">Horses - By Type</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Harness&PaperTrades=true')">Trots - By Type</li>
					<hr>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Races&InternationalsOnly=true&PaperTrades=true')">Horses(Int)- By Type</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Type','RaceType=Harness&InternationalsOnly=true&PaperTrades=true')">Trots(Int)- By Type</li>
					<hr>				
					<li onclick="GO('RP/TH')">Trade History</li>
					<hr>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=Races&PaperTrades=true')">Monthly - Horse</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=Harness&PaperTrades=true')">Monthly - Harness</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=Greyhounds&PaperTrades=true')">Monthly - Dogs</li>
					<li onclick="MVC('Luxbook.MVC/Reports/Monthly','RaceType=7&InternationalsOnly=true&PaperTrades=true')">Monthly - Int.</li>
				</ul>
				</li>
				<%	End If    %>
				   
				<li onclick="">Manager
				<ul>
					<li onclick="GO('MG/upload')">Upload Data
					<%  If Session("LVL") < 8	Then	%>
						<% If Session("LUX") Then %>
							<li onclick="GO('MG/setting')">Parameters LUX
							<li onclick="GO('MG/mixer')">Price Blend LUXBET
						<%	End If  %>
						<% If Session("SUN") Then %>
							<li onclick="GO('MG/setting_SUN')">Parameters SUN
							<li onclick="GO('MG/mixer_SUN')">Price Blend SUN
						<%	End If  %>
						<% If Session("TAB") Then %>
							<li onclick="GO('MG/setting_TAB')">Parameters TAB
							<li onclick="GO('MG/mixer_TAB')">Price Blend TAB
						<%	End If  %>
						<li onclick="MVC('Luxbook.MVC/Staking/Index')">Stakings
						<li onclick="GO('MG/matrix')">Var. Matrix
						<li onclick="GO('MG/AccessLog')">Access Log
						<li onclick="MVC('Luxbook.MVC/Rules/Manage')"/> Alert Rules
						<li onclick="MVC('Luxbook.MVC/MeetingMatch/Index')"/> Venues
						<%  If Session("LVL") <= 1	OrElse Session("LVL") = 5	%>
						<li onclick="MVC('Luxbook.MVC/TradeManagement/Accounts')"/> Trading Accounts
						<% End If %>
					<!--<li onclick="MVC('Luxbook.MVC/MaxExposure/Index')"/> Exposure -->
					<%	End If  %>
				</ul>
				</li>
				<%  If Session("LVL") < 8		%>	
					<li onclick="">Diagnostics
					<ul>
						<li onclick="GO('_soon')">Trading P & L</li>
						<li onclick="GO('_soon')">Operational Risk</li>
						<li onclick="GO('_soon')">Model Simulation</li>
						<li onclick="GO('_soon')">Model Diagnostics</li>
					</ul>
					</li>
					
					<li onclick="">Video
					<ul>
						<li onclick="GO('_soon')">FOX 1</li>
						<li onclick="GO('_soon')">FOX 2</li>
						<li onclick="GO('_soon')">FOX 3</li>
					</ul>
					</li>
					
				<%	End If  %>
			<%	End If  %>
				
			<li onclick="">Account
			<ul>
				<li onclick="GO('profile')">Profile</li>
                <%  If Session("LVL") < 10 Then%>
					<li onclick="GO('MG/MakerLayout')">Maker Layout
				<%	End If  %>
				<hr>
				<li onclick="GO('logout')">Logout</li>
			</ul>
			</li>
		  
		<%  End If %>

		</ul>
			
		<div id=TTL></div>
		
		<%	If Session("LID") <> "" Then %>
			<div id=ACC><%= Session("ACC") %> &ndash; <%= Session("LNM") %></div>
		<% End If%>
		<img id=CLG src="img/logo.png">
		<script type="text/javascript">
		<%If Session("LID") <> "" AND Request("redirect") <> "" Then %>
			DTL.location = '<%=Request("redirect")%>';
		<% End If%>		
		</script>
	</body>
</html>