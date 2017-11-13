// defaults for taxa chart
var taxonomyPieChartOptions = {
    width: 450,
    height: 450
};

// defaults for facet charts
var genericChartOptions = {
    width: 600,
    height: 400,
    is3D: false,
    sliceVisibilityThreshold: 0,
    chartType: 'pie',
    backgroundColor: 'transparent',
    chartArea: {
        left: 10,
        top: 30,
        width: '100%',
        height: '100%'
    },

    legend: {
        position: 'right',
        textStyle: {
            fontSize: 12
        }
    },

    titleTextStyle: {
        color: '#555',
        fontName: 'Arial',
        fontSize: 16
    }
};

/* ----------------- FACET-BASED CHARTS USING DIRECT CALLS TO BIO-CACHE SERVICES ---------------------*/
// these override the facet names in chart titles
var chartLabels = {
    institution_uid: 'charts.labels.institution',
    data_resource_uid: 'charts.labels.dataset',
    assertions: 'charts.labels.dataassertion',
    biogeographic_region: 'charts.labels.biogeographicregion',
    occurrence_year: 'charts.labels.decade'
};

function cleanUp(chartOptions) {
    $('img.loading').remove();
    if(chartOptions !== undefined && chartOptions.error) {
        window[chartOptions.error]();
    }
}

/**
 * Ajax request for initial taxonomic breakdown.
 */
function loadTaxonomyChart(chartOptions) {
    if(chartOptions.collectionsUrl != undefined) { collectionsUrl = chartOptions.collectionsUrl; }
    if(chartOptions.biocacheServicesUrl != undefined) { biocacheServicesUrl = chartOptions.biocacheServicesUrl; }
    if(chartOptions.biocacheWebappUrl != undefined) { biocacheWebappUrl = chartOptions.biocacheWebappUrl; }

    var query = chartOptions.query ? chartOptions.query : buildQueryString(chartOptions.instanceUid);

    var url = urlConcat(biocacheServicesUrl, '/breakdown.json?q=') + query;

    // add url params to set state
    if(chartOptions.rank) {
        url += '&rank=' + chartOptions.rank + (chartOptions.name ? '&name=' + chartOptions.name : '');
    } else {
        url += '&max=' + (chartOptions.threshold ? chartOptions.threshold : '55');
    }

    $.ajax({
        url: url,
        dataType: 'jsonp',
        timeout: 30000,
        complete: function(jqXHR, textStatus) {
            if(textStatus !== 'success') {
                cleanUp(chartOptions);
            }
        },
        success: function(data) {
            // check for errors
            if(data == undefined || data.length === 0) {
                cleanUp(chartOptions);
            } else {
                // draw the chart
                drawTaxonomyChart(data, chartOptions, query);
            }
        }
    });
}

/**
 * Create and show the taxonomy chart.
 */
function drawTaxonomyChart(data, chartOptions, query) {
    // create the data table
    var dataTable = new google.visualization.DataTable();

    dataTable.addColumn('string', chartLabels[name] ? $.i18n.prop(chartLabels[name]) : name);
    dataTable.addColumn('number', 'records');

    $.each(data.taxa, function(i, obj) {
        var label = obj.label === '' ? 'Unknown' : obj.label;

        dataTable.addRow([label, obj.count]);
    });

    // resolve the chart options
    var rango = '';
    var opts = $.extend(genericChartOptions, taxonomyPieChartOptions);

    opts = $.extend(true, opts, chartOptions);

    switch(data.rank) {
        case 'kingdom':
            rango = $.i18n.prop('charts.taxonomy.byRank.kingdom');
            break;
        case 'phylum':
            rango = $.i18n.prop('charts.taxonomy.byRank.phylum');
            break;
        case 'order':
            rango = $.i18n.prop('charts.taxonomy.byRank.order');
            break;
        case 'family':
            rango = $.i18n.prop('charts.taxonomy.byRank.family');
            break;
        case 'genus':
            rango = $.i18n.prop('charts.taxonomy.byRank.genus');
            break;
        case 'class':
            rango = $.i18n.prop('charts.taxonomy.byRank.class');
            break;
        case 'species':
            rango = $.i18n.prop('charts.taxonomy.byRank.species');
            break;
        default:
            rango = data.rank;
    }

    if(opts.name) {
        opts.title = opts.name + ' ' + rango;
    } else {
        // Capitalize the first letter. Can't do it in CSS because it's buried in third party SVG.
        opts.title = rango.charAt(0).toUpperCase() + rango.slice(1);
    }

    // create the outer div that will contain the chart and the additional links
    var $outerContainer = $('#taxa');

    if($outerContainer.length === 0) {
        $outerContainer = $('<div id="taxa"></div>'); // create it
        var chartsDiv = $('div#' + (chartOptions.targetDivId ? chartOptions.targetDivId : 'charts'));
        // append it
        chartsDiv.prepend($outerContainer);
    }

    // create the chart container if not already there
    var $container = $('#taxa-chart');
    if($container.length === 0) {
        $container = $('<div id="taxa-chart" class="chart-pie"></div>');
        $outerContainer.append($container);
    }

    // create the chart
    var chart = new google.visualization.PieChart(document.getElementById('taxa-chart'));

    // draw the chart
    chart.draw(dataTable, opts);

    // draw the back button / instructions
    var $backLink = $('#backLink');

    if($backLink.length === 0) {
        $backLink = $('<div class="erk-link-button erk-button--inline" id="backLink">&laquo; ' + $.i18n.prop('charts.taxonPie.previousRank') + '</div>').appendTo($outerContainer);  // create it
        $backLink.click(function() {
            // only act if link was real
            if(!$backLink.hasClass('erk-link-button')) { return; }

            // show spinner while loading
            $container.append($('<img class="loading" style="position:absolute;left:130px;top:220px;z-index:2000" ' +
                    'alt="cargando..." src="' + collectionsUrl + '/assets/ala/ajax-loader.gif"/>'));

            // get state from history
            var previous = popHistory(chartOptions);

            // set new chart state
            chartOptions.rank = previous.rank;
            chartOptions.name = previous.name;

            // redraw chart
            loadTaxonomyChart(chartOptions);
        });
    }
    if(chartOptions.history) {
        // show the prev link
        $backLink.html('&laquo; ' + $.i18n.prop('charts.taxonPie.previousRank')).addClass('erk-link-button');
    } else {
        // show the instruction
        $backLink.html(
            '<span class="fa fa-info-circle"></span>&nbsp;' +
            $.i18n.prop('charts.taxonPie.sliceToDrill')
        ).removeClass('erk-link-button');
    }

    // draw records link
    var $recordsLink = $('#recordsLink');

    if($recordsLink.length === 0) {
        $recordsLink = $('<div class="erk-link" id="recordsLink">' + $.i18n.prop('charts.taxonPie.viewRecords') + '</div>').appendTo($outerContainer);  // create it
        $recordsLink.click(function() {
            // show occurrence records
            var fq = '';

            if(chartOptions.rank != undefined && chartOptions.name != undefined) {
                fq = '&fq=' + chartOptions.rank + ':' + chartOptions.name;
            }

            document.location = urlConcat(biocacheWebappUrl, '/occurrences/search?q=') + query + fq;
        });
    }

    // set link text
    if(chartOptions.history) {
        var rankLabel = $.i18n.prop('taxonomy.rank.' + chartOptions.rank);

        $recordsLink.html(
            '<span class="fa fa-list"></span> ' +
            $.i18n.prop('charts.taxonPie.viewRecordsFor', rankLabel, chartOptions.name)
        );
    } else {
        $recordsLink.html('<span class="fa fa-list"></span> ' + $.i18n.prop('charts.taxonPie.viewAllRecords'));
    }

    // setup a click handler - if requested
    var clickThru = chartOptions.clickThru == undefined ? true : chartOptions.clickThru;  // default to true
    var drillDown = chartOptions.drillDown == undefined ? true : chartOptions.drillDown;  // default to true

    if(clickThru || drillDown) {
        google.visualization.events.addListener(chart, 'select', function() {
            // find out what they clicked
            var name = dataTable.getValue(chart.getSelection()[0].row, 0);

            if(name === 'Unknown') {
                var fq = '-' + data.rank + ':*';
                var url = urlConcat(biocacheWebappUrl, '/occurrence/search?q=') + query + '&fq=' + fq;

                if(chartOptions.name) {
                    url += '&fq=' + chartOptions.rank + ':' + chartOptions.name;
                }

                document.location = url;
            } else if(drillDown && data.rank !== 'species') {
                // show spinner while loading
                $container.append($('<img class="loading" style="position:absolute;left:130px;top:220px;z-index:2000" ' +
                        'alt="loading..." src="' + collectionsUrl + '/assets/ala/ajax-loader.gif"/>'));

                // save current state as history - for back-tracking
                pushHistory(chartOptions);

                // set new chart state
                chartOptions.rank = data.rank;
                chartOptions.name = name;

                // redraw chart
                loadTaxonomyChart(chartOptions);
            } else {
                // show occurrence records
                document.location = urlConcat(biocacheWebappUrl, '/occurrences/search?q=') + query +
                    '&fq=' + data.rank + ':' + name;
            }
        });
    }
}

/**
 * Add current chart state to its history.
 */
function pushHistory(options) {
    if(options.history == undefined) {
        options.history = [];
    }
    options.history.push({ rank: options.rank, name: options.name });
}

/**
 * Pop the previous current chart state from its history.
 */
function popHistory(options) {
    if(options.history == undefined) {
        return {};
    }
    var state = options.history.pop();
    if(options.history.length === 0) {
        options.history = null;
    }
    return state;
}

/** ------------------------- UTILITIES ------------------------------ */
/**
 * build records query handling multiple uids
 * uidSet can be a comma-separated string or an array
 */
function buildQueryString(uidSet) {
    var uids = (typeof uidSet === 'string') ? uidSet.split(',') : uidSet;
    var str = '';

    $.each(uids, function(index, value) {
        str += solrFieldNameForUid(value) + ':' + value + ' OR ';
    });

    return str.substring(0, str.length - 4);
}

/**
 * Returns the appropriate facet name for the uid - to build
 * biocache occurrence searches
 */
function solrFieldNameForUid(uid) {
    switch(uid.substring(0, 2)) {
        case 'co': return 'collection_uid';
        case 'in': return 'institution_uid';
        case 'dp': return 'data_provider_uid';
        case 'dr': return 'data_resource_uid';
        case 'dh': return 'data_hub_uid';
        default: return '';
    }
}

/**
 * Returns the appropriate context for the uid - to build
 * biocache webservice urls
 */
function wsEntityForBreakdown(uid) {
    switch(uid.substr(0, 2)) {
        case 'co': return 'collections';
        case 'in': return 'institutions';
        case 'dr': return 'dataResources';
        case 'dp': return 'dataProviders';
        case 'dh': return 'dataHubs';
        default: return '';
    }
}

/**
 * Concatenate url fragments handling stray slashes
 */
function urlConcat(base, context) {
    // remove any trailing slash from base
    base = base.replace(/\/$/, '');
    // remove any leading slash from context
    context = context.replace(/^\//, '');
    // join
    return base + '/' + context;
}
