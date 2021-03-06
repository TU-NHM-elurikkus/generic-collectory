<%@ page import="grails.converters.JSON" %>
<%@ page import="grails.util.Holders" %>
<%@ page import="au.org.ala.collectory.ProviderGroup" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <g:set var="entityName" value="${instance.ENTITY_TYPE}" />
        <g:set var="entityNameLower" value="${cl.controller(type: instance.ENTITY_TYPE)}" />
        <title>
            <g:message code="general.show.label" args="[entityName]" />
        </title>
        <script type="text/javascript" language="javascript" src="https://www.google.com/jsapi"></script>
    </head>

    <body onload="initializeLocationMap('${instance.canBeMapped()}',${instance.latitude},${instance.longitude});">
        <style>
            #mapCanvas {
              width: 200px;
              height: 170px;
              float: right;
            }

            .privateMenuLink {
                margin-right: 1rem;
                text-decoration: underline;
            }

        </style>

        <div class="row">
            <div class="col-12">
                <span class="privateMenuLink">
                    <cl:homeLink />
                </span>

                <span class="privateMenuLink">
                    <g:link class="list" action="list">
                        <g:message code="general.list.label" args="[entityName]" />
                    </g:link>
                </span>

                <span class="privateMenuLink">
                    <g:link class="create" action="create">
                        <g:message code="general.new.label" args="[entityName]" />
                    </g:link>
                </span>

                <p class="float-right">
                    <span class="button">
                        <cl:viewPublicLink uid="${instance?.uid}"/>
                    </span>
                    <span class="button">
                        <cl:jsonSummaryLink uid="${instance.uid}"/>
                    </span>
                    <span class="button">
                        <cl:jsonDataLink uid="${instance.uid}"/>
                    </span>
                </p>
            </div>

            <div class="col-12">
                <div class="body">
                    <g:if test="${flash.message}">
                        <div class="message">
                            ${flash.message}
                        </div>
                    </g:if>

                    <div class="dialog emulate-public">
                        <!-- base attributes -->
                        <div class="card titleBlock">
                            <div class="card-header">
                                <!-- Name --><!-- Acronym -->
                                <h1>
                                    ${fieldValue(bean: instance, field: "name")}
                                    <cl:valueOrOtherwise value="${instance.acronym}">
                                        (${fieldValue(bean: instance, field: "acronym")})
                                    </cl:valueOrOtherwise>
                                </h1>
                            </div>

                            <div class="card-body">
                                <!-- Data Provider --><!-- ALA Partner -->
                                <g:if test="${instance.dataProvider}">
                                    <h2 style="display: inline">
                                        <g:link controller="dataProvider" action="show" id="${instance.dataProvider?.id}">
                                            ${instance.dataProvider?.name}
                                        </g:link>
                                    </h2>
                                </g:if>

                                <cl:partner test="${instance.dataProvider?.isALAPartner}" />

                                <%-- XXX --%>
                                <br />

                                <!-- Institution -->
                                <g:if test="${instance.institution}">
                                    <p>
                                        <span class="category">
                                            <g:message code="dataresource.show.sor" />:&nbsp;
                                        </span>
                                        &nbsp; <%-- Why two spaces here but one elsewhere. --%>
                                        <g:link controller="institution" action="show" id="${instance.institution?.uid}">
                                            ${instance.institution?.name}
                                        </g:link>
                                    </p>
                                </g:if>

                                <!-- GUID    -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.guid" />:&nbsp;
                                    </span>
                                    &nbsp;<cl:guid target="_blank" guid='${fieldValue(bean: instance, field: "guid")}' />
                                </p>

                                <!-- UID    -->
                                <p>
                                    <span class="category">
                                        <g:message code="providerGroup.uid.label" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "uid")}
                                </p>

                                <!-- type -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.resourcetype" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "resourceType")}
                                </p>

                                <!-- Web site -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.website" />:&nbsp;
                                    </span>
                                    &nbsp;<cl:externalLink href="${fieldValue(bean:instance, field:'websiteUrl')}" />
                                </p>

                                <!-- Networks -->
                                <g:if test="${instance.networkMembership}">
                                    <p>
                                        <cl:membershipWithGraphics coll="${instance}"/>
                                    </p>
                                </g:if>

                                <!-- Notes -->
                                <g:if test="${instance.notes}">
                                    <p>
                                        <cl:formattedText>
                                            ${fieldValue(bean: instance, field: "notes")}
                                        </cl:formattedText>
                                    </p>
                                </g:if>

                                <!-- last edit -->
                                <p>
                                    <span class="category">
                                        <g:message code="datahub.show.lastchange" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "userLastModified")} on ${fieldValue(bean: instance, field: "lastUpdated")}
                                </p>

                                <g:if test="${instance.gbifDataset}">
                                    <p>
                                        This dataset was downloaded from GBIF.&nbsp;
                                        <a href="http://www.gbif.org/dataset/${instance.guid}">
                                            View details on GBIF.org
                                        </a>
                                    </p>
                                </g:if>

                                <p>
                                    <cl:editButton uid="${instance.uid}" page="/shared/base" notAuthorisedMessage="You are not authorised to edit this resource." />
                                </p>
                            </div>
                        </div>

                        <!-- description -->
                        <div class="card">
                            <div class="card-header">
                                <h2>
                                    <g:message code="collection.show.title.description" />
                                </h2>
                            </div>

                            <div class="card-body">
                                <!-- Pub Short Desc -->
                                <span class="category">
                                    <g:message code="collection.show.pubShort"  default="Public short description" />
                                </span>

                                <%-- XXX --%>
                                <br />

                                <cl:formattedText body="${instance.pubShortDescription?:'Not provided'}" />

                                <!-- Pub Desc -->
                                <span class="category">
                                    <g:message code="collection.show.span04" />
                                </span>

                                <%-- XXX --%>
                                <br />

                                <cl:formattedText body="${instance.pubDescription?:'Not provided'}" />

                                <!-- Tech Desc -->
                                <span class="category">
                                    <g:message code="collection.show.span05" />
                                </span>

                                <%-- XXX --%>
                                <br />

                                <cl:formattedText body="${instance.techDescription?:'Not provided'}" />

                                <!-- Focus -->
                                <span class="category">
                                    <g:message code="providerGroup.focus.label" />
                                </span>

                                <%-- XXX --%>
                                <br />

                                <cl:formattedText>
                                    ${instance.focus?:'Not provided'}
                                </cl:formattedText>

                                <!-- generalisations -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.dg" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "dataGeneralizations")}
                                </p>

                                <!-- info withheld -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.iw" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "informationWithheld")}
                                </p>

                                <!-- content types -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.contentTypes.label" />:&nbsp;
                                    </span>
                                    &nbsp;<cl:formatJsonList value="${instance.contentTypes}" />
                                </p>

                                <p>
                                    <cl:editButton uid="${instance.uid}" page="description" />
                                </p>
                            </div>
                        </div>

                        <!-- image metadata -->
                        <div class="card">
                            <div class="card-header">
                                <h2>
                                    Image metadata
                                </h2>
                            </div>

                            <div class="card-body">
                                <p>
                                    These values the default values displayed for any images loaded for this data resource.
                                </p>

                                <cl:showImageMetadata imageMetadata="${instance.imageMetadata}" />

                                <p>
                                    <cl:editButton uid="${instance.uid}" page="/dataResource/imageMetadata" />
                                </p>
                            </div>
                        </div>

                        <!-- taxonomic range -->
                        <div class="card">
                            <div class="card-header">
                                <h2>
                                    Taxonomic range
                                </h2>
                            </div>

                            <div class="card-body">
                                <!-- range -->
                                <cl:taxonomicRangeDescription obj="${instance.taxonomyHints}" key="range" />

                                <p>
                                    <cl:editButton uid="${instance.uid}" page="/shared/taxonomicRange" />
                                </p>
                            </div>
                        </div>

                        <!-- mobilisation -->
                        <div class="card">
                            <div class="card-header">
                                <h2>
                                    <g:message code="dataresource.show.title01" />
                                </h2>
                            </div>

                            <div class="card-body">
                                <g:if test="${instance.gbifDataset}">
                                    <cl:ifGranted role="${ProviderGroup.ROLE_ADMIN}">
                                        <div class="float-right">
                                            <span class="buttons">
                                                <g:link class="" controller="manage" action="gbifDatasetDownload" id="${instance.uid}">
                                                    <button class="erk-button erk-button--light">
                                                        <i class="icon-refresh"> </i>
                                                        ${message(code: 'datasource.button.update', default: 'Reload from GBIF')}
                                                    </button>
                                                </g:link>
                                            </span>
                                        </div>
                                    </cl:ifGranted>
                                </g:if>

                                <!-- contributor -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.ac" />:&nbsp;
                                    </span>

                                    <cl:tickOrCross test="${instance.status == 'dataAvailable' || instance.status == 'linksAvailable'}">
                                        yes|no
                                    </cl:tickOrCross>
                                </p>

                                <!-- status -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.status" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "status")}
                                </p>

                                <!-- provenance -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.provenance" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "provenance")}
                                </p>

                                <!-- last checked -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.lc" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "lastChecked")}
                                </p>

                                <!-- data currency -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.dc" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "dataCurrency")}
                                </p>

                                <!-- harvest frequency -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.hf" />:&nbsp;
                                    </span>

                                    <g:if test="${instance.harvestFrequency}">
                                        <g:message code="dataresource.show.ed" args="[instance.harvestFrequency]" />.
                                    </g:if>
                                    <g:else>
                                        <g:message code="dataresource.show.manual" />
                                    </g:else>
                                </p>

                                <!-- mobilisation notes -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.mn" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "mobilisationNotes")}
                                </p>

                                <!-- harvesting notes -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.hn" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "harvestingNotes")}
                                </p>

                                <!-- public archive available -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataresource.show.paa" />:&nbsp;
                                    </span>

                                    <cl:tickOrCross test="${instance.publicArchiveAvailable}">
                                        yes|no
                                    </cl:tickOrCross>
                                </p>

                                <!-- connection parameters -->
                                <h3>
                                    <g:message code="dataresource.show.title02" />
                                </h3>

                                <cl:showConnectionParameters connectionParameters="${instance.connectionParameters}" />

                                <g:if test="${instance.resourceType == 'records'}">
                                    <!-- darwin core defaults -->
                                    <g:set var="dwc" value="${instance.defaultDarwinCoreValues ? JSON.parse(instance.defaultDarwinCoreValues) : [:]}" />
                                    <h4>
                                        Default values for DwC fields
                                    </h4>

                                    <g:if test="${!dwc}">
                                        none
                                    </g:if>

                                    <dl class="dl-horizontal">
                                        <g:each in="${dwc.entrySet()}" var="dwct">
                                            <dt>${dwct.key}:</dt>
                                            <dd>${dwct.value?:'Not supplied'}</dd>
                                        </g:each>
                                    </dl>
                                </g:if>

                                <cl:ifGranted role="${ProviderGroup.ROLE_ADMIN}">
                                    <div>
                                        <span class="buttons">
                                            <p>
                                                <g:link action='edit' params="[page:'contribution']" id="${instance.uid}">
                                                    <button class="erk-button erk-button--light">
                                                        ${message(code: 'general.button.edit.label', default: 'Edit')}
                                                    </button>
                                                </g:link>
                                            </p>
                                        </span>
                                    </div>
                                </cl:ifGranted>
                            </div>
                        </div>

                        <div class="card">
                            <div class="card-header">
                                <h3>
                                    <g:message code="dataresource.show.title03" />
                                </h3>
                            </div>

                            <div class="card-body">
                                <p>
                                    <g:link controller="dataResource" action="upload" id="${instance.uid}">
                                        <button class="erk-button erk-button--light">
                                            <i class="icon-upload"></i>
                                            &nbsp;<g:message code="dataresource.show.link.upload" />
                                        </button>
                                    </g:link>
                                </p>
                            </div>
                        </div>

                        <!-- rights -->
                        <div class="card">
                            <div class="card-header">
                                <h2>
                                    <g:message code="dataresource.show.title04" />
                                </h2>
                            </div>

                            <div class="card-body">
                                <!-- citation -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.citation.label" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "citation")}
                                </p>

                                <!-- rights -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.rights.label" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "rights")}
                                </p>

                                <!-- license type-->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.licenseType.label" />:&nbsp;
                                    </span>
                                    &nbsp;<cl:displayLicenseType type="${instance.licenseType}" />
                                </p>

                                <!-- license version -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.licenseVersion.label" />:&nbsp;
                                    </span>
                                    ${fieldValue(bean: instance, field: "licenseVersion")}
                                </p>

                                <!-- permissions document -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.permissionsDocument.label" />:&nbsp;
                                    </span>

                                    <g:if test="${instance.permissionsDocument?.startsWith('http://') || instance.permissionsDocument?.startsWith('https://')}">
                                        <g:link class="external_icon" target="_blank" url="${instance.permissionsDocument}">
                                            ${fieldValue(bean: instance, field: "permissionsDocument")}
                                        </g:link>
                                    </g:if>
                                    <g:else>
                                        ${fieldValue(bean: instance, field: "permissionsDocument")}
                                    </g:else>
                                </p>

                                <!-- permissions document type -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.permissionsDocumentType.label" />:&nbsp;
                                    </span>
                                    &nbsp;${fieldValue(bean: instance, field: "permissionsDocumentType")}
                                </p>

                                <!-- DPA flags -->
                                <g:if test="${instance.permissionsDocumentType == 'Data Provider Agreement'}">
                                    <p>
                                        <span class="category">
                                            <g:message code="dataResource.riskAssessment.label" />:&nbsp;
                                        </span>
                                        <cl:tickOrCross test="${instance.riskAssessment}">
                                            yes|no
                                        </cl:tickOrCross>
                                    </p>

                                    <p>
                                        <span class="category">
                                            <g:message code="dataresource.show.documentfield.label" />:&nbsp;
                                        </span>
                                        <cl:tickOrCross test="${instance.filed}">
                                            yes|no
                                        </cl:tickOrCross>
                                    </p>
                                </g:if>

                                <!-- download limit -->
                                <p>
                                    <span class="category">
                                        <g:message code="dataResource.downloadLimit.label" />:&nbsp;
                                    </span>
                                    &nbsp;${instance.downloadLimit ? fieldValue(bean:instance,field:'downloadLimit') : 'no limit'}
                                </p>

                                <p>
                                    <cl:editButton uid="${instance.uid}" page="rights" />
                                </p>
                            </div>
                        </div>

                        <!-- images -->
                        <g:render template="/shared/images" model="[target: 'logoRef', image: instance.logoRef, title:'Logo', instance: instance]" />
                        <g:render template="/shared/images" model="[target: 'imageRef', image: instance.imageRef, title:'Representative image', instance: instance]" />

                        <!-- location -->
                        <g:render template="/shared/location" model="[instance: instance]" />

                        <!-- Record consumers -->
                        <g:if test="${instance.resourceType == 'records'}">
                            <g:render template="/shared/consumers" model="[instance: instance]" />
                        </g:if>

                        <!-- Contacts -->
                        <g:render template="/shared/contacts" model="[contacts: contacts, instance: instance]" />

                        <!-- Attributions -->
                        <g:render template="/shared/attributions" model="[instance: instance]" />

                        <!-- taxonomy hints -->
                        <g:render template="/shared/taxonomyHints" model="[instance: instance]" />

                        <!-- change history -->
                        <g:render template="/shared/changes" model="[changes: changes, instance: instance]" />
                    </div>

                    <div class="buttons">
                        <div class="float-right">
                            <span class="button"><cl:viewPublicLink uid="${instance?.uid}"/></span>
                            <span class="button"><cl:jsonSummaryLink uid="${instance.uid}"/></span>
                            <span class="button"><cl:jsonDataLink uid="${instance.uid}"/></span>
                        </div>

                        <g:form>
                            <g:hiddenField name="id" value="${instance?.id}" />

                            <cl:ifGranted role="${ProviderGroup.ROLE_ADMIN}">
                                <span>
                                    <g:actionSubmit
                                        class="erk-button erk-button--dark"
                                        action="delete"
                                        value="${message(code: 'general.button.delete.label', default: 'Delete')}"
                                        onclick="return confirm('${message(code: 'general.button.delete.confirm.message', default: 'Are you sure?')}');"
                                    />
                                </span>
                            </cl:ifGranted>
                        </g:form>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
