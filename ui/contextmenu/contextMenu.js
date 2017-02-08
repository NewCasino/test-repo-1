var contextMenuControl = {
	menu: null,
	data: {},
	
	initContextMenu: function () {
		// attach listener to all applicable html elements
		var elements = document.getElementsByClassName('context-menu-one');		
		for (var i = 0; i < elements.length; i++) {
			elements[i].addEventListener("contextmenu", function(event) {
				contextMenuControl.showContextMenu(event)
			});
		}
		window.onclick = function(event){
			contextMenuControl.hideContextMenu(event);
		};
		window.onkeydown = function(event){
			contextMenuControl.listenKeys(event);
		};
		this.menu = document.getElementById('contextMenu');
	},

	// display context menu for current element under mouse cursor
	showContextMenu: function (event) {
		event.preventDefault();
		var el = (event.target.parentNode.tagName == 'TR' ? event.target : event.target.parentNode);
		this.data = this.getDataItems(el.getAttribute('data-attrs'));
		document.getElementById('context-menu-title').innerHTML = this.data.runner;
		// built menu items
		this.setMenuContent({menuNum:1, el:el});
		// render menu
		this.menu.style.display = 'block';
		this.menu.style.left = (event.clientX-120) + 'px';
		this.menu.style.top = event.clientY + 'px';
		var elements = document.getElementsByClassName('context-menu-item');
		// delegate menu item 'click'  listener
		for (var i = 0; i < elements.length; i++) {
			elements[i].addEventListener("click", function(event) {
				contextMenuControl.contextMenuAction(event)
			});
		}
		return true;
	},

	// context menu items
	setMenuContent: function(options) {
		var items = (options.el.className.indexOf('scratched') == -1 ? 
			'<li class="context-menu-item" data-action="scratchRunner">Scratch Runner</li>' : 
			'<li class="context-menu-item" data-action="unscratchRunner">Un-Scratch Runner</li>');
		items += '<li class="separator"></li>' +
				 '<li class="context-menu-item" data-action="editRunner">Edit Runner Data</li>';
		document.getElementById('context-menu-items').innerHTML = items;		
	},

	// link action to angular via router
	contextMenuAction: function (event) {
		var id = jQuery.param(this.data);
		switch(event.target.getAttribute('data-action')) {
		    case 'scratchRunner':
		    	document.location.href = "#/Runner/Scratch/"+id
		        break;
		    case 'unscratchRunner':
		    	document.location.href = "#/Runner/UnScratch/"+id
		        break;
		    case 'editRunner':
		    	document.location.href = "#/Runner/Edit/"+id
		        break;
		}		
		return true;
	},

	hideContextMenu: function (event) {
		if (contextMenuControl.menu !== null) {
			contextMenuControl.menu.style.display = 'none';
		}
	},

	listenKeys: function (event) {
		var keyCode = event.which || event.keyCode;
		if(keyCode == 27){
			this.hideContextMenu();
		}
	},

	getDataItems: function (serializedData) {
		var a = serializedData.split(':');
		return {
			runner: a[0],
			meeting_id: a[1],
			race_num: a[2],
			runner_num: a[3],
			tab_prop: a[4]
		};
	}
};
