<!--- processLogin.cfm 

This template checks the login information 

--->

<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="rememberMe" default="0">

<cfset localSecret = "En su grave rincon, los jugadores "
							& "rigen las lentas piezas. El tablero "
							& "los demora hasta el alba en su severo "
							& "ambito en que se odian dos colores. ">

<cftry>
	<cfset oAccountsService = application.homePortals.getAccountsService()>

	<!--- check login --->
	<cfset qryUser = oAccountsService.loginUser(username, password)>

	<cfif rememberMe eq 1>
		<cfset userKey = encrypt(qryUser.userID, localSecret)>
		<cfcookie name="homeportals_username" value="#qryUser.username#" expires="never">			
		<cfcookie name="homeportals_userKey" value="#userKey#" expires="never">			
	</cfif>

	<cflocation url="../index.cfm?account=#qryUser.username#">
			
	<cfcatch type="any">
		<cflocation url="../index.cfm?_statusMessage=Invalid%20Login">
	</cfcatch>
</cftry>