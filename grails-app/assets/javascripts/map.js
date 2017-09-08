var COLLECTORY_CONF;  // Populated by map3.gsp inline script
var altMap; // Populated by some of the templates

$(document).ready(function() {
    $('#map-tab-header').on('shown.bs.tab', function(e) {
        mymap.invalidateSize(true);
        mymap.setView([58.7283, 25.4169192], 7);
    });
});
/*
 * Mapping - plot collection locations
 */

/** **********************************************************\
 * i18n
 \************************************************************/
$.i18n.properties({
    name: 'messages',
    path: COLLECTORY_CONF.contextPath + '/messages/i18n/',
    mode: 'map',
    language: COLLECTORY_CONF.locale // default is to use browser specified locale
});
/** **********************************************************/

/* some globals */
// the map
var map;

// the WGS projection
var proj = new OpenLayers.Projection('EPSG:4326');

// projection options for interpreting GeoJSON data
var proj_options;

// the data layer
var vectors;

// the server base url
var baseUrl;

// the ajax url for getting filtered features
var featuresUrl;

// flag to make sure we only apply the url initial filter once
var firstLoad = true;

if(altMap === undefined) {
    altMap = false;
}

// centre point for map of Australia - this value is transformed
// to the map projection once the map is created.
var centrePoint;

var defaultZoom;

// represents the number in 'all' collections - used in case the total number changes on an ajax request
var maxCollections = 0;

/** **********************************************************\
* initialise the map
* note this must be called from body.onload() not $ document.ready() as the latter is too early
\************************************************************/
function initMap(mapOptions) {
    centrePoint = new OpenLayers.LonLat(mapOptions.centreLon, mapOptions.centreLat);
    defaultZoom = mapOptions.defaultZoom;

    // serverUrl is the base url for the site eg http://collections.ala.org.au in production
    // cannot use relative url as the context path varies with environment
    baseUrl = mapOptions.serverUrl;
    featuresUrl = mapOptions.serverUrl + '/public/mapFeatures';

    // var featureGraphicUrl = mapOptions.serverUrl + '/static/images/map/orange-dot.png';
    // var clusterGraphicUrl = mapOptions.serverUrl + '/static/images/map/orange-dot-multiple.png';
    var featureGraphicUrl = mapOptions.serverUrl + '/assets/marker.png';
    var clusterGraphicUrl = mapOptions.serverUrl + '/assets/markermultiple.png';

    // create the map
    map = new OpenLayers.Map('map_canvas', {
        controls: [],
        sphericalMercator: true,
        layers: [
            new OpenLayers.Layer.XYZ('Base layer',
            ['http://${s}.basemaps.cartocdn.com/light_all/${z}/${x}/${y}.png'], {
                sphericalMercator: true,
                wrapDateLine: true
            })
        ]
    });

    // restrict mouse wheel chaos
    map.addControl(new OpenLayers.Control.Navigation({ zoomWheelEnabled: false }));
    map.addControl(new OpenLayers.Control.ZoomPanel());
    map.addControl(new OpenLayers.Control.PanPanel());

    // zoom map
    map.zoomToMaxExtent();

    // add layer switcher for now - review later
    map.addControl(new OpenLayers.Control.LayerSwitcher());

    // centre the map on Australia
    map.setCenter(centrePoint.transform(proj, map.getProjectionObject()), defaultZoom);

    // set projection options
    proj_options = {
        'internalProjection': map.baseLayer.projection,
        'externalProjection': proj
    };

    // create a style that handles clusters
    var style = new OpenLayers.Style({
        externalGraphic: '${pin}',
        graphicHeight: '${size}',
        graphicWidth: '${size}',
        graphicYOffset: -23
    }, {
        context: {
            pin: function(feature) {
                return (feature.cluster) ? clusterGraphicUrl : featureGraphicUrl;
            },
            size: function(feature) {
                return (feature.cluster) ? 25 : 23;
            }
        }
    });

    // create a layer for markers and set style
    var clusterStrategy = new OpenLayers.Strategy.Cluster({ distance: 11, threshold: 2 });
    vectors = new OpenLayers.Layer.Vector('Collections', {
        strategies: [clusterStrategy],
        styleMap: new OpenLayers.StyleMap({ 'default': style })
    });

    // listen for feature selection
    vectors.events.register('featureselected', vectors, selected);
    map.addLayer(vectors);

    // listen for changes to visible region
    map.events.register('moveend', map, moved);

    // control for selecting features (on click)
    var control = new OpenLayers.Control.SelectFeature(vectors, {
        clickout: true
    });
    map.addControl(control);
    control.activate();

    // create custom button to zoom extents to Australia
    var button = new OpenLayers.Control.Button({
        displayClass: 'resetZoom',
        title: $.i18n.prop('zoom.to.australia'),
        trigger: resetZoom
    });
    var panel = new OpenLayers.Control.Panel({ defaultControl: button });
    panel.addControls([button]);
    map.addControl(panel);

    // initial data load
    reloadData();
}

/** **********************************************************\
*   load features via ajax call
\************************************************************/
function reloadData() {
    if(altMap) {
        $.get(featuresUrl, { filters: 'all' }, dataRequestHandler);
    } else {
        $.get(featuresUrl, { filters: getAll() }, dataRequestHandler);
    }
}

var markers = new L.FeatureGroup();

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
            var mapMarker = L.marker(geomObj.geometry.coordinates.reverse(), { icon: mapIcon }).addTo(mymap);
            mapMarker.bindPopup(outputSingleFeature(geomObj));
            markers.addLayer(mapMarker);
        }
    });
    mymap.addLayer(markers);
}

/** **********************************************************\
*   handler for loading features
\************************************************************/
function dataRequestHandler(data) {

    // clear existing
    // vectors.destroyFeatures();
    //
    // // parse returned json
    // var features = new OpenLayers.Format.GeoJSON(proj_options).read(data);
    //
    // // add features to map
    // vectors.addFeatures(features);
    //
    // // remove non-mappable collections
    // var unMappable = [];
    //
    // for(var i = 0; i < features.length; i++) {
    //     if(!features[i].properties.isMappable) {
    //         unMappable.push(features[i]);
    //     }
    // }
    //
    // vectors.destroyFeatures(unMappable);
    //
    // // update number of unmappable collections
    // var unMappedText = '';
    //
    // switch(unMappable.length) {
    //     case 0: unMappedText = ''; break;
    //     case 1: unMappedText = $.i18n.prop('map.js.collectioncannotbemapped'); break;
    //     default: unMappedText = $.i18n.prop('map.js.collectionscannotbemapped', unMappable.length); break;
    // }
    //
    // $('#numUnMappable').html(unMappedText);
    //
    // // update display of number of features
    // var selectedFilters = getSelectedFiltersAsString();
    // var selectedFrom = $.i18n.prop('map.js.collectionstotal', features.length);
    //
    // // TODO
    // if(selectedFilters !== 'all') {
    //     selectedFrom = features.length + ' ' + $.i18n.prop('map.js.' + selectedFilters) + ' ' +
    //         $.i18n.prop('map.js.collections') + '.';
    // }
    //
    // var innerFeatures = '';
    //
    // switch(features.length) {
    //     case 0: innerFeatures = $.i18n.prop('map.js.nocollectionsareselected'); break;
    //     case 1: innerFeatures = $.i18n.prop('map.js.onecollectionisselected'); break;
    //     default: innerFeatures = selectedFrom; break;
    // }
    //
    // $('#numFeatures').html(innerFeatures);
    //
    // // fire moved to initialise number visible
    // moved(null);
    //
    // // first time only: select the filter if one is specified in the url
    // if(firstLoad) {
    //     selectInitialFilter();
    //     firstLoad = false;
    // }
}

/** **********************************************************\
*   build human-readable string from selected filter list
\************************************************************/
function getSelectedFiltersAsString() {
    var list;
    if(altMap) {
        // new style
        list = getSelectedFilters();
    } else {
        // old style
        list = getAll();
    }
    // transform some
    list = list.replace(/plants/, 'plant');
    list = list.replace(/microbes/, 'microbial');

    // remove trailing comma
    if(list.substr(list.length - 1) === ',') {
        list = list.substring(0, list.length - 1);
    }
    // replace last with 'and'
    var last = list.lastIndexOf(',');
    if(last > 0) {
        list = list.substr(0, last) + ' and ' + list.substr(last + 1);
    }
    // insert space after remaining commas
    list = list.replace(/,/g, ', ');
    return list;
}

/** **********************************************************\
*   regenerate list of collections - update total number
\************************************************************/
function updateList() {
    $.get('http://ala-test.ut.ee/collectory/public/mapFeatures?filters=all', function(data) {
        var features = data.features;
        // update the potential total
        maxCollections = Math.max(features.length, maxCollections);

        if(!$('div#all').hasClass('inst')) {  // don't change text if showing institutions
            $('#collections-total').html($.i18n.prop('public.map3.link.showall', maxCollections));
        }

        // update display of number of features
        var innerFeatures = '';

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

        for(var i = 0; i < sortedParents.length; i++) {
            var collList = sortedParents[i];
            // show institution - use name of institution from first collection
            var firstColl = collList[0];
            var content = '';
            if(!firstColl.properties.instName && firstColl.properties.entityType === 'Collection') {
                content +=
                    '<li class="indented-list-item">' +
                        '<span class="highlight">' +
                            '<span class="fa fa-archive"></span>' +
                            '&nbsp;' +
                            $.i18n.prop('collections.with.no.institution') +
                        '</span>' +
                    '<ul class="list-unstyled">';
            } else if(!firstColl.properties.instName && firstColl.properties.entityType === 'DataProvider') {
                content +=
                    '<li class="indented-list-item">' +
                        '<span class="highlight">' +
                            '<span class="fa fa-database"></span>' +
                            '&nbsp;' +
                            $.i18n.prop('dataproviders.list') +
                        '</span>' +
                    '<ul class="list-unstyled">';

            } else {
                content +=
                    '<li class="indented-list-item">' +
                        '<a class="highlight" href="' + baseUrl + '/public/show/' + firstColl.properties.instUid + '">' +
                            '<span class="fa fa-university"></span>' +
                            '&nbsp;' +
                            firstColl.properties.instName +
                        '</a>' +
                    '<ul class="list-unstyled">';
            }
            // show each collection
            for(var c = 0; c < collList.length; c++) {
                var coll = collList[c];
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
                        '</a>';

                // if(!coll.properties.isMappable) {
                //     content += '<img style="vertical-align:middle" src="' + baseUrl + '/images/map/nomap.gif"/>';
                // }

                content += '</li>';
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

/** **********************************************************\
*   handle map movement (zoom pan)
\************************************************************/
function moved(evt) {
    // determine how many individual features are visible
    var visibleCount = 0;
    var totalCount = 0;

    for(var c = 0; c < vectors.features.length; c++) {
        var f = vectors.features[c];

        if(f.cluster) {
            totalCount += f.cluster.length;

            // for clusters count each feature
            if(f.onScreen(true)) {
                visibleCount += f.cluster.length;
            }
        } else {
            totalCount++;

            // single feature
            if(f.onScreen(true)) {
                visibleCount++;
            }
        }
    }

    // update display of number of features visible
    var innerFeatures = '';

    switch(visibleCount) {
        case 0:
            innerFeatures = $.i18n.prop('map.js.nocollectionsarecurrentlyvisible');
            break;
        case 1:
            if(totalCount === 1) {
                innerFeatures = $.i18n.prop('map.js.itiscurrentlyvisible');
            } else {
                innerFeatures = visibleCount + ' ' + $.i18n.prop('map.js.collectioniscurrentlyvisible');
            }

            break;
        default:
            if(visibleCount === totalCount) {
                innerFeatures = $.i18n.prop('map.js.allarecurrentlyvisible');
            } else {
                innerFeatures = visibleCount + ' ' + $.i18n.prop('map.js.collectionarecurrentlyvisible');
            }

            break;
    }

    $('#numVisible').html(innerFeatures);
}

/** **********************************************************\
*   handle feature selection
\************************************************************/
function selected(evt) {
    var feature = evt.feature;

    // get rid of any dags - hopefully
    clearPopups();

    // build content
    var content = '';

    if(feature.cluster) {
        content = outputClusteredFeature(feature);
    } else {
        content = outputSingleFeature(feature);
    }

    // create popoup
    var popup = new OpenLayers.Popup.FramedCloud('featurePopup',
            feature.geometry.getBounds().getCenterLonLat(),
            new OpenLayers.Size(50, 100),
            content,
            null, true, onPopupClose);

    // control shape
    if(!feature.cluster) {
        popup.maxSize = new OpenLayers.Size(350, 500);
    }

    popup.onmouseup(function() {
        alert('up');
    });

    // add to map
    map.addPopup(popup);

}

/** **********************************************************\
*   generate html for a single collection
\************************************************************/
function outputSingleFeature(feature) {
    if($('div#all').hasClass('inst') && $('div#all').hasClass('selected')) { // simple list if showing institutions
        return outputSingleInstitution(feature);
    } else {
        var address = '';
        if(feature.properties.address) {
            address = feature.properties.address;
        }
        var desc = feature.properties.desc;
        var acronym = '';
        if(feature.properties.acronym) {
            acronym = ' (' + feature.properties.acronym + ')';
        }
        var instLink = '';

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

        instLink =
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
        return instLink;
    }
}

/** **********************************************************\
*   generate html for a single institution
\************************************************************/
function outputSingleInstitution(feature) {
    var address = '';
    if(feature.properties.address && feature.properties.address !== '') {
        address = feature.properties.address;
    }
    var acronym = '';
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

/** **********************************************************\
*   group features by their parent institutions
*   groupOrphans = true -> orphans are grouped in zz-other rather than interspersed
\************************************************************/
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

/** **********************************************************\
*   generate html for a clustered feature
\************************************************************/
function outputClusteredFeature(feature) {
    var sortedParents = groupByParent(feature.cluster, false);
    // output the parents list
    var content = '<ul>';
    if($('div#all').hasClass('inst') && $('div#all').hasClass('selected')) { // simple list if showing institutions
        content += outputMultipleInstitutions(sortedParents);
    } else {
        // adopt different collapsing strategies based on number to display
        var strategy = 'verbose';
        if(sortedParents.length === 1) { strategy = 'veryVerbose'; }
        if(sortedParents.length > 4) { strategy = 'brief'; }
        if(sortedParents.length > 6) { strategy = 'terse'; }
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

    content += '</ul>';
    return content;
}

/** **********************************************************\
*   generate html for a list of institutions
\************************************************************/
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

/** **********************************************************\
*   grab name from institution
\************************************************************/
function getName(obj) {

    if($.isArray(obj) && obj[0].properties && obj[0].properties.name && obj[0].properties.entityType !== 'Collection') {
        return obj[0].properties.name;
    } else if(!$.isArray(obj) && obj.properties && obj.properties.name && obj.properties.entityType !== 'Collection') {
        return obj.properties.name;
    }

    var name;
    if($.isArray(obj)) {
        name = obj[0].properties.instName;
    } else {
        name = obj.properties.instName;
    }
    // remove leading 'The ' so the institutions sort by first significant letter
    if(name && name.length > 4 && name.substr(0, 4) === 'The ') {
        name = name.substr(4);
    }
    return name;
}

/** **********************************************************\
*   build html for multiple collection for an institution
\************************************************************/
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

/** **********************************************************\
* abbreviates institution name if long (assumes inst is present)
\************************************************************/
function getTightInstitutionName(obj, max) {
    if(obj.properties.instName.length > max && obj.properties.instAcronym) {
        return obj.properties.instAcronym;
    } else {
        return obj.properties.instName;
    }
}

/** **********************************************************\
* abbreviates collections name by removing leading institution name
\************************************************************/
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

/** **********************************************************\
*   build html for an institution on its own line
\************************************************************/
function outputInstitutionOnOwnLine(obj) {
    var instLink =
        '<a class="highlight" href="' + baseUrl + '/public/show/' + obj.properties.instUid + '">' +
            '<span class="fa fa-university"></span>' +
            '&nbsp;' +
            getTightInstitutionName(obj, 55) +
        '</a>';
    return instLink;
}

/** **********************************************************\
*   build html for a single collection with an institution
\************************************************************/
function outputCollectionWithInstitution(obj, strategy) {
    var max = 60;
    var acronym = '';
    if(!obj.properties.acronym) {
        acronym = ' (' + obj.properties.acronym + ')';
    }
    var instLink = '<a class="highlight" href="' + baseUrl + '/public/show/' + obj.properties.instUid + '">';

    var result;

    if(strategy === 'verbose') {

        if(obj.properties.name.length + acronym.length > max) {
            // drop acronym
            result =
            '<li>' +
                instLink +
                    obj.properties.instName +
                '</a>' +
                '<ul>' +
                    '<li>' +
                        '<a href="' + obj.properties.url + '">' +
                            obj.properties.name +
                        '</a>' +
                    '</li>' +
                '</ul>' +
            '</li>';
            return result;
        } else {
            result =
                '<li>' +
                    instLink +
                        obj.properties.instName +
                    '</a>' +
                    '<ul>' +
                        '<li>' +
                            '<a href="' + obj.properties.url + '"/>' +
                                obj.properties.name + acronym +
                            '</a>' +
                        '</li>' +
                    '</ul>' +
                '</li>';
            return result;
        }
    } else {
        // present both in one line
        var inst = obj.properties.instName;
        var briefInst = getTightInstitutionName(obj, 25);
        var coll = obj.properties.name;

        // try full inst + full coll + acronym
        if(inst.length + coll.length + acronym.length < max) {
            result =
                '<li>' +
                    instLink +
                        inst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        coll + acronym +
                    '</a>' +
                '</li>';
            return result;

        // try full inst + short coll + acronym
        } else if(inst.length + getShortCollectionName(obj).length + acronym.length < max) {
            result =
                '<li>' +
                    instLink +
                        inst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        getShortCollectionName(obj) + acronym +
                    '</a>' +
                '</li>';
            return result;

        // try full inst + short coll
        } else if(inst.length + getShortCollectionName(obj).length < max) {
            result =
                '<li>' +
                    instLink +
                        inst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        getShortCollectionName(obj) +
                    '</a>' +
                '</li>';
            return result;

        // try acronym of inst + full coll + acronym
        } else if(briefInst.length + coll.length + acronym.length < max) {
            result =
                '<li>' +
                    instLink +
                        briefInst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        coll +
                    '</a>' +
                '</li>';
            return result;

        // try acronym of inst + full coll
        } else if(briefInst.length + coll.length < max) {
            result =
                '<li>' +
                    instLink +
                        briefInst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        coll +
                    '</a>' +
                '</li>';
            return result;

        // try acronym of inst + short coll
        } else if(briefInst.length + getShortCollectionName(obj).length < max) {
            result =
                '<li>' +
                    instLink +
                        briefInst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        getShortCollectionName(obj) +
                    '</a>' +
                '</li>';
            return result;

        // try acronym of inst + coll acronym
        } else if(acronym !== '') {
            result =
                '<li>' +
                    instLink +
                        briefInst +
                    '</a>' +
                    ' - <a href="' + obj.properties.url + '">' +
                        acronym +
                    '</a>' +
                '</li>';
            return result;

        // try full inst + 1 collection
        } else if(inst.length < max - 12) {
            return '<li>' + instLink + inst + '</a> - 1 ' + $.i18n.prop('collection') + '</li>';

        // try acronym of inst + 1 collection (worst case!)
        } else {
            return '<li>' + instLink + briefInst + '</a> - 1 ' + $.i18n.prop('collection') + '</li>';
        }
    }
}

/** **********************************************************\
*   build html for a collection on its own line
\************************************************************/
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
        name = obj.properties.name + '</a>' + acronym;

    // try short name + acronym
    } else if(getShortCollectionName(obj).length + acronym.length < max) {
        name = getShortCollectionName(obj) + acronym + '</a>';

    // try name
    } else if(obj.properties.name.length < max) {
        name = obj.properties.name + '</a>';

    // try short name
    } else if(getShortCollectionName(obj).length < max) {
        name = getShortCollectionName(obj) + '</a>';

    // stuck with name
    } else {
        name = obj.properties.name + '</a>';
    }

    return '<li><a href="' + obj.properties.url + '">' + name + '</li>';
}

/** **********************************************************\
*   remove pop-ups on close
\************************************************************/
function onPopupClose(evt) {
    map.removePopup(this);
}

/** **********************************************************\
*   clear all pop-ups
\************************************************************/
function clearPopups() {
    for(pop in map.popups) {
        map.removePopup(map.popups[pop])
    }
    // maybe iterate features and clear popups?
}

/** **********************************************************\
*   reset map to initial view of Australia
\************************************************************/
function resetZoom() {
    // centre the map on Australia
    // note that the point has already been transformed
    map.setCenter(centrePoint);
    map.zoomTo(4);
}
/* END plot collection locations */

/*
 * Helpers for managing Filter checkboxes
 */
/** **********************************************************\
*   set all boxes checked and trigger change handler
\************************************************************/
function setAll() {
    $('input[name=filter]').attr('checked', $('input#all').is(':checked'));
    filterChange();
}

/** **********************************************************\
*   build comma-separated string representing all selected boxes
\************************************************************/
function getAll() {
    if($('input#all').is(':checked')) {
        return 'all';
    }
    var checked = '';
    $('input[name=filter]').each(function(index, element) {
        if(element.checked) {
            checked += element.value + ',';
        }
    });

    return checked;
}

/** **********************************************************\
*   need separate handler for ento change because we need to know which checkbox changed
*   to manage the ento-fauna paradigm
\************************************************************/
function entoChange() {
    // set state of faunal box
    if($('input#fauna').is(':checked') && !$('input#ento').is(':checked')) {
        $('input#fauna').attr('checked', false);
    }
    filterChange();
}

/** **********************************************************\
*   handler for filter selection change
\************************************************************/
function filterChange() {
    // set ento based on faunal
    // set state of faunal box
    if($('input#fauna').is(':checked') && !$('input#ento').is(':checked')) {
        $('input#ento').attr('checked', true);
    }
    // find out if they are all checked
    var all = true;
    $('input[name=filter]').each(function(index, element) {
        if(!element.checked) {
            all = false;
        }
    });
    // set state of 'select all' box
    if($('input#all').is(':checked') && !all) {
        $('input#all').attr('checked', false);
    } else if(!$('input#all').is(':checked') && all) {
        $('input#all').attr('checked', true);
    }

    // reload features based on new filter selections
    reloadData();
}
/* END filter checkboxes */

/*
 * Helpers for managing Filter buttons
 */
/** **********************************************************\
*   Handle filter button click. Doesn't actually toggle.
\************************************************************/
function toggleButton(button) {
    // if already selected do nothing
    if($(button).hasClass('selected')) {
        return;
    }

    // Clear map before new markers
    mymap.removeLayer(markers);
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

/** **********************************************************\
 *  select filter if one is specified in the url
\************************************************************/
function selectInitialFilter() {
    var params = $.deparam.querystring(),
        start = params.start,
        filter;

    if(start) {
        if(start === 'insects') {
            start = 'entomology';
        }

        filter = $('#' + start);

        if(filter.length > 0) {
            toggleButton(filter[0]);
        }
    }
}

/** **********************************************************\
*   build comma separated string of selected buttons - NOT USED
\************************************************************/
function getSelectedFilters() {
    var checked = '';
    $('.filter-button').each(function(index, element) {
        if($(element).hasClass('selected')) {
            checked += element.id + ',';
        }
    });
    if(checked === 'fauna,entomology,microbes,plants,') {
        checked = 'all';
    }

    return checked;
}

/* END filter buttons */
