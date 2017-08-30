<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

        <title>
            <g:message code="public.map3.title" /> | ${grailsApplication.config.projectName}
        </title>
    </head>

    <body>
        <div id="page-collections-map" class="nav-datasets">
            <div id="content">
                <div id="header" class="page-header">
                    <h1 class="page-header__title">
                        <g:message code="public.map3.title" />
                    </h1>

                    <div class="page-header__subtitle">
                        <g:message code="public.map3.header.description" args="[grailsApplication.config.projectNameShort, grailsApplication.config.regionName]" />
                    </div>
                </div>

                <div>
                    <p class="active-filters vertical-block">
                        <span class="active-filters__title">
                            <g:message code="activefilters.title" />:
                        </span>

                        <span class="active-filters__filter">
                            <span id="numFeatures"></span>
                            <span id="numVisible"></span>
                            <span id="numUnMappable"></span>
                        </span>
                    </p>

                    <p class="vertical-block">
                        <span class="fa fa-info-circle"></span>
                        <g:message code="public.map3.filtercollections" />
                    </p>
                </div>

                <g:if test="${flash.message}">
                    <div class="message">
                        ${flash.message}
                    </div>
                </g:if>

                <div class="row">
                    <div class="col-md-5">
                        <div class="section filter-buttons">
                            <div class="all selected" id="all" onclick="toggleButton(this);return false;">
                                <h2>
                                    <%-- XXX Illegal href, also on same level elements below. --%>
                                    <a href="">
                                        <g:message code="public.map3.link.allcollections" />

                                        <span id="allButtonTotal">
                                            <%-- XXX NOT USED! OR RATHER: OVERWRITTEN BY JS. --%>
                                            <g:message code="public.map3.link.showall" />
                                            <collections></collections>
                                        </span>
                                    </a>
                                </h2>
                            </div>

                            <div class="fauna" id="fauna" onclick="toggleButton(this);return false;">
                                <h2>
                                    <a href="">
                                        <g:message code="public.map3.link.fauna" />

                                        <span>
                                            <g:message code="public.map3.link.mammals" />.
                                        </span>
                                    </a>
                                </h2>
                            </div>

                            <div class="insects" id="entomology" onclick="toggleButton(this);return false;">
                                <h2>
                                    <a href="">
                                        <g:message code="public.map3.link.insect" />
                                        <span>
                                            <g:message code="public.map3.link.insects" />.
                                        </span>
                                    </a>
                                </h2>
                            </div>

                            <div class="microbes" id="microbes" onclick="toggleButton(this);return false;">
                                <h2>
                                    <a href="">
                                        <g:message code="public.map3.link.mos" />
                                        <span>
                                            <g:message code="public.map3.link.protists" />.
                                        </span>
                                    </a>
                                </h2>
                            </div>

                            <div class="plants" id="plants" onclick="toggleButton(this);return false;">
                                <h2>
                                    <a href="">
                                        <g:message code="public.map3.link.plants" />
                                        <span>
                                            <g:message code="public.map3.link.vascular" />.
                                        </span>
                                    </a>
                                </h2>
                            </div>
                        </div>

                        <%--
                        <div id="adminLink" class="dropdown" style="margin-top:110px;">
                            <g:link controller="manage" action="list" style="color:#DDDDDD; margin-top:80px;">
                                <g:message code="public.map3.adminlink" />
                            </g:link>
                        </div>
                        --%>
                    </div>

                    <div class="col-md-7" id="map-list-col">
                        <div class="tabbable">
                            <ul class="nav nav-tabs" id="home-tabs">
                                <li class="nav-item">
                                    <a href="#map" data-toggle="tab" class="nav-link active">
                                        <g:message code="public.map3.maplistcol.map" />
                                    </a>
                                </li>

                                <li class="nav-item">
                                    <a href="#list" data-toggle="tab" class="nav-link">
                                        <g:message code="public.map3.maplistcol.list" />
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <div class="tab-content">
                            <div class="tab-pane active" id="map">
                                <div  class="map-column">
                                    <div class="section">
                                        <p>
                                            <span class="fa fa-info-circle"></span>
                                            <g:message code="public.map3.maplistcol.des01" />.
                                        <p>

                                        <p class="vertical-block">
                                            <%-- <span class="fa fa-info-circle"></span> --%>
                                            <img src="${resource(dir:'images', file:'markermultiple.png')}" class="map-legend-img" />

                                            <g:message code="public.map3.maplistcol.des02" />.
                                        </p>

                                        <div id="map-container">
                                            <div id="map_canvas"></div>
                                        </div>

                                        <%--
                                        <div class="map-footer">
                                            <span class="fa fa-info-circle"></span>
                                            <img src="${resource(dir:'images', file:'markermultiple.png')}" class="map-legend-img" />

                                            <g:message code="public.map3.maplistcol.des02" />.
                                        </div>
                                        --%>
                                    </div>
                                </div>
                            </div>

                            <div id="list" class="tab-pane">
                                <div class="list-column">
                                    <div class="nameList section" id="names">
                                        <p>
                                            <span class="fa fa-info-circle"></span>
                                            <g:message code="public.map3.maplistcol.des04" />&nbsp;
                                        </p>

                                        <ul id="filtered-list">
                                            <g:each var="c" in="${collections}" status="i">
                                                <li>
                                                    <g:link controller="public" action="show" id="${c.uid}">
                                                        ${fieldValue(bean: c, field: "name")}
                                                    </g:link>

                                                    <g:if test="${!c.canBeMapped()}">
                                                        <img style="vertical-align:middle" src="${resource(dir:'assets/map', file:'nomap.gif')}" />
                                                    </g:if>
                                                </li>
                                            </g:each>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            var altMap = true;
            var COLLECTIONS_MAP_OPTIONS = {
                serverUrl:   "${grailsApplication.config.grails.serverURL}",
                centreLat:   ${grailsApplication.config.collectionsMap.centreMapLat?:"-28.2"},
                centreLon:   ${grailsApplication.config.collectionsMap.centreMapLon?:"134"},
                defaultZoom: ${grailsApplication.config.collectionsMap.defaultZoom?:"4"}
            }

            initMap(COLLECTIONS_MAP_OPTIONS);
        </script>
    </body>
</html>
