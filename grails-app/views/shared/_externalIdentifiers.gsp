<!-- external identifiers -->
<div class="card">
    <div class="card-header">
        <h2>
            <g:message code="shared.ext.title01" />
        </h2>
    </div>

    <div class="card-block">
        <ul class='simple'>
            <g:each in="${instance.externalIdentifiers}" var="id">
                <li>
                    <g:fieldValue bean="${id}" field="label"/>
                    <g:if test="${id.uri}">
                        <a href="${id.uri}" target="_blank" class="external">
                            &nbsp;<g:fieldValue bean="${id}" field="uri"/>
                        </a>
                    </g:if>
                </li>
            </g:each>
        </ul>

        <div style="clear:both;"></div>

        <p>
            <cl:editButton uid="${instance.uid}" page="/shared/editExternalIdentifiers"/>
        </p>
    </div>
</div>
