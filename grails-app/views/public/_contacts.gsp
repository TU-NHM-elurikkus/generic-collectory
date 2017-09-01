<g:if test="${it?.size() > 0}">
    <div class="section">
        <h3>
            <g:message code="public.show.contacts.contact" />
        </h3>

        <g:each in="${it}" var="cf">
            <div class="contact">
                <p>
                    <span class="contactName">
                        ${cf?.contact?.buildName()}
                    </span>

                    <br />

                    <g:if test="${cf?.role}">
                        ${cf?.role}
                        <br />
                    </g:if>

                    <g:if test="${cf?.contact?.phone}">
                        <g:message code="public.show.contacts.phone" /> : ${cf?.contact?.phone}
                        <br />
                    </g:if>

                    <g:if test="${cf?.contact?.fax}">
                        <g:message code="public.show.contacts.phone" />: ${cf?.contact?.fax}
                        <br />
                    </g:if>

                    <cl:emailLink email="${cf?.contact?.email}">
                        <span class="fa fa-envelope"></span>
                        <g:message code="public.show.contacts.email" />
                    </cl:emailLink>
                </p>
            </div>
        </g:each>
    </div>
</g:if>
