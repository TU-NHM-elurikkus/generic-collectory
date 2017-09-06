<%@ page import="au.org.ala.collectory.CollectoryTagLib" %>

<div class="section">
    <g:set var="facet" value="${new CollectoryTagLib().getFacetForEntity(instance)}" />

    <h3>
        <g:message code="dataAccess.title" />
    </h3>

    <div>
        <a id="totalRecordCountLink" href="${grailsApplication.config.biocacheUiURL}/occurrences/search?q=${facet}:${instance.uid}"></a>
    </div>

    <div class="dataAccess btn-group-vertical">
        <cl:createNewRecordsAlertsLink query="${facet}:${instance.uid}" displayName="${instance.name}"
            linkText="${g.message(code:'dataAccess.alert.records.alt')}" altText="${g.message(code:'dataAccess.alert.records')} ${instance.name}"
        />

        <cl:createNewAnnotationsAlertsLink query="${facet}:${instance.uid}" displayName="${instance.name}"
            linkText="${g.message(code:'dataAccess.alert.annotations.alt')}" altText="${g.message(code:'dataAccess.alert.annotations')} ${instance.name}"
        />
    </div>
</div>
