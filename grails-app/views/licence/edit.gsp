<%@ page import="au.org.ala.collectory.ProviderCode" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="${grailsApplication.config.skin.layout}" />
		<g:set var="entityName" value="${message(code: 'licence.label', default: 'Licence')}" />
		<title><g:message code="general.edit.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#edit-providerCode" class="skip" tabindex="-1"><g:message code="general.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="general.home.label"/></a></li>
				<li><g:link class="list" action="list"><g:message code="general.list.label" args="[entityName]" /></g:link></li>
				<li><g:link class="create" action="create"><g:message code="general.new.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="edit-providerCode" class="content scaffold-edit" role="main">
			<h1><g:message code="general.edit.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<g:hasErrors bean="${licenceInstance}">
			<ul class="errors" role="alert">
				<g:eachError bean="${licenceInstance}" var="error">
				<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
				</g:eachError>
			</ul>
			</g:hasErrors>
			<g:form method="post" >
				<g:hiddenField name="id" value="${licenceInstance?.id}" />
				<g:hiddenField name="version" value="${licenceInstance?.version}" />
				<fieldset class="form">
					<g:render template="form"/>
				</fieldset>
				<fieldset class="buttons">
					<g:actionSubmit class="btn save" action="update" value="${message(code: 'general.button.update.label', default: 'Update')}" />
					<g:actionSubmit class="btn delete" action="delete" value="${message(code: 'general.button.delete.label', default: 'Delete')}" formnovalidate="" onclick="return confirm('${message(code: 'general.button.delete.confirm.message', default: 'Are you sure?')}');" />
				</fieldset>
			</g:form>
		</div>
	</body>
</html>
