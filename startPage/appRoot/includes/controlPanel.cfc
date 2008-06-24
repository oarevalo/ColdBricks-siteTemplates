<!---
/******************************************************/
/* controlPanel.cfc									  */
/*													  */
/* This component provides functionality to           */
/* manage all aspects of a xilya account page.        */
/*													  */
/* (c) 2007 - Oscar Arevalo							  */
/* oarevalo@cfempire.com							  */
/*													  */
/******************************************************/
--->

<cfcomponent displayname="controlPanel" hint="This component provides functionality to manage all aspects of a HomePortals page.">

	<!--- constructor code --->
	<cfscript>
		variables.moduleRoot = "includes";
		variables.imgRoot = "images";
		
		variables.accountsRoot = "";
		variables.pageHREF = "";
		variables.oPage = 0;
		variables.reloadPageHREF = "index.cfm";
		
		variables.view = "";
		variables.useLayout = true;
	</cfscript>


	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="controlPanel" hint="Initializes component.">
		<cfargument name="pageHREF" type="string" required="true" hint="the address of the current page">
		<cfscript>
			variables.accountsRoot = application.homePortals.getConfig().getAccountsRoot();
			variables.pageHREF = arguments.pageHREF;
				
			variables.oPage = CreateObject("component", "Home.Components.page").init(variables.pageHREF);	
			
			variables.reloadPageHREF = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(variables.pageHREF),".xml","");
				
			return this;
		</cfscript>
	</cffunction>
	
	

	<!---****************************************************************--->
	<!---         G E T     V I E W S     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- getView                          --->
	<!---------------------------------------->	
	<cffunction name="getView" access="public" output="true">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
	
		<cfset variables.view = arguments.viewName>
		<cfset variables.useLayout = arguments.useLayout>

		<cfset tmpHTML = renderView(argumentCollection = arguments)>

		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>			



	<!---****************************************************************--->
	<!---         D O     A C T I O N     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- addModule			               --->
	<!---------------------------------------->	
	<cffunction name="addModule" access="public" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="no" default="">
		
        <cfset var stRet = structNew()>
		<cftry>
			<cfset stRet = addModuleToPage(arguments.moduleID, arguments.locationID, false)>
			
            <script>
                controlPanel.closePanel();
 				window.location.replace("#variables.reloadPageHREF#");
            </script>

            <cfcatch type="any">
                <script>controlPanel.setStatusMessage("#jsstringformat( cfcatch.Message)#");</script>
            </cfcatch>   	
		</cftry>
	</cffunction>	

	<!---------------------------------------->
	<!--- deleteModule                     --->
	<!---------------------------------------->
	<cffunction name="deleteModule" access="public" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.deleteModule(arguments.moduleID);
			</cfscript>
			<script>
				controlPanel.removeModuleFromLayout('#arguments.moduleID#');
				controlPanel.setStatusMessage("Module has been removed.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="public" output="true">
		<cfargument name="pageName" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">
		<cfset var newPageURL = "">
		<cftry>
			<cfscript>
				validateOwner();
				newPageURL = getSite().addPage(arguments.pageName, arguments.pageHREF);
				newPageURL = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(newPageURL),".xml","");
			</cfscript>
			<script>
				controlPanel.closePanel();
				window.location.replace('#newPageURL#');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- deletePage		               --->
	<!---------------------------------------->	
	<cffunction name="deletePage" access="public" output="true">
		<cfargument name="pageHREF" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				getSite().deletePage(arguments.pageHREF);
				redirHREF = "index.cfm?account=" & variables.oPage.getOwner();
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Removing workspace...");
				window.location.replace('#redirHREF#');
			</script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- changeTitle	                   --->
	<!---------------------------------------->		
	<cffunction name="changeTitle" access="public" output="true">
		<cfargument name="title" type="string" required="yes">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.setPageTitle(arguments.title);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Title changed.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- renamePage	                   --->
	<!---------------------------------------->		
	<cffunction name="renamePage" access="public" output="true">
		<cfargument name="pageName" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				if(pageName eq "") throw("The page title cannot be blank.");
		
				// get the original location of the page
				originalPageHREF = variables.oPage.getHREF();
		
				// rename the actual page 
				variables.oPage.setPageTitle(arguments.pageName);
				variables.oPage.renamePage(arguments.pageName);
				newPageHREF = variables.oPage.getHREF();
				
				// set the new reload location
				variables.reloadPageHREF = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(newPageHREF),".xml","") & "&#RandRange(1,100)#";
				
				// update the site definition
				getSite().setPageHREF(originalPageHREF, newPageHREF);			
			</cfscript>
			
			<script>
				controlPanel.closePanel();
				window.location.replace("#variables.reloadPageHREF#");
			</script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!---------------------------------------->
	<!--- updateModuleOrder                --->
	<!---------------------------------------->	
	<cffunction name="updateModuleOrder" access="public" output="true">
		<cfargument name="layout" type="string" required="true" hint="New layout in serialized form">
		<cftry>
			<cfscript>
				validateOwner();
				
				// remove the '_lp' string at the end of all the layout objects
				// (this string was added so that the module css rules dont get applied
				// to the modules on the layout preview )
				arguments.layout = replace(arguments.layout,"_lp","","ALL");
				
				variables.oPage.setModuleOrder(arguments.layout);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Layout changed.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setSiteTitle" access="public" output="true">
		<cfargument name="title" type="string" required="true" hint="The new title for the site">
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.title eq "") throw("Site title cannot be empty"); 
				getSite().setSiteTitle(arguments.title);
			</cfscript>
			<script>
				window.location.replace("#variables.reloadPageHREF#");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- addFeed				           --->
	<!---------------------------------------->	
	<cffunction name="addFeed" access="public" output="true">
		<cfargument name="feedURL" type="string" required="true" hint="The URL of the feed">
		<cfargument name="feedTitle" type="string" required="true" hint="The title for the feed module">

		<cfset var stRet = structNew()>
		<cfset var stAttributes = structNew()>
		
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.feedURL eq "") throw("The feed URL cannot be empty"); 

				// build custom properties
				stAttributes = structNew();
				stAttributes["rss"] = arguments.feedURL;
				if(arguments.feedTitle neq "") 
					stAttributes["title"] = arguments.feedTitle;
				stAttributes["maxItems"] = 10;

				stRet = addModuleToPage("rssReader", "", false, stAttributes);
            </cfscript>
            
            <script>
              	controlPanel.closePanel();
				window.location.replace("#variables.reloadPageHREF#");
            </script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>



	<!---****************************************************************--->
	<!---                P R I V A T E   M E T H O D S                   --->
	<!---****************************************************************--->

	<!-------------------------------------->
	<!--- getUserInfo                    --->
	<!-------------------------------------->
	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user" access="public">
		<cfscript>
			var oUserRegistry = 0;
			var stRet = structNew();
			
			oUserRegistry = createObject("Component","Home.Components.userRegistry").init();
			stRet = oUserRegistry.getUserInfo();	// information about the logged-in user		
			stRet.isOwner = (stRet.username eq variables.oPage.getOwner());
		</cfscript>

		<cfreturn stRet>
	</cffunction>	

	<!---------------------------------------->
	<!--- renderView                       --->
	<!---------------------------------------->		
	<cffunction name="renderView" access="private" returntype="string">
		<cfset var tmpHTML = "">
		<cfset var viewHREF = "views/vw" & variables.view & ".cfm">
		
		<cftry>
			<cfsavecontent variable="tmpHTML">
				<cfinclude template="#viewHREF#">				
			</cfsavecontent>

			<cfcatch type="any">
				<cfset tmpHTML = cfcatch.Message & "<br>" & cfcatch.Detail>
			</cfcatch>
		</cftry>
		
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderPage                       --->
	<!---------------------------------------->
	<cffunction name="renderPage" access="private">
		<cfargument name="html" default="" hint="contents">
		<cfinclude template="layouts/controlPanelPage.cfm">
	</cffunction>
	
	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>

	<!---------------------------------------->
	<!--- abort                            --->
	<!---------------------------------------->
	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>
	
	<!---------------------------------------->
	<!--- dump                             --->
	<!---------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	

	<!---------------------------------------->
	<!--- savePage                         --->
	<!---------------------------------------->
	<cffunction name="savePage" access="private" hint="Stores a HomePortals page">
		<cfargument name="pageURL" type="string" hint="Path for the page as a relative URL">
		<cfargument name="pageContent" type="string" hint="page content">

		<!--- store page --->
		<cffile action="write" file="#expandpath(arguments.pageURL)#" output="#arguments.pageContent#">
	</cffunction>
	
	<!---------------------------------------->
	<!--- removeFile                       --->
	<!---------------------------------------->
	<cffunction name="removeFile" access="private" hint="deletes a file">
		<cfargument name="href" type="string" hint="relative path to page">

		<cffile action="delete" file="#expandpath(arguments.href)#">
	</cffunction>	

	<!---------------------------------------->
	<!--- selectTab                        --->
	<!---------------------------------------->
	<cffunction name="selectTab" access="private">
		<cfargument name="tab" type="string" required="yes">
		<cfoutput>	
			<script>
				<cfif arguments.tab eq "Page">
					$("cp_PageTab").className="cp_selectedTab";
					$("cp_SiteTab").className="";
				<cfelse>
					$("cp_PageTab").className="";
					$("cp_SiteTab").className="cp_selectedTab";
				</cfif>
			</script>
		</cfoutput>
	</cffunction>

	<!---------------------------------------->
	<!--- validateOwner                    --->
	<!---------------------------------------->
	<cffunction name="validateOwner" access="private" hint="Throws an error if the current user is not the page owner" returntype="boolean">
		<cfif Not getUserInfo().isOwner>
			<cfthrow message="You must sign-in as the current page owner to access this feature." type="custom">
		<cfelse>
			<cfreturn true> 
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- getResourcesForAccount           --->
	<!---------------------------------------->
	<cffunction name="getResourcesForAccount" access="private" hint="Retrieves a query with all resources of the given type available for a given account" returntype="query">
		<cfargument name="resourceType" type="string" required="yes">

		<cfscript>
			var aAccess = arrayNew(1);
			var j = 1;
			var oHP = application.homePortals;
			var owner = variables.oPage.getOwner();
		
			var oFriendsService = oHP.getAccountsService().getFriendsService();
			var qryFriends = oFriendsService.getFriends(owner);
			var lstFriends = valueList(qryFriends.userName);
			
			var qryResources = oHP.getCatalog().getResourcesByType(arguments.resourceType);
			
			for(j=1;j lte qryResources.recordCount;j=j+1) {
				aAccess[j] = qryResources.access[j] eq "general"
							or qryResources.access[j] eq ""
							or qryResources.owner[j] eq owner
							or (qryResources.access[j] eq "friend" and listFindNoCase(lstFriends, qryResources.owner[j]));
			}
			queryAddColumn(qryResources, "hasAccess", aAccess);
		</cfscript>
		
		<cfquery name="qryResources" dbtype="query">
			SELECT *
				FROM qryResources
				WHERE hasAccess = 1
		</cfquery>

		<cfreturn qryResources>
	</cffunction>

	<!---------------------------------------->
	<!--- createDir				           --->
	<!---------------------------------------->
	<cffunction name="createDir" access="private" returnttye="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#ExpandPath(arguments.path)#">
	</cffunction>

	<!---------------------------------------->
	<!--- setControlPanelTitle                --->
	<!---------------------------------------->
	<cffunction name="setControlPanelTitle" access="private" output="true">
		<cfargument name="label" type="string" required="yes">
		<cfargument name="img" type="string" required="yes">
		<cfset variables.controlPanelTitle = arguments.label>
		<cfset variables.controlPanelIcon = arguments.img>
		<script>
			$("cp_TitleBar_icon").src="#variables.imgRoot#/#variables.controlPanelIcon#.png";
			$("cp_TitleBar_label").innerHTML="#variables.controlPanelTitle#";
		</script>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getSite			                --->
	<!---------------------------------------->
	<cffunction name="getSite" access="private" output="false" returntype="Home.Components.site">
		<cfscript>
			var oAccountsService = application.homePortals.getAccountsService();
			var owner = variables.oPage.getOwner();
			return createObject("component","Home.Components.site").init(owner, oAccountsService);
		</cfscript>
	</cffunction>
		
	<!-------------------------------------->
	<!--- addModuleToPage                --->
	<!-------------------------------------->
	<cffunction name="addModuleToPage" access="private" returntype="struct">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="initializeModule" type="boolean" required="no" default="false">
		<cfargument name="moduleAttributes" type="struct" required="no" default="#structNew()#">
		
		<cfscript>
	        var oModuleController = 0;
	        var tmpCFCPath = "";
	        var oHP = 0;
	        var oResourceBean = 0;
	        var moduleClassName = "";
	        var newModuleID = ""; 
			var oCatalog = 0;
			var moduleLibraryPath = "";
			var stRet = structNew();
			
			// prepare return struct
			stRet.locationID = "";
			stRet.moduleID = "";
	
			oHP = application.homePortals;
			oCatalog = oHP.getCatalog();
			moduleLibraryPath = oHP.getConfig().getResourceLibraryPath() & "/modules/";

            // get info for new module
            oResourceBean = oCatalog.getResourceNode("module", arguments.moduleID);
			
         	// get location info
         	if(arguments.locationID neq "") {
				qryLocation = variables.oPage.getLocationByName(arguments.locationID);
				if(qryLocation.recordCount eq 0)
					throw("The selected location does not exist on the page");
         	} else {
               	// get location info
               	qryLocation = variables.oPage.getLocations();
               	arguments.locationID = qryLocation.name;         	
         	}

			// add the module to the page
			newModuleID = variables.oPage.addModule(oResourceBean, arguments.locationID, arguments.moduleAttributes);

	
			// initialize module if requested (this does not work very well!!)
			if(arguments.initializeModule) {
			
	            // build module class name
	            moduleClassName = moduleLibraryPath & oResourceBean.getName();
	            moduleClassName = replace(moduleClassName,"/",".","ALL");
	            if(left(moduleClassName,1) eq ".")
	                moduleClassName = right(moduleClassName, len(moduleClassName)-1);
	
	            // get moduleController
	            oModuleController = createObject("component", "Home.Components.moduleController");
	
	            stPageSettings = duplicate(variables.oPage.getModule(newModuleID));
	            stPageSettings["_page"] = structNew();
				stPageSettings["_page"].owner = variables.oPage.getOwner();
				stPageSettings["_page"].href = variables.oPage.getHREF();                
	            
	            // initialize new module
	            oModuleController.init(newModuleID,
	                                    moduleClassName,
	                                    stPageSettings,
	                                    true,
	                                    "local",
	                                    oHP.getConfig());
			}
	
			// prepare return struct
			stRet.locationID = qryLocation.id;
			stRet.moduleID = newModuleID;
			
			return stRet;
		</cfscript>
	</cffunction>
		
</cfcomponent>