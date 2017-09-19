//= require leaflet/leaflet-1.2.0
//= require leaflet-marker-cluster/leaflet.markercluster

var altMap; // Populated by some of the templates
var collectionsMap;
var baseUrl; // The server base url

// represents the number in 'all' collections - used in case the total number changes on an ajax request
var maxCollections = 0;

var clusterMarkers;

$(document).ready(function() {
    updateList('all');
    collectionsMap = L.map('map_canvas', {
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
    }).addTo(collectionsMap);

    updateMap('all');

    $('#map-tab-header').on('shown.bs.tab', function(e) {
        collectionsMap.invalidateSize(true);
        collectionsMap.setView([58.7283, 25.4169192], 7);
    });
});

/**
* Generate cluster popup from child elements
*/
function clusterPopup(children) {
    var popupContent = '';
    var mapping = {};
    var instLinkTag;

    children.forEach(function(child) {
        instLinkTag = $(child._popup._content).find('a')[0].outerHTML;
        if(!mapping.hasOwnProperty(instLinkTag)) {
            mapping[instLinkTag] = [];
        }
        mapping[instLinkTag].push($(child._popup._content).find('.collection-acro')[0].outerHTML);
    });

    var keys = Object.keys(mapping);
    keys.forEach(function(key) {
        popupContent +=
            '<li>' +
                key +
                '<ul class="list-unstyled">';

        mapping[key].forEach(function(coll) {
            popupContent += '<li class="indented-list-item">' + coll + '</li>';
        });

        popupContent +=
                '</ul>' +
            '</li>';
    });

    popupContent = '<ul class="list-unstyled" style="font-size: 14px;">' + popupContent + '</ul>';

    return popupContent;
}

if(altMap === undefined) {
    altMap = false;
}

function updateMap(filters) {
    var mapIcon = L.icon({
        iconUrl: 'assets/marker.png',
        iconSize: [25, 25]
    });

    var queryUrl = 'http://ala-test.ut.ee/collectory/public/mapFeatures?filters=' + filters;

    clusterMarkers = L.markerClusterGroup({
        showCoverageOnHover: false,
        zoomToBoundsOnClick: false,
        iconCreateFunction: function(cluster) {
            return L.icon({
                iconUrl: 'assets/markermultiple.png',
                iconSize: [25, 25]
            });
        }
    });

    $.get(queryUrl, function(data) {
        var geomObjects = data.features;

        geomObjects.forEach(function(geomObj) {
            var mapMarker = L.marker(geomObj.geometry.coordinates.reverse(), { icon: mapIcon });

            clusterMarkers.addLayer(mapMarker);
            mapMarker.bindPopup(outputSingleFeature(geomObj));
        });
    });

    collectionsMap.closePopup();
    collectionsMap.addLayer(clusterMarkers);

    // Add tooltip for cluster icons on map
    clusterMarkers.on('clusterclick', function(c) {
        var popupContent = clusterPopup(c.layer.getAllChildMarkers());

        L.popup()
            .setLatLng(c.layer.getLatLng())
            .setContent(popupContent)
            .openOn(collectionsMap);
    });
}

/**
* Inject the number of collections without geom info to template
*/
function findUnMappable(features) {
    var unMappable = [];

    features.forEach(function(geomObj) {
        if(!geomObj.properties.isMappable) {
            unMappable.push(geomObj);
        }
    });

    var unMappedText = '';

    switch(unMappable.length) {
        case 0: unMappedText = ''; break;
        case 1: unMappedText = $.i18n.prop('map.js.collectioncannotbemapped'); break;
        default: unMappedText = $.i18n.prop('map.js.collectionscannotbemapped', unMappable.length); break;
    }

    $('#numUnMappable').html(unMappedText);
}

/**
* Inject the number of currently selected collections to template
*/
function findSelected(features) {
    var selectedFrom = $.i18n.prop('map.js.collectionstotal', features.length);
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
}

/**
* Regenerate list of collections - update total number
*/
function updateList(filters) {
    $.get('http://ala-test.ut.ee/collectory/public/mapFeatures?filters=' + filters, function(data) {
        var features = data.features;

        findSelected(features);
        findUnMappable(features);

        // update the potential total
        maxCollections = Math.max(features.length, maxCollections);

        if(!$('div#all').hasClass('inst')) {  // don't change text if showing institutions
            $('#collections-total').html($.i18n.prop('public.map3.link.showall', maxCollections));
        }

        // group by institution
        var sortedParents = groupByParent(features, true);
        var innerHtml = '';
        var orphansHtml = '';

        sortedParents.forEach(function(collList) {
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
            collList.forEach(function(coll) {
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
            });

            content += '</ul></li>';
            if(!firstColl.properties.instName) {
                orphansHtml = content;
            } else {
                innerHtml += content;
            }
        });
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
                '<a class="collection-acro" style="margin-left:5px;" href="' + feature.properties.url + '">' +
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
    features.forEach(function(collectionFeature) {
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
    });

    // move to an array so we can sort
    var sortedParents = [];
    Object.keys(parents).forEach(function(key) {
        sortedParents.push(parents[key]);
    });
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
* Handle filter button click. Doesn't actually toggle.
*/
function toggleButton(button) {
    // if already selected do nothing
    if($(button).hasClass('selected')) {
        return;
    }

    // Focus on new clicked button
    $('.filter-button').toggleClass('selected', false);
    $(button).toggleClass('selected', true);

    // Clear map of previous markers
    collectionsMap.removeLayer(clusterMarkers);
    clusterMarkers = null;

    // reloadData
    var filters = button.id;

    if(filters === 'fauna') {
        filters = 'fauna,entomology';
    }

    updateMap(filters);
    updateList(filters);
}
