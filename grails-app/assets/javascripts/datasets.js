//= require jquery-migration-plugins

/* holds full list of resources */
var allResources;

/* holds current filtered list */
var resources;

/* list of filters currently in effect - items are {name, value} */
var currentFilters = [];

/* pagination offset into the record set */
var offset = 0;

/* size of current filtered list */
var total = 0;

/* the base url of the home server */
var baseUrl;

/* the base url of the biocache server */
var biocacheUrl;

/* options for all tooltips */
var tooltipOptions = {
    position: 'center right',
    offset: '-10, 5',
    predelay: 130,
    effect: 'fade',
    fadeOutSpeed:  200
};

/** load resources and show first page **/
function loadResources(serverUrl, biocacheRecordsUrl) {
    baseUrl = serverUrl;
    biocacheUrl = biocacheRecordsUrl;
    $.getJSON(baseUrl + '/public/resources.json', function(data) {
        allResources = data;
        // no filtering at this stage
        resources = allResources;

        setStateFromHash();
        updateTotal();
        calculateFacets();
        showFilters();
        resources.sort(comparator);
        displayPage();
        wireDownloadButton();
        wireSearchLink();

        // set up tooltips
        // - don't do download link because the title changes and the tooltip app does not update
        // - also limit to content to exclude links in header
        $('div.collectory-content [title][id!="downloadButton"]').tooltip(tooltipOptions);
    });
}

/**
  * List display
  */

/* display a page */
function displayPage() {
    // clear list
    $('#results-container div').remove();

    var _pageSize = pageSize();
    var item;
    // paginate and show list
    for(var i = offset; i < _pageSize; i++) {
        item = resources[i];

        // item will be undefined if there are less items than the page size
        if(item) {
            appendResource(resources[i]);
        }
    }

    showPaginator();
}

/** append one resource to the list **/
function appendResource(value) {
    // clear the loading sign
    $('#loading').remove();

    // create a container inside results
    var $container = $('<div class="dataset"></div>');

    $('#results-container').append($container);

    // Row: header
    var $rowHeader = $('<div class="dataset__row-header"></div>');

    // $rowHeader.append('<img src="' + baseUrl + '/assets/skin/ExpandArrow.png"/>');

    $rowHeader.append(
        '<span class="result-name">' +
            '<a href="' + baseUrl + '/public/showDataResource/' + value.uid + '">' +
                '<span class="fa fa-database"></span>' +
                '&nbsp;' +
                value.name +
            '</a>' +
        '</span>'
    ); // name

    // Row: summary
    var $rowSummary = $('<div class="dataset__row-summary"></div>');

    // resource type
    $rowSummary.append(
        '<span class="dataset__summary-part">' +
            '<label class="dataset__label">' +
                $.i18n.prop('datasets.js.appendresource06') + ': ' +
            '</label>' +
            $.i18n.prop('datasets.js.resourceTypes.' + value.resourceType) +
        '</span>'
    );

    if(value.licenseType) {
        // license type
        $rowSummary.append(
            '<span class="dataset__summary-part">' +
                '<label class="dataset__label">' +
                    $.i18n.prop('datasets.js.appendresource07') + ': ' +
                '</label>' +
                (value.licenseType === 'other' ? $.i18n.prop('datasets.js.licenseTypes.other') : value.licenseType) +
            '</span>'
        );
    }

    if(value.licenseVersion) {
        // license version
        $rowSummary.append(
            '<span class="dataset__summary-part">' +
                '<label class="dataset__label">' +
                    $.i18n.prop('datasets.js.appendresource08') + ': ' +
                '</strong>' +
                value.licenseVersion +
            '</span>'
        );
    }

    if(value.resourceType === 'records') {
        // records link
        $rowSummary.append(
            '<span class="dataset__summary-part">' +
                '<a href="' + biocacheUrl + '/occurrences/search?q=data_resource_uid:' + value.uid + '">' +
                    '<span class="fa fa-list"></span>' +
                    '&nbsp;' +
                    $.i18n.prop('general.btn.viewRecords') + ' (' + value.recordsCount + ')' +
                '</a>' +
            '</span>'
        );
    }

    if(value.resourceType === 'website' && value.websiteUrl) {
        // website link
        $rowSummary.append(
            '<span class="dataset__summary-part">' +
                '<a class="external" target="_blank" href="' + value.websiteUrl + '">' +
                    $.i18n.prop('datasets.js.appendresource11') +
                '</a>' +
            '</span>'
        );
    }

    // Wrap
    $container.append($rowHeader);
    $container.append($rowSummary);
}

/** clear the list and reset values **/
function clearList() {
    resources = [];
    total = 0;
    offset = 0;
    $.bbq.removeState('offset');
}

/** display the current size of the filtered list **/
function updateTotal() {
    total = resources.length;

    $('#resultsReturned').html(
        $.i18n.prop('public.datasets.resultsReturned.showing') +
        ' <strong>' + total + '</strong> ' +
        (total === 1 ? $.i18n.prop('public.datasets.resultsReturned.dataset') : $.i18n.prop('public.datasets.resultsReturned.datasets'))
    );

    $('#downloadButton').attr('title', $.i18n.prop('datasets.js.updatetotal01') + ' ' + total + ' ' + $.i18n.prop('datasets.js.updatetotal02'));
}

function hideTooltip(element) {
    if(element === undefined) { return; }
    if($(element).data('tooltip')) {
        $(element).data('tooltip').hide();
    }
}

/**
  *  Filters
  */

/* applies current filters to the list */
function filterList() {
    // clear list of data sets
    clearList();
    // clear search term
    $('#dr-search').val('');
    // revert to full list
    resources = allResources;

    // aggregate all search criteria
    var searchTerms = [];
    $.each(currentFilters, function(i, obj) {
        if(obj.name === 'contains') {
            searchTerms.push(obj.value.toLowerCase());
        }
    });

    // perform any solr search and wait for result
    if(searchTerms.length > 0) {
        $('.collectory-content').css('cursor', 'wait');
        // build query string from terms
        var query = '';
        $.each(searchTerms, function(i, term) {
            query += (i === 0) ? term : '&fq=text:' + term;
        });
        // do search
        $.ajax({ url: baseUrl + '/public/dataSetSearch?q=' + query,
            success: function(uids) {
                applyFilters(uids);
                $('.collectory-content').css('cursor', 'default');
            }
        });
    } else {
        // do it now
        applyFilters();
    }
}

function applyFilters(uidList) {
    // apply each filter in effect
    $.each(currentFilters, function(i, obj) {
        filterBy(obj, uidList);
    });
    updateTotal();
    calculateFacets();
    showFilters();
    displayPage();
}

/** applies a single filter to the list **/
function filterBy(filter, uidList) {
    var newResourcesList = [];
    var facet = facets[filter.name];
    $.each(resources, function(index, resource) {

        // filter by has
        if(facet.action === 'has') {
            if(resource[filter.name] && resource[filter.name].indexOf(filter.value) > 0) {
                newResourcesList.push(resource);
            }
        } else if(facet.action === 'containedIn') {
            // filter by search results
            if(uidList.length === 1 && resource.uid === uidList[0]) { // don't know why this is needed - seems to be a bug
                newResourcesList.push(resource);
            } else if(uidList && $.inArray(resource.uid, uidList) >= 0) {
                newResourcesList.push(resource);
            }
        } else if(resource[filter.name] === filter.value || (filter.value === 'noValue' && resource[filter.name] === null)) {
            // filter by equality
            newResourcesList.push(resource);
        }
    });
    resources = newResourcesList;
}

/** displays the current filters **/
function showFilters() {
    $('#currentFilters').remove();

    if(currentFilters.length === 0) {
        return;
    }

    $('#currentFilterHolder').append(
        '<p id="currentFilters" class="active-filters">' +
            '<span class="active-filters__title">' +
                $.i18n.prop('public.datasets.drsearch.currentfilters') +
            '</span>' +
            ': &nbsp;' +
        '</p>'
    );

    var container = $('#currentFilters');

    currentFilters.forEach(function(obj) {
        var displayValue = obj.name === 'contains' ? obj.value : labelFor(obj.value);
        var onclick = 'removeFilter(\'' + obj.name + '\',\'' + obj.value + '\',this);return false;';

        container.append(
            '<span class="active-filters__filter">' +
                '<span class="active-filters__label">' +
                    labelFor(obj.name) + ': ' + displayValue +
                '</span>' +
                '&nbsp;<span class="fa fa-close active-filters__close-button" onclick="' + onclick + '">' +
                '</span>' +
            '</span>'
        );
    });

    if(currentFilters.length > 1) {
        container.append(
            '<span class="active-filters__clear-all-button" onclick="reset()">' +
                $.i18n.prop('general.btn.clearAll.label') +
            '</span>'
        );
    }
}

/** adds a filter and re-filters list**/
function addFilter(facet, value, element) {
    // hide tooltip
    hideTooltip(element);

    if(findInCurrentFilters(facet, value) >= 0) {
        // duplicate of existing filter so do nothing
        return;
    }

    if(value === 'noValue') {
        value = '';
    }

    var filter = { name: facet, value: value, action: facets[facet].action };
    currentFilters.push(filter);
    serialiseFiltersToHash();
    filterList();
}

/** removes a filter and re-filters list**/
function removeFilter(facet, value, element) {
    var idx = findInCurrentFilters(facet, value);
    if(idx > -1) {
        currentFilters.splice(idx, 1);
    }
    // make sure no tooltips are left visible
    hideTooltip(element);
    serialiseFiltersToHash();
    filterList();
}

function findInCurrentFilters(facet, value) {
    var idx = -1;
    $.each(currentFilters, function(index, obj) {
        if(obj.name === facet && obj.value === value) {
            idx = index;
        }
    });
    return idx;
}

/** ***********************************************\
 *  Pagination
 \*************************************************/
/** build and append the pagination widget **/
function showPaginator() {
    if(total <= pageSize()) {
        // no pagination required
        $('div#navLinks').html('');
        return;
    }
    var currentPage = Math.floor(offset / pageSize()) + 1;
    var maxPage = Math.ceil(total / pageSize());
    var $pagination = $('<div class="pagination"></div>');

    // add prev
    if(offset > 0) {
        $pagination.append(
            '<a href="javascript:prevPage();" class="pagination__step">' +
                $.i18n.prop('general.paginate.prev') +
            '</a>'
        );
    }

    for(var i = 1; i <= maxPage && i < 20; i++) {
        if(i === currentPage) {
            $pagination.append('<span class="pagination__step pagination__step--current currentPage disabled">' + i + '</span>');
        } else {
            $pagination.append('<a href="javascript:gotoPage(' + i + ');" class="pagination__step">' + i + '</a>');
        }
    }

    // add next
    if((offset + pageSize()) < total) {
        $pagination.append(
            '<a href="javascript:nextPage();" class="pagination__step">' +
                $.i18n.prop('general.paginate.next') +
            '</a>'
        );
    }

    $('div#navLinks').html($pagination);
}

/** get current page size **/
function pageSize() {
    return parseInt($('select#per-page').val());
}

/** show the specified page **/
function gotoPage(pageNum) {
    // calculate new offset
    offset = (pageNum - 1) * pageSize();
    displayPage();
}

/** show the previous page **/
function prevPage() {
    // calculate new offset
    offset -= pageSize();
    displayPage();
}

/** show the next page **/
function nextPage() {
    // calculate new offset
    offset += pageSize();
    $.bbq.pushState({ offset: offset });
    displayPage();
}

/** action for changes to the pageSize widget */
function onPageSizeChange() {
    offset = 0;
    $.bbq.pushState({ pageSize: pageSize() });
    displayPage();
}

/** action for changes to the sort widget */
function onSortChange() {
    offset = 0;
    $.bbq.pushState({ sort: $('select#sort').val() });
    resources.sort(comparator);
    displayPage();
}

/** action for changes to the sort order widget */
function onDirChange() {
    offset = 0;
    $.bbq.pushState({ dir: $('select#dir').val() });
    resources.sort(comparator);
    displayPage();
}

/* comparator for data resources */
function comparator(a, b) {
    var va, vb;
    var sortBy = $('select#sort').val();
    switch($('select#sort').val()) {
        case 'name':
            va = a.name;
            vb = b.name;
            break;
        case 'type':
            va = a.resourceType;
            vb = b.resourceType;
            break;
        case 'license':
            va = a.licenseType;
            vb = b.licenseType;
            break;
        default:
            va = a.name;
            vb = b.name;
    }
    if(va === vb) {
        // sort on name
        va = a.name;
        vb = b.name;
    }
    // use lowercase
    va = va === null ? '' : va.toLowerCase();
    vb = vb === null ? '' : vb.toLowerCase();

    if($('select#dir').val() === 'ascending') {
        return (va < vb ? -1 : (va > vb ? 1 : 0));
    } else {
        return (vb < va ? -1 : (vb > va ? 1 : 0));
    }
}

/** ***********************************************\
 *  Facet management
 \*************************************************/

/* this holds the display text for all values of facets - keyed by the facet value */
// the default if not in this list is to capitalise the record value
// also holds display text for the facet categories
var displayText = {
    ccby: 'datasets.js.displaytext01',
    ccbync: 'datasets.js.displaytext02',
    ccbysa: 'datasets.js.displaytext03',
    ccbyncsa: 'datasets.js.displaytext04',
    other: 'datasets.js.displaytext05',
    noLicense: 'datasets.js.displaytext06',
    noValue: 'datasets.js.displaytext07',
    '3.0': 'datasets.js.displaytext08',
    '2.5': 'datasets.js.displaytext09',
    dataAvailable: 'datasets.js.displaytext10',
    linksAvailable: 'datasets.js.displaytext11',
    inProgress: 'datasets.js.displaytext12'
};

/* Map of dataset attributes to treat as facets */
var facets = {
    resourceType: {
        name: 'resourceType', labelProperty: 'datasets.js.facets01'
    },
    licenseType: {
        name: 'licenseType', labelProperty: 'datasets.js.facets02'
    },
    licenseVersion: {
        name: 'licenseVersion', labelProperty: 'datasets.js.facets03'
    },
    status: {
        name: 'status', labelProperty: 'datasets.js.facets04'
    },
    contentTypes: {
        name: 'contentTypes', action: 'has', labelProperty: 'datasets.js.facets06'
    },
    contains: {
        name: 'contains', action: 'containedIn', labelProperty: 'datasets.js.facets08'
    },
    institution: {
        name: 'institution', labelProperty: 'datasets.js.facets09'
    }
};

/** calculate facet totals and display them **/
function calculateFacets() {
    $('#dsFacets div').remove();

    $.each(facets, function(i, obj) {
        if(obj.name !== 'contains') {
            var list = sortByCount(getSetOfFacetValuesAndCounts(obj));
            // don't show if only one value
            if(list.length > 1) {
                $('#dsFacets').append(displayFacet(obj, list));
            }
        }
    });
}

/** Returns a map of distinct values of the facet and the number of each for the current filtered list **/
function getSetOfFacetValuesAndCounts(facet) {
    var map = {};
    $.each(resources, function(index, value) {
        var attr = value[facet.name];
        if(facet.action === 'has') {
            if(attr) {
                // treat each value in the json list as a facet value
                $.each($.parseJSON(attr), function(i, v) {
                    addToMap(map, v);
                });
            }
        } else {
            if(!attr) {
                attr = 'noValue';
            }
            addToMap(map, attr);
        }
    });
    return map;
}
/* add the count of an value to the map */
function addToMap(map, attr) {
    if(map[attr] === undefined) {
        map[attr] = 1;
    } else {
        map[attr]++;
    }
}

var SHOWN_FACET_VALUE_COUNT = 5;

/** Creates DOM elements to represent the facet **/
function displayFacet(facet, list) {
    // add facet header
    var $header = $(
        '<h4 class="search-facet__header">' +
        $.i18n.prop(facet.labelProperty) +
        '</h4>'
    );

    // add each value
    var $list = $('<ul class="erk-ulist"></ul>');

    list.slice(0, SHOWN_FACET_VALUE_COUNT).forEach(function(value) {
        $list.append(displayFacetValue(facet, value, false));
    });

    // remaining values are added as hidden
    if(list.length > SHOWN_FACET_VALUE_COUNT) {
        $list.append(moreLink());

        list.slice(SHOWN_FACET_VALUE_COUNT).forEach(function(value) {
            $list.append(displayFacetValue(facet, value, true));
        });
    }

    // wrap
    var $div = $('<div class="datasets-facet"></div>');

    $div.append($header);
    $div.append($list);

    return $div;
}

function moreLink() {
    var $more = $(
        '<li class="erk-ulist__item">' +
            '<a class="erk-link" href="#">' +
                $.i18n.prop('general.facets.showMore') +
            '</a>' +
        '</li>'
    );
    $more.click(function() {
        // make following items visible and add a 'less' link
        $(this).parent().find('li').css('display', 'list-item');
        // add 'less' link
        $(this).parent().append(lessLink());
        // remove this link
        $(this).remove();
    });
    return $more;
}

function lessLink() {
    var $less = $(
        '<li class="erk-ulist__item">' +
            '<a class="erk-link" href="#">' +
                $.i18n.prop('general.facets.showLess') +
            '</a>' +
        '</li>'
    );
    $less.click(function() {
        // make items > 5 hidden and add a 'more' link
        $(this).parent().find('li:gt(4)').css('display', 'none');
        // add 'more' link
        $(this).parent().append(moreLink());
        // remove this link
        $(this).remove();
    });
    return $less;
}

function displayFacetValue(facet, value, hide) {
    var attr = value.facetValue;
    var count = value.count;

    var $item = $(
        '<li class="erk-ulist__item">' +
        '</li>'
    );

    if(hide) {
        $item.css('display', 'none');
    }

    var $link = $(
        '<span class="erk-link">' +
            '<span class="fa fa-square-o"></span>' +
            '&nbsp;' +
            labelFor(attr) + ' (' + count + ')' +
        '</span>'
    );

    $link.click(function() {
        addFilter(facet.name, attr, this);
    });

    $item.append($link);

    return $item;
}

/* sorts a map in desc order based on the map values */
function sortByCount(map) {
    // turn it into an array of maps
    var list = [];
    for(var item in map) {
        list.push({ facetValue: item, count: map[item] });
    }
    list.sort(function(a, b) {
        return b.count - a.count;
    });
    return list;
}

/* returns a display label for the facet */
function labelFor(item) {
    var labelProperty = displayText[item];

    if(labelProperty === undefined) {
        // just capitalise - TODO: break out camel case
        return capitalise(item);
    } else {
        return $.i18n.prop(labelProperty);
    }
}

/* capitalises the first letter of the passed string */
function capitalise(item) {
    if(!item) {
        return item;
    }
    if(item.length === 1) {
        return item.toUpperCase();
    }
    return item.substring(0, 1).toUpperCase() + item.substring(1, item.length);
}

/** ***********************************************\
 *  Download csv of data sets
\*************************************************/
function wireDownloadButton() {
    $('#downloadButton').click(function() {
        var uids = [];
        $.each(resources, function(i, obj) {
            uids.push(obj.uid);
        });
        document.location.href = baseUrl + '/public/downloadDataSets?uids=' + uids.join(',');
        return false;
    });
}

/** ***********************************************\
 *  Searching
\*************************************************/
function wireSearchLink() {
    $('#dr-search-link').click(function() {
        if($('#dr-search').val() !== '') {
            addFilter('contains', $('#dr-search').val());
        }
    });
    $('#dr-search').keypress(function(event) {
        if(event.which === 13 && $('#dr-search').val() !== '') {
            event.preventDefault();
            addFilter('contains', $('#dr-search').val());
        }
    });
}

function extractListOfUidsFromSearchResults(data) {
    var list = [];
    $.each(data.searchResults.results, function(i, obj) {
        var uri = obj.guid;
        var slash = uri.lastIndexOf('/');
        if(slash > 0) {
            list.push(uri.substr(slash + 1, uri.length - slash));
        }
    });
    return list;
}

/** ***********************************************\
 *  State handling
 \*************************************************/
/* called on page load to set the initial state */
function setStateFromHash() {
    var hash = $.deparam.fragment(true);
    if(hash.pageSize) {
        $('select#per-page').val(hash.pageSize);
    }
    if(hash.sort) {
        $('select#sort').val(hash.sort);
    }
    if(hash.dir) {
        $('select#dir').val(hash.dir);
    }
    if(hash.filters) {
        deserialiseFilters(hash.filters);
    }
    if(hash.offset && hash.offset < total) {
        offset = hash.offset;
    }
}
/* puts the current filter state into the hash */
function serialiseFiltersToHash() {
    var str = '';
    $.each(currentFilters, function(i, obj) {
        str += obj.name + ':' + obj.value + ';';
    });
    if(str.length === 0) {
        $.bbq.removeState('filters');
    } else {
        str = str.substr(0, str.length - 1);
        $.bbq.pushState({ filters: str });
    }
}
/* reinstates current filters from the specified hash */
function deserialiseFilters(filters) {
    var list = filters.split(';');
    $.each(list, function(i, obj) {
        var bits = obj.split(':');
        addFilter(bits[0], bits[1]);
    });
}
/* sets the controls for the heart of the sun */
function reset() {
    currentFilters = [];
    resources = allResources;
    offset = 0;
    $('select#per-page').val(20);
    $('select#sort').val('name');
    $('select#dir').val('asc');
    $.bbq.removeState();
    updateTotal();
    calculateFacets();
    showFilters();
    displayPage();
}
