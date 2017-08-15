<%@ page import="au.org.ala.collectory.DataProvider" %>
<%@ page import="au.org.ala.collectory.DataResource" %>
<%@ page import="au.org.ala.collectory.Institution" %>
<%@ page import="au.org.ala.collectory.ProviderGroup" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <g:set var="entityName" value="${command.ENTITY_TYPE}" />
        <g:set var="entityNameLower" value="${command.urlForm()}" />
        <title>
            <g:message code="collection.base.label" args="[entityNameLower]" default="Edit ${entityNameLower}  metadata" />
        </title>
    </head>

    <body>
        <div class="card">
            <div class="card-header">
                <g:if test="${mode == 'create'}">
                    <h1>
                        Creating a new collection
                    </h1>
                </g:if>
                <g:else>
                    <h1>
                        Editing: ${command.name}
                    </h1>
                </g:else>
            </div>

            <div id="baseForm" class="body card-block">
                <g:if test="${message}">
                    <div class="message">
                        ${message}
                    </div>
                </g:if>

                <g:hasErrors bean="${command}">
                    <div class="errors">
                        <g:renderErrors bean="${command}" as="list" />
                    </div>
                </g:hasErrors>

                <g:form method="post" name="baseForm" action="base">
                    <g:hiddenField name="id" value="${command?.id}" />
                    <g:hiddenField name="version" value="${command.version}" />

                    <div class="form-group">
                        <label for="guid">
                            <g:message code="collection.guid.label" default="Guid" />
                        </label>
                        <g:textField name="guid" value="${command?.guid}" class="form-control" />
                        <cl:helpText code="${entityNameLower}.guid" />
                    </div>

                    <div class="form-group">
                        <label for="name">
                            <g:message code="collection.name.label" default="Name" />
                            <span>
                                * required field
                            </span>
                        </label>

                        <g:textField name="name" class="form-control" value="${command?.name}" />
                        <cl:helpText code="${entityNameLower}.name" />
                    </div>

                    <div class="form-group">
                        <label for="acronym">
                            <g:message code="collection.acronym.label" default="Acronym" />
                        </label>

                        <g:textField name="acronym" value="${command?.acronym}" class="form-control" />
                        <cl:helpText code="providerGroup.acronym" />
                    </div>

                    <g:if test="${command.ENTITY_TYPE == 'DataResource'}">
                        <div class="form-group">
                            <label for="resourceType">
                                <g:message code="collection.resourceType.label" default="Resource type" />
                            </label>

                            <g:select
                                name="resourceType"
                                from="${DataResource.resourceTypeList}"
                                value="${command.resourceType}"
                                class="form-control"
                            />

                            <cl:helpText code="providerGroup.resourceType" />
                        </div>
                    </g:if>

                    <g:if test="${command.ENTITY_TYPE == 'Collection'}">
                        <!-- institution -->
                        <div class="form-group">
                            <label for="institution.id">
                                <g:message code="collection.institution.label" default="Institution" />
                            </label>

                            <g:select
                                name="institution.id"
                                from="${Institution.list([sort:'name'])}"
                                optionKey="id"
                                noSelection="${['null':'Select an institution']}"
                                value="${command.institution?.id}"
                                class="form-control"
                            />

                            <cl:helpText code="collection.institution" />
                        </div>
                    </g:if>

                    <g:if test="${command.ENTITY_TYPE == 'DataResource'}">
                        <!-- data provider -->
                        <div class="form-group">
                            <label for="dataProvider.id">
                                <g:message code="dataResource.dataProvider.label" default="Data provider" />
                            </label>

                            <g:select name="dataProvider.id"
                                from="${DataProvider.list([sort:'name'])}"
                                optionKey="id"
                                noSelection="${['null':'Select a data provider']}"
                                value="${command.dataProvider?.id}"
                                class="form-control"
                            />

                            <cl:helpText code="dataResource.dataProvider" />
                        </div>

                        <!-- institution -->
                        <div class="form-group">
                            <label for="institution.id">
                                <g:message code="institution.dataProvider.label" default="Institution" />
                            </label>

                            <g:select
                                name="institution.id"
                                from="${Institution.list([sort:'name'])}"
                                optionKey="id"
                                noSelection="${['null':'Select an institution']}"
                                value="${command.institution?.id}"
                                class="form-control"
                            />

                            <cl:helpText code="dataResource.institution" />
                        </tr>
                    </g:if>

                    <!-- ALA partner -->
                    <cl:ifGranted role="${ProviderGroup.ROLE_ADMIN}">
                        <div class="form-group">
                            <label for="isALAPartner">
                                <g:message code="providerGroup.isALAPartner.label" default="=Is Atlas Partner" />
                            </label>
                            <br />

                            <g:checkBox name="isALAPartner" value="${command?.isALAPartner}" />
                        </div>
                    </cl:ifGranted>

                    <!-- network membership -->
                    <div class="form-group">
                        <label for="networkMembership">
                            <g:message code="providerGroup.networkMembership.label" default="Belongs to" />
                        </label>

                        <cl:checkboxSelect
                            name="networkMembership"
                            from="${ProviderGroup.networkTypes}"
                            value="${command?.networkMembership}"
                            multiple="yes"
                            valueMessagePrefix="providerGroup.networkMembership"
                            noSelection="['': '']"
                        />

                        <cl:helpText code="providerGroup.networkMembership" />
                    </div>

                    <!-- web site url -->
                    <div class="form-group">
                        <label for="websiteUrl">
                            <g:message code="providerGroup.websiteUrl.label" default="Website Url" />
                        </label>

                        <g:textField name="websiteUrl" class="form-control" value="${command?.websiteUrl}" />
                        <cl:helpText code="providerGroup.websiteUrl" />
                    </div>

                    <!-- notes -->
                    <div class="form-group">
                        <label for="notes">
                            <g:message code="providerGroup.notes.label" default="Notes" />
                        </label>

                        <g:textArea name="notes" cols="40" class="form-control" rows="${cl.textAreaHeight(text:command.notes)}" value="${command?.notes}" />
                        <cl:helpText code="collection.notes" />
                    </div>

                    <div class="buttons">
                        <button type="submit" name="_action_updateBase" class="erk-button erk-button--light">
                            Update
                        </button>
                        <button type="submit" name="_action_cancel" value="Cancel" class="erk-button erk-button--light">
                            Cancel
                        </button>
                    </div>
                </g:form>
            </div>
        </div>
    </body>
</html>
