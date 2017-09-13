<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <title>
            <g:message code="public.datasets.title" />
        </title>

        <asset:javascript src="datasets.js" />
        <asset:stylesheet src="datasets.css" />

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
                <g:message code="public.datasets.title" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="public.datasets.title.description" />
            </div>

            <div class="page-header-links">
                <a href="${request.contextPath}/" class="page-header-links__link">
                    <span class="fa fa-archive"></span>
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
                                <span class="fa fa-search"></span>
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

            <div class="datasets-header">
                <span class="fa fa-info-circle"></span>
                <g:message code="public.datasets.sidebar.header" />
            </div>

            <div class="collectory-content row">
                <div class="col-sm-5 col-md-5 col-lg-3">
                    <div class="card card-body filters-container">
                        <div id="dsFacets"></div>
                    </div>
                </div>

                <%-- TODO: Mobile responsiveness. --%>
                <div id="data-set-list" class="col-sm-7 col-md-7 col-lg-9">
                    <div class="card card-body">
                        <div>
                            <button id="downloadButton" class="erk-button erk-button--light float-left">
                                <span class="fa fa-download"></span>
                                <g:message code="public.datasets.downloadlink.label" />
                            </button>

                            <div class="inline-controls inline-controls--right">
                                <div class="inline-controls__group">
                                    <label for="per-page">
                                        <g:message code="public.datasets.sortwidgets.rpp" />
                                    </label>

                                    <g:select id="per-page" name="per-page" from="${[10,20,50,100,500]}" value="${pageSize ?: 20}" class="input-sm" />
                                </div>

                                <div class="inline-controls__group">
                                    <label for="sort">
                                        <g:message code="public.datasets.sortwidgets.sb" />
                                    </label>

                                    <g:select id="sort" name="sort" from="${['name','type','license']}" class="input-sm" />
                                </div>

                                <div class="inline-controls__group">
                                    <label for="dir">
                                        <g:message code="public.datasets.sortwidgets.so" />
                                    </label>

                                    <g:select id="dir" name="dir" from="${['ascending','descending']}" class="input-sm" />
                                </div>
                            </div>
                        </div>

                        <div id="results-container">
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
