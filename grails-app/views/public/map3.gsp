<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

        <asset:stylesheet src="map3.css" />
        <asset:javascript src="map.js" />

        <title>
            <g:message code="public.map3.title" />
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
                            <span id="numFeatures">
                                <%-- Filled by map.js --%>
                            </span>
                            <span id="numUnMappable">
                                <%-- Filled by map.js --%>
                            </span>
                        </span>
                    </p>
                </div>

                <g:if test="${flash.message}">
                    <div class="message">
                        ${flash.message}
                    </div>
                </g:if>

                <div class="row">
                    <div class="col-md-5">
                        <p class="vertical-block">
                            <span class="fa fa-info-circle"></span>
                            <g:message code="public.map3.filtercollections" />
                        </p>
                        <div class="section">
                            <div class="filter-button-container">
                                <button type="button" class="filter-button all selected" id="all" onclick="toggleButton(this);return false;">
                                    <h2 class="filter-button__title">
                                        <g:message code="public.map3.link.allcollections" />
                                    </h2>

                                    <div class="filter-button__body">
                                        <span id="collections-total">
                                            <%-- XXX NOT USED! OR RATHER: OVERWRITTEN BY JS. --%>
                                            <g:message code="public.map3.link.showall" />
                                            <collections></collections>
                                        </span>
                                    </div>
                                </button>
                            </div>

                            <div class="filter-button-container">
                                <button type="button" class="filter-button fauna" id="fauna" onclick="toggleButton(this);return false;">
                                    <h2 class="filter-button__title">
                                        <g:message code="public.map3.link.fauna" />
                                    </h2>

                                    <div class="filter-button__body">
                                        <g:message code="public.map3.link.mammals" />
                                    </div>
                                </button>
                            </div>

                            <div class="filter-button-container">
                                <button type="button" class="filter-button insects" id="entomology" onclick="toggleButton(this);return false;">
                                    <h2 class="filter-button__title">
                                        <g:message code="public.map3.link.insect" />
                                    </h2>

                                    <div class="filter-button__body">
                                        <g:message code="public.map3.link.insects" />.
                                    </div>
                                </button>
                            </div>

                            <div class="filter-button-container">
                                <button type="button" class="filter-button microbes" id="microbes" onclick="toggleButton(this);return false;">
                                    <h2 class="filter-button__title">
                                        <g:message code="public.map3.link.mos" />
                                    </h2>

                                    <div class="filter-button__body">
                                        <g:message code="public.map3.link.protists" />.
                                    </div>
                                </button>
                            </div>

                            <div class="filter-button-container">
                                <button type="button" class="filter-button plants" id="plants" onclick="toggleButton(this);return false;">
                                    <h2 class="filter-button__title">
                                        <g:message code="public.map3.link.plants" />
                                    </h2>

                                    <div class="filter-button__body">
                                        <g:message code="public.map3.link.vascular" />.
                                    </div>
                                </button>
                            </div>
                        </div>
                    </div>

                    <div id="map-list-col" class="col-md-7">
                        <p class="vertical-block">
                            <span class="fa fa-info-circle"></span>
                            <g:message code="public.map3.maplistcol.des01" />.
                        </p>

                        <div class="tabbable">
                            <ul id="home-tabs" class="nav nav-tabs">
                                <li class="nav-item">
                                    <a href="#list" data-toggle="tab" class="nav-link active">
                                        <g:message code="public.map3.maplistcol.list" />
                                    </a>
                                </li>

                                <li class="nav-item">
                                    <a id="map-tab-header" href="#map" data-toggle="tab" class="nav-link">
                                        <g:message code="public.map3.maplistcol.map" />
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <div class="tab-content">
                            <div id="map" class="tab-pane">
                                <div class="map-column">
                                    <div class="section">
                                        <p class="vertical-block">
                                            <img src="${resource(dir:'images', file:'markermultiple.png')}" class="map-legend-img" />
                                            <g:message code="public.map3.maplistcol.des02" />.
                                        </p>
                                        <div id="map_canvas"></div>
                                    </div>
                                </div>
                            </div>

                            <div id="list" class="tab-pane active">
                                <div class="list-column">
                                    <div id="names" class="nameList section">
                                        <ul id="filtered-list" class="list-unstyled"></ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <g:javascript>
            var baseUrl = "${grailsApplication.config.grails.serverURL}";
        </g:javascript>
    </body>
</html>
