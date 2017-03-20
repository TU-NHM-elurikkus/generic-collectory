<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="app.version" content="${g.meta(name:'app.version')}"/>
        <meta name="app.build" content="${g.meta(name:'app.build')}"/>
        <title><g:layoutTitle /></title>
        <g:render template="/layouts/global" plugin="collectory"/>
        <r:require modules="jquery, jquery_migration, application, generic, menu" />
        <r:layoutResources/>
        <g:layoutHead />
    </head>

    <body>
        <g:render template="/menu" plugin="elurikkus-commons" />

        <div class="container" id="main-content">
            <g:layoutBody />
        </div>

        <!-- JS resources-->
        <r:layoutResources/>

        <g:render template="/footer" plugin="elurikkus-commons" />
    </body>
</html>
