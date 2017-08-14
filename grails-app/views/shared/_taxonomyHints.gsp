<%@ page import="au.org.ala.collectory.JSONHelper" %>


<div class="card">
    <div class="card-header">
        <h2>
            <g:message code="shared.th.title01" />
        </h2>
    </div>

    <div class="card-block">
        <ul class='simple'>
            <g:each in="${JSONHelper.taxonomyHints(instance.taxonomyHints)}" var="hint">
                <g:set var="key" value="${hint.keySet().iterator().next()}" />
                <li>
                    ${key} = ${hint[key]}
                </li>
            </g:each>
        </ul>

        <div style="clear:both;"></div>

        <p>
            <cl:editButton uid="${instance.uid}" page="/shared/editTaxonomyHints" />
        </p>
    </div>
</div>
