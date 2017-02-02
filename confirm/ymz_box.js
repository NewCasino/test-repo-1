/*! ymzbox toast & loading & alert & confirm v1.0.0 Web弹层盒子 MIT License  http://ymz.returnphp.com  By KENT */
var ymz =ymz||{};

;!function(jq, y) {
    "use strict";
	
	var _lang ={},
		jWin =jq(window),
		ww = jWin.width(),
		wh = jWin.height(),
		st = jWin.scrollTop(),
        sl = jWin.scrollLeft();
		
	if(y && y.lang){
		_lang =y.lang;
	}
	
	var pos_center =function(j, topval){
		var _w =j.width();
		if( _w >= ww ){
			_w =ww -60;
			j.width(_w);
		}
		var l, t, w =j.outerWidth(), h =j.outerHeight();
		l = (ww - w)/2, t = (wh - h)/2;
		if(topval) t =topval;
		j.css({left: l+"px", top: "5px"});
		
	}, toast =function(p){
		var d = {text: "", type: "success", sec: 3},
			jqToast =jq('<div class="ymz-toast-box"><div class="toast-icon"></div><div class="toast-text"></div></div>'),
			jIcon =jqToast.find(".toast-icon"),
			jText =jqToast.find(".toast-text");
		
		p =jq.extend({}, d, p||{});
		jText.html(p.text);
		jIcon.addClass("toast-"+p.type);
		jqToast.appendTo(jq("body"));
		
		var bw =jqToast.width();
		jText.width( bw -jIcon.width()-10 );
		jIcon.height( jText.height() );
		
		pos_center(jqToast, 60);
		
		if(p.sec){
			var _jqToast =jqToast;
			setTimeout(function (){ _jqToast.remove(); }, p.sec*1000)
		}
	};
	
	var jqCover =null, jqLoad =null,
	cover ={
		show: function(){
			if(!jqCover){
				jqCover =jq('<div class="ymz-cover-box"></div>');
				jq("body").append(jqCover);
			}
			jqCover.show();
		},
		hide: function(){
			if(jqCover) jqCover.hide();
		}
	},
	loading ={
		show: function(p){
			if(!jqLoad){
				jqLoad =jq('<div class="ymz-loading-box"><div class="loading-icon"></div><div class="loading-text"></div></div>');
				jq("body").append(jqLoad);
			}
			
			var d = {width:null, text: _lang.loading||'', is_cover:1},
				jText =jqLoad.find(".loading-text");
			
			p =jq.extend({}, d, p||{});
			jText.html(p.text);
			
			if(p.is_cover) cover.show();
			if(p.width) jqLoad.css({width: p.width});
			
			pos_center(jqLoad);
			
			jqLoad.show();
		},
		hide: function(){
			if(jqLoad) jqLoad.hide();
		}
	};
	
	var jqConfirm =null, jqNo =null, jqYes =null, _confirm =function(p){
		if(!jqConfirm){
			jqConfirm =jq('<div class="ymz-alert-box"><h1 class="alert-title"></h1><div class="alert-text"></div><div class="alert-btn-wrap"><button id="alert-btn-no"></button><button id="alert-btn-yes"></button></div></div>');
			jq("body").append(jqConfirm);
			jqNo =jq("#alert-btn-no");
			jqYes =jq("#alert-btn-yes");
		}
		var d = {width:null, title: _lang.tip||'', text: "", no_btn: _lang.cancel||'', yes_btn: _lang.confirm||'', no_fn:null, yes_fn:null},
		jTitle =jqConfirm.find(".alert-title"),
		jText =jqConfirm.find(".alert-text");
		
		var btn_unbind =function(){
			jqNo.unbind("click");
			jqYes.unbind("click");
		}, box_close =function(){
			btn_unbind();
			jqConfirm.hide();
			cover.hide();
		};
		
		p =jq.extend({}, d, p||{});
		
		//btn_unbind();
		jTitle.html(p.title);
		jText.html(p.text);
		
		jqNo.html(p.no_btn);
		jqNo.click(function(){
			if(p.no_fn){
				p.no_fn();
				p.no_fn =null;
			}
			box_close();
		});
		
		jqYes.html(p.yes_btn);
		jqYes.click(function(){
			if(p.yes_fn){
				p.yes_fn();
				p.yes_fn =null;
			}
			box_close();
		});
		
		pos_center(jqConfirm);
		
		cover.show();
		jqConfirm.show();
	};
	
	var jqAlert =null, jqOK =null, _alert =function(p){
		if(!jqAlert){
			jqAlert =jq('<div class="ymz-alert-box"><h1 class="alert-title"></h1><div class="alert-text"></div><div class="alert-btn-wrap"><button id="alert-btn-ok"></button></div></div>');
			jq("body").append(jqAlert);
			jqOK =jq("#alert-btn-ok");
		}
		var d = {width:null, title: _lang.tip||'', text: "", ok_btn: _lang.close||'', close_fn:null},
		jTitle =jqAlert.find(".alert-title"),
		jText =jqAlert.find(".alert-text");
		
		var btn_unbind =function(){
			jqOK.unbind("click");
		}, box_close =function(){
			btn_unbind();
			jqAlert.hide();
			cover.hide();
		};
		
		//btn_unbind();
		p =jq.extend({}, d, p||{});
		
		jTitle.html(p.title);
		jText.html(p.text);
		
		jqOK.html(p.ok_btn);
		jqOK.click(function(){
			if(p.close_fn){
				p.close_fn();
				p.close_fn =null;
			}
			box_close();
		});
		
		pos_center(jqAlert);
		
		cover.show();
		jqAlert.show();
	};
	
	y.jq_toast =toast;
	y.jq_loading =loading;
	y.jq_confirm =_confirm;
	y.jq_alert =_alert;
	
} (jQuery, ymz);