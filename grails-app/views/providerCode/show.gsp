<%@ page import="au.org.ala.collectory.ProviderCode" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="${grailsApplication.config.skin.layout}" />
		<g:set var="entityName" value="${message(code: 'providerCode.label', default: 'ProviderCode')}" />
		<title><g:message code="general.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#show-providerCode" class="skip" tabindex="-1"><g:message code="general.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="general.home.label"/></a></li>
				<li><g:link class="list" action="list"><g:message code="general.list.label" args="[entityName]" /></g:link></li>
				<li><g:link class="create" action="create"><g:message code="general.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>

		<div class="pull-right span5 well">
			<g:link controller="providerMap">
				Click here to create/edit a provider map
			</g:link>
		</div>

		<div id="show-providerCode" class="content scaffold-show" role="main">
			<h1><g:message code="general.show.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<ol class="property-list providerCode">
				<g:if test="${providerCodeInstance?.code}">
				<li class="fieldcontain">
					<span id="code-label" class="property-label"><g:message code="providerCode.code.label" default="Code" /></span>
					
						<span class="property-value" aria-labelledby="code-label"><g:fieldValue bean="${providerCodeInstance}" field="code"/></span>
					
				</li>
				</g:if>
			</ol>
			<g:form>
				<fieldset class="buttons">
					<g:hiddenField name="id" value="${providerCodeInstance?.id}" />
					<g:link class="edit" action="edit" id="${providerCodeInstance?.id}"><g:message code="general.button.edit.label" default="Edit" /></g:link>
					<g:actionSubmit class="delete" action="delete" value="${message(code: 'general.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'general.button.delete.confirm.message', default: 'Are you sure?')}');" />
				</fieldset>
			</g:form>
		</div>
	</body>
</html>
