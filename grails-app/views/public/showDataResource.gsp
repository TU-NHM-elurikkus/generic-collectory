<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

        <title>
            ${instance.name}
        </title>

        <asset:stylesheet src="public-show.css" />
        <asset:javascript src="public-show-data-resource.js" />

        <script>
            loadLoggerStats = ${!grailsApplication.config.disableLoggerLinks.toBoolean()};
        </script>
    </head>

    <body class="nav-datasets">
        <div id="content">
            <div id="header" class="page-header">
                <h1 class="page-header__title">
                    ${instance.name}
                </h1>

                <div class="page-header-links">
                    <a href="${request.contextPath}/public/datasets/" title="List" class="page-header-links__link">
                        <span class="fa fa-arrow-left"></span>
                        <g:message code="page.navigation.datasets" />
                    </a>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3">
                    <g:if test="${dp?.logoRef?.file}">
                        <g:link action="show" id="${dp.uid}">
                            <img
                                src="${resource(absolute: 'true', dir: 'data/dataProvider/', file: fieldValue(bean: dp, field: 'logoRef.file'))}"
                                alt="${fieldValue(bean: dp, field: 'logoRef.file')}"
                                class="sidebar-image"
                              />
                        </g:link>
                    </g:if>
                    <g:elseif test="${instance?.logoRef?.file}">
                        <img
                            src="${resource(absolute: 'true', dir: 'data/dataResource/', file: instance.logoRef.file)}"
                            alt="${fieldValue(bean: instance, field: 'logoRef.file')}"
                            class="sidebar-image"
                        />
                    </g:elseif>

                    <%-- We are going to use only logo for now and not the reference image.
                    <g:if test="${fieldValue(bean: instance, field: 'imageRef') && fieldValue(bean: instance, field: 'imageRef.file')}">
                        <div class="section">
                            <img
                                src="${resource(absolute: 'true', dir: 'data/dataResource/', file: instance.imageRef.file)}"
                                alt="${fieldValue(bean: instance, field: 'imageRef.file')}"
                                class="sidebar-image"
                            />

                            <p class="caption">
                                <cl:formattedText>
                                    ${fieldValue(bean: instance, field: "imageRef.caption")}
                                </cl:formattedText>
                            </p>

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
                    --%>

                    <div id="dataAccessWrapper" style="display:none;">
                        <g:render template="dataAccess" model="[instance:instance]" />
                    </div>

                    <%-- LSID & DATA PROVIDER IMAGE --%>
                    <g:if test="${instance.guid}">
                        <div>
                            <h3>
                                LSID
                            </h3>

                            <p>
                                ${fieldValue(bean: instance, field: "guid")}
                            </p>
                        </div>
                    </g:if>

                    <%-- use parent location if the collection is blank --%>
                    <g:set var="address" value="${instance.address}" />

                    <g:if test="${address == null || address.isEmpty()}">
                        <g:if test="${instance.dataProvider}">
                            <g:set var="address" value="${instance.dataProvider?.address}" />
                        </g:if>
                    </g:if>

                    <g:if test="${address != null && !address?.isEmpty()}">
                        <div class="section">
                            <h3>
                                <g:message code="public.location" />
                            </h3>

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
                    </g:if>

                    <!-- contacts -->
                    <g:if test="${instance.makeContactPublic}">
                        <%-- added so that contact visibility on website is on data resource level --%>
                        <g:set var="contacts" value="${instance.getContacts()}" />
                    </g:if>

                    <g:else>
                        <g:set var="contacts" value="${instance.getPublicContactsPrimaryFirst()}" />

                        <g:if test="${!contacts}">
                            <g:set var="contacts" value="${instance.dataProvider?.getContactsPrimaryFirst()}" />
                        </g:if>
                    </g:else>

                    <g:render template="contacts" bean="${contacts}" />

                    <!-- web site -->
                    <g:if test="${instance.resourceType == 'species-list'}">
                        <div class="section">
                            <h3>
                                <g:message code="public.sdr.content.label12" />
                            </h3>

                            <div class="webSite">
                                <a class='external_icon' target="_blank" href="${grailsApplication.config.speciesListToolUrl}${instance.uid}">
                                    <g:message code="public.sdr.content.link03" />
                                </a>
                            </div>
                        </div>
                    </g:if>
                    <g:elseif test="${instance.websiteUrl}">
                        <div class="section">
                            <h3>
                                <g:message code="public.website" />
                            </h3>

                            <div class="webSite">
                                <a class='external_icon' target="_blank" href="${instance.websiteUrl}">
                                    <g:message code="public.sdr.content.link04" />
                                </a>
                            </div>
                        </div>
                    </g:elseif>

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

                                <img src="${resource(absolute: "true", dir: "data/network/", file: "butflyyl.gif")}" />
                            </g:if>

                            <g:if test="${instance.isMemberOf('CHAH')}">
                                <p>
                                    <g:message code="public.network.membership.des02" />
                                </p>

                                <a target="_blank" href="http://www.chah.gov.au">
                                    <img src="${resource(absolute: "true", dir: "data/network/", file: "CHAH_logo_col_70px_white.gif")}" />
                                </a>
                            </g:if>

                            <g:if test="${instance.isMemberOf('CHAFC')}">
                                <p>
                                    <g:message code="public.network.membership.des03" />
                                </p>

                                <img src="${resource(absolute: "true", dir: "data/network/", file: "CHAFC_sm.jpg")}" />
                            </g:if>

                            <g:if test="${instance.isMemberOf('CHACM')}">
                                <p>
                                    <g:message code="public.network.membership.des04" />
                                </p>

                                <img src="${resource(absolute: "true", dir: "data/network/", file: "chacm.png")}" />
                            </g:if>
                        </div>
                    </g:if>

                    <!-- attribution -->
                    <g:set var="attribs" value="${instance.getAttributionList()}" />
                    <g:if test="${attribs.size() > 0}">
                        <div class="section" id="infoSourceList">
                            <h4>
                                <g:message code="public.sdr.infosourcelist.title" />
                            </h4>

                            <ul class="list-unstyled indented-list-item">
                                <g:each var="a" in="${attribs}">
                                    <li>
                                        <a href="${a.url}" class="external" target="_blank">
                                            ${a.name}
                                        </a>
                                    </li>
                                </g:each>
                            </ul>
                        </div>
                    </g:if>

                    <cl:lastUpdated date="${instance.lastUpdated}" />

                </div>

                <div class="col-md-9">
                    <div class="card detached-card">
                        <div class="card-header">
                            <h4>
                                <g:message code="public.show.overviewtabs.overview" />
                            </h4>
                        </div>

                        <div class="card-body">
                            <h3>
                                <g:message code="public.des" />
                            </h3>

                            <cl:formattedText>
                                ${fieldValue(bean: instance, field: "pubDescription")}
                            </cl:formattedText>
                            <cl:formattedText>
                                ${fieldValue(bean: instance, field: "techDescription")}
                            </cl:formattedText>
                            <cl:formattedText>
                                ${fieldValue(bean: instance, field: "focus")}
                            </cl:formattedText>
                            <cl:dataResourceContribution resourceType="${instance.resourceType}" status="${instance.status}" tag="p" />

                            <g:if test="${instance.contentTypes}">
                                <h3>
                                    <g:message code="public.sdr.content.label02" />
                                </h3>
                                <cl:contentTypes types="${instance.contentTypes}" />
                            </g:if>

                            <h3>
                                <g:message code="public.sdr.content.label03" />
                            </h3>

                            <g:if test="${instance.citation}">
                                <cl:formattedText>
                                    ${fieldValue(bean: instance, field: "citation")}
                                </cl:formattedText>
                            </g:if>
                            <g:else>
                                <p>
                                    <g:message code="public.sdr.content.des01" />.
                                </p>
                            </g:else>

                            <g:if test="${instance.rights || instance.licenseType}">
                                <h3>
                                    <g:message code="public.sdr.content.label04" />
                                </h3>

                                <g:if test="${instance.rights}">
                                    <cl:formattedText>
                                        ${fieldValue(bean: instance, field: "rights")}
                                    </cl:formattedText>
                                </g:if>
                            </g:if>

                            <g:if test="${instance.licenseType}">
                                <h3>
                                    <g:message code="dataResource.licenseType.label" />
                                </h3>

                                <cl:displayLicenseType type="${instance.licenseType}" version="${instance.licenseVersion}" />
                            </g:if>

                            <g:if test="${instance.dataGeneralizations}">
                                <h3>
                                    <g:message code="public.sdr.content.label05" />
                                </h3>

                                <cl:formattedText>
                                    ${fieldValue(bean: instance, field: "dataGeneralizations")}
                                </cl:formattedText>
                            </g:if>

                            <g:if test="${instance.informationWithheld}">
                                <h3>
                                    <g:message code="public.sdr.content.label06" />
                                </h3>

                                <cl:formattedText>
                                    ${fieldValue(bean: instance, field: "informationWithheld")}
                                </cl:formattedText>
                            </g:if>

                            <g:if test="${instance.downloadLimit}">
                                <h3>
                                    <g:message code="public.sdr.content.label07" />
                                </h3>

                                <p>
                                    <g:message code="public.sdr.content.des02" />
                                    ${fieldValue(bean: instance, field: "downloadLimit")}
                                    <g:message code="public.sdr.content.des03" />.
                                </p>
                            </g:if>

                            <g:if test="${instance.resourceType == 'website' && (instance.lastChecked || instance.dataCurrency)}">
                                <h3>
                                    <g:message code="public.sdr.content.label08" />
                                </h3>

                                <p>
                                    <cl:lastChecked date="${instance.lastChecked}" />
                                    <cl:dataCurrency date="${instance.dataCurrency}" />
                                </p>
                            </g:if>
                        </div> <%-- main card --%>
                    </div>

                    <g:if test="${instance.resourceType == 'records'}">
                        <div class="card detached-card">
                            <div class="card-header">
                                <h4>
                                    <g:message code="public.sdr.content.label09" />
                                </h4>
                            </div>

                            <div class="card-body">
                                <p>
                                    <span id="numBiocacheRecords">
                                        <g:message code="public.show.portalRecordsBit.searching" />
                                    </span>

                                    <g:message code="public.show.portalRecordsBit.available" />.

                                    <cl:lastChecked date="${instance.lastChecked}" />
                                    <cl:dataCurrency date="${instance.dataCurrency}" />
                                </p>

                                <cl:recordsLink collection="${instance}">
                                    <span class="fa fa-list"></span>
                                    <g:message code="page.navigation.records" args="${ [instance.name] }" />
                                </cl:recordsLink>

                                <cl:downloadPublicArchive uid="${instance.uid}" available="${instance.publicArchiveAvailable}" />

                                <div id="recordsBreakdown" class="section vertical-charts">
                                    <g:if test="${!grailsApplication.config.disableOverviewMap}">
                                        <h3>
                                            <g:message code="public.sdr.content.label10" />
                                        </h3>

                                        <cl:recordsMapDirect uid="${instance.uid}" />
                                    </g:if>

                                    <div id="tree" class="vertical-block"></div>
                                    <div id="charts" class="vertical-block"></div>
                                </div>
                            </div>
                        </div>
                    </g:if>

                    <g:if test="${!grailsApplication.config.disableLoggerLinks.toBoolean() && (instance.resourceType == 'website' || instance.resourceType == 'records')}">
                        <div class="card detached-card">
                            <div class="card-header">
                                <h4>
                                    <g:message code="public.sdr.usagestats.label" />
                                </h4>
                            </div>

                            <div class="card-body">
                                <div id="usage">
                                    <p>
                                        <g:message code="general.loading" />&hellip;
                                    </p>
                                </div>

                                <g:if test="${instance.resourceType == 'website'}">
                                    <div id="usage-visualization" style="width: 600px; height: 200px;"></div>
                                </g:if>
                            </div>
                        </div>
                    </g:if>
                </div>  <%--close column-one--%>
            </div>
        </div>

        <script type="text/javascript" src="https://www.google.com/jsapi"></script>

        <script type="text/javascript">
            google.load('visualization', '1.0', {'packages': ['corechart']});
        </script>

        <script type="text/javascript">
            var CHARTS_CONFIG = {
                biocacheServicesUrl: "${grailsApplication.config.biocacheService.ui.url}",
                biocacheWebappUrl: "${grailsApplication.config.occurrences.ui.url}",
                collectionsUrl: "${grailsApplication.config.collectory.ui.url}"
            };

            // configure the charts
            var taxonomyChartOptions = {
                /* base url of the collectory */
                collectionsUrl: CHARTS_CONFIG.collectionsUrl,
                /* base url of the biocache ws*/
                biocacheServicesUrl: CHARTS_CONFIG.biocacheServicesUrl,
                /* base url of the biocache webapp*/
                biocacheWebappUrl: CHARTS_CONFIG.biocacheWebappUrl,
                /* support drill down into chart - default is false */
                drillDown: true,
                is3D: false,
                /* a uid or list of uids to chart - either this or query must be present */
                instanceUid: "${instance.uid}",
                //query: "notomys",
                //rank: "kingdom",
                /* threshold value to use for automagic rank selection - defaults to 55 */
                threshold: 25
            }

            var taxonomyTreeOptions = {
                /* base url of the collectory */
                collectionsUrl: CHARTS_CONFIG.collectionsUrl,
                serverUrl: CHARTS_CONFIG.collectionsUrl,
                /* base url of the biocache ws*/
                biocacheServicesUrl: CHARTS_CONFIG.biocacheServicesUrl,
                /* base url of the biocache webapp*/
                biocacheWebappUrl: CHARTS_CONFIG.biocacheWebappUrl,
                /* the id of the div to create the charts in - defaults is 'charts' */
                targetDivId: "tree",
                /* a uid or list of uids to chart - either this or query must be present */
                instanceUid: "${instance.uid}"
            }

            /************************************************************\
            *
            \************************************************************/
            var queryString = '';
            var decadeUrl = '';

            $('img#mapLegend').each(function(i, n) {
                // if legend doesn't load, then it must be a point map
                $(this).error(function() {
                    $(this).attr('src',"${resource(dir: 'images/map', file: 'single-occurrences.png')}");
                });
            });

            /************************************************************\
            *
            \************************************************************/
            function onLoadCallback() {
                // stats
                if(loadLoggerStats) {
                    if (${instance.resourceType == 'website'}) {
                        loadDownloadStats("${grailsApplication.config.collectory.ui.url}", "${instance.uid}","${instance.name}", "2000");
                    } else if (${instance.resourceType == 'records'}) {
                        loadDownloadStats("${grailsApplication.config.collectory.ui.url}", "${instance.uid}","${instance.name}", "1002");
                    }
                }

                // records
                if (${instance.resourceType == 'records'}) {
                    // summary biocache data
                    $.ajax({
                        url: CHARTS_CONFIG.biocacheServicesUrl + "/occurrences/search.json?pageSize=0&q=data_resource_uid:${instance.uid}",
                        dataType: 'jsonp',
                        timeout: 30000,
                        complete: function(jqXHR, textStatus) {
                            if(textStatus == 'timeout') {
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

                    // taxon chart
                    loadTaxonomyChart(taxonomyChartOptions);

                    // tree
                    initTaxonTree(taxonomyTreeOptions);
                }
            }

            /************************************************************\
            *
            \************************************************************/
            google.load("visualization", "1.0", { packages:["corechart"] });
            google.setOnLoadCallback(onLoadCallback);
        </script>
    </body>
</html>
