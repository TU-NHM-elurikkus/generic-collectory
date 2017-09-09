var COLLECTORY_CONF;  // Populated by _global.gsp layout inline script
var altMap; // Populated by some of the templates
var myMap;
var baseUrl; // The server base url

// represents the number in 'all' collections - used in case the total number changes on an ajax request
var maxCollections = 0;

var markers = new L.FeatureGroup();

$(document).ready(function() {
    updateList();
    myMap = L.map('map_canvas', {
        center: [58.7283, 25.4169192],
        zoom: 7
    });

    L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution:
            '&copy; ' +
            '<a href="http://www.openstreetmap.org/copyright">' +
                'OpenStreetMap' +
            '</a>' +
            ', &copy;' +
            '<a href="https://carto.com/attribution">' +
                'CARTO' +
            '</a>'
    }).addTo(myMap);

    updateMap('all');

    $('#map-tab-header').on('shown.bs.tab', function(e) {
        myMap.invalidateSize(true);
        myMap.setView([58.7283, 25.4169192], 7);
    });
});

/**
 * i18n
*/
$.i18n.properties({
    name: 'messages',
    path: COLLECTORY_CONF.contextPath + '/messages/i18n/',
    mode: 'map',
    language: COLLECTORY_CONF.locale // default is to use browser specified locale
});

if(altMap === undefined) {
    altMap = false;
}

function updateMap(filters) {
    var mapIcon = L.icon({
        iconUrl: 'assets/marker.png',
        iconSize: [25, 25]
    });

    var queryUrl = 'http://ala-test.ut.ee/collectory/public/mapFeatures?filters=' + filters;

    $.get(queryUrl, function(data) {
        var geomObj;
        var geomObjects = data.features;
        for(geomObj of geomObjects) {
            var mapMarker = L.marker(geomObj.geometry.coordinates.reverse(), { icon: mapIcon }).addTo(myMap);
            mapMarker.bindPopup(outputSingleFeature(geomObj));
            markers.addLayer(mapMarker);
        }
    });
    myMap.addLayer(markers);
}

/**
* Regenerate list of collections - update total number
*/
function updateList() {
    $.get('http://ala-test.ut.ee/collectory/public/mapFeatures?filters=all', function(data) {
        var features = data.features;

        // Populate general tooltip
        var selectedFrom = $.i18n.prop('map.js.collectionstotal', features.length);
        // update display of number of features
        var selectedFilters = $('button.selected')[0].id;
        if(selectedFilters !== 'all') {
            selectedFrom = features.length + ' ' + $.i18n.prop('map.js.' + selectedFilters) + ' ' +
                $.i18n.prop('map.js.collections') + '.';
        }
        var innerFeatures = '';
        switch(features.length) {
            case 0: innerFeatures = $.i18n.prop('map.js.nocollectionsareselected'); break;
            case 1: innerFeatures = $.i18n.prop('map.js.onecollectionisselected'); break;
            default: innerFeatures = selectedFrom; break;
        }

        $('#numFeatures').html(innerFeatures);

        var unMappable = [];

        for(var geomObj of features) {
            if(!geomObj.properties.isMappable) {
                unMappable.push(geomObj);
            }
        }

        var unMappedText = '';

        switch(unMappable.length) {
            case 0: unMappedText = ''; break;
            case 1: unMappedText = $.i18n.prop('map.js.collectioncannotbemapped'); break;
            default: unMappedText = $.i18n.prop('map.js.collectionscannotbemapped', unMappable.length); break;
        }

        $('#numUnMappable').html(unMappedText);

        // update the potential total
        maxCollections = Math.max(features.length, maxCollections);

        if(!$('div#all').hasClass('inst')) {  // don't change text if showing institutions
            $('#collections-total').html($.i18n.prop('public.map3.link.showall', maxCollections));
        }

        // update display of number of features
        switch(features.length) {
            case 0: innerFeatures = $.i18n.prop('map.js.nocollectionsareselected'); break;
            case 1: innerFeatures = features.length + ' ' + $.i18n.prop('map.js.collectionislisted'); break;
            default: innerFeatures = $.i18n.prop('map.js.collectionsarelistedalphabetically'); break;
        }
        $('span#numFilteredCollections').html(innerFeatures);

        // group by institution
        var sortedParents = groupByParent(features, true);
        var innerHtml = '';
        var orphansHtml = '';

        for(var j = 0; j < sortedParents.length; j++) {
            var collList = sortedParents[j];
            // show institution - use name of institution from first collection
            var firstColl = collList[0];
            var content;
            if(!firstColl.properties.instName && firstColl.properties.entityType === 'Collection') {
                content =
                    '<span class="highlight">' +
                        '<span class="fa fa-archive"></span>' +
                        '&nbsp;' +
                        $.i18n.prop('collections.with.no.institution') +
                    '</span>';
            } else if(!firstColl.properties.instName && firstColl.properties.entityType === 'DataProvider') {
                content =
                    '<span class="highlight">' +
                        '<span class="fa fa-database"></span>' +
                        '&nbsp;' +
                        $.i18n.prop('dataproviders.list') +
                    '</span>';
            } else {
                content =
                    '<a class="highlight" href="' + baseUrl + '/public/show/' + firstColl.properties.instUid + '">' +
                        '<span class="fa fa-university"></span>' +
                        '&nbsp;' +
                        firstColl.properties.instName +
                    '</a>';
            }

            content =
                '<li class="indented-list-item">' +
                    content +
                    '<ul class="list-unstyled">';

            // show each collection
            for(var coll of collList) {
                var acronym = '';

                if(coll.properties.acronym) {
                    acronym = ' (' + coll.properties.acronym + ')';
                }

                content +=
                    '<li class="indented-list-item">' +
                        '<a href="' + baseUrl + '/public/show/' + coll.properties.uid + '">' +
                            '<span class="fa fa-archive"></span>' +
                            '&nbsp;' +
                            coll.properties.name + acronym +
                        '</a>' +
                    '</li>';
            }

            content += '</ul></li>';
            if(!firstColl.properties.instName) {
                orphansHtml = content;
            } else {
                innerHtml += content;
            }
        }
        innerHtml += orphansHtml;
        $('ul#filtered-list').html(innerHtml);
    });
}

/**
* Generate html for a single collection
*/
function outputSingleFeature(feature) {
    if($('div#all').hasClass('inst') && $('div#all').hasClass('selected')) { // simple list if showing institutions
        return outputSingleInstitution(feature);
    } else {
        var address = '';
        var acronym = '';
        var instLink;
        var desc = feature.properties.desc;

        if(feature.properties.address) {
            address = feature.properties.address;
        }
        if(feature.properties.acronym) {
            acronym = ' (' + feature.properties.acronym + ')';
        }
        if(feature.properties.instUid) {
            instLink =
                outputInstitutionOnOwnLine(feature) +
                '<br />' +
                '<a style="margin-left:5px;" href="' + feature.properties.url + '">' +
                    '<span class="fa fa-archive"></span>' +
                    '&nbsp;' +
                    getShortCollectionName(feature) +
                '</a>';
        } else {
            instLink =
                '<a href="' + feature.properties.url + '">' +
                    feature.properties.name +
                '</a>';
        }

        var popUpHtml =
            '<div class="map-popup">' +
                instLink +
                acronym +
                '<div class="address">' +
                    address +
                '</div>' +
                '<hr />' +
                '<div class="desc">' +
                    desc +
                '</div>' +
            '</div>';
        return popUpHtml;
    }
}

/**
* Generate html for a single institution
*/
function outputSingleInstitution(feature) {
    var address = '';
    var acronym = '';

    if(feature.properties.address) {
        address = feature.properties.address;
    }
    if(feature.properties.instAcronym) {
        acronym = ' (' + feature.properties.instAcronym + ')';
    }
    var content =
        '<a class="highlight" href="' + baseUrl + '/public/show/' + feature.properties.instUid + '">' +
            feature.properties.instName +
        '</a>' +
        acronym +
        '<div class="address">' +
            address +
        '</div>';
    return content;
}

/**
* Group features by their parent institutions
* groupOrphans = true -> orphans are grouped in zz-other rather than interspersed
*/
function groupByParent(features, groupOrphans) {
    // build 'map' of institutions and orphan collections
    var parents = {};
    for(var c = 0; c < features.length; c++) {
        var collectionFeature = features[c];
        var instUid = collectionFeature.properties.instUid;
        if(!instUid && groupOrphans) {
            instUid = 'zz-other';
        }
        if(!instUid) {
            // add as orphan collection
            parents[collectionFeature.properties.uid] = collectionFeature;
        } else {
            var collList = parents[instUid];
            if(!collList) {
                // create new inst entry
                collList = [];
                collList.push(collectionFeature);
                parents[instUid] = collList;
            } else {
                // add to existing inst entry
                collList.push(collectionFeature);
            }
        }
    }
    // move to an array so we can sort
    var sortedParents = [];
    for(var key in parents) {
        sortedParents.push(parents[key]);
    }
    // sort
    sortedParents.sort(function(a, b) {
        var aname = getName(a);
        var bname = getName(b);
        if(aname < bname) {
            return -1;
        } else if(aname > bname) {
            return 1;
        } else {
            return 0;
        }
    });
    return sortedParents;
}

/**
* Generate html for a clustered feature
*/
function outputClusteredFeature(feature) {
    var sortedParents = groupByParent(feature.cluster, false);
    // output the parents list
    var content = '';
    if($('div#all').hasClass('inst') && $('div#all').hasClass('selected')) { // simple list if showing institutions
        content += outputMultipleInstitutions(sortedParents);
    } else {
        // adopt different collapsing strategies based on number to display
        var strategy;
        var parentsCount = sortedParents.length;

        if(parentsCount === 1) {
            strategy = 'veryVerbose';
        } else if(parentsCount < 5) {
            strategy = 'verbose';
        } else if(parentsCount < 7) {
            strategy = 'brief';
        } else {
            strategy = 'terse';
        }

        // show them
        for(var k = 0; k < sortedParents.length; k++) {
            var item = sortedParents[k];
            if(item instanceof Array) {
                content += outputMultipleCollections(item, strategy);
            } else {
                content += outputCollectionOnOwnLine(item);
            }
        }
    }

    var result =
        '<ul>' +
            content +
        '</ul>';
    return result;
}

/**
* Generate html for a list of institutions
*/
function outputMultipleInstitutions(parents) {
    var content = '';
    for(var i = 0; i < parents.length; i++) {
        var obj = parents[i];
        // use name of institution from first collection
        if(obj instanceof Array) { obj = obj[0]; }
        // skip collections with no institution
        var name = obj.properties.instName;
        if(!name) {
            content +=
                '<li>' +
                    '<a class="highlight" href="' + baseUrl + '/public/show/' + obj.properties.instUid + '">' +
                        getTightInstitutionName(obj, 55) +
                    '</a>' +
                '</li>';
        }
    }
    return content;
}

/**
* Grab name from institution
*/
function getName(obj) {
    var newObj;

    if($.isArray(obj)) {
        newObj = obj[0];
    } else {
        newObj = obj;
    }

    if(newObj.properties && newObj.properties.name && newObj.properties.entityType !== 'Collection') {
        return obj[0].properties.name;
    }

    var name = newObj.properties.instName;

    // remove leading 'The ' so the institutions sort by first significant letter
    if(name && name.length > 4 && name.substr(0, 4) === 'The ') {
        name = name.substr(4);
    }
    return name;
}

/**
* Build html for multiple collection for an institution
*/
function outputMultipleCollections(obj, strategy) {
    // use name of institution from first collection
    var content;
    var limit = 4;
    if(strategy === 'brief') { limit = 2; }
    if(strategy === 'terse') { limit = 0; }
    if(strategy === 'veryVerbose') { limit = 10; }
    if(obj.length < limit) {
        content = '<li>' + outputInstitutionOnOwnLine(obj[0]) + '<ul>';
        for(var c = 0; c < obj.length; c++) {
            content += outputCollectionOnOwnLine(obj[c]);
        }
        content += '</ul>';
    } else {
        if(obj.length === 1) {
            content = outputCollectionWithInstitution(obj[0], strategy);
        } else {
            content = '<li>' + outputInstitutionOnOwnLine(obj[0]) + ' - ' + obj.length + ' ' + $.i18n.prop('map.js.collections') + '</li>';
        }
    }
    return content;
}

/**
* Abbreviates institution name if long (assumes inst is present)
*/
function getTightInstitutionName(obj, max) {
    if(obj.properties.instName.length > max && obj.properties.instAcronym) {
        return obj.properties.instAcronym;
    } else {
        return obj.properties.instName;
    }
}

/**
* Abbreviates collections name by removing leading institution name
*/
function getShortCollectionName(obj) {
    var inst = obj.properties.instName;
    var shortName = obj.properties.name;
    if(!inst && inst.match('^The ') === 'The ') {
        inst = inst.substr(4);
    }
    if(!inst && obj.properties.name.match('^' + inst) === inst && // coll starts with the inst name
            inst !== shortName) { // but not if inst name is the whole of the coll name (ie they are the same)
        shortName = obj.properties.name.substr(inst.length);
        // check for stupid collection names
        if(shortName.substr(0, 2) === ', ') {
            shortName = shortName.substr(2);
        }
    }
    return shortName;
}

/**
* Build html for an institution on its own line
*/
function outputInstitutionOnOwnLine(obj) {
    var instLink =
        '<a class="highlight" href="' + baseUrl + '/public/show/' + obj.properties.instUid + '">' +
            '<span class="fa fa-university"></span>' +
            '&nbsp;' +
            getTightInstitutionName(obj, 55) +
        '</a>';
    return instLink;
}

/**
* Build html for a single collection with an institution
*/
function outputCollectionWithInstitution(obj, strategy) {
    var max = 60;
    var acronym = '';
    if(!obj.properties.acronym) {
        acronym = ' (' + obj.properties.acronym + ')';
    }
    var instLink = '<a class="highlight" href="' + baseUrl + '/public/show/' + obj.properties.instUid + '">';
    var briefInst = getTightInstitutionName(obj, 25);
    var briefInstLink = instLink + briefInst + '</a>';
    var instName = obj.properties.instName;
    var collName = obj.properties.name;
    var url = obj.properties.url

    var result;

    if(strategy === 'verbose') {
        var linkName;

        if(collName.length + acronym.length > max) {
            // drop acronym
            linkName = collName;
        } else {
            linkName = collName + acronym;
        }

        result =
            instLink +
                instName +
            '</a>' +
            '<ul>' +
                '<li>' +
                    '<a href="' + url + '">' +
                        linkName +
                    '</a>' +
                '</li>' +
            '</ul>';
    } else {
        // present both in one line
        // try full inst + full coll + acronym
        if(instName.length + collName.length + acronym.length < max) {
            result =
                instLink +
                    instName +
                '</a>' +
                ' - ' +
                '<a href="' + url + '">' +
                    collName + acronym +
                '</a>';
        // try full inst + short coll + acronym
        } else if(instName.length + getShortCollectionName(obj).length + acronym.length < max) {
            result =
                instLink +
                    instName +
                '</a>' +
                ' - ' +
                '<a href="' + url + '">' +
                    getShortCollectionName(obj) + acronym +
                '</a>';
        // try full inst + short coll
        } else if(instName.length + getShortCollectionName(obj).length < max) {
            result =
                instLink +
                    instName +
                '</a>' +
                ' - ' +
                '<a href="' + url + '">' +
                    getShortCollectionName(obj) +
                '</a>';
        // try acronym of inst + full coll + acronym
        } else if(briefInst.length + collName.length + acronym.length < max) {
            result =
                briefInstLink +
                ' - ' +
                '<a href="' + url + '">' +
                    collName +
                '</a>';
        // try acronym of inst + full coll
        } else if(briefInst.length + collName.length < max) {
            result =
                briefInstLink +
                ' - ' +
                '<a href="' + url + '">' +
                    collName +
                '</a>';
        // try acronym of inst + short coll
        } else if(briefInst.length + getShortCollectionName(obj).length < max) {
            result =
                briefInstLink +
                ' - ' +
                '<a href="' + url + '">' +
                    getShortCollectionName(obj) +
                '</a>';
        // try acronym of inst + coll acronym
        } else if(acronym !== '') {
            result =
                briefInstLink +
                ' - ' +
                '<a href="' + url + '">' +
                    acronym +
                '</a>';
        // try full inst + 1 collection
        } else if(instName.length < max - 12) {
            result =
                instLink +
                    instName +
                '</a>' +
                ' - 1 ' + $.i18n.prop('collection');
        // try acronym of inst + 1 collection (worst case!)
        } else {
            result = briefInstLink + ' - 1 ' + $.i18n.prop('collection');
        }
    }
    return '<li>' + result + '</li>';
}

/**
* Build html for a collection on its own line
*/
function outputCollectionOnOwnLine(obj) {
    var max = 60;
    // build acronym
    var acronym = '';
    if(!obj.properties.acronym) {
        acronym = ' <span>(' + obj.properties.acronym + ')</span>';
    }

    /* try combos in order of preference */
    var name;
    // try full name + acronym
    if(obj.properties.name.length + acronym.length < max / 2) { // favour next option unless very short
        name = obj.properties.name + acronym;

    // try short name + acronym
    } else if(getShortCollectionName(obj).length + acronym.length < max) {
        name = getShortCollectionName(obj) + acronym;

    // try name
    } else if(obj.properties.name.length < max) {
        name = obj.properties.name;

    // try short name
    } else if(getShortCollectionName(obj).length < max) {
        name = getShortCollectionName(obj);

    // stuck with name
    } else {
        name = obj.properties.name;
    }

    var result =
        '<li>' +
            '<a href="' + obj.properties.url + '">' +
                name +
            '</a>' +
        '</li>';
    return result;
}

/**
* Handle filter button click. Doesn't actually toggle.
*/
function toggleButton(button) {
    // if already selected do nothing
    if($(button).hasClass('selected')) {
        return;
    }

    // Clear map before new markers
    myMap.removeLayer(markers);
    markers = new L.FeatureGroup();

    // de-select all
    $('.filter-button').toggleClass('selected', false);

    // select the one that was clicked
    $(button).toggleClass('selected', true);

    // reloadData
    var filters = button.id;

    if(filters === 'fauna') {
        filters = 'fauna,entomology';
    }
    updateMap(filters);
}
