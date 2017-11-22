<!DOCTYPE html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />

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

        <title>
            <g:message code="public.datasets.title" />
        </title>

        <asset:stylesheet src="datasets.css" />
        <asset:javascript src="datasets.js" />
    </head>

    <body id="page-datasets" class="nav-datasets">
        <div class="page-header">
            <h1 class="page-header__title">
                <g:message code="public.datasets.title" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="public.datasets.title.description" />
            </div>
        </div>

        <div class="row">
            <div class="col">
                <form id="search-inpage" action="search" method="get" name="search-form">
                    <div class="input-plus">
                        <input
                            id="dr-search"
                            type="text"
                            name="dr-search"
                            class="input-plus__field"
                            placeholder="${message(code: 'public.datasets.btn.search.placeholder')}"
                        />

                        <button type="submit" class="erk-button erk-button--dark input-plus__addon" >
                            <span class="fa fa-search"></span>
                            <g:message code="general.btn.search" />
                        </button>
                    </div>
                </form>

                <p>
                    <span id="resultsReturned">
                        <g:message code="public.datasets.resultsReturned.showing" />
                            <strong></strong>&nbsp;
                        <g:message code="public.datasets.resultsReturned.datasets" />
                    </span>
                </p>

                <%-- List of active filters populated by javascript. --%>
                <div id="currentFilterHolder"></div>
            </div>
        </div>

        <div class="collectory-content row">
            <%-- Refine info --%>
            <div class="col-sm-4 col-md-5 col-lg-3">
                <div class="row">
                    <div class="col">
                        <p>
                            <span class="fa fa-info-circle"></span>
                            <g:message code="general.facets.infoText" />
                        </p>
                    </div>
                </div>
            </div>

            <%-- Filters --%>
            <div class="col-sm-4 col-md-5 col-lg-3 order-sm-2">
                <div class="card card-body filters-container">
                    <div id="dsFacets"></div>
                </div>
            </div>

            <%-- Buttons --%>
            <div class="col-sm-8 col-md-7 col-lg-9"></div>

            <%-- Datasets list --%>
            <div id="data-set-list" class="col-sm-8 col-md-7 col-lg-9 order-sm-2">
                <div class="card card-body">
                    <div>
                        <button id="downloadButton" class="erk-button erk-button--light float-left">
                            <span class="fa fa-download"></span>
                            <g:message code="general.btn.download.label" />
                        </button>

                        <div class="inline-controls inline-controls--right">
                            <div class="inline-controls__group">
                                <label for="per-page">
                                    <g:message code="general.list.pageSize.label" />
                                </label>

                                <g:select
                                    id="per-page"
                                    name="per-page"
                                    from="${[10, 20, 50, 100, 500]}"
                                    value="${pageSize ?: 20}"
                                    class="input-sm"
                                />
                            </div>

                            <div class="inline-controls__group">
                                <label for="sort">
                                    <g:message code="general.list.orderBy.label" />
                                </label>

                                <select id="sort" name="sort" class="input-sm">
                                    <g:each in="${['name', 'type', 'license']}">
                                        <option value="${it}">
                                            <g:message code="general.sortBy.${it}" />
                                        </option>
                                    </g:each>
                                </select>
                            </div>

                            <div class="inline-controls__group">
                                <label for="dir">
                                    <g:message code="general.list.sortBy.label" />
                                </label>

                                <select id="dir" name="dir" class="input-sm" >
                                    <option value="ascending">
                                        <g:message code="general.list.sortOrder.asc" />
                                    </option>
                                    <option value="descending">
                                        <g:message code="general.list.sortOrder.desc" />
                                    </option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div id="results-container">
                        <div id="loading">
                            <g:message code="general.loading" />&hellip;
                        </div>
                    </div>

                    <%-- TODO: What is this? --%>
                    <div id="searchNavBar" class="clearfix">
                        <div id="navLinks"></div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
