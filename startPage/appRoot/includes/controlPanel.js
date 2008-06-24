
/* *****************************************************/
/* controlPanel.js								   		*/
/*												   		*/
/* This javascript contains all js functions for the  	*/
/* of the startPage application.  				  		*/
/*												   		*/
/* (c) 2007 - Oscar Arevalo - info@homeportals.net  	*/
/*												   		*/
/* *****************************************************/

var editHTML = "";
var _pageHREF = "";
var _pageFileName = "";

function controlPanelClient() {

	// pseudo-constructor
	function init(lstLocations) {
		this.server = h_appRoot + "/includes/controlPanelGateway.cfm";
		this.instanceName = "";	
		this.currentModuleLayout = "";
		this.currentModuleID = "";
		this.locations = lstLocations;
		this.panelDivID = "cp_panelWindow";
	}

	function openPanel() {
		scroll(0,0);
		var d = $(this.panelDivID);
		if(!d) {
			var tmpHTML = "<div id='" + this.panelDivID + "'></div>";
			new Insertion.Before("anchorAddContent",tmpHTML);
		}
	}
	
	function isPanelOpen() {
		var d = $(this.panelDivID);
		if(!d) 
			return false;
		else
			return true;
	}
	
	function closePanel() {
		if($(this.panelDivID)) 
			new Element.remove(this.panelDivID);
	}
	
	function togglePanel() {
		if(isPanelOpen()) 
			closePanel();
		else
			openPanel();
	}
	
	function getView(view, args) {
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = true;
			
		if(!this.isPanelOpen()) this.openPanel();

		h_callServer(this.server, "getView", this.panelDivID, args);
	}

	function getPartialView(view, args, tgt) {
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = false;
		h_callServer(this.server, "getView", tgt, args);
	}


	// *****   Actions ****** //

	function addModule(modID) {
		controlPanel.setStatusMessage("Adding module to workspace...");
		h_callServer(this.server,"addModule","siteMapStatusBar",{moduleID:modID});
	}

	function addFeed(feedURL, feedTitle) {
		h_callServer(this.server,"addFeed","siteMapStatusBar",{feedURL:feedURL, feedTitle:feedTitle});
	}			

	function deleteModule(modID) {
		if(confirm('Are you sure you wish to delete this module?')) {
			h_callServer(this.server, "deleteModule", "siteMapStatusBar", {moduleID:modID});
		}
	}		
	
	function removeModuleFromLayout(modID) {
		var m1 = $(modID);
		var m2 = $(modID+"_lp");
		if(m1) new Element.remove(modID);
		if(m2) new Element.remove(modID+"_lp");
		controlPanel.currentModuleID = "";
	}
	
	function addPage(pageName) {
		if(pageName=="") 
			alert("The page name cannot be blank.");	
		else 
			h_callServer(this.server,"addPage","siteMapStatusBar",{pageName:pageName});
	}

	function deletePage(pageHREF) {
		if(confirm("Delete page from site?")) {
			h_callServer(this.server,"deletePage","siteMapStatusBar",{pageHREF:pageHREF});
		}
	}
	
	function changeTitle(frm) {
		h_callServer(this.server,"changeTitle","siteMapStatusBar",{title:frm.title.value});
	}
	
	function renamePage(fldID,txtID) {
		var d = $(txtID);
		var title = $(fldID).value;
		d.innerHTML = title;
		h_callServer(this.server,"renamePage","siteMapStatusBar",{pageName:title});
	}	
	function renameSite(fldID,txtID) {
		var d = $(txtID);
		var title = $(fldID).value;
		d.innerHTML = title;
		h_callServer(this.server,"setSiteTitle","siteMapStatusBar",{title:title});
	}



	// *****   Misc   ****** //
	
	function setStatusMessage(msg,timeout) {
		var s1 = $("cp_status_BodyRegion");
		var s2 = $("siteMapStatusBar");

		if(s1) s1.innerHTML = msg;
		if(s2) s2.innerHTML = msg;
	
		if(!timeout || timeout==null) timeout=2000;
		setTimeout('controlPanel.clearStatusMessage()',timeout);
	}

	function clearStatusMessage() {
		var s1 = $("cp_status_BodyRegion");
		var s2 = $("siteMapStatusBar");
		if(s1) s1.innerHTML = "";
		if(s2) s2.innerHTML = "";
	}
		
    function updateLayout() {
		var container = DragDrop.firstContainer;
		var j = 0;
		var string = "";	
		
		var newLayout = DragDrop.serData('main');

		for(loc in this.locations) {
			tmpNameOriginal = this.locations[loc].id + "|";	
			tmpNameTarget = this.locations[loc].name + "|";	
			newLayout = newLayout.replace(tmpNameOriginal, tmpNameTarget);
		}

		controlPanel.setStatusMessage("Updating workspace layout...");
		h_callServer(this.server,"updateModuleOrder","siteMapStatusBar",{layout:newLayout});
    }
	
	function insertModule(modID, locID) {
		var tmpHTML = "<div class='Section' id='" + modID + "'>"
						+ "<div class='SectionTitle' id='" + modID + "_Head'>"
							+ "<h2>"
								+ getModuleIconsHTML(modID) 
								+ "<div class='SectionTitleLabel' id='" + modID + "_Title'>" + modID + "</div>"
							+ "</h2>"
						+ "</div>"
						+ "<div class='SectionBody' id='" + modID + "_Body'>"
							+ "<div class='SectionBodyRegion' id='" + modID + "_BodyRegion'>Module Content</div>"
						+ "</div>"
					+ "</div>"	
		
		new Insertion.Bottom(locID,tmpHTML);
		
		eval(modID + "= new moduleClient()");
		eval(modID + ".init('" + modID + "')");
		eval(modID + ".getView()");
		
		startDragDrop();
	}
	
	
	function rename(txtID,title,type) {
		var fldID = "sb_" + type + "Name";
		var func = "controlPanel.rename" + type + "(\"" + fldID + "\",\"" + txtID + "\")";
		var d = $(txtID);
		d.innerHTML = "<input type='text' id='" + fldID + "' value='" + title + "' class='inlineTextbox'>&nbsp;";
		d.innerHTML = d.innerHTML + "<input type='button' onclick='" + func + "' style='font-size:10px;width:30px;' value='Go'>&nbsp;";
		if(type!='Site')
			d.innerHTML = d.innerHTML + "<a href='#' onclick='navCmdDeletePage()'><img src='images/omit-page-orange.gif' border='0' align='absmiddle' alt='Click to delete page' title='click to delete page'></a>"
		d.innerHTML = d.innerHTML + "<a href='#' onclick='$(\""+txtID+"\").innerHTML=\"" + title + "\"'><img src='images/closePanel.gif' border='0' align='absmiddle' alt='Close' title='Close' style='margin-left:2px;'></a>"
		$(fldID).focus();
	}


	
	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	controlPanelClient.prototype.init = init;

	controlPanelClient.prototype.openPanel = openPanel;
	controlPanelClient.prototype.closePanel = closePanel; 
	controlPanelClient.prototype.isPanelOpen = isPanelOpen;
	controlPanelClient.prototype.getView = getView;
	controlPanelClient.prototype.getPartialView = getPartialView;

	controlPanelClient.prototype.addModule = addModule;
	controlPanelClient.prototype.addFeed = addFeed;
	controlPanelClient.prototype.deleteModule = deleteModule;
	controlPanelClient.prototype.addPage = addPage;
	controlPanelClient.prototype.deletePage = deletePage;
	controlPanelClient.prototype.changeTitle = changeTitle;
	controlPanelClient.prototype.renamePage = renamePage;
	controlPanelClient.prototype.updateLayout = updateLayout;
	controlPanelClient.prototype.setStatusMessage = setStatusMessage;
	controlPanelClient.prototype.clearStatusMessage = clearStatusMessage;
	controlPanelClient.prototype.renameSite = renameSite;
	controlPanelClient.prototype.removeModuleFromLayout = removeModuleFromLayout;
	controlPanelClient.prototype.insertModule = insertModule;
	controlPanelClient.prototype.rename = rename;
	controlPanelClient.prototype.togglePanel = togglePanel;
}


function startDragDrop() {
    DragDrop.tag = "div";
    DragDrop.theClass = "Section";
    DragDrop.firstContainer = null;
    DragDrop.lastContainer = null;
    DragDrop.parent_id = null;
    DragDrop.parent_group = null;

	controlPanel.setStatusMessage("Enabling draggable modules...",1000);

	for(loc in controlPanel.locations) {
        layoutSection = $(controlPanel.locations[loc].id);
        if(layoutSection) {
	        DragDrop.makeListContainer( layoutSection , "main");
	        layoutSection.onDragOver = function() { this.style["background"] = "#f5f5f5"; this.style["border"] = "0";};
	        layoutSection.onDragOut = function() {this.style["background"] = "none"; this.style["border"] = "0";};
	        layoutSection.onDragDrop = function() {controlPanel.updateLayout()};
		}
	}

	var aSections = document.getElementsByClassName("Section");
	for(i=0;i<aSections.length;i++) {
		d = $(aSections[i].id);
		h = $(aSections[i].id+"_Head");
		if(h) h.style.cursor="move";
		if(d) d.setDragHandle(h);
	}
	
}	

function addEvent(obj, event, listener, useCapture) {
  // Non-IE
  if(obj.addEventListener) {
    if(!useCapture) useCapture = false;

    obj.addEventListener(event, listener, useCapture);
    return true;
  }

  // IE
  else if(obj.attachEvent) {
    return obj.attachEvent('on'+event, listener);
  }
}

function getModuleIconsHTML(modID) {
	return tmpHTML = "<a href=\"javascript:controlPanel.deleteModule('" + modID + "');\"><img src='images/omit-page-orange.gif' alt='Remove from page' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>"
}

function attachModuleIcons() {
	var aSections = document.getElementsByClassName("Section");
	var modID = "";
	controlPanel.setStatusMessage("attaching module icons...",1000);
	for(i=0;i<aSections.length;i++) {
		modID = aSections[i].id;
		d = $(modID);
		h = $(modID + "_Head");
		aElem = h.getElementsByTagName("h2");
		new Insertion.Top(aElem[0], getModuleIconsHTML(modID));
	}
}

function attachLayoutHolders() {
	var html = "<div class='layoutSectionHolder'>&nbsp;</div>";
	
	for(loc in controlPanel.locations) {
        layoutSection = $(controlPanel.locations[loc].id);
        if(layoutSection) {
			new Insertion.Top(layoutSection, html);
		}
	}
}

function attachModuleIcon(modID, imgSrc, onclickStr, alt) {
	controlPanel.setStatusMessage("attaching module icons...",1000);
	h = $(modID + "_Head");
	aElem = h.getElementsByTagName("h2");
	new Insertion.Top(aElem[0],  "<a href='#' onclick=\"" + onclickStr + "\"><img src=\"" + imgSrc + "\" border='0' style='margin-top:3px;margin-right:3px;' align='right' alt='" + alt + "' title='" + alt + "'></a>");
}

function getRadioButtonValue(rad) {
	for (var i=0; i < rad.length; i++) {
	   if (rad[i].checked)
		  return rad[i].value;
	}
}

function navCmdAddPage() {
	controlPanel.addPage('New Page');
}
function navCmdAddContent() {
	if(controlPanel.isPanelOpen())
		controlPanel.closePanel()
	else
		controlPanel.getView('AddFeed')
}
function navCmdDeletePage() {
	controlPanel.deletePage(_pageFileName);
}


function h_callServer(server,method,sec,params,rcv) {
	var pars = "";

	h_setLoadingImg(sec);

	// build the query string
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";

	// add the method to execute
	pars = pars + "method=" + method;
	pars = pars + "&_server=" + server;
	pars = pars + "&_pageHREF=" + _pageHREF;

	// do the AJAX call
	if(rcv==null) 
		var myAjax = new Ajax.Updater(sec,
									  "includes/controlPanelGateway.cfm",
									  {method:'post', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:h_clearLoadingImg});
	else
		var myAjax = new Ajax.Updater(sec,
									  "includes/controlPanelGateway.cfm",
									  {method:'post', parameters: pars, onFailure: h_callError, onComplete:rcv, evalScripts:true});
}
