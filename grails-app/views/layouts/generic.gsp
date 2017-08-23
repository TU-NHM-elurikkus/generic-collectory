<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="app.version" content="${g.meta(name:'app.version')}" />
        <meta name="app.build" content="${g.meta(name:'app.build')}" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        <g:render template="/manifest" plugin="elurikkus-commons" />
        <g:render template="/layouts/global" plugin="erkcollectory" />

        <title>
            <g:layoutTitle />
        </title>

        <asset:javascript src="collectory.js" />

        <asset:stylesheet src="generic.css" />
        <asset:stylesheet src="elurikkus-common.css" />
        <asset:stylesheet src="collectory.css" />
        <asset:stylesheet src="jquery-ui.css" />
        <asset:stylesheet src="fancybox.css" />
        <asset:stylesheet src="openlayers.css" />

        <g:layoutHead />
    </head>

    <body>
        <g:render template="/menu" plugin="elurikkus-commons" />

        <div id="main-content">
            <g:layoutBody />
        </div>

        <g:render template="/footer" plugin="elurikkus-commons" />
    </body>
</html>
