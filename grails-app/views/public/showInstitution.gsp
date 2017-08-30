<%@ page contentType="text/html;charset=UTF-8"%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <title>
            <cl:pageTitle>
                ${fieldValue(bean: instance, field: "name")}
            </cl:pageTitle>
        </title>
        <script type="text/javascript" language="javascript" src="https://www.google.com/jsapi"></script>

        <asset:javascript src="public-show.js" />

        <script type="text/javascript">
            biocacheServicesUrl = "${grailsApplication.config.biocacheServicesUrl}";
            biocacheWebappUrl = "${grailsApplication.config.biocacheUiURL}";
            loadLoggerStats = ${!grailsApplication.config.disableLoggerLinks.toBoolean()};
        </script>
    </head>

    <body>
        <div id="content">
            <div id="header" class="page-header">
                <cl:pageOptionsPopup instance="${instance}" />

                <h1 class="page-header__title">
                    ${instance.name}
                </h1>

                <div class="page-header__subtitle">
                    <g:set var="parents" value="${instance.listParents()}" />
                    <g:each var="p" in="${parents}">
                        <h2>
                            <g:link action="show" id="${p.uid}">
                                ${p.name}
                            </g:link>
                        </h2>
                    </g:each>

                    <cl:valueOrOtherwise value="${instance.acronym}">
                        <span class="acronym">
                            <g:message code="public.show.header.acronym" />:
                            ${fieldValue(bean: instance, field: "acronym")}
                        </span>
                    </cl:valueOrOtherwise>

                    <g:if test="${instance.guid?.startsWith('urn:lsid:')}">
                        <span class="lsid">
                            <a href="#lsidText" id="lsid" class="local" title="Life Science Identifier (pop-up)">
                                <g:message code="public.lsid" />
                            </a>
                        </span>

                        <%-- TODO --%>
                        <div style="display:none; text-align: left;">
                            <div id="lsidText" style="text-align: left;">
                                <b>
                                    <a class="external_icon" href="http://lsids.sourceforge.net/" target="_blank">
                                        <g:message code="public.lsidtext.link" />:
                                    </a>
                                </b>
                                <p>
                                    <cl:guid target="_blank" guid='${fieldValue(bean: instance, field: "guid")}' />
                                </p>
                                <p>
                                    <g:message code="public.lsidtext.des" />.
                                </p>
                            </div>
                        </div>
                    </g:if>

                    <g:if test="${fieldValue(bean: instance, field: 'logoRef') && fieldValue(bean: instance, field: 'logoRef.file')}">
                        <img
                            class="institutionImage"
                            src='${resource(absolute: "true", dir: "data/institution/", file: fieldValue(bean: instance, field: 'logoRef.file'))}'
                        />
                    </g:if>
                </div>

                <div class="page-header-links">
                    <a href="${request.contextPath}/" class="page-header-links__link">
                        Collections
                    </a>

                    <a href="${grailsApplication.config.biocacheUiURL}/occurrences/search?q=institution_uid:${instance.uid}" class="page-header-links__link">
                        ${instance.name} records
                    </a>

                    <%-- TODO SHOULD BE A BUTTON
                    <cl:pageOptionsLink>
                        ${fieldValue(bean:instance,field:'name')}
                    </cl:pageOptionsLink>
                    --%>
                </div>
            </div> <%-- /header --%>

            <div class="row">
                <div class="col-md-9">
                    <g:if test="${instance.pubDescription}">
                        <h2>
                            <g:message code="public.des" />
                        </h2>
                        <cl:formattedText>
                            ${fieldValue(bean: instance, field: "pubDescription")}
                        </cl:formattedText>
                        <cl:formattedText>
                            ${fieldValue(bean: instance, field: "techDescription")}
                        </cl:formattedText>
                    </g:if>

                    <g:if test="${instance.focus}">
                        <h2>
                            <g:message code="public.si.content.label02" />
                        </h2>
                        <cl:formattedText>
                            ${fieldValue(bean: instance, field: "focus")}
                        </cl:formattedText>
                    </g:if>

                    <div class="card">
                        <div class="card-header">
                            <h4>
                                <g:message code="public.si.content.label03" />
                            </h4>
                        </div>

                        <div class="card-body">
                            <ol class="erk-olist">
                                <g:each var="c" in="${instance.listCollections().sort { it.name }}">
                                    <li class="erk-olist__item">
                                        <g:link controller="public" action="show" id="${c.uid}">
                                            ${c?.name}
                                        </g:link>

                                        ${c?.makeAbstract(400)}
                                    </li>
                                </g:each>
                            </ol>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header">
                            <h4>
                                <g:message code="public.si.content.label04" />
                            </h4>
                        </div>

                        <div class="card-body">
                            <div>
                                <p>
                                    <span id="numBiocacheRecords">
                                        <g:message code="public.numbrs.des01" />
                                    </span>
                                    <g:message code="public.numbrs.des02" />.
                                </p>

                                <cl:recordsLink entity="${instance}">
                                    <g:message code="public.numbrs.link" /> ${instance.name}.
                                </cl:recordsLink>
                            </div>

                            <div id="recordsBreakdown" class="section vertical-charts">
                                <div id="charts"></div>
                            </div>

                            <cl:lastUpdated date="${instance.lastUpdated}" />
                        </div>
                    </div>

                    <div id="usage-stats" class="card">
                        <a data-toggle="collapse" href="#usage">
                            <div class="card-header">
                                <h4>
                                    <g:message code="public.usagestats.label" />
                                </h4>
                            </div>
                        </a>

                        <div id="usage" class="collapse card-body" data-parent="#usage-stats">
                            <p>
                                <g:message code="public.usage.des" />...
                            </p>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <g:if test="${fieldValue(bean: instance, field: 'imageRef') && fieldValue(bean: instance, field: 'imageRef.file')}">
                        <div class="section">
                            <img
                                alt="${fieldValue(bean: instance, field: 'imageRef.file')}"
                                src="${resource(absolute: 'true', dir: 'data/institution/', file: instance.imageRef.file)}"
                            />

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
                        </div>
                    </g:if>

                    <div id="pataAccessWrapper">
                        <g:render template="dataAccess" model="[instance:instance]" />
                    </div>

                    <g:set var="haveAddress" value="${instance.address != null && !instance.address.isEmpty()}" />
                    <g:set var="haveEmail" value="${instance.email}" />
                    <g:set var="havePhone" value='${fieldValue(bean: instance, field: "phone")}' />

                    <g:if test="${haveAddress || haveEmail || havePhone}">
                        <div class="section">
                            <h3>
                                <g:message code="public.location" />
                            </h3>
                            <g:if test="${haveAddress}">
                                <p>
                                    <cl:valueOrOtherwise value="${instance.address?.street}">
                                        ${instance.address?.street}
                                        <br />
                                    </cl:valueOrOtherwise>
                                    <cl:valueOrOtherwise value="${instance.address?.city}">
                                        ${instance.address?.city}
                                        <br />
                                    </cl:valueOrOtherwise>
                                    <cl:valueOrOtherwise value="${instance.address?.state}">
                                        ${instance.address?.state}
                                    </cl:valueOrOtherwise>
                                    <cl:valueOrOtherwise value="${instance.address?.postcode}">
                                        ${instance.address?.postcode}
                                        <br />
                                    </cl:valueOrOtherwise>
                                    <cl:valueOrOtherwise value="${instance.address?.country}">
                                        ${instance.address?.country}
                                        <br />
                                    </cl:valueOrOtherwise>
                                </p>
                            </g:if>
                            <g:if test="${haveEmail}">
                                <cl:emailLink>
                                    ${fieldValue(bean: instance, field: "email")}
                                </cl:emailLink>
                                <br />
                            </g:if>
                            <cl:ifNotBlank value='${fieldValue(bean: instance, field: "phone")}' />
                        </div>
                    </g:if>

                    <!-- contacts -->
                    <g:render template="contacts" bean="${instance.getPublicContactsPrimaryFirst()}" />

                    <!-- web site -->
                    <g:if test="${instance.websiteUrl}">
                        <div class="section">
                            <h3>
                                <g:message code="public.website" />
                            </h3>

                            <div class="webSite">
                                <a class='external' target="_blank" href="${instance.websiteUrl}">
                                    <g:message code="public.si.website.link01" />
                                    <cl:institutionType inst="${instance}" />
                                    <g:message code="public.si.website.link02" />
                                </a>
                            </div>
                        </div>
                    </g:if>

                    <!-- network membership -->
                    <g:if test="${instance.networkMembership}">
                        <div class="section">
                            <h3>
                                <g:message code="public.network.membership.label" />
                            </h3>
                            <g:if test="${instance.isMemberOf('CHAEC')}">
                                <p>
                                    <g:message code="public.network.membership.des01" />
                                </p>
                                <img src="${resource(absolute: "true", dir: "data/network/", file: "chaec-logo.png")}" />
                            </g:if>
                            <g:if test="${instance.isMemberOf('CHAH')}">
                                <p>
                                    <g:message code="public.network.membership.des02" />
                                </p>
                                <a target="_blank" href="http://www.chah.gov.au">
                                    <img style="padding-left:25px;" src="${resource(absolute: 'true', dir: 'data/network/', file: 'CHAH_logo_col_70px_white.gif')}" />
                                </a>
                            </g:if>
                            <g:if test="${instance.isMemberOf('CHAFC')}">
                                <p>
                                    <g:message code="public.network.membership.des03" />
                                </p>
                                <img src="${resource(absolute: 'true', dir: 'data/network/', file: 'CHAFC_sm.jpg')}" />
                            </g:if>
                            <g:if test="${instance.isMemberOf('CHACM')}">
                                <p>
                                    <g:message code="public.network.membership.des04" />
                                </p>
                                <img src="${resource(absolute: 'true', dir: 'data/network/', file: 'chacm.png')}" />
                            </g:if>
                        </div>
                    </g:if>
                </div>
            </div><!--close content-->
        </div>

        <script type="text/javascript">
              // configure the charts
              var facetChartOptions = {
                  /* base url of the collectory */
                  collectionsUrl: "${grailsApplication.config.grails.serverURL}",
                  /* base url of the biocache ws*/
                  biocacheServicesUrl: biocacheServicesUrl,
                  /* base url of the biocache webapp*/
                  biocacheWebappUrl: biocacheWebappUrl,
                  /* a uid or list of uids to chart - either this or query must be present
                    (unless the facet data is passed in directly AND clickThru is set to false) */
                  instanceUid: "${instance.descendantUids().join(',')}",
                  /* the list of charts to be drawn (these are specified in the one call because a single request can get the data for all of them) */
                  charts: ['country','state','species_group','assertions','type_status',
                      'biogeographic_region','state_conservation','occurrence_year']
              }
              var taxonomyChartOptions = {
                  /* base url of the collectory */
                  collectionsUrl: "${grailsApplication.config.grails.serverURL}",
                  /* base url of the biocache ws*/
                  biocacheServicesUrl: biocacheServicesUrl,
                  /* base url of the biocache webapp*/
                  biocacheWebappUrl: biocacheWebappUrl,
                  /* a uid or list of uids to chart - either this or query must be present */
                  instanceUid: "${instance.descendantUids().join(',')}",
                  /* threshold value to use for automagic rank selection - defaults to 55 */
                  threshold: 55,
                  rank: "${instance.startingRankHint()}"
              }

            /************************************************************\
            * Actions when page is loaded
            \************************************************************/
            function onLoadCallback() {

              // stats
              if(loadLoggerStats){
                loadDownloadStats("${grailsApplication.config.loggerURL}", "${instance.uid}","${instance.name}", "1002");
              }

              // records
              $.ajax({
                url: urlConcat(biocacheServicesUrl, "/occurrences/search.json?pageSize=0&q=") + buildQueryString("${instance.descendantUids().join(',')}"),
                dataType: 'jsonp',
                timeout: 20000,
                complete: function(jqXHR, textStatus) {
                    if (textStatus == 'timeout') {
                        noData();
                        alert('Sorry - the request was taking too long so it has been cancelled.');
                    }
                    if (textStatus == 'error') {
                        noData();
                        alert('Sorry - the records breakdowns are not available due to an error.');
                    }
                },
                success: function(data) {
                    // check for errors
                    if (data.length == 0 || data.totalRecords == undefined || data.totalRecords == 0) {
                        noData();
                    } else {
                        setNumbers(data.totalRecords);
                        // draw the charts
                        drawFacetCharts(data, facetChartOptions);
                        if(data.totalRecords > 0){
                            $('#dataAccessWrapper').css({display:'block'});
                            $('#totalRecordCountLink').html(data.totalRecords.toLocaleString() + " ${g.message(code: 'public.show.rt.des03')}");
                        }
                    }
                }
              });

              // taxon chart
              loadTaxonomyChart(taxonomyChartOptions);
            }
            /************************************************************\
            *
            \************************************************************/

            google.load("visualization", "1", {packages:["corechart"]});
            google.setOnLoadCallback(onLoadCallback);
        </script>
    </body>
</html>
