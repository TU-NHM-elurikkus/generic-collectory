<%@ page contentType="text/html;charset=UTF-8"%>

<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

        <title>
            ${instance.name}
        </title>

        <asset:stylesheet src="public-show.css" />
        <asset:javascript src="public-show.js" />

        <script type="text/javascript" language="javascript" src="https://www.google.com/jsapi"></script>

        <script type="text/javascript">
            biocacheServicesUrl = "${grailsApplication.config.biocacheService.ui.url}";
            biocacheWebappUrl = "${grailsApplication.config.occurrences.ui.url}";
            loadLoggerStats = ${!grailsApplication.config.disableLoggerLinks.toBoolean()};
        </script>
    </head>

    <body>
        <div id="content">
            <div id="header" class="page-header">

                <h1 class="page-header__title">
                    ${instance.name}
                </h1>

                <div class="page-header__subtitle">
                    <g:set var="parents" value="${instance.listParents()}" />
                    <g:each var="p" in="${parents}">
                        <h3>
                            <g:link action="show" id="${p.uid}">
                                ${p.name}
                            </g:link>
                        </h3>
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
                </div>

                <div class="page-header-links">
                    <a href="${request.contextPath}/" class="page-header-links__link">
                        <span class="fa fa-arrow-left"></span>
                        <g:message code="general.collections" />
                    </a>
                </div>
            </div>  <%-- /header --%>

            <g:if test="${!grailsApplication.config.disableLoggerLinks.toBoolean() && grailsApplication.config.loggerService.ui.url}">
                <div class="row">
                    <div class="col">
                        <div class="float-right">
                            <p>
                                <a
                                    href="${grailsApplication.config.loggerService.ui.url}/service/reasonBreakdownCSV?eventId=1002&entityUid=${instance.uid}"
                                    class="erk-button erk-button--light erk-button-link"
                                >
                                    <span class="fa fa-download"></span>&nbsp;
                                    <g:message code="dataAccess.download.stats" />
                                </a>
                            </p>
                        </div>
                    </div>
                </div>
            </g:if>

            <div class="row">
                <div class="col-md-3">
                    <g:if test="${fieldValue(bean: instance, field: 'logoRef') && fieldValue(bean: instance, field: 'logoRef.file')}">
                        <div class="section">
                            <img
                                src="${resource(absolute:"true", dir:"data/institution/", file: instance.logoRef.file)}"
                                alt="${fieldValue(bean: instance, field: "logoRef.file")}"
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

                    <cl:lastUpdated date="${instance.lastUpdated}" />

                </div>

                <div class="col-md-9">
                    <g:if test="${instance.pubDescription}">
                        <h3>
                            <g:message code="public.des" />
                        </h3>
                        <cl:formattedText>
                            ${fieldValue(bean: instance, field: "pubDescription")}
                        </cl:formattedText>
                        <cl:formattedText>
                            ${fieldValue(bean: instance, field: "techDescription")}
                        </cl:formattedText>
                    </g:if>

                    <g:if test="${instance.focus}">
                        <h3>
                            <g:message code="public.si.content.label02" />
                        </h3>
                        <cl:formattedText>
                            ${fieldValue(bean: instance, field: "focus")}
                        </cl:formattedText>
                    </g:if>

                    <div class="card detached-card">
                        <div class="card-header">
                            <h4>
                                <g:message code="general.collections" />
                            </h4>
                        </div>

                        <div class="card-body">
                            <ol class="erk-olist">
                                <g:each var="c" in="${instance.listCollections().sort { it.name }}">
                                    <li class="erk-olist__item">
                                        <g:link controller="public" action="show" id="${c.uid}">
                                            <span class="fa fa-archive"></span>
                                            ${c?.name}
                                        </g:link>

                                        ${c?.makeAbstract(400)}
                                    </li>
                                </g:each>
                            </ol>
                        </div>
                    </div>

                    <div class="card detached-card">
                        <div class="card-header">
                            <h4>
                                <g:message code="public.si.content.label04" />
                            </h4>
                        </div>

                        <div class="card-body">
                            <div>
                                <p>
                                    <span id="numBiocacheRecords">
                                        <g:message code="public.show.portalRecordsBit.searching" />
                                    </span>

                                    <g:message code="public.show.portalRecordsBit.available" />.
                                </p>

                                <cl:recordsLink entity="${instance}">
                                    <span class="fa fa-list"></span>
                                    <g:message code="page.navigation.records" args="${ [instance.name] }" />
                                </cl:recordsLink>
                            </div>

                            <div id="recordsBreakdown" class="section vertical-block">
                                <div id="charts"></div>
                            </div>

                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header">
                            <h4>
                                <g:message code="public.usagestats.label" />
                            </h4>
                        </div>

                        <div id="usage" class="card-body">
                            <p>
                                <g:message code="general.loading" />&hellip;
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script type="text/javascript">
              var taxonomyChartOptions = {
                  /* base url of the collectory */
                  collectionsUrl: "${grailsApplication.config.collectory.ui.url}",
                  /* base url of the biocache ws*/
                  biocacheServicesUrl: biocacheServicesUrl,
                  /* base url of the biocache webapp*/
                  biocacheWebappUrl: biocacheWebappUrl,
                  /* a uid or list of uids to chart - either this or query must be present */
                  instanceUid: "${instance.descendantUids().join(',')}",
                  /* threshold value to use for automagic rank selection - defaults to 55 */
                  threshold: 55,
                  is3D: false,
                  rank: "${instance.startingRankHint()}"
              }

            /************************************************************\
            * Actions when page is loaded
            \************************************************************/
            function onLoadCallback() {

              // stats
              if(loadLoggerStats){
                loadDownloadStats("${grailsApplication.config.collectory.ui.url}", "${instance.uid}","${instance.name}", "1002");
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

                        if(data.totalRecords > 0){
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
