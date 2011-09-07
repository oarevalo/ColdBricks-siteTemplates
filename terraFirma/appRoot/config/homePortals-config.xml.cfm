<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<contentRoot>$CONTENT_ROOT$</contentRoot>
	<defaultPage>default</defaultPage>
	<renderTemplates>
		<renderTemplate default="true" href="templates/secondary.html" name="secondaryContent" type="module" />
		<renderTemplate default="true" href="templates/primary.html" name="primaryContent" type="module" />
		<renderTemplate default="true" href="templates/index.html" name="website" type="page" />
	</renderTemplates>
	<resourceLibraryPaths>
		<resourceLibraryPath>legacy://$RESOURCES_ROOT$</resourceLibraryPath>
	</resourceLibraryPaths>
	<pageProperties>
		<property name="siteTagline" value="Made with ColdBricks" />
		<property name="siteTitle" value="Your Website" />
	</pageProperties>
	<contentRenderers>
		<contentRenderer moduleType="nav" path=".components.nav" />
	</contentRenderers>
</homePortals>
