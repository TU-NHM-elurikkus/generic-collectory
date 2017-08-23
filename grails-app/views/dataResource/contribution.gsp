<%@ page import="au.org.ala.collectory.DataHub" %>
<%@ page import="au.org.ala.collectory.DataResource" %>
<%@ page import="au.org.ala.collectory.ProviderGroup" %>
<%@ page import="au.org.ala.collectory.resources.DarwinCoreFields" %>
<%@ page import="grails.converters.JSON" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <title>
            <g:message code="dataResource.base.label" default="Edit data resource metadata" />
        </title>

        <asset:javascript src="jquery-ui.js" />
        <asset:stylesheet stc="jquery-ui.css" />
    </head>

    <body>
        <div class="card">
            <div class="card-header">
                <h1>
                    <g:message code="collection.title.editing" />: ${command.name}
                </h1>
            </div>

            <div id="baseForm" class="card-body">
                <g:if test="${message}">
                    <div class="message">
                        ${message}
                    </div>
                </g:if>

                <g:hasErrors bean="${command}">
                    <div class="errors">
                        <g:renderErrors bean="${command}" as="list" />
                    </div>
                </g:hasErrors>

                <g:form method="post" name="contributionForm" action="contribution">
                    <g:hiddenField name="id" value="${command?.id}" />
                    <g:hiddenField name="uid" value="${command?.uid}" />
                    <g:hiddenField name="version" value="${command.version}" />

                    <!-- status -->
                    <div class="form-group">
                        <label for="status">
                            <g:message code="dataResource.status.label" default="Status" />
                        </label>
                        <g:select name="status"
                            from="${DataResource.statusList}"
                            value="${command.status}"
                            class="form-control"
                        />

                        <cl:helpTD />
                    </div>

                    <!-- provenance -->
                    <div class="form-group">
                        <label for="provenance">
                            <g:message code="dataResource.provenance.label" default="Provenance" />
                        </label>
                        <g:select name="provenance"
                            from="${DataResource.provenanceTypesList}"
                            value="${command.provenance}"
                            noSelection="${['':'none']}"
                            class="form-control"
                        />

                        <cl:helpText code="dataResource.provenance" />

                        <cl:helpTD />
                    </div>

                    <!-- last checked -->
                    <div class="form-group">
                        <label for="lastChecked">
                            <g:message code="dataResource.lastChecked.label" default="Last checked" />
                        </label>

                        <g:textField name="lastChecked" value="${command.lastChecked}" class="form-control" />

                        <cl:helpText code="dataResource.lastChecked" />
                        <cl:helpTD />
                    </div>

                    <!-- data currency -->
                    <div class="form-group">
                        <label for="dataCurrency">
                            <g:message code="dataResource.dataCurrency.label" default="Data currency" />
                        </label>

                        <g:textField name="dataCurrency" value="${command.dataCurrency}" class="form-control" />

                        <cl:helpText code="dataResource.dataCurrency" />
                        <cl:helpTD />
                    </div>

                    <!-- harvest frequency -->
                    <div class="form-group">
                        <label for="harvestFrequency">
                            <g:message code="dataResource.harvestFrequency.label" default="Harvest frequency" />
                        </label>

                        <g:textField name="harvestFrequency" value="${command.harvestFrequency}" class="form-control" />

                        <cl:helpText code="dataResource.harvestFrequency" />
                        <cl:helpTD />
                    </div>

                    <!-- mob notes -->
                    <div class="form-group">
                        <label for="mobilisationNotes">
                            <g:message code="dataResource.mobilisationNotes.label" default="Mobilisation notes" />
                        </label>

                        <g:textArea name="mobilisationNotes" class="form-control" rows="${cl.textAreaHeight(text:command.mobilisationNotes)}" value="${command?.mobilisationNotes}" />

                        <p>
                            <g:message code="dataresource.contribution.des01" />.
                        </p>
                        <cl:helpText code="dataResource.mobilisationNotes" />
                        <cl:helpTD />
                    </div>

                    <!-- harvest notes -->
                    <div class="form-group">
                        <label for="harvestingNotes">
                            <g:message code="dataResource.harvestingNotes.label" default="Harvesting notes" />
                        </label>

                        <g:textArea name="harvestingNotes" class="form-control" rows="${cl.textAreaHeight(text:command.harvestingNotes)}" value="${command?.harvestingNotes}" />

                        <cl:helpText code="dataResource.harvestingNotes" />
                        <cl:helpTD />
                    </div>

                    <!-- public archive -->
                    <div class="form-group">
                        <label for="publicArchiveAvailable">
                            <g:message code="dataResource.publicArchiveAvailable.label" default="Public archive available" />
                        </label>

                        <g:checkBox name="publicArchiveAvailable" value="${command?.publicArchiveAvailable}" />

                        <cl:helpText code="dataResource.publicArchiveAvailable" />
                        <cl:helpTD />
                    </div>

                    <!-- harvest parameters -->
                    <h3>
                        <g:message code="dataresource.contribution.table0101" />
                    </h3>
                    <cl:connectionParameters bean="command" connectionParameters="${command.connectionParameters}" />

                    <g:if test="${command.resourceType == 'records'}">
                        <!-- darwin core defaults -->
                        <h3>
                            <g:message code="dataresource.contribution.table0201" />
                        </h3>
                        <g:message code="dataresource.contribution.table0301" />.

                        <g:set var="dwc" value="${command.defaultDarwinCoreValues ? JSON.parse(command.defaultDarwinCoreValues) : [:]}" />

                        <!-- add fields for each of the important terms -->
                        <g:each in="${DarwinCoreFields.getImportant()}" var="dwcf">
                            <div class="form-group">
                                <label for="${dwcf.name}">
                                    <g:message code="dataResource.DwC.${dwcf.name}.label" default="${dwcf.name}" />
                                </label>

                                <g:if test="${dwcf.values}">
                                    <!-- pick list -->
                                    <g:select name="${dwcf.name}" class="form-control" from="${dwcf.values}" value="${dwc[dwcf.name]}" />
                                </g:if>
                                <g:else>
                                    <!-- text field -->
                                    <g:textField name="${dwcf.name}" class="form-control" value="${dwc[dwcf.name]}" />
                                </g:else>
                                <cl:helpText code="dataResource.${dwcf.name}" />
                            </div>
                        </g:each>

                        <!-- add fields for any other terms that have values -->
                        <g:each var="dwcf" in="${dwc.entrySet()}">
                            <g:if test="${dwcf.key in DarwinCoreFields.getLessImportant().collect({it.name})}">
                                <div class="form-group">
                                    <label for="${dwcf.key}">
                                        <g:message code="dataResource.DwC.${dwcf.key}.label" default="${dwcf.key}" />
                                    </label>

                                    <g:textField name="${dwcf.key}" value="${dwcf.value}" class="form-control" />
                                </div>
                            </g:if>
                        </g:each>

                        <!-- add a blank field so other DwC terms can be added -->
                        <div class="form-group">
                            <g:select name="otherKey" from="${DarwinCoreFields.getLessImportant().collect({it.name})}" class="form-control" />

                            <button id="more-terms" type="button" class="erk-button erk-button--light">
                                <g:message code="dataresource.contribution.table.button" />
                            </button>
                        </div>
                    </g:if>

                    <div class="buttons">
                        <input type="submit" name="_action_updateContribution" value="${message(code:"collection.button.update")}" class="erk-button erk-button--light" />
                        <input type="submit" name="_action_cancel" value="${message(code:"collection.button.cancel")}" class="erk-button erk-button--light" />
                    </div>
                </g:form>
            </div>

            <script>
                function instrument() {
                    var availableTags = [
                        "institutionCode",
                        "collectionCode",
                        "catalogNumber",
                        "occurrenceID",
                        "recordNumber"
                    ];
                    function split( val ) {
                        return val.split( /,\s*/ );
                    }
                    function extractLast( term ) {
                        return split( term ).pop();
                    }
                    $( "input#termsForUniqueKey:enabled" )
                        // don't navigate away from the field on tab when selecting an item
                            .bind( "keydown", function( event ) {
                                if ( event.keyCode === $.ui.keyCode.TAB &&
                                        $( this ).data( "autocomplete" ).menu.active ) {
                                    event.preventDefault();
                                }
                            })
                            .autocomplete({
                                minLength: 0,
                                source: function( request, response ) {
                                    // delegate back to autocomplete, but extract the last term
                                    response( $.ui.autocomplete.filter(
                                            availableTags, extractLast( request.term ) ) );
                                },
                                focus: function() {
                                    // prevent value inserted on focus
                                    return false;
                                },
                                select: function( event, ui ) {
                                    var terms = split( this.value );
                                    // remove the current input
                                    terms.pop();
                                    // add the selected item
                                    terms.push( ui.item.value );
                                    // add placeholder to get the comma-and-space at the end
                                    terms.push( "" );
                                    this.value = terms.join( ", " );
                                    return false;
                                }
                            });
                }
                function changeProtocol() {
                    var protocol = $('#protocolSelector').attr('value');
                    // remove autocomplete binding
                    $('input#termsForUniqueKey:enabled').autocomplete('destroy');
                    $('input#termsForUniqueKey:enabled').unbind('keydown');
                    // clear all
                    $('tr.labile').css('display','none');
                    $('tr.labile input,textArea').attr('disabled','true');
                    // show the selected
                    $('tr#'+protocol).removeAttr('style');
                    $('tr#'+protocol+' input,textArea').removeAttr('disabled');
                    // re-enable the autocomplete functionality
                    instrument();
                }
                instrument();
                //$('[name="start_date"]').datepicker({dateFormat: 'yy-mm-dd'});
                /* this expands lists of urls into an array of text inputs */
                // create a delete element that removes the element before it and itself
                %{--var deleteImageUrl = "${resource(dir:'/images/ala',file:'delete.png')}";--}%
                var $deleteLink = $('<span class="delete btn btn-mini btn-danger"><i class="icon icon-remove icon-white"></i> </span>')
                        .click(function() {
                            $(this).prev().remove();
                            $(this).remove();
                        });
                // handle all urls (including hidden ones)
                var urlInputs = $('input[name="url"]');
                $('input[name="url"]').addClass('input-xxlarge');
                $.each(urlInputs, function(i, obj) {
                    var urls = $(obj).val().split(',');
                    if (urls.length > 1) {
                        // more than one url so create an input for each extra one
                        $.each(urls,function(i,url) {
                            if (i == 0) {
                                // existing input gets the first url
                                $(obj).val(url);
                            }
                            else {
                                // clone the existing field and inject the next value - adding a delete link
                                $(obj).clone()
                                        .val(url.trim())
                                        .css('width','93%')
                                        .addClass('input-xxlarge')
                                        .insertAfter($(obj).parent().children('input,span').last())
                                        .after($deleteLink.clone(true));
                            }
                        });
                    }
                });
                /* this injects 'add another' functionality to urls */
                $.each(urlInputs, function(i, obj) {
                    $('<button class="erk-button erk-button--light pull-right">Add another</button>')
                            .insertAfter($(obj).parent().children('input,span').last())
                            .click(function() {
                                // clone the original input
                                var $clone = $(obj).clone();
                                $clone.val('');
                                $clone.insertBefore(this);
                                $clone.after($deleteLink.clone(true)); // add delete link
                            });
                });
                /* this binds the code to add a new term to the list */
                $('#more-terms').click(function() {
                    var term = $('#otherKey').val();
                    // check that term doesn't already exist
                    if ($('#'+term).length > 0) {
                        alert(term + " is already present");
                    }
                    else {
                        var newField = "<tr class='prop'><td valign='top' class='name'><label for='" + term +
                                "'>" + term + "</label></td>" +
                                "<td valign='top' class='value'><input type='text' id='" + term + "' name='" + term + "'/></td></tr>";
                        $('#add-another').parent().append(newField);
                    }
                });
            </script>
        </div>
    </body>
</html>
