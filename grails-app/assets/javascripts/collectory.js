//= require jquery
//= require common
//= require jquery-ui
//= require jquery-migration-plugins
//= require application
//= require openlayers
//= require map

/************************************************************\
 * i18n
 \************************************************************/
jQuery.i18n.properties({
    name: 'messages',
    path: COLLECTORY_CONF.contextPath + '/messages/i18n/',
    mode: 'map',
    language: COLLECTORY_CONF.locale // default is to use browser specified locale
});

/************************************************************\
* Build phrase with num records and set to elements with id = numBiocacheRecords
\************************************************************/
function setNumbers(totalBiocacheRecords) {
  var recordsClause = "";
  switch (totalBiocacheRecords) {
    //case 0: recordsClause = "No records"; break;
    //case 1: recordsClause = "1 record"; break;
    //default: recordsClause = addCommas(totalBiocacheRecords) + " records";
    case 0: recordsClause = jQuery.i18n.prop('collectory.js.norecord'); break;
    case 1: recordsClause = "1 " + jQuery.i18n.prop('collectory.js.record'); break;
    default: recordsClause = addCommas(totalBiocacheRecords) + " " + jQuery.i18n.prop('collectory.js.records');
  }
  $('#numBiocacheRecords').html(recordsClause);
}
/************************************************************\
 * Called when an ajax request returns no records.
 \************************************************************/
function noData() {
    setNumbers(0);
    $('a.recordsLink').css('display','none');
    $('#recordsBreakdown').css('display','none');
}

/************************************************************\
 * Sort a key-value array
 \************************************************************/
function sortKV(items) {
    var values = [];
    for (var item in items) {
        values.push({ key: item, value: items[item] });
    }
    values.sort(function (a, b) {
        return a.key.localeCompare(b.key);
    });

    return values;
}

/************************************************************\
* Add commas to number strings
\************************************************************/
function addCommas(nStr){
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
}
/************************************************************\
*
\************************************************************/
function toggleHelp(obj) {
  node = findPrevious(obj.parentNode, 'td', 4);
  var div;
  if (node)
    div = node.childNodes[0];
  for(;div = div.nextSibling;) {
    if (div.className && div.className == 'fieldHelp') {
      vis = div.style;
      // if the style.display value is blank we try to figure it out here
      if(vis.display==''&&elem.offsetWidth!=undefined&&elem.offsetHeight!=undefined)
        vis.display = (elem.offsetWidth!=0&&elem.offsetHeight!=0)?'block':'none';
      vis.display = (vis.display==''||vis.display=='block')?'none':'block';
    }
  }
}
/************************************************************\
*
\************************************************************/
function findPrevious(o, tag, limit){
  for(tag = tag.toLowerCase(); o = o.previousSibling;)
      if(o.tagName && o.tagName.toLowerCase() == tag)
          return o;
      else if(limit && o == limit)
          return null;
  return null;
}
/************************************************************\
*
\************************************************************/
function anySelected(idOfSelect, message) {
    var selected = document.getElementById(idOfSelect).selectedIndex;
    if (selected == 0) {
      alert(message);
      return false;
    } else {
      return true;
    }
}
/************************************************************\
*
\************************************************************/
// opens email window for slightly obfuscated email addy
var strEncodedAtSign = "(SPAM_MAIL@ALA.ORG.AU)";
function sendEmail(strEncoded) {
    var strAddress;
    strAddress = strEncoded.split(strEncodedAtSign);
    strAddress = strAddress.join("@");
    //var objWin = window.open ('mailto:' + strAddress + '?subject=' + document.title + '&body=' + document.title + ' \n(' + window.location.href + ')','_blank');
    //console.log('mailto:' + strAddress + '?subject=' + document.title + '&body=' + document.title);
    //window.location.href = 'mailto:' + strAddress + '?subject=' + document.title + '&body=' + document.title;
    window.location.href = 'mailto:' + strAddress;
    //if (objWin) objWin.close();
    if (event) {
        event.cancelBubble = true;
    }
    return false;
}
/************************************************************\
*
\************************************************************/
function initializeLocationMap(canBeMapped,lat,lng) {
  var map;
  var marker;
  if (canBeMapped) {
    if (lat == undefined || lat == 0 || lat == -1 ) {lat = -35.294325779329654}
    if (lng == undefined || lng == 0 || lng == -1 ) {lng = 149.10602960586547}
    var latLng = new google.maps.LatLng(lat, lng);
    map = new google.maps.Map(document.getElementById('mapCanvas'), {
      zoom: 14,
      center: latLng,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      scrollwheel: false,
      streetViewControl: false
    });
    marker = new google.maps.Marker({
      position: latLng,
      title: 'Edit section to change pin location',
      map: map
    });
  } else {
    var middleOfAus = new google.maps.LatLng(-28.2,133);
    map = new google.maps.Map(document.getElementById('mapCanvas'), {
      zoom: 2,
      center: middleOfAus,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      draggable: false,
      disableDoubleClickZoom: true,
      scrollwheel: false,
      streetViewControl: false
    });
  }
}

/************************************************************\
 *******        LOAD DOWNLOAD STATS        *****
\************************************************************/
function loadDownloadStats(loggerServicesUrl, uid, name, eventType) {
    if (eventType == '') {
        // nothing to show
        return;
    }

    if (loggerServicesUrl == ''){
        return;
    }

    var displayNameMap = {
        'thisMonth' : jQuery.i18n.prop('collectory.js.thismonth'),
        'last3Months' : jQuery.i18n.prop('collectory.js.last3month'),
        'lastYear' : jQuery.i18n.prop('collectory.js.last12month'),
        'all' : jQuery.i18n.prop('collectory.js.alldownloads')
    };

    $('div#usage').html(jQuery.i18n.prop('collectory.js.loadingstatistics'));

    var url = loggerServicesUrl + "/reasonBreakdown.json?eventId=" + eventType + "&entityUid=" + uid;

    $.ajax({
        url: url,
        dataType: 'jsonp',
        cache: false,
        error: function (jqXHR, textStatus, errorThrown) {
            $('div#usage').html(jQuery.i18n.prop('collectory.js.nousagestatistics'));
        },
        success: function (data) {
            $('div#usage').html('');
            $.each(displayNameMap, function( nameKey, displayString ) {
                var value = data[nameKey];
                var $usageDiv = $('<div class="usageDiv card"/>');

                var nonTestingRecords  = (value.reasonBreakdown["testing"] == undefined) ? value.records : value.records -  value.reasonBreakdown["testing"].records;
                var nonTestingEvents   = (value.reasonBreakdown["testing"] == undefined) ? value.events  : value.events  -  value.reasonBreakdown["testing"].events;
                $usageDiv.html('<div class="card-header"><h4><span>' + displayString + "</span><span class='float-right'>" + addCommas(nonTestingRecords) + " " + jQuery.i18n.prop('collectory.js.recordsdownloaded') + " " +  addCommas(nonTestingEvents) + " downloads. </span></h4></div>");

                var $usageContent = $('<div class="card-block" />');
                var $usageTable = $('<table class="table"/>');

                var reasons = sortKV(value['reasonBreakdown']);

                $.each(reasons, function( index, details ) {
                    var usageTableRow = '<tr';

                    if (details.key.indexOf("test") >=0){
                        usageTableRow += " style=color:#999999;";
                    }

                    usageTableRow += '><td>' + capitalise(details.key) ;

                    if (details.key.indexOf("test") >=0){
                        usageTableRow += "<br/><span style='font-size: 12px;'> *" + jQuery.i18n.prop('collectory.js.testingstatistics') + "</span>";
                    }

                    usageTableRow += '</td><td style="text-align: right;">' + addCommas(details.value.events) + ' events</td><td style="text-align: right">'  + addCommas(details.value.records)  + ' records </td></tr>';
                    $usageTable.append($(usageTableRow));
                });

                $usageContent.append($usageTable);
                $usageDiv.append($usageContent);

                $('div#usage').append($usageDiv);
            })
        }
    });
}
