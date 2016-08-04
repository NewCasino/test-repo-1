var memVNL = "", curVNL = "", memSPD = "", posVNL = null,   tmrEVN = null /* timer ID */ , timerPause = false, timerPauseCount = 0;

function toNum( x ) { return ( isNaN(x) )? 0: x * 1  }
function xNW() { try { return new XMLHttpRequest } catch(e) { try { return new ActiveXObject("Msxml2.XMLHTTP.6.0") } catch(e) { return new ActiveXObject("Msxml2.XMLHTTP") } } }
function xDL( X ) { try { delete X; X = null; CollectGarbage() } catch(e) {} }

function $( X )  { return document.getElementById(X) }
function $N( X ) { return document.getElementsByName(X) }
function $T( X ) { return document.getElementsByTagName(X) }
function $W( U ) { var X = xNW(), R = ""; if( X ) { X.open("GET", U, false); X.send(); if( X.status == 200 ) R = X.responseText; xDL(X) } return R }
function $R( U, F ) { var X = xNW(); if( X ) { X.open("GET", U, true); X.onload = function() { if( X.status == 200 ) F(X.responseText); xDL(X) }; X.send() } }

function vCX( x ) { x = $(x); x.style.display = ( x.style.display == "none" )? "": "none" }
function cNM( x, y, z ) { z = z?z:0; if( x.value < z ) x.value = z; if( x.value > y ) x.value = y }

function sLcDt( X ) { var T = new Date(parseInt(X, 16) * 1000); return T.toTimeString().substr(0,5) }


function tvGP( m ) {
  var i, G = $("TVGP").childNodes, D = $("STV").getElementsByTagName("DIV");
  for( i = 0; i < 2; i++ ) if( i != m ) { G[i].className = ""; $("TV" + i).style.display = D[i].style.display = "none"; }
  G[m].className = "HL";  $("TV" + m).style.display = D[m].style.display = "";
  if( m == 0 ) { $("STV").getElementsByTagName("SELECT")[0].value = ""; $("TV1").src = "" }
}

function tvSZ( m ) {
  var  P = $("TV0"), V = $("VNT"), L = $("VNL");
  switch(m) {
    case 1: P.width = 280; P.height = 157; jwplayer("TV0").resize(280,157); break;
    case 2: P.width = 640; P.height = 360; jwplayer("TV0").resize(640,360);break;
    case 3: P.width = 960; P.height = 540; jwplayer("TV0").resize(960,540);
  } if( V ) switch(m) {
    case 1: V.style.bottom = "188px"; L.style.bottom = "203px"; break;
    case 2: V.style.bottom = "391px"; L.style.bottom = "406px"; break;
    case 3: V.style.bottom = "571px"; L.style.bottom = "586px";
  }
 }

 function tvCH( ChNo )  { var tvURL;
	switch(ChNo) {
		case 1: tvURL = "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/sky1.m3u8" ; break;
		case 2: tvURL = "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/sky2.m3u8" ;break;
		case 3: tvURL =  "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/skyrnsw.m3u8";
	};
	jwplayer("TV0").load([{file:tvURL}]);
 }

var _tvMT = 0, _tvVL = 100;
function tvLC( m ) { $("TV0").LoadChannel(m, _tvMT, _tvVL) }
function tvMT( x ) { $("TV0").MuteTV(); x.style.color = _tvMT?"#0c0":"#d00"; _tvMT = !_tvMT }
function tvRF()    { $("TV0").RefreshTV() }
function tvVL( e, x ) {
  var W = e.wheelDelta; W = _tvVL + (W / Math.abs(W)) * 2; W = (W > 300)? 300: (W < 2)? 2: W;
  $("TV0").SetVolume(W); _tvVL = W; _tvMT = 0; x.style.color = "#0c0";
}

/*
function tvCH1()  { jwplayer("TV0").setup({
							file:  "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/sky1.m3u8",
							autostart: true,
							height: 157,
							width: 280,							
						}); }
						
function tvCH2()  { jwplayer("TV0").setup({
							file:  "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/sky2.m3u8",
							autostart: true,
							height: 157,
							width: 280,
							}); }
							
function tvCH3()  { jwplayer("TV0").setup({
							file:  "http://kitdigitaioslive-i.akamaihd.net/hls/live/219670/skyr_ios_unblocked/skyrnsw.m3u8",
							autostart: true,
							height: 157,
							width: 280,
							}); }
*/
//load replays from Sky channel														//eg. "http://media.skyracing.com.au/Race_Replay/2014/10/20141028GAWG09_V.mp4",
function tvReplay( vidID )  { jwplayer("TV0").setup({
							file:  "http://media.skyracing.com.au/Race_Replay/" + vidID + "_V.mp4" ,
							autostart: true,
							height: 157,
							width: 280,
							}); }


function iFC( x ) {
  $("divDSP").innerHTML = "Change: " + x; clearTimeout(tmrEVN); var i, y = $N("FCMD");
  for( i = 0; i < y.length; i++ ) if( y[i].id != "btnUPDT" ) y[i].disabled = true
}

function iBL() { $("divDSP").innerHTML = "Updating..."; tmrEVN = setTimeout('$("btnUPDT").click()', 10) }

function iNR( x, y, m ) { var i, p, t = 0, a = [];
  if( m ) for( i = 10, p = 0; i < 330; i+=10 ) { if($N(x + i)[0]) a[p++] = i }
  else    for( i =  1, p = 0; i <  31; i++   ) { if($N(x + i)[0]) a[p++] = i }
  for( i = 0; i < a.length; i++ ) { p = toNum($N(x + a[i])[0].value); if(p > 0) t += 100 / p }
  if( Math.round(t * 10) / 10 != y ) for( i = 0; i < a.length; i++ ) { p = $N(x + a[i])[0];
    if( toNum(p.value) > 0 ) p.value = Math.round(toNum(p.value) * t * 10) / (y * 10) }
}

function iHS( x ) { $("btnUPDT").value = "Update Runner"; $N("RNR_NO")[0].value = x; $("btnUPDT").click() }


function KD( ev, n ) {
  var ch = ev.keyCode, nx = null, pv = null, i, fn = n.name.substr(0, n.name.lastIndexOf("_")), id = toNum(n.name.substr(n.name.lastIndexOf("_") + 1));
  for( i = id + 1; i != id && !nx; i = (i % 330) + 1 ) nx = $N(fn + "_" + i)[0];
  for( i = (id == 1)? 330: id - 1; i != id && !pv; i = (i == 1)? 330: i - 1 ) pv = $N(fn + "_" + i)[0];
  if( ch == 9 ) { if( ev.shiftKey ) { pv.focus(); pv.select(); } else { nx.focus(); nx.select(); } return false; }
  else if( ch == 8 || ch == 46 || (ch > 47 && ch < 58) || (ch > 95 && ch < 106) || (ch == 110 || ch == 190) ) return true;
  return false;
}


function getRPT( x, y ) {
  if( y ) { if( posVNL ) posVNL.className = ""; y.className = "CLK"; curVNL = x; posVNL = y }
  $R(location.pathname + "?DT=" + x, function(R) { $("CNT").innerHTML = R });
}

// Get Event data. Fills page with event info and runner data. Sets timer to auto refresh in 5 secs
function getEVN( x, y, n ) {
   if(handleTimerPause(x)){
      return;
    }

  if( tmrEVN ) clearTimeout(tmrEVN);
  if( y ) { if( posVNL ) posVNL.className = ""; y.className = "CLK"; curVNL = x; posVNL = y }
  $R((n? n+".aspx": location.pathname) + "?EV=" + (x? x: curVNL + "&VM=1"), function(R) {

    if(handleTimerPause(x)){
      return;
    }

    if( R.substr(0,8) == "<ScRIpT>" ) eval(R.replace("<ScRIpT>","").replace("</ScRIpT>","")); else {
      R = R.replace(/SLK\_AG\=\'/g, "img src='/Jersey/AG/")
           .replace(/SLK\_UG\=\'/g, "img src='/Jersey/UG/")
           .replace(/SLK\_SR\=\'/g, "img src='http://silks.skyracing.com.au/silks/");
      if( $("C1") && $("C2") ) { var b = ["HST","VIC","NSW","QLD"], d, i, j;
        R = R.split("<!--[ Next_Content ]-->"); $("C1").innerHTML = R[0];
        for( i = 0; i < b.length; i++ ) for( j = 0; j < 7; j++ ) { d = $("tb" + b[i] + j); 
          d = "=tb" + b[i] + j + " style='display:" + (d? d.style.display: "none") + "'";
          R[1] = R[1].replace("=tb" + (b[i] + j), d);
        } $("C2").innerHTML = R[1];
      } else { $("CNT").innerHTML = R; if($("SPG") && memSPD == "SPG") vSPD($("SPD"), "SPG"); else vSPD($("SPG"), "SPD") }
    }
  }); if( x && !n ) tmrEVN = setTimeout("getEVN('" + x + "')", 5000);
}

function handleTimerPause(x){
   if(timerPause === true) {

     timerPauseCount++;
      if(timerPauseCount <= 3){
        console.log('timer paused');
        tmrEVN = setTimeout("getEVN('" + x + "')", 5000);
        return true;
      }
    }
    // if we exceed more than 2 rounds of refresh, we unpaause it just in case the trader accidentally paused it.
    timerPauseCount = 0;
    timerPause = false;

    return false;
}
function vSPD( x, y ) { if(x) x.style.display = "none"; if($(y)) $(y).style.display = ""; memSPD = y }


//F[] defined in venues.aspx. 0=Cty 1=RType 2=MtgID 3=St_time 4=EvNo 5=venue 6=Status 7=M2R 8=MissingLXB 9=FX count 10=?
function getVNL( G, C, FX ) {
  $R("/venues.aspx", function(R) {
    var i, j, k = 0, S = "", F;
    if( memVNL != R ) { memVNL = R; R = R.split("\n");
      var D = C.replace(/1/,"AU").replace(/2/,"HK,JP,MO,MY,SG,UA,KO").replace(/3/,"FR,IR,UK,NO,SW,DE,FI").replace(/4/,"ZA").replace(/5/,"US,SE,CH,AR,UR").replace(/6/,"NZ");
      for( i = 0; i < R.length - 1; i++ ) { F = R[i].split("\t"); F[7] = toNum(F[7]);
        if( G.indexOf(F[1]) >= 0 && D.indexOf(F[0]) >= 0 ) {
          if( curVNL == F[2] + "_" + F[4] ) j = k;
          S += "<tr" + (curVNL == F[2] + "_" + F[4]?" class=CLK":"") + " onclick=getEVN('" + F[2] + "_" + F[4] + "',this)" + (F[10]=="!"?" style='background:#ff8'":"") + ">";
          S += "<td>" + sLcDt(F[3]) + "<td class=ST0>" + (F[9]>0?"F" + F[9]:"") + "<td>" + (F[0]?"<img src='/img/" + F[0] + ".jpg'>":"") + "<td><img src='/img/" + F[1] + ".png'><td>" + F[4] +
               "<td" + (FX && F[10] && "RYG".indexOf(F[10]) > -1?" class='ALR C" + F[10] + "'":"") + ">" + F[5] ;
          switch( F[6].toUpperCase() ) {
            case "OPEN": S += (F[7] <-60)? "<td class=ST0>Open": (F[7] <  1)? "<td class=ST0>" + F[7] + "m":
                              (F[7] < 61 && F[8]!=1)? "<td class=ST1>" + F[7] + "m": (F[7] < 61 && F[8]==1)? "<td class=ST4>" + F[7] + "m": "<td class=ST1>Open"; break;
            case "CLOSED": case "INTERIM": case "PROTEST": case "FINAL": S += "<td class=ST2>" + F[6]; break;
            case "ABANDONED": S+= "<td class=ST3>Abndn"; break;
            case "SKIP": S+= "<td class=ST3>Skip"; break;
            case "CHECK": S+= "<td class=ST0>Check"; break;
            default: S+= "<td>" + F[6];
          } k++;
        }
      } $("VNL").innerHTML = "<table><col width=38><col width=17><col width=31><col width=30><col width=17><col><col width=40>" + S + "</table>";
      try { posVNL = $("VNL").childNodes[0].childNodes[1].childNodes[j] } catch(e) {}
    }
  }); setTimeout("getVNL('" + G + "','" + C + "'" + (FX? ",1": "") + ")", 7000);
}

// Mouse over graph generator
var OldChart = {
  Canvas: "GPH", dX: 25, BoxColor: "#fff", BgColor: "#eae9e8", AxisY: null,
  AxisColor: "#048", LineColor: "rgba(100,150,50,.5)", BulletColor: "#f60",
  Label: function ( Y ) { this.AxisY = Y; return this },
  Draw: function( D , timeline, scratchings) {
    if( D.length > 64 ) this.dX = 1600 / D.length; else this.dX = 25;
    var Pi = Math.PI, X1 = 9999, X2 = 0, Xd, i, j, k, A = $(this.Canvas), C = A.getContext("2d"), G,
        L = D.length, W = A.width = L * this.dX + 30, H = A.height;
    // Find Min & Max Data Values
    for( i = 0; i < L; i++ ) { if( X1 > D[i] ) X1 = D[i]; if( X2 < D[i] ) X2 = D[i] }
    if( X1 == X2 ) { X1 /= 2; X2 += X1; } Xd = (H-80) / (X2 - X1);
    // Common Chart Setting
    C.font = "9px tahoma, helvetica"; C.textAlign = "center"; C.textBaseline = "middle";
    C.lineCap = "square"; C.shadowOffsetX = 1; C.shadowOffsetY = 1; C.shadowBlur = 2;
    G = C.createLinearGradient(0, 0, 0, H-60); G.addColorStop(0, this.BoxColor); G.addColorStop(1, this.BgColor);
    // Background, Grid & Axis
    C.save(); C.fillStyle = G; C.fillRect(20, 20, W-30, H-60);
    C.beginPath(); for( i = 0; i < 10; i++ ) { j = 20 + i * (H-60) / 10; C.moveTo(21, j+.5); C.lineTo(W-10, j+.5) }
    C.strokeStyle = "rgba(0,0,0,.2)"; C.lineWidth = .5; C.stroke();
    C.beginPath(); C.moveTo(20, 10); C.lineTo(20, H-40); C.lineTo(W-10, H-40);
    C.strokeStyle = this.AxisColor; C.lineWidth = 2; C.stroke(); C.restore();
    if( this.AxisY ) { C.save(); C.translate(11, H / 2); C.rotate(-.5 * Pi); C.fillText(this.AxisY, 0, 0); C.restore() }
    // Line Chart
    C.beginPath(); C.moveTo(30, (H-40) - (D[0] - X1) * Xd);
    for( i = 1; i < L; i++ ) C.lineTo(30 + i * this.dX, (H-40) - (D[i] - X1) * Xd);
    C.strokeStyle = this.LineColor; C.lineWidth = 4; C.stroke();
    // Bullet
    C.fillStyle = this.BulletColor; C.shadowColor = "rgba(0,0,0,.8)"; for( i = 0, k = -21; i < L; i++ ) if( i * this.dX - k > 20 ) {
      C.beginPath(); k = i * this.dX; C.arc(30 + k, (H-40) - (D[i] - X1) * Xd, 4, 0, 2 * Pi); C.fill() }
    // Text Data
    C.fillStyle = "#000"; C.shadowColor = "rgba(0,0,0,.5)"; for( i = 0, k = -21; i < L; i++ ) if( i * this.dX - k > 20 ) {
      j = (H-40) - (D[i] - X1) * Xd; if( i < L-1 && D[i] < D[i+1] ) j += 20; k = i * this.dX; C.fillText(D[i], 30 + k, j - 10) }

    // Draw scratchings
    /*var pointIndex = 1;
    C.beginPath();    
    C.moveTo(30 + pointIndex * this.dX, H-40);
    C.strokeStyle = "#ff0000";
    C.lineWidth = 1;
    C.lineTo(30 + pointIndex * this.dX, 10);
    C.stroke();*/

    if(timeline){
      console.log(timeline);
       // draw timeline on X axis label
      C.fillStyle = "#000"; 
     for( i = 0; i < timeline.length; i++ ) {
        C.fillText(timeline[i], 30+ i * this.dX, H - 20);
     }
    }
   

  }
}
//Generic graph display
function gXX( r ) { var G = $("GPH").style; if( r ) { G.top = 60+r.offsetTop+r.offsetHeight+"px"; G.display = "" } else G.display = "none" }
//Trigger graph display for specific columns
function gRD( x, r ) { gXX(r); OldChart.Label("Run Double Dividend").Draw(x) }
function gAP( x, r ) { gXX(r); OldChart.Label("APN (Bookie) Price").Draw(x)  }
function gTB( x, r , timeLine, scratchings) { gXX(r); OldChart.Label("Price History").Draw(x,timeLine, scratchings) }
function gBT( x, r ) { gXX(r); OldChart.Label("Bet365 Fixed Dividend").Draw(x) }
function gVT( x, r ) { gXX(r); OldChart.Label("Virtual WIN - Trifecta").Draw(x) }
function gLX( x, r ) { gXX(r); OldChart.Label("Luxbet Price").Draw(x) }

// Mouseover Citibet List display
function tCB( x, m, r ) { if( x.length > 0 ) { $("CBL").innerHTML = "<div id=TDG><b class=" + (m?"PK>EAT":"BL>BET") + " List</b>" +
    "<table class=ODR><tr class=HD><th width=25>Rc<th width=25>Hs<th>WIN<th>PLA<th width=25>%<th width=60>Limit<tr><td class=CT>" + 
    x.replace(/\|0\|/g,"|-|").replace(/~/g,"<tr><td class=CT>").replace(/\|/g,"<td class=CT>") + "</table></div>";
  tXX(r); $("CBL").className = m?"bPK":"bBL"; $("CBL").style.display = "";
}}
function tXX( r ) { var T = $("CBL").style; if( r ) T.top = 60+r.offsetTop+r.offsetHeight+"px"; else T.top = "-750px" }


function drawPriceHistory(priceHistory, timeLine, scratchings, form, closeTime){

    var prettyTimeLine = [];
    var endTime = moment();
    if(closeTime) {
      endTime = moment(closeTime);
    }

    console.log('current time: ' + moment().format() + ' used time: ' + endTime.format());

    // get a humanized timeline array
    timeLine.forEach(function(time){
      var postfix = "m";
      var difference = endTime.diff(moment(time), 'minutes');

      if(difference > 60){
        difference = endTime.diff(moment(time), 'hours');
        postfix = "h";
      }  else if (difference < 2){
        difference = endTime.diff(moment(time), 'seconds');
        postfix = "s";  
      }

      prettyTimeLine.push(difference + postfix);
    });
    var scratchingIndex = [];


    // get the closest timeline index for every scratching we have
    if(scratchings){
      scratchings.forEach(function(scratching){
        var closest = 99999;
        var closestsIndex = 0;

        for(i =0; i < timeLine.length; i++){
          var difference = moment(scratching.timestamp).diff(moment(timeLine[i]), 'seconds');
          if(closest > difference){
            closest = difference;
            closestsIndex = i;
          }
        }
        scratchingIndex.push(closestsIndex);
      });
    }

    if (prettyTimeLine.length > 0) {
      gTB(priceHistory, form, prettyTimeLine, scratchingIndex);
    }
}

function scratching(runner, timestamp){
  this.runner = runner;
  this.timestamp = timestamp;
}

$(function(){
  console.log('ready!');
});

window.toggleTicks = function(masterTick){
   var allTickboxes = document.getElementsByClassName("pm_tick");

   for(var i = 0; i < allTickboxes.length;i++){
      allTickboxes[i].checked= masterTick.checked;
   }

};


function trade(meetingId, eventNumber,traderName, tradeType,parent){
  var tradeData = { "meetingId": meetingId, "eventNumber": eventNumber , "tradeType": tradeType , "trader": traderName };
  jQuery.ajax({
                    type: "GET",
                    url: "/Luxbook.MVC/api/Trade/Race",
                    contentType: "application/json; charset=utf-8",
                    data: tradeData,
                    dataType: "jsonp",
                    success: function(data) {
                        console.log(data);
                        parent.getEVN(parent.curVNL);
                    },
                    error: function(data) {
                        console.log(data);
                    }
                });
}

function updateRoll(dropdown, rollType, meetingId, eventNumber, runnerNumber){

  var tradeData = { "roll": dropdown.value, "rollType": rollType , "meetingId": meetingId , "eventNumber": eventNumber, "runnerNumber": runnerNumber };

  jQuery.ajax({
                    type: "GET",
                    url: "/Luxbook.MVC/api/runner/roll",
                    contentType: "application/json; charset=utf-8",
                    data: tradeData,
                    async: false,
                    dataType: "jsonp",
                    success: function(data) {
                    
                    },
                    error: function(data) {
                     
                    }
                });
}


function updateBoundary(textbox, meetingId, eventNumber, runnerNumber, boundaryType){

  var tradeData = { "boundary": textbox.value, "boundaryType": boundaryType , "meetingId": meetingId , "eventNumber": eventNumber, "runnerNumber": runnerNumber };

  jQuery.ajax({
                    type: "GET",
                    url: "/Luxbook.MVC/api/runner/boundary",
                    contentType: "application/json; charset=utf-8",
                    data: tradeData,       
                    async: false,             
                    dataType: "jsonp",
                    success: function(data) {
                    
                    },
                    error: function(data) {
                     
                    }
                });
}

function pauseTimer(){
  console.log('pausing timer');
  timerPause = true;
}

function resumeTimer(){
  timerPause  = false;
}