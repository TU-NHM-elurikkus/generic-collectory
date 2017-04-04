<%@ page import="au.org.ala.collectory.CollectoryTagLib" %>

<div class="section">
    <g:set var="facet" value="${new CollectoryTagLib().getFacetForEntity(instance)}"/>

    <h3>
        <g:message code="dataAccess.title"/>
    </h3>

    <h4>
        <a id="totalRecordCountLink" href="${grailsApplication.config.biocacheUiURL}/occurrences/search?q=${facet}:${instance.uid}"></a>
    </h4>

    <div class="dataAccess btn-group-vertical">
        <a href="${grailsApplication.config.biocacheUiURL}/occurrences/search?q=${facet}:${instance.uid}">
            <button class="erk-button erk-button--light">
                <span class="fa fa-list"></span>&nbsp;
                <g:message code="dataAccess.view.records"/>
            </button>
        </a>

        <g:if test="${!grailsApplication.config.disableLoggerLinks.toBoolean() && grailsApplication.config.loggerURL}">
            <a href="${grailsApplication.config.loggerURL}/reasonBreakdownCSV?eventId=1002&entityUid=${instance.uid}"">
                <button class="erk-button erk-button--light">
                    <span class="icon icon-download-alt"></span>&nbsp;
                    <g:message code="dataAccess.download.stats"/>
                </button>
            </a>
        </g:if>

        <cl:createNewRecordsAlertsLink query="${facet}:${instance.uid}" displayName="${instance.name}"
            linkText="${g.message(code:'dataAccess.alert.records.alt')}" altText="${g.message(code:'dataAccess.alert.records')} ${instance.name}"/>

        <cl:createNewAnnotationsAlertsLink query="${facet}:${instance.uid}" displayName="${instance.name}"
            linkText="${g.message(code:'dataAccess.alert.annotations.alt')}" altText="${g.message(code:'dataAccess.alert.annotations')} ${instance.name}"/>
    </div>
</div>
