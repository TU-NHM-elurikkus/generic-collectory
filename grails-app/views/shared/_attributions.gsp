<!-- Attributions -->
<div class="card">
    <div class="card-header">
        <h2>
            <g:message code="shared.a.title01" />
        </h2>
    </div>

    <div class="card-body">
        <ul class="fancy">
            <g:each in="${instance.getAttributionList()}" var="att">
                <li>
                    ${att.name}
                </li>
            </g:each>
        </ul>

        <div style="clear:both;"></div>

        <p>
            <cl:editButton uid="${instance.uid}" action="editAttributions" target="${target}" />
        </p>
    </div>
</div>
