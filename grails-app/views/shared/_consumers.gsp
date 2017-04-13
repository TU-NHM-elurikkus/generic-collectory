<%@ page import="au.org.ala.collectory.ProviderGroup" %>
<div class="card">
    <div class="card-header">
        <h2>
            <g:message code="shared.consumers.title01" />
        </h2>
    </div>

    <div class="card-block">
        <p>
            <g:message code="shared.consumers.des01" args="[ProviderGroup.textFormOfEntityType(instance.uid)]" />.
            <br/>
            <g:message code="shared.consumers.des02" />.
        </p>

        <ul class="fancy">
            <g:each in="${instance.listConsumers()}" var="con">
                <g:set var="pg" value="${ProviderGroup._get(con)}"/>
                <g:if test="${pg}">
                    <li>
                        <g:link controller="${cl.controllerFromUid(uid:con)}" action="show" id="${con}">${pg.name}</g:link>
                        &nbsp;(${con[0..1] == 'in' ? 'institution' : 'collection'})
                    </li>
                </g:if>
                <g:else>
                    <li><g:message code="shared.consumers.des03" />!</li>
                </g:else>
            </g:each>
        </ul>

        <div style="clear:both;"></div>

        <p>
            <g:link action='editConsumers' params="[source:'co']" id="${instance.uid}">
                <button class="erk-button erk-button--light">
                    <g:message code="shared.consumers.link01" />&nbsp;
                </button>
            </g:link>

            <g:link action='editConsumers' params="[source:'in']" id="${instance.uid}">
                <button class="erk-button erk-button--light">
                    <g:message code="shared.consumers.link02" />
                </button>
            </g:link>
        </p>
    </div>
</div>
