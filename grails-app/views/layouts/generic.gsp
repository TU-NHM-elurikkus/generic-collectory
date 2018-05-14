<!DOCTYPE html>
<%@ page import="grails.util.Environment" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="app.version" content="${g.meta(name:'app.version')}" />
        <meta name="app.build" content="${g.meta(name:'app.build')}" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

        <g:render template="/manifest" plugin="elurikkus-commons" />

        <%-- This is needed because charts.js runs before GLOBAL_LOCALE_CONF is populated from commons --%>
        <script type="text/javascript">
            var COLLECTORY_CONF = {
                contextPath: "${request.contextPath}",
                locale: "${(org.springframework.web.servlet.support.RequestContextUtils.getLocale(request).toString())?:request.locale}",
                alaRoot: "${grailsApplication.config.serverRoot}"
            };

            var GRAILS_APP = {
                environment: "${Environment.current.name}",
                rollbarApiKey: "${grailsApplication.config.rollbar.postApiKey}"
            };
        </script>

        <title>
            <g:layoutTitle />
        </title>

        <asset:stylesheet src="collectory.css" />
        <asset:javascript src="collectory.js" />

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
