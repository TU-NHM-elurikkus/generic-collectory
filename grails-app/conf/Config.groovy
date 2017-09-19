grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination

grails.appName = "${appName}"

default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if (new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"
println "default_config = ${default_config}"

/******************************************************************************\
*  SKINNING
\******************************************************************************/
if (!skin.layout) {
    //skin.layout = 'ala2'
    skin.layout = 'generic'
}
if (!skin.orgNameShort) {
    skin.orgNameShort = "ALA"
}
if (!skin.includeBaseUrl) {
    // whether crumb trail should include a home link that is external to this webabpp - ala.baseUrl is used if true
    skin.includeBaseUrl = true
}
if (!skin.headerUrl) {
    skin.headerUrl = "classpath:resources/generic-header.jsp" // can be external URL
}
if (!skin.footerUrl) {
    skin.footerUrl = "classpath:resources/generic-footer.jsp" // can be external URL
}
skin.fluidLayout=false

/******************************************************************************\
*  EXTERNAL SERVERS
\******************************************************************************/
if (!bie.baseURL) {
    bie.baseURL = "http://bie.ala.org.au/"
}
if (!bie.searchPath) {
    bie.searchPath = "/search"
}
if (!biocacheUiURL) {
    biocacheUiURL = "http://biocache.ala.org.au"
}
if(!biocacheServicesUrl){
    biocacheServicesUrl = "http://biocache.ala.org.au/ws"
}
if (!spatial.baseURL) {
    spatial.baseURL = "http://spatial.ala.org.au/"
}
if (!ala.baseURL) {
    ala.baseURL = "http://www.ala.org.au"
}
if (!headerAndFooter.baseURL) {
    headerAndFooter.baseURL = "http://www2.ala.org.au/commonui"
}
if(!alertUrl){
    alertUrl = "http://alerts.ala.org.au/"
}
if(!speciesListToolUrl){
    speciesListToolUrl = "http://lists.ala.org.au/speciesListItem/list/"
}

if(!alertResourceName){
    alertResourceName = "eElurikkus"
}
if(!uploadFilePath){
    uploadFilePath = "/data/${appName}/upload/"
}
if(!uploadExternalUrlPath){
    uploadExternalUrlPath = "/upload/"
}
/******************************************************************************\
*  RELOADABLE CONFIG
\******************************************************************************/
//reloadable.cfgPollingFrequency = 1000 * 60 * 60 // 1 hour
//reloadable.cfgPollingRetryAttempts = 5
//reloadable.cfgs = ["file:/data/collectory/config/Collectory-config.properties"]
reloadable.cfgs = ["file:/data/${appName}/config/${appName}-config.properties"]

/******************************************************************************\
*  TEMPLATES
\******************************************************************************/
if (!citation.template) {
    citation.template = 'Records provided by @entityName@, accessed through eElurikkus website.'
}
if (!citation.link.template) {
    citation.link.template = 'For more information: @link@'
}
if (!citation.rights.template) {
    citation.rights.template = ''
}
if (!resource.publicArchive.url.template) {
    resource.publicArchive.url.template = "${biocacheUiURL}/archives/@UID@/@UID@_ror_dwca.zip"
}
/******************************************************************************\
*  ADDITIONAL CONFIG
\******************************************************************************/
if(!projectNameShort){
    projectNameShort="eElurikkus"
}
if(!projectName){
    projectName="eElurikkus"
}
if(!regionName){
    regionName="Estonia"
}
if(!collectionsMap.centreMapLon){
    collectionsMap.centreMapLon = '58.3735552'
}
if(!collectionsMap.centreMapLat){
    collectionsMap.centreMapLat = '26.7169192'
}
if(!collectionsMap.defaultZoom){
    collectionsMap.defaultZoom = '2'
}
if(!eml.organizationName){
    eml.organizationName="eElurikkus"
}
if(!eml.deliveryPoint){
    eml.deliveryPoint="Vanemuise 46"
}
if(!eml.city){
    eml.city="Tartu"
}
if(!eml.administrativeArea){
    eml.administrativeArea="Tartumaa"
}
if(!eml.postalCode){
    eml.postalCode="51014"
}
if(!eml.country){
    eml.country="Estonia"
}
if(!eml.electronicMailAddress){
    eml.electronicMailAddress = "info@elurikkus.ut.ee"
}
//
///******* standard grails **********/
grails.project.groupId = 'au.org.ala' // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = true
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text/plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      tsv: 'text/tsv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data'
]
// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
//grails.resources.uri.prefix = ''
grails.resources.adhoc.patterns = ['/img/**', '/images/**', '/data/*', '/css/*', '/js/*', '/plugins/**']
grails.resources.resourceLocatorEnabled = true

// The default codec used to encode data with ${}
grails.views.default.codec="html" // none, html, base64
grails.views.gsp.encoding="UTF-8"
grails.converters.encoding="UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

grails.plugins.cookie.cookieage.default = 86400 // if not specified default in code is 30 days

// Serve i18n messages files over http. Needed for i18n support in .js files
grails.plugins.fileserver.paths = [
    "messages": "grails-app/i18n/"
]

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder=false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// whether to install the java.util.logging bridge for sl4j. Disable fo AppEngine!
grails.logging.jul.usebridge = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// MEW tell the framework which packages to search for @Validateable classes
grails.validateable.packages = ['au.org.ala.collectory']

/******* location of images **********/
// default location for images
repository.location.images = "/data/${appName}/data"


disableOverviewMap=false
disableAlertLinks=false
disableLoggerLinks=false


/******************************************************************************\
*  ENVIRONMENT SPECIFIC
\******************************************************************************/

hibernate = "off"

/******************************************************************************\
*  AUDIT LOGGING
\******************************************************************************/
auditLog {
    actorClosure = { request, session ->
        def cas = session?.getAttribute('_const_cas_assertion_')
        def actor = cas?.getPrincipal()?.getName()
        if (!actor) {
            actor = request.getUserPrincipal()?.attributes?.email
        }
        if (!actor) {
            actor = session.username  // injected by data controller for web services
        }
        return actor ?: "anonymous"
    }
    TRUNCATE_LENGTH = 2048
}
auditLog.verbose = false

environments {
    development {
        grails.logging.jul.usebridge = true
    }
    production {
        grails.logging.jul.usebridge = false
    }
}

logging.dir = (System.getProperty('catalina.base') ? System.getProperty('catalina.base') + '/logs'  : '/var/log/tomcat7')
if(!new File(logging.dir).exists()){
    logging.dir  = '/tmp'
}

log4j = {
    appenders {
        environments {
            production {
                rollingFile name: "tomcatLog", maxFileSize: 102400000, file: logging.dir + "/${appName}.log", threshold: org.apache.log4j.Level.INFO, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
            }
            development {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"), threshold: org.apache.log4j.Level.DEBUG
            }
            test {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"), threshold: org.apache.log4j.Level.INFO
            }
        }
    }

    root {
        // change the root logger to my tomcatLog file
        error 'tomcatLog'
        warn 'tomcatLog'
        additivity = true
    }

    error   'org.codehaus.groovy.grails.web.servlet',        // controllers
            'org.codehaus.groovy.grails.web.pages',          // GSP
            'org.codehaus.groovy.grails.web.sitemesh',       // layouts
            'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
            'org.codehaus.groovy.grails.web.mapping',        // URL mapping
            'org.codehaus.groovy.grails.commons',            // core / classloading
            'org.codehaus.groovy.grails.plugins',            // plugins
            'org.codehaus.groovy.grails.orm.hibernate',      // hibernate integration
            'org.springframework',
            'org.hibernate',
            'net.sf.ehcache.hibernate',
            'grails.app.service.org.grails.plugin.resource.ResourceTagLib',
            'grails.app.services.org.grails.plugin.resource',
            'grails.app.taglib.org.grails.plugin.resource',
            'grails.app.resourceMappers.org.grails.plugin.resource'
    debug   'au.org.ala.collectory',
            'grails.app',
            'grails.app.service.org.grails.plugin.au.org.ala'
}
// Uncomment and edit the following lines to start using Grails encoding & escaping improvements

/* remove this line
// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside null
                scriptlet = 'none' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //'text/html' = 'html'
        }
    }
}
remove this line */
