<%@ page import="grails.converters.JSON; au.org.ala.collectory.ProviderGroup; au.org.ala.collectory.DataProvider" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <g:set var="entityName" value="${instance.ENTITY_TYPE}" />
        <g:set var="entityNameLower" value="${cl.controller(type: instance.ENTITY_TYPE)}"/>
        <title><g:message code="default.show.label" args="[entityName]" /></title>
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.3&sensor=false"></script>
        <r:require modules="fileupload"/>
    </head>

    <body>
        <h1>
            <g:message code="dataresource.upload.title" />:

            <g:link controller="dataResource" action="show" id="${instance.uid}">
                ${fieldValue(bean: instance, field: "name")}
                <cl:valueOrOtherwise value="${instance.acronym}"> (${fieldValue(bean: instance, field: "acronym")})</cl:valueOrOtherwise>
            </g:link>
        </h1>

        <div class="well pull-right span6">
            <g:message code="dataresource.upload.des" />.
        </div>

        <g:uploadForm action="uploadDataFile" controller="dataResource">
            <g:hiddenField name="id" value="${instance.uid}"/>

            <!-- drag and drop file uploads -->
            <div class="form-group">
                <label for="protocol"><g:message code="dataresource.upload.label.protocol" />:</label>

                <g:select
                    id="protocol"
                    name="protocol"
                    from="${connectionProfiles}"
                    value="protocol"
                    optionValue="display"
                    optionKey="name"
                    class="form-control"/>
            </div>

            <div class="form-group">
                <label for="fileToUpload">
                    <g:message code="dataresource.upload.label.file" />:
                </label>

                <input type="file" name="myFile" class="erk-button erk-button--light"/>
            </div>

            <div id="connectionParams"></div>

            <div style="clear:both">
                <input type="submit" id="fileToUpload" class="erk-button erk-button--light fileupload-exists" value="Upload"/>
                <button class="erk-button erk-button--light  cancel">
                    <g:message code="dataresource.upload.label.cancel" />
                </button>
            </div>
        </g:uploadForm>

        <div id="connectionTemplates" class="hidden-node">
            <g:each in="${connectionProfiles}" var="profile">
                <div id="profile-${profile.name}">
                    <g:each in="${profile.params.minus('LOCATION_URL')}" var="param">
                        <div class="form-group">
                            <!-- get param -->
                            <g:set var="connectionParam" value="${connectionParams[param]}"/>
                            <g:if test="${connectionParam.type == 'boolean'}">
                                <label class="checkbox ${profile.name}">
                                    <g:checkBox id="${connectionParam.paramName}" name="${connectionParam.paramName}"/>
                                    ${connectionParam.display}
                                </label>
                            </g:if>
                            <g:else>
                                <label for="${connectionParam.paramName}">${connectionParam.display}:</label>
                                <input type="text" id="${connectionParam.paramName}" name="${connectionParam.paramName}" value="${connectionParam.defaultValue}" class="form-control"/>
                            </g:else>
                        </div>
                    </g:each>
                </div>
            </g:each>
        </div>

        <r:script>
            function loadConnParams(){
                $('#connectionParams').html('');

                var $protocol = $('#protocol');
                $('#connectionParams').html($('#profile-' + $protocol.val()).html());
            }

            $(function(){
                $('#protocol').change(function(){
                    loadConnParams();
                });

                loadConnParams();
            })
        </r:script>
    </body>
</html>
