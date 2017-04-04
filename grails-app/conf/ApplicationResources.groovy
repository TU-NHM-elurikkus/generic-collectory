modules = {
    collectory {
        dependsOn 'jquery_ui_custom,smoothness,jquery_i18n,jquery_json,jquery_tools,jquery_jsonp,fancybox,openlayers,map'
        resource url:[dir:'js', file:'collectory.js']
        resource url:[dir:'css', file:'temp-style.css', plugin:'collectory-plugin']
    }

    generic {
        dependsOn 'bootstrap, collectory' //
        resource url: [dir: 'js', file: 'application.js']
        resource url: [dir: 'css', file: 'generic.css']
    }

    charts {
        dependsOn 'jquery_i18n'
        resource url: [dir: 'js', file: 'charts2.js', plugin: 'collectory-plugin']
        resource url: [dir: 'js', file: 'charts.js']
    }

    map {
        resource url: [dir: 'js', file: 'map.js']
    }
}
