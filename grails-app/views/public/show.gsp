<%@ page import="au.org.ala.collectory.Collection" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

        <title>
            ${instance.name}
        </title>

        <script type="text/javascript" language="javascript" src="https://www.google.com/jsapi"></script>

        <asset:javascript src="public-show" />
        <asset:stylesheet src="public-show" />

        <script type="text/javascript">
            biocacheServicesUrl = "${grailsApplication.config.biocacheServicesUrl}";
            biocacheWebappUrl = "${grailsApplication.config.biocacheUiURL}";
            loadLoggerStats = ${!grailsApplication.config.disableLoggerLinks.toBoolean()};

            $(document).ready(function() {
                $('#overviewTabs a:first').tab('show');
            });
        </script>
    </head>

    <body class="two-column-right">
        <div id="content">
            <div id="header" class="page-header">
                <%-- XXX MAGIC. TODO: place it. --%>
                <cl:pageOptionsPopup instance="${instance}" />

                <%-- Not likely to need it. --%>
                <%-- <cl:h1 value="${instance.name}" /> --%>

                <%-- these variable names really grind my gears --%>
                <g:set var="inst" value="${instance.getInstitution()}" />

                <h1 class="page-header__title">
                    ${instance.name}
                </h1>

                <div class="page-header__subtitle">
                    <g:if test="${inst}">
                        ${inst.name}
                    </g:if>
                </div>

                <%-- TODO --%>
                <span style="display: none;">
                    <cl:valueOrOtherwise value="${instance.acronym}">
                        <span class="acronym">
                            <g:message code="public.show.header.acronym" />: ${fieldValue(bean: instance, field: "acronym")}
                        </span>
                    </cl:valueOrOtherwise>

                    <span class="lsid">
                        <a href="#lsidText" id="lsid" class="local" title="Life Science Identifier (pop-up)">
                            <g:message code="public.lsid" />
                        </a>
                    </span>
                </span>

                <%-- TODO the hell is this? --%>
                <div style="display:none; text-align: left;">
                    <div id="lsidText" style="text-align: left;">
                        <b>
                            <a class="external_icon" href="http://lsids.sourceforge.net/" target="_blank">
                                <g:message code="public.lsidtext.link" />:
                            </a>
                        </b>

                        <p style="margin: 10px 0;">
                            <cl:guid target="_blank" guid="${fieldValue(bean: instance, field: "guid")}" />
                        </p>

                        <p style="font-size: 12px;">
                            <g:message code="public.lsidtext.des" />.&nbsp;
                        </p>
                    </div>
                </div>

                <div class="page-header-links">
                    <a href="${request.contextPath}/" class="page-header-links__link">
                        <span class="fa fa-arrow-left"></span>
                        <g:message code="page.navigation.collections" />
                    </a>

                    <a href="${request.contextPath}/public/show/${instance.institution.uid}" class="page-header-links__link">
                        <span class="fa fa-institution"></span>
                        ${instance.institution.name}
                    </a>
                </div>
            </div>

            <div class="row">
                <div id="overview-sidebar" class="col-md-3">
                    <g:if test="${fieldValue(bean: instance, field: 'imageRef') && fieldValue(bean: instance, field: 'imageRef.file')}">
                        <div class="section">
                            <img
                                src="${resource(absolute:"true", dir:"data/collection/", file:instance.imageRef.file)}"
                                alt="${fieldValue(bean: instance, field: "imageRef.file")}"
                                class="sidebar-image"
                            />
                            <%-- Not sure whether or not we want to display this information
                            <cl:formattedText pClass="caption">
                                ${fieldValue(bean: instance, field: "imageRef.caption")}
                            </cl:formattedText>
                            <cl:valueOrOtherwise value="${instance.imageRef?.attribution}">
                                <p class="caption">
                                    ${fieldValue(bean: instance, field: "imageRef.attribution")}
                                </p>
                            </cl:valueOrOtherwise>
                            <cl:valueOrOtherwise value="${instance.imageRef?.copyright}">
                                <p class="caption">
                                    ${fieldValue(bean: instance, field: "imageRef.copyright")}
                                </p>
                            </cl:valueOrOtherwise>
                            --%>
                        </div>
                    </g:if>

                    <div id="dataAccessWrapper" style="display:none;">
                        <g:render template="dataAccess" model="[instance:instance]" />
                    </div>

                    <div class="section">
                        <h3>
                            <g:message code="public.location" />
                        </h3>

                        <%-- use parent location if the collection is blank --%>
                        <g:set var="address" value="${instance.address}" />

                        <g:if test="${address == null || address.isEmpty()}">
                            <g:if test="${instance.getInstitution()}">
                                <g:set var="address" value="${instance.getInstitution().address}" />
                            </g:if>
                        </g:if>

                        <g:if test="${!address?.isEmpty()}">
                            <p>
                                <cl:valueOrOtherwise value="${address?.street}">
                                    ${address?.street}
                                    <br />
                                </cl:valueOrOtherwise>

                                <cl:valueOrOtherwise value="${address?.city}">
                                    ${address?.city}
                                    <br />
                                </cl:valueOrOtherwise>

                                <cl:valueOrOtherwise value="${address?.state}">
                                    ${address?.state}
                                </cl:valueOrOtherwise>

                                <cl:valueOrOtherwise value="${address?.postcode}">
                                    ${address?.postcode}
                                    <br />
                                </cl:valueOrOtherwise>

                                <cl:valueOrOtherwise value="${address?.country}">
                                    ${address?.country}
                                    <br />
                                </cl:valueOrOtherwise>
                            </p>
                        </g:if>

                        <g:if test="${instance.email}">
                            <cl:emailLink>
                                ${fieldValue(bean: instance, field: "email")}
                            </cl:emailLink>

                            <br />
                        </g:if>

                        <cl:ifNotBlank value='${fieldValue(bean: instance, field: "phone")}' />
                    </div>

                    <!-- contacts -->
                    <g:render template="contacts" bean="${instance.getPublicContactsPrimaryFirst()}" />

                    <!-- web site -->
                    <g:if test="${instance.websiteUrl || instance.institution?.websiteUrl}">
                        <div class="section">
                            <h3>
                                <g:message code="public.website" />
                            </h3>

                            <g:if test="${instance.websiteUrl}">
                                <div class="webSite">
                                    <a class='external' rel='nofollow' target="_blank" href="${instance.websiteUrl}">
                                        <g:message code="public.show.osb.collectionLink" />
                                    </a>
                                </div>
                            </g:if>

                            <g:if test="${instance.institution?.websiteUrl}">
                                <div class="webSite">
                                    <a class='external' rel='nofollow' target="_blank" href="${instance.institution?.websiteUrl}">
                                        <g:message code="public.show.obs.institutionLink" args="[cl.institutionType(inst: instance.institution)]" />
                                    </a>
                                </div>
                            </g:if>
                        </div>
                    </g:if>

                    <!-- attribution -->
                    <g:set var='attribs' value='${instance.getAttributionList()}' />
                    <g:if test="${attribs.size() > 0}">
                        <div class="section" id="infoSourceList">
                            <h4>
                                <g:message code="public.show.osb.label04" />
                            </h4>

                            <ul class="list-unstyled">
                                <g:each var="a" in="${attribs}">
                                    <g:if test="${a.url}">
                                        <li>
                                            <cl:wrappedLink href="${a.url}">
                                                ${a.name}
                                            </cl:wrappedLink>
                                        </li>
                                    </g:if>
                                    <g:else>
                                        <li>
                                            ${a.name}
                                        </li>
                                    </g:else>
                                </g:each>
                            </ul>
                        </div>
                    </g:if>

                    <cl:lastUpdated date="${instance.lastUpdated}" />

                </div>

                <div class="col-md-9">
                    <div class="tabbable">
                        <ul class="nav nav-tabs" id="overviewTabs">
                            <li class="nav-item active">
                                <a id="tab1" href="#overviewTab" data-toggle="tab" class="nav-link">
                                    <g:message code="public.show.overviewtabs.overview" />
                                </a>
                            </li>

                            <li class="nav-item">
                                <a id="tab2" href="#recordsTab" data-toggle="tab" class="nav-link">
                                    <g:message code="public.show.overviewtabs.records" />
                                </a>
                            </li>

                            <li id="imagesTabEl" style="display:none;" class="nav-item">
                                <a id="tab3" href="#imagesTab" data-toggle="tab" class="nav-link">
                                    <g:message code="public.show.overviewtabs.images" />
                                </a>
                            </li>
                        </ul>
                    </div>

                    <div class="tab-content">
                        <div id="overviewTab" role="tabpanel" class="tab-pane active">
                            <div class="row">
                                <div id="overview-content" class="col">
                                    <h3>
                                        <g:message code="public.des" />
                                    </h3>

                                    <cl:formattedText body="${instance.pubDescription}" />

                                    <cl:formattedText>
                                        ${fieldValue(bean: instance, field: "techDescription")}
                                    </cl:formattedText>

                                    <g:if test="${instance.startDate || instance.endDate}">
                                        <p>
                                            <cl:temporalSpanText start='${fieldValue(bean: instance, field: "startDate")}' end='${fieldValue(bean: instance, field: "endDate")}' />
                                        </p>
                                    </g:if>

                                    <%-- TAXONOMIC RANGE --%>
                                    <p>
                                        <h3>
                                            <g:message code="public.show.oc.taxonomicRange" />
                                        </h3>

                                        <g:if test="${fieldValue(bean: instance, field: 'focus')}">
                                            <cl:formattedText>
                                                ${fieldValue(bean: instance, field: "focus")}
                                            </cl:formattedText>
                                        </g:if>

                                        <g:if test="${fieldValue(bean: instance, field: 'kingdomCoverage')}">
                                            <p>
                                                <g:message code="public.show.oc.des01" />: <cl:concatenateStrings values='${fieldValue(bean: instance, field: "kingdomCoverage")}' />.
                                            </p>
                                        </g:if>

                                        <g:if test="${fieldValue(bean: instance, field: 'scientificNames')}">
                                            <p>
                                                <cl:collectionName name="${instance.name}" prefix="The "/> <g:message code="public.show.oc.des02" />:
                                                <br />
                                                <cl:JSONListAsStrings json='${instance.scientificNames}' />.
                                            </p>
                                        </g:if>

                                        <g:if test="${instance?.geographicDescription || instance.states}">
                                            <h3>
                                                <g:message code="public.show.oc.label03" />
                                            </h3>

                                            <g:if test="${fieldValue(bean: instance, field: 'geographicDescription')}">
                                                <p>
                                                    ${fieldValue(bean: instance, field: "geographicDescription")}
                                                </p>
                                            </g:if>

                                            <g:if test="${fieldValue(bean: instance, field: 'states')}">
                                                <p>
                                                    <cl:stateCoverage states='${fieldValue(bean: instance, field: "states")}' />
                                                </p>
                                            </g:if>

                                            <g:if test="${instance.westCoordinate != -1}">
                                                <p>
                                                    <g:message code="public.show.oc.des03" />: <cl:showDecimal value='${instance.westCoordinate}' degree='true' />
                                                </p>
                                            </g:if>

                                            <g:if test="${instance.eastCoordinate != -1}">
                                                <p>
                                                    <g:message code="public.show.oc.des04" />: <cl:showDecimal value='${instance.eastCoordinate}' degree='true' />
                                                </p>
                                            </g:if>

                                            <g:if test="${instance.northCoordinate != -1}">
                                                <p>
                                                    <g:message code="public.show.oc.des05" />: <cl:showDecimal value='${instance.northCoordinate}' degree='true' />
                                                </p>
                                            </g:if>

                                            <g:if test="${instance.southCoordinate != -1}">
                                                <p>
                                                    <g:message code="public.show.oc.des06" />: <cl:showDecimal value='${instance.southCoordinate}' degree='true' />
                                                </p>
                                            </g:if>
                                        </g:if>
                                    </p>

                                    <%-- NUMBER OF SPECIMENS IN THE COLLECTION --%>
                                    <g:set var="nouns" value="${cl.nounForTypes(types:instance.listCollectionTypes())}" />

                                    <h3>
                                        <g:message code="public.show.oc.numberOfRecords" args="${ [nouns] }" />
                                    </h3>

                                    <g:if test="${fieldValue(bean: instance, field: 'numRecords') != '-1'}">
                                        <p>
                                            <g:message code="public.show.oc.estimatedRecords" args="[nouns, instance.name, fieldValue(bean: instance, field: 'numRecords')]" />
                                        </p>
                                    </g:if>
                                    <g:else>
                                        <p>
                                            <g:message code="public.show.estimation.noEstimation" args="[nouns]" />
                                        </p>
                                    </g:else>

                                    <g:if test="${fieldValue(bean: instance, field: 'numRecordsDigitised') != '-1'}">
                                        <p>
                                            <g:message
                                                code="public.show.oc.percentageDatabased"
                                                args="[
                                                    fieldValue(bean: instance, field: 'numRecordsDigitised'),
                                                    cl.percentIfKnown(dividend: instance.numRecordsDigitised, divisor: instance.numRecords)
                                                ]"
                                            />
                                        </p>
                                    </g:if>

                                    <%-- A bit redundant
                                    <p>
                                        <g:message code="public.show.oc.des13" />.
                                    </p>
                                    --%>

                                    <g:if test="${instance.listSubCollections()?.size() > 0}">
                                        <h3>
                                            <g:message code="public.show.oc.label06" />
                                        </h3>

                                        <p>
                                            <g:message code="public.show.oc.des14" args="[instance.name]" />:
                                        </p>

                                        <cl:subCollectionList list="${instance.subCollections}" />
                                    </g:if>

                                    <g:if test="${biocacheRecordsAvailable && !grailsApplication.config.disableLoggerLinks?.toBoolean()}">
                                        <h3>
                                            <g:message code="public.show.oc.label07" />
                                        </h3>

                                        <div id="usage"></div>
                                    </g:if>
                                </div>
                            </div>
                        </div>

                        <div id="recordsTab" class="tab-pane">
                            <h3>
                                <g:message code="public.show.rt.title" />
                            </h3>

                            <div class="row">
                                <div class="col">
                                    <g:if test="${instance.numRecords != -1}">
                                        <p>
                                            <%-- XXX TODO NOTE FIXME REMOVE IT
                                            <cl:collectionName prefix="The " name="${instance.name}" />
                                            has an estimated
                                            ${fieldValue(bean: instance, field: "numRecords")} ${nouns}.
                                            --%>

                                            <g:message
                                                code="public.show.oc.estimatedRecords2"
                                                args="[
                                                    instance.name,
                                                    fieldValue(bean: instance, field: "numRecords"),
                                                    nouns
                                                ]"
                                            />
                                        </p>

                                        <div class="vertical-block">
                                            <div class="erk-collection-progress">
                                                <div class="progress">
                                                    <div id="progress-bar" class="progress-bar erk-progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                                                    </div>
                                                </div>

                                                <p>
                                                    <span id="numBiocacheRecords">
                                                        <g:message code="public.show.portalRecordsBit.searching" />
                                                    </span>

                                                    <g:message code="public.show.portalRecordsBit.available" />.

                                                    <span id="speedoCaption">
                                                        <g:message code="public.show.speedocaption" />.
                                                    </span>
                                                </p>

                                                <g:if test="${biocacheRecordsAvailable}">
                                                    <cl:warnIfInexactMapping collection="${instance}" />

                                                    <div>
                                                        <cl:recordsLink entity="${instance}">
                                                            <span class="fa fa-list"></span>
                                                            <g:message code="public.show.rt.recordsLink" args="[instance.name]" />
                                                        </cl:recordsLink>
                                                    </div>
                                                </g:if>
                                            </div>

                                            <g:if test="${instance.numRecordsDigitised != -1}">
                                                <p>
                                                    <g:message
                                                        code="public.show.rt.description"
                                                        args="[
                                                            cl.percentIfKnown(dividend: instance.numRecordsDigitised, divisor: instance.numRecords),
                                                            fieldValue(bean: instance, field: 'numRecordsDigitised')
                                                        ]"
                                                    />
                                                </p>
                                            </g:if>
                                        </div>
                                    </g:if>

                                    <g:if test="${biocacheRecordsAvailable}">
                                        <%-- XXX UNEXPECTED MAP OF AUSTRALIA
                                            <g:if test="${!grailsApplication.config.disableOverviewMap?.asBoolean()}">
                                                <div id="collectionRecordsMapContainer">
                                                    <h3>
                                                        <g:message code="public.show.crmc.title" />
                                                        ${grailsApplication.config.disableOverviewMap?.asBoolean()}
                                                    </h3>

                                                    <cl:recordsMapDirect uid="${instance.uid}" />
                                                </div>
                                            </g:if>
                                        --%>

                                        <div id="charts" class="vertical-block"></div>
                                    </g:if>
                                    <g:else>
                                        <p>
                                            <g:message code="public.show.rt.noRecords" />.
                                        </p>
                                    </g:else>
                                </div>
                            </div>
                        </div>

                        <div id="imagesTab" class="tab-pane">
                            <h3>
                                <g:message code="public.show.it.title" />
                            </h3>

                            <div id="imagesSpiel"></div>
                            <div id="imagesList"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- XXX XXX XXX --%>
        <script type="text/javascript">
            var taxonomyChartOptions = {
                /* base url of the collectory */
                collectionsUrl: "${grailsApplication.config.grails.serverURL}",
                /* base url of the biocache */
                biocacheServicesUrl: biocacheServicesUrl,
                /* base url of the biocache webapp*/
                biocacheWebappUrl: biocacheWebappUrl,
                /* support drill down into chart - default is true */
                drillDown: true,
                is3D: false,
                /* a uid or list of uids to chart - either this or query must be present */
                instanceUid: "${instance.uid}",
                /* threshold value to use for automagic rank selection - defaults to 55 */
                threshold: 55,
                rank: "${instance.startingRankHint()}"
            };

            /************************************************************\
             *
            \************************************************************/
            var queryString = '';
            var decadeUrl = '';
            var initial = -120;
            var imageWidth = 240;
            var eachPercent = (imageWidth/2)/100;

            $('img#mapLegend').each(function(i, n) {
                // if legend doesn't load, then it must be a point map
                $(this).error(function() {
                    $(this).attr('src',"${resource(dir:'images/map',file:'single-occurrences.png')}");
                });
                // IE hack as IE doesn't trigger the error handler
                /*if($.browser.msie && !n.complete) {
                    $(this).attr('src',"${resource(dir:'images/map',file:'single-occurrences.png')}");
                }*/
            });

            /************************************************************\
             * initiate ajax calls
            \************************************************************/
            function onLoadCallback() {
                if(loadLoggerStats) {
                    loadDownloadStats("${grailsApplication.config.grails.serverURL}", "${instance.uid}","${instance.name}", "1002");
                }

                // records
                $.ajax({
                    url: urlConcat(biocacheServicesUrl, "/occurrences/search.json?pageSize=0&q=") + buildQueryString("${instance.uid}"),
                    dataType: 'jsonp',
                    timeout: 20000,
                    complete: function(jqXHR, textStatus) {
                        if(textStatus == 'timeout') {
                            noBiocacheData();
                            alert('Sorry - the request was taking too long so it has been cancelled.');
                        }

                        if(textStatus == 'error') {
                            noBiocacheData();
                            alert('Sorry - the records breakdowns are not available due to an error.');
                        }
                    },
                    success: function(data) {
                        // check for errors
                        if(data.length == 0 || data.totalRecords === undefined || data.totalRecords == 0) {
                            noBiocacheData();
                        } else {
                            setPercentAgeNumbers(data.totalRecords, ${instance.numRecords});

                            if(data.totalRecords > 0) {
                                $('#dataAccessWrapper').css({display:'block'});
                                $('#totalRecordCountLink').html(
                                    '<span class="fa fa-list"></span> ' +
                                    data.totalRecords.toLocaleString(GLOBAL_LOCALE_CONF.locale) +
                                    ' ${g.message(code: "public.show.rt.des03")}'
                                );
                            }
                        }
                    }
                });

                // images
                var wsBase = "/occurrences/search.json";
                var uiBase = "/occurrences/search";
                var imagesQueryUrl = "?facets=type_status&fq=multimedia%3AImage&pageSize=100&q=" + buildQueryString("${instance.uid}");

                $.ajax({
                    url: urlConcat(biocacheServicesUrl, wsBase + imagesQueryUrl),
                    dataType: 'jsonp',
                    timeout: 20000,
                    complete: function(jqXHR, textStatus) {
                        if(textStatus == 'timeout') {
                            noBiocacheData();
                        }
                        if(textStatus == 'error') {
                            noBiocacheData();
                        }
                    },
                    success: function(data) {
                        // check for errors
                        if(data.length == 0 || data.totalRecords == undefined || data.totalRecords == 0) {
                            //noBiocacheData();
                        } else {
                            if(data.totalRecords > 0) {
                                var description = '';

                                $('#imagesTabEl').css({ display: 'block' });
                                var typeStatusField = data.facetResults[0];

                                if(data.facetResults.length > 0 && typeStatusField.fieldResult && typeStatusField.fieldResult.length > 1) {

                                    description = jQuery.i18n.prop('public.show.imagesAvailable.ofThese') + ' ';

                                    var queryLinks = typeStatusField.fieldResult.map(function(facet) {
                                        if(facet.label) {
                                            var queryUrl = biocacheWebappUrl + uiBase + imagesQueryUrl + '&fq=' + data.facetResults[0].fieldName + ':' + facet.label;
                                            var queryLink =
                                                '<a href="' + queryUrl + '">' +
                                                    '<span class="fa fa-list"></span> ' + (facet.count + ' ' + facet.label) +
                                                '</a>';
                                            return queryLink;
                                        }
                                    });
                                    queryLinks = queryLinks.filter(function(x) { return typeof x !== 'undefined'; });
                                    description += queryLinks.join(', ');
                                }

                                // Was ist das Spiel?
                                $('#imagesSpiel').html(
                                    '<p>' +
                                        '<a href="' + biocacheWebappUrl + uiBase + imagesQueryUrl +'">' +
                                            '<span class="fa fa-list"></span>' +
                                            '&nbsp;' +
                                            data.totalRecords + ' ' +
                                            $.i18n.prop('public.show.imagesAvailable.images') +
                                        '</a>' + ' ' +
                                        $.i18n.prop('public.show.imagesAvailable.available', "${instance.name}") +
                                        '<br /> ' +
                                        description +
                                    '</p>'
                                );

                                $.each(data.occurrences, function(idx, item) {
                                    var imageText = item.scientificName;

                                    if(item.typeStatus) {
                                        imageText = item.typeStatus + " - " + imageText;
                                    }

                                    $('#imagesList').append(
                                        '<div class="gallery-thumb">' +
                                            '<a href="' + biocacheWebappUrl + '/occurrences/' + item.uuid + '">' +
                                                '<img class="gallery-thumb__img" src="' + item.smallImageUrl+'" />' +
                                                '<div class="gallery-thumb__footer">' +
                                                    imageText +
                                                '</div>' +
                                            '</a>' +
                                        '</div>'
                                    );
                                })
                            }
                        }
                    }
                });

                // taxon chart
                loadTaxonomyChart(taxonomyChartOptions);
            }

            /************************************************************\
             * Handle biocache records response
            \************************************************************/
            function biocacheRecordsHandler(response) {
                if(response.error == undefined) {
                    setNumbers(response.totalRecords, ${instance.numRecords});
                    if(response.totalRecords < 1) {
                        noBiocacheData();
                    }
                    drawDecadeChart(response.decades, "${instance.uid}", {
                        width: 470,
                        chartArea:  {left: 50, width:"88%", height: "75%"}
                    });
                } else {
                    noBiocacheData();
                }
            }

            /************************************************************\
             * Set biocache record numbers to none and hide link and chart
            \************************************************************/
            function noBiocacheData() {
                setNumbers(0);
                $('a.recordsLink').css('visibility','hidden');
                $('div#decadeChart').css("display","none");
            }

            /************************************************************\
             * Set total and percent biocache record numbers
            \************************************************************/
            function setPercentAgeNumbers(totalBiocacheRecords, totalRecords) {
                var recordsClause = "";

                switch (totalBiocacheRecords) {
                    case 0: recordsClause = jQuery.i18n.prop('public.show.portalRecordsBit.noRecords'); break;
                    case 1: recordsClause = jQuery.i18n.prop('public.show.portalRecordsBit.oneRecord'); break;
                    default: recordsClause = jQuery.i18n.prop('public.show.portalRecordsBit.records', totalBiocacheRecords.toLocaleString(GLOBAL_LOCALE_CONF.locale));
                }

                $('#numBiocacheRecords').html(recordsClause);

                if(totalRecords > 0) {
                    var percent = totalBiocacheRecords/totalRecords * 100;

                    if(percent > 100 && ${instance.isInexactlyMapped()}) {
                        // don't show greater than 100 if the mapping is not exact as the estimated num records may be correct
                        percent = 100;
                    }

                    setProgress(percent);
                } else {
                    // to update the speedo caption
                    setProgress(0);
                }
            }

            /************************************************************\
             * DEPRECATED
            \************************************************************/
            function decadeBreakdownRequestHandler(response) {
                var data = new google.visualization.DataTable(response);

                if(data.getNumberOfRows() > 0) {
                    draw(data);
                }
            }

            /************************************************************\
             * Draw % digitised bar (progress bar)
            \************************************************************/
            function setProgress(percentage) {
                var captionText = "";

                if(${instance.numRecords < 1}) {
                    captionText = jQuery.i18n.prop(
                        'public.show.estimation.noEstimation',
                        '${nouns}'
                    );
                } else if(percentage == 0) {
                    captionText = jQuery.i18n.prop('public.show.estimation.noRecords');
                } else {
                    var displayPercent = percentage.toFixed(1);

                    if(percentage < 0.1) {
                        displayPercent = percentage.toFixed(2)
                    } else if(percentage > 100) {
                        displayPercent = '>100'
                    } else if(percentage > 20) {
                        displayPercent = percentage.toFixed(0)
                    }

                    captionText = jQuery.i18n.prop(
                        'public.show.estimation.percentRecords',
                        displayPercent,
                        '${nouns}'
                    );
                }

                $('#speedoCaption').html(captionText);
                $('#progress-bar').css('width', percentage + '%');
            }

            /************************************************************\
             * Load charts
            \************************************************************/
            // define biocache server
            google.load("visualization", "1", {packages:["corechart"]});
            google.setOnLoadCallback(onLoadCallback);

            // perform JavaScript after the document is scriptable.
            $(function() {
                // setup ul.tabs to work as tabs for each div directly under div.panes
                $("ul#nav-tabs").tabs("div.panes > div", {
                    history: true,
                    effect: 'fade',
                    fadeOutSpeed: 200
                });
            });
        </script>
    </body>
</html>
