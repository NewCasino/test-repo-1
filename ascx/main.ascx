<!-- #include virtual="/inc/control.inc" -->
<script language=VBScript runat=server>

Public Type As String, EventID As String, Odds As String

</script>
<script type="text/javascript" src="http://p.jwpcdn.com/6/10/jwplayer.js"></script>
<script type="text/javascript">jwplayer.key="paNMqrqOCHnKJkSCBLRmBrZRS1W+ssQse+Ts7qVOjlg=";</script>


<%	Dim EV As Object = Split(EventID, "_")
	Select Case Type.ToUpper

		Case "VENUE_LIST" '--------------------------------------------------------------------------------
		%>
		  
		  <div id=VNT>
			  <table>
				  <tr height=21>
				  <td>
				  <table>
					  <td width=4>
					  <td width=33>Time
					  <td width=20> FX
					  <td width=62>
					  <td>Race
					  <td width=56>Status
				  </table>
				  <tr>
			  </table>
		  </div>
		  <div id=VNL></div>
		  
		<%
		Case "DATE_LIST" '--------------------------------------------------------------------------------
		%>
			<div id=VNT style="width:150px">
				<table>
					<tr height=21>
					<td>
					<table>
						<td width=4>
						<td width=33>Meeting Date
					</table>
					<tr>
					</table>
			</div>
			<div id=VNL style="width:150px">
				<table>
					<col width=45><col>
				<%	Dim RS As Object = getRecord("SELECT DISTINCT MEETING_DATE FROM MEETING(nolock) ORDER BY MEETING_DATE DESC")
					While RS.Read() %>
						<tr onclick=getRPT('<%= CDate(RS(0)).ToString("yyyy-MM-dd") %>',this)>
						<td>&nbsp;<%= CDate(RS(0)).ToString("ddd") %>
						<td><%= CDate(RS(0)).ToString("dd MMM yyyy") %>
				<%	End While
					RS.Close() %>
				</table>
			</div>
		  
		<%
		Case "CHART_CANVAS" '------------------------------------------------------------------------------
		%>
			<canvas id=GPH width=0 height=400 style="display:none"></canvas>
		
		<%
		Case "LIVE_STREAM" '-------------------------------------------------------------------------------
		%>
			<div id=STV>
				<!--ol id=TVGP>
					<li class=HL onclick=tvGP(0)>AUS
					<li onclick=tvGP(1)>Sports
				</ol -->
				<!--video id=TV0 width=280 height=157 src="http://10.35.2.28:25000" type="video/ogg"  controls autoplay Muted>Loading Video. Please wait...</video>
  <!--embed id=TV0 style="display:" width=280 height=157 flashvars="buffer=0.2" type="application/x-vlc-plugin" pluginspage="http://www.videolan.org"<%  %> 
  target="http://10.35.2.28:25000" " bgcolor="#000000" quality="high" menu="false" scale="noscale" salign="lt" allowfullscreen="true" allowscriptaccess="sameDomain"><%  %>
  <!--embed id=TV0 style="display:" width=280 height=157 flashvars="buffer=0.2" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"<%  %>
  src="/OP/STV.swf" bgcolor="#000000" quality="high" menu="false" scale="noscale" salign="lt" allowfullscreen="true" allowscriptaccess="sameDomain"--><%  %>
  
				<div id=TV0>Loading...</div>
					<script  type="text/javascript">
						jwplayer("TV0").setup({
							file:  "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/sky1.m3u8",
							height: 157,
							width: 280,
							autostart: true,
							mute: true
						});
					</script>
				<iframe id=TV1 style="display:none" width=280 height=157 scrolling=no>
				</iframe>

				<div style="display:">
					<!--ul>
						<li onclick="tvMT(this)" onmousewheel="tvVL(event,this)" style="color:#0c0">&#9835;
						<li onclick="tvRF()">&#8635;
					</ul-->
					<!--button onclick="tvLC('//www.youtube-nocookie.com/embed/qG-xuUIRCuI?rel=0&autoplay=1')" style="width:42px; background:rgba(255,100,95,.7)" -->
					<button onclick="tvCH(1)" style="width:42px; background:rgba(255,100,95,.7)">
						<b>SKY1</b>
					</button>
					<button onclick="tvCH(2)" style="width:42px; background:rgba(75,150,255,.7)">
						<b>SKY2</b>
					</button>
					<button onclick="tvCH(3)" style="width:42px; background:rgba(150,255,75,.7)">
						<b>STC</b>
					</button>
				   &nbsp; 
				   <button onclick=tvSZ(1)>x1</button>
				   <button onclick=tvSZ(2)>x2</button>
				   <button onclick=tvSZ(3)>x3</button>
				</div>
				<!-- Sports display. Drop down list & 3 buttons -->
				<div style="display:none">
					<select onchange="tvCH(this.value)">
						<option value="">- Select a channel -
						<option value="Test1">TEST1</option>
						<option value="Test2">TEST2</option>
					</select>&nbsp; 
					<!--button onclick=tvSZ(1)>x1</button><button onclick=tvSZ(2)>x2</button><button onclick=tvSZ(3)>x3</button-->
				</div>
			</div>
  
		<%
		Case "MEETING_INFO" '------------------------------------------------------------------------------
			If Odds = "" Then Odds = "PM"
		%>
			<div class="MTG <%= Odds %>D">
				<%	Dim RS As Object = getRecord("SELECT * " _
					& "FROM dbo.MEETING_VIEW " _
					& "WHERE MEETING_ID=" & Val(EV(0)) & " AND EVENT_NO=" & Val(EV(1)))
				If RS.Read()  					%>
					<div class=VNU>
						<img src="/img/<%= RS("TYPE") %>.png"> <%= sLcDt(RS("START_TIME"), "hh:mmtt").ToLower	%> 
						<span><%= Val(RS("EVENT_NO")) %></span> <%= sVar(RS("VENUE"), "PTC") %>
					</div>

					<div class=VD1>
						<img src="/img/<%= RS("COUNTRY") %>.jpg"> <% If sNN(RS("CLOSE_TIME")) Then %>
							<b><%= sLcDt(RS("CLOSE_TIME"), "HH:mm:ss") %></b> | <% End If %>
							<%= RS("NAME").ToString.ToUpper %> (<%= RS("COUNTRY") %>) 
							<% If RS("SHOW_PRICE") = "1"  %>
								<span id="showPrice" style="color:#f47b82;">SHOW PRICE ENABLED</span>
							<% End If %>
					</div>

					<div class=VD2>
						<%= RS("STARTERS") %><%= IIf(Odds = "FX" And RS("FX_MODE") > 0, " / " & RS("FX_STARTERS"), "") %> Runners<%
						%> | <%= RS("DISTANCE") %>m<%
						If sNN(RS("CLASS")) Then %> | Class: <%= RS("CLASS") %><% End If
						If Not IsDbNull(RS("PRIZE"))  AndAlso RS("PRIZE") > 0 Then %> | $<%= sVar(RS("PRIZE"), "NUM") %><% End If
						If sNN(RS("TRK_COND")) Then %> | <%= RS("TRK_COND") %><%= IIf(sNN(RS("TRK_RATE")), " (" & RS("TRK_RATE") & ")", "") %><% End If	%>
						<%= " | " & sVar(RS("BTK_ID")) & " | " & sVar(RS("QLD_ID"))	%>
					</div>
					
					<div class="STS 
					<% 	Select Case RS("STATUS")
							Case "OPEN"
								Dim TS As New TimeSpan(0, 0, RS("S2R"))
								If RS("S2R") >= 0 Then %>ST1"><%
									If TS.Days   > 0 Then %><%= TS.Days   %>d <% End If
									If TS.Hours   > 0 Then %><%= TS.Hours   %>h <% End If
									If TS.Minutes > 0 Then %><%= TS.Minutes %>m <% End If
									If TS.Seconds > 0 Then %><%= TS.Seconds %>s <% End If %>Till Jump<%
								Else %>ST0"><%
									If TS.Hours   < 0 Then %><%= Math.Abs(TS.Hours)   %>h <% End If
									If TS.Minutes < 0 Then %><%= Math.Abs(TS.Minutes) %>m <% End If
									If TS.Seconds < 0 Then %><%= Math.Abs(TS.Seconds) %>s <% End If %>Past Jump<%
								End If
							Case "INTERIM", "CLOSED", "PROTEST" %>ST2"><%= RS("STATUS") %><%
							Case "ABANDONED", "SKIP"            %>ST3"><%= RS("STATUS") %><%
							Case "CHECK"                        %>ST0"><%= RS("STATUS") %><%
							Case "DONE"  %>"><%= sLcDt(RS("START_TIME"), "dd MMM yyyy") %><%
							Case Else    %>"><%= RS("STATUS") %><%
						End Select %>
					</div>
			<%	End If
				RS.Close()			%>
			</div>
			
<%	End Select %>	