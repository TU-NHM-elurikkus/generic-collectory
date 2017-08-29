<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <title>
            <g:message code="public.datasets.title" /> | ${grailsApplication.config.projectName}
        </title>

        <asset:javascript src="datasets.js" />
        <asset:javascript src="jquery-plugins/jQueryRotateCompressed.2.1.js" />
        <asset:stylesheet src="filters.css" />

        <script type="text/javascript">
            var altMap = true;

            $(document).ready(function() {
                $('#nav-tabs > ul').tabs();

                loadResources("${grailsApplication.config.grails.serverURL}","${grailsApplication.config.biocacheUiURL}");

                $('select#per-page').change(onPageSizeChange);
                $('select#sort').change(onSortChange);
                $('select#dir').change(onDirChange);
            });
        </script>
    </head>

    <body id="page-datasets" class="nav-datasets">
        <%-- WEIRD --%>
        <div class="page-header">
            <h1 class="page-header__title">
                ${grailsApplication.config.projectName}
                <g:message code="public.datasets.header.title" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="public.datasets.header.message01" />
                ${grailsApplication.config.projectName},
                <g:message code="public.datasets.header.message02" />.
            </div>

            <div class="page-header-links">
                <a href="${request.contextPath}/" class="page-header-links__link">
                    <g:message code="page.navigation.collections" />
                </a>
            </div>
        </div>

        <%-- TODO: PROPER CONTAINER LOGIC --%>
            <div class="row">
                <div class="col">
                    <form id="search-inpage" action="search" method="get" name="search-form">
                        <div class="input-plus">
                            <%--
                                TODO: Value, placeholder, autofocus, onfocus, autocomplete.
                            --%>
                            <input
                                id="dr-search"
                                type="text"
                                name="dr-search"
                                class="input-plus__field"
                            />

                            <button type="submit" class="erk-button erk-button--dark input-plus__addon">
                                <g:message code="public.datasets.drsearch.search" />
                            </button>
                        </div>
                    </form>

                    <p>
                        <span id="resultsReturned">
                            <g:message code="public.datasets.resultsreturned.message01" />
                                <strong></strong>&nbsp;
                            <g:message code="public.datasets.resultsreturned.message02" />.
                        </span>
                    </p>

                    <%-- List of active filters populated by javascript. --%>
                    <div id="currentFilterHolder"></div>
                </div>
            </div>

            <%-- SOMETHING SOMETHING --%>
            <g:if test="${flash.message}">
                <div class="full-width">
                    <div class="message">
                        ${flash.message}
                    </div>
                </div<
            </g:if>

            <div class="collectory-content row">
                <div class="col-sm-5 col-md-5 col-lg-3">
                    <div class="card card-body filters-container">
                        <h2 class="card-title">
                            <g:message code="public.datasets.sidebar.header" />
                        </h2>

                        <div id="dsFacets"></div>
                    </div>
                </div>

                <%-- TODO: Mobile responsiveness. --%>
                <div id="data-set-list" class="col-sm-7 col-md-7 col-lg-9">
                    <div class="card card-body">
                        <div class="search-controls">
                            <button id="downloadButton" class="erk-button erk-button--light">
                                <span class="fa fa-download"></span>
                                <g:message code="public.datasets.downloadlink.label" />
                            </button>

                            <form class="form-inline float-right">
                                <div class="form-group">
                                    <label for="per-page">
                                        <g:message code="public.datasets.sortwidgets.rpp" />
                                    </label>

                                    <g:select id="per-page" name="per-page" from="${[10,20,50,100,500]}" value="${pageSize ?: 20}" class="input-sm" />
                                </div>

                                <div class="form-group">
                                    <label for="sort">
                                        <g:message code="public.datasets.sortwidgets.sb" />
                                    </label>

                                    <g:select id="sort" name="sort" from="${['name','type','license']}" class="input-sm" />
                                </div>

                                <div class="form-group">
                                    <label for="dir">
                                        <g:message code="public.datasets.sortwidgets.so" />
                                    </label>

                                    <g:select id="dir" name="dir" from="${['ascending','descending']}" class="input-sm" />
                                </div>
                            </form>
                        </div><!--drop downs-->

                        <div id="results">
                            <div id="loading">
                                <g:message code="public.datasets.loading" /> ..
                            </div>
                        </div>

                        <%-- TODO: What is this? --%>
                        <div id="searchNavBar" class="clearfix">
                            <div id="navLinks"></div>
                        </div>
                    </div>
                </div>
            </div><!-- close collectory-content-->
        </div><!--close content-->
    </body>
</html>
