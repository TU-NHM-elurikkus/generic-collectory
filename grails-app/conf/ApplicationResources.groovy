modules = {
    collectory {
        dependsOn 'jquery_ui_custom,smoothness,jquery_i18n,jquery_json,jquery_tools,jquery_jsonp,fancybox,openlayers,map'
        resource url:[dir:'js', file:'collectory.js'], disposition: 'head'
        resource url:[dir:'css', file:'temp-style.css', plugin:'erkcollectory-plugin']
    }

    generic {
        dependsOn 'bootstrap, collectory' //
        resource url: [dir: 'js', file: 'application.js']
        resource url: [dir: 'css', file: 'generic.css']
    }

    charts {
        dependsOn 'jquery_i18n'
        resource url: [dir: 'js', file: 'charts2.js', plugin: 'erkcollectory-plugin']
        resource url: [dir: 'js', file: 'charts.js']
    }

    map {
        resource url: [dir: 'js', file: 'map.js']
    }

    // Don't know why, but datasets resource isn't mark as depending on collectory. And for some reason this can't be overriden.
    // And because datasets.js uses jqury.i18n, that is initialized using sync xhr (!) in collectory.js, it MUST be after collectory.
    // Which it isn't, because grails
    datasets_hack {
        dependsOn 'collectory'
        resource url: [dir: 'js', file: 'datasets.js']
    }

    jquery_migration {
        resource url: [dir: 'js', file: 'jquery-migrate-1.2.1.min.js', plugin: 'erkcollectory-plugin']
    }
}
