<cfparam name="searchTerm" default="">

<cfset qryResources = getResourcesForAccount("module")>

<!--- order resources --->
<cfquery name="qryResources" dbtype="query">
	SELECT *
		FROM qryResources
		<cfif searchTerm neq "">
			WHERE  upper(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">
					OR upper(package) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  
					OR upper(name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  
		</cfif>
		ORDER BY package, name
</cfquery>


<cfoutput query="qryResources" group="package">
	<cfquery name="qryResCount" dbtype="query">
		SELECT *
			FROM qryResources
			WHERE package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryResources.package#">
	</cfquery> 

	<div class="rd_packageTitle">
		<a href="##" onclick="Element.toggle('cp_feedGroup#qryResources.currentRow#');return false;" style="color:##333;font-weight:bold;">&raquo; #qryResources.package# (#qryResCount.recordCount#)</a>
	</div>

	<div style="display:none;margin-left:10px;margin-bottom:8px;" id="cp_feedGroup#qryResources.currentRow#"> 
		<cfoutput>
			<cfset tmpName = qryResources.id>
			<a href="##" 
				onclick="controlPanel.addModule('#jsstringFormat(qryResources.id)#')" 
				style="color:##333;margin-bottom:5px;font-size:10px;line-height:11px;white-space:nowrap;">#tmpName#</a><br>
		</cfoutput>
	</div>
</cfoutput>

<cfif qryResources.recordCount eq 0>
	<em>There are no modules in the library</em>
</cfif>
