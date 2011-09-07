<?xml version="1.0" encoding="UTF-8"?>
<homePortals>

	<appRoot>$APP_ROOT$</appRoot>
	<contentRoot>$CONTENT_ROOT$</contentRoot>
	<resourceLibraryPaths>
		<resourceLibraryPath>$RESOURCES_ROOT$</resourceLibraryPath>
	</resourceLibraryPaths>
	<defaultPage>default</defaultPage>
	<renderTemplates>
		<renderTemplate name="three-column" type="page" href="$APP_ROOT$/templates/index.html" />
		<renderTemplate name="two-column" type="page" href="$APP_ROOT$/templates/2-columns.html" />
		<renderTemplate name="paragraph" type="module" href="$APP_ROOT$/templates/paragraph.html" />
	</renderTemplates>
	<plugins>
		<plugin name="skins" path="homePortals.plugins.skins.plugin" />
	</plugins>
</homePortals>
