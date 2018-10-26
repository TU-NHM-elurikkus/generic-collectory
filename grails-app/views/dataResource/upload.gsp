<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <g:set var="entityName" value="${instance.ENTITY_TYPE}" />
        <g:set var="entityNameLower" value="${cl.controller(type: instance.ENTITY_TYPE)}" />

        <title>
            <g:message code="general.show.label" args="[entityName]" />
        </title>

        <script type="text/javascript" language="javascript" src="https://www.google.com/jsapi"></script>

        <asset:javascript src="fileupload.js" />
        <asset:stylesheet src="fileupload.css" />
    </head>

    <body>
        <div id="content">
            <div id="header" class="page-header">
                <h1 class="page-header__title">
                    <g:message code="dataresource.upload.title" />:

                    <g:link controller="dataResource" action="show" id="${instance.uid}">
                        ${fieldValue(bean: instance, field: "name")}
                        <cl:valueOrOtherwise value="${instance.acronym}">
                            (${fieldValue(bean: instance, field: "acronym")})
                        </cl:valueOrOtherwise>
                    </g:link>
                </h1>

                <div class="submenu__title">
                    NB! WHen using DWC-A from GBIF
                </div>
                <div class="page-header__subtitle">
                    <ul>
                        <li>
                            If DWC-A doesn't have eml.xml file <br />
                            ALA fills Data Resource Metadata from eml file. If there's dataset file, copy the xml file
                            with dataset's hash as name to DWC-A root level and rename it to "eml.xml". Else if there's
                            a metadata.xml in DWC-A root level, make a copy of it named "eml.xml"
                        </li>
                        <li>
                            When uploading DWC-A, unique separator is probably <b>"gbifID"</b>
                        </li>
                        <li>
                            If biocache ingest command fails, try manually calling
                            <ul>
                                <li>
                                    load-dwca drID
                                </li>
                                <li>
                                    process -dr drID
                                </li>
                                <li>
                                    sample -dr drID
                                </li>
                                <li>
                                    index -dr drID
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>

            </div>

            <div class="tab-pane">
                <g:uploadForm action="uploadDataFile" controller="dataResource">
                    <g:hiddenField name="id" value="${instance.uid}" />

                    <%-- drag and drop file uploads --%>
                    <div class="form-group">
                        <label for="protocol">
                            <g:message code="dataresource.upload.label.protocol" />:
                        </label>

                        <g:select
                            id="protocol"
                            name="protocol"
                            from="${connectionProfiles}"
                            value="DwCA"
                            optionValue="display"
                            optionKey="name"
                            class="erk-select"
                        />
                    </div>

                    <div class="form-group">
                        <label class="control-label" for="fileToUpload">
                            <g:message code="dataresource.upload.label.file" />:
                        </label>

                        <input type="file" name="myFile" class="form-control-file file-input" />
                    </div>

                    <div id="connectionParams"></div>

                    <div class="form-group">
                        <button type="submit" id="fileToUpload" class="erk-button erk-button--dark fileupload-exists">
                            <g:message code="dataresource.gbifupload.btn.upload" />
                        </button>

                        <button class="erk-button erk-button--light cancel">
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
                                    <g:set var="connectionParam" value="${connectionParams[param]}" />
                                    <g:if test="${connectionParam.type == 'boolean'}">
                                        <label class="checkbox ${profile.name} control-label">
                                            <g:checkBox
                                                id="${connectionParam.paramName}"
                                                name="${connectionParam.paramName}"
                                                class="erk-radio-input"
                                            />
                                            ${connectionParam.display}
                                        </label>
                                    </g:if>
                                    <g:else>
                                        <label for="${connectionParam.paramName}">
                                            ${connectionParam.display}:
                                        </label>
                                        <input
                                            type="text"
                                            id="${connectionParam.paramName}"
                                            name="${connectionParam.paramName}"
                                            value="${connectionParam.defaultValue}"
                                            class="form-control"
                                        />
                                    </g:else>
                                </div>
                            </g:each>
                        </div>
                    </g:each>
                </div>

            </div>
        </div>

        <script>
            function setFormDefaults() {
                if(!$('#termsForUniqueKey').val()) {
                    $('#termsForUniqueKey').val('occurrenceID');
                }
            }

            function loadConnParams() {
                $('#connectionParams').html('');

                var $protocol = $('#protocol');
                $('#connectionParams').html($('#profile-' + $protocol.val()).html());

                setFormDefaults();
            }

            $('#protocol').change(function(){
                loadConnParams();
            });

            $(document).ready(function() {
                loadConnParams();
            });
        </script>
    </body>
</html>
