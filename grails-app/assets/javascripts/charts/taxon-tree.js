/** *** external services & links *****/
// an instance of the collections app - used for name lookup services
// TODO search and replace this urls from values in COLLECTORY_CONF
var collectionsUrl = 'http://fake-collections.ala.org.au';  // should be overridden from config by the calling page
// an instance of the biocache web services app - used for facet and taxonomic breakdowns
var biocacheServicesUrl = 'http://fake-biocache.ala.org.au/ws';  // should be overridden from config by the calling page
// an instance of a web app - used to display search results
var biocacheWebappUrl = 'http://fake-biocache.ala.org.au';  // should be overridden from config by the calling page
/* ------------------------- TAXON TREE -----------------------------*/

function initTaxonTree(treeOptions) {
    var query = treeOptions.query ? treeOptions.query : buildQueryString(treeOptions.instanceUid);

    var targetDivId = treeOptions.targetDivId ? treeOptions.targetDivId : 'tree';
    var $container = $('#' + targetDivId);
    var title = treeOptions.title || $.i18n.prop('charts.taxonPie.exploreRecords');
    if(treeOptions.title !== '') {
        $container.append($('<h4>' + title + '</h4>'));
    }
    var $treeContainer = $('<div id="treeContainer"></div>').appendTo($container);
    $treeContainer.resizable({
        maxHeight: 900,
        minHeight: 100,
        maxWidth: 900,
        minWidth: 500
    });
    var $tree = $('<div id="taxaTree"></div>').appendTo($treeContainer);
    $tree.bind('after_open.jstree', function(event, data) {
        var children = $.jstree._reference(data.rslt.obj)._get_children(data.rslt.obj);
        // automatically open if only one child node
        if(children.length === 1) {
            $tree.jstree('open_node', children[0]);
        }
        // adjust container size
        var fullHeight = $tree[0].scrollHeight;
        if(fullHeight > $tree.height()) {
            fullHeight = Math.min(fullHeight, 700);
            $treeContainer.animate({
                height: fullHeight
            });
        }
    })
        .bind('select_node.jstree', function(event, data) {
            // click will show the context menu
            $tree.jstree('show_contextmenu', data.rslt.obj);
        })
        .bind('loaded.jstree', function(event, data) {
            // get rid of the anchor click handler because it hides the context menu (which we are 'binding' to click)
            // $tree.undelegate("a", "click.jstree");
            $tree.jstree('open_node', '#top');
        })
        .jstree({
            json_data: {
                data: {
                    'data': 'Kingdoms',
                    'state': 'closed',
                    'attr': {
                        'rank': 'kingdoms',
                        'id': 'top'
                    }
                },
                ajax: {
                    url: function(node) {
                        var rank = $(node).attr('rank');
                        var u = urlConcat(biocacheServicesUrl, '/breakdown.json?q=') + query + '&rank=';
                        if(rank === 'kingdoms') {
                            u += 'kingdom';  // starting node
                        } else {
                            u += rank + '&name=' + $(node).attr('id');
                        }
                        return u;
                    },
                    dataType: 'jsonp',
                    success: function(data) {
                        var nodes = [];
                        var rank = data.rank;
                        $.each(data.taxa, function(i, obj) {
                            var label = obj.label ? obj.label : $.i18n.prop('general.value.missing');
                            label += ' - ' + obj.count;
                            if(rank === 'species') {
                                nodes.push({
                                    'data': label,
                                    'attr': {
                                        'rank': rank,
                                        'id': obj.label
                                    }
                                });
                            } else {
                                nodes.push({
                                    'data': label,
                                    'state': 'closed',
                                    'attr': {
                                        'rank': rank,
                                        'id': obj.label
                                    }
                                });
                            }
                        });
                        return nodes;
                    },
                    error: function(xhr, text_status) {
                        // alert(text_status);
                    }
                }
            },
            core: {
                animation: 200,
                open_parents: true
            },
            themes: {
                theme: treeOptions.theme || 'default',
                icons: treeOptions.icons || false,
                url: treeOptions.serverUrl + '/js/themes/' + (treeOptions.theme || 'default') + '/style.css'
            },
            checkbox: {
                override_ui: true
            },
            contextmenu: {
                select_node: false,
                show_at_node: false,
                items: {
                    records: {
                        label: '<span class="fa fa-list"></span>&nbsp;' + $.i18n.prop('charts.taxonPie.viewRecords'),
                        action: function(obj) {
                            showRecords(obj, query);
                        }
                    },
                    bie: {
                        label: '<span class="fa fa-search"></span>&nbsp;' + $.i18n.prop('charts.taxonPie.viewSpecies'),
                        action: function(obj) {
                            showBie(obj);
                        }
                    },
                    create: false,
                    rename: false,
                    remove: false,
                    ccp: false }
            },
            plugins: ['json_data', 'themes', 'ui', 'contextmenu']
        });
}

/**
 * Go to occurrence records for selected node
 */
function showRecords(node, query) {
    var recordsUrl = urlConcat(biocacheWebappUrl, '/occurrences/search?q=') + query;
    var rank = node.attr('rank');
    var name = node.attr('id');
    if(rank === 'kingdoms') {
        recordsUrl += '&fq=rank:"kingdom"';
    } else if(!name) {
        recordsUrl += '&fq=rank:' + rank;
    } else {
        recordsUrl += '&fq=' + rank + ':' + node.attr('id');
    }
    document.location.href = recordsUrl;
}

/**
 * Go to 'species' page for selected node
 */
function showBie(node) {
    var sppUrl = COLLECTORY_CONF.alaRoot + '/bie-hub/search?';
    var rank = node.attr('rank');
    var name = node.attr('id');
    if(rank === 'kingdoms') {
        sppUrl += '&fq=rank:"kingdom"';
    } else if(!name) {
        sppUrl += '&fq=rank:' + rank;
    } else {
        sppUrl += 'q=' + node.attr('id') + '&fq=rank:' + rank;
    }
    document.location.href = sppUrl;
}

/* ------------------------- UTILITIES ------------------------------ */
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
 * returns the appropriate facet name for the uid - to build
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

// TODO Find out whether or not this is used anywhere.
/**
 * returns the appropriate context for the uid - to build
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
