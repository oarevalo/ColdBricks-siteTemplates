<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<contentRoot>$CONTENT_ROOT$/pages/</contentRoot>
	<resourceLibraryPath>$CONTENT_ROOT$/resources</resourceLibraryPath>
	<plugins>
		<plugin name="jquery"  />
		<plugin name="accounts"  />
		<plugin name="modules"  />
	</plugins>
	<baseResources>
		<resource href="includes/header.cfm" type="header" />
		<resource href="includes/footer.cfm" type="footer" />
		<resource href="includes/controlPanel.js" type="script" />
		
		<resource href="includes/reset.css" type="style"/>
		<resource href="includes/style.css" type="style" />
	</baseResources>
	<renderTemplates>
		<renderTemplate name="page" type="page" href="$CONTENT_ROOT$/templates/page.htm" />
	</renderTemplates>
	<pageProperties>
		<property name="locale" value="en_US" />
	</pageProperties>
	
</homePortals>
