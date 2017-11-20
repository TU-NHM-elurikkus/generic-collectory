import grails.util.Environment
// from /commons/lib/
import com.nextdoor.rollbar.RollbarLog4jAppender

grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination

// This may be unnecessary.
grails.appName = "${appName}"

default_config = "/data/${appName}/config/${appName}-config.properties"
commons_config = "/data/commons/config/commons-config.properties"
env_config = "conf/${Environment.current.name}/Config.groovy"

grails.config.locations = [
    "file:${env_config}",
    "file:${commons_config}",
    "file:${default_config}"
]

def prop = new Properties()
def rollbarServerKey = ""

// Load rollbar key from commons config file.
try {
    File fileLocation = new File(commons_config)
    prop.load(new FileInputStream(fileLocation))
    rollbarServerKey = prop.getProperty("rollbar.postServerKey") ?: ""
} catch(IOException e) {
    e.printStackTrace()
}

if(!new File(env_config).exists()) {
    println "ERROR - [${appName}] Couldn't find environment specific configuration file: ${env_config}"
}
if(!new File(default_config).exists()) {
    println "ERROR - [${appName}] No external configuration file defined. ${default_config}"
}
if(!new File(commons_config).exists()) {
    println "ERROR - [${appName}] No external commons configuration file defined. ${commons_config}"
}
if(rollbarServerKey.isEmpty()) {
    println "ERROR - [${appName}] No Rollbar key."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

/******************************************************************************\
*  SKINNING
\******************************************************************************/
if (!skin.layout) {
    //skin.layout = 'ala2'
    skin.layout = 'generic'
}
if (!skin.orgNameShort) {
    skin.orgNameShort = "eElurikkus"
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
reloadable.cfgs = ["file:" + default_config, "file:" + commons_config]

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
        org.apache.shiro.SecurityUtils.getSubject()?.getPrincipal()
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


def logging_dir = System.getProperty("catalina.base") ? System.getProperty("catalina.base") + "/logs" : "/var/log/tomcat7"
if(!new File(logging_dir).exists()) {
    logging_dir = "/tmp"
}

println "INFO - [${appName}] logging_dir: ${logging_dir}"

log4j = {
    def logPattern = pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")

    def rollbarAppender = new RollbarLog4jAppender(
        name: "rollbar",
        layout: logPattern,
        threshold: org.apache.log4j.Level.ERROR,
        environment: Environment.current.name,
        accessToken: rollbarServerKey
    )

    def tomcatLogAppender = rollingFile(
        name: "tomcatLog",
        maxFileSize: "10MB",
        file: "${logging_dir}/collectory.log",
        threshold: org.apache.log4j.Level.WARN,
        layout: logPattern
    )

    appenders {
        environments {
            production {
                appender(tomcatLogAppender)
                appender(rollbarAppender)
            }
            test {
                appender(tomcatLogAppender)
                appender(rollbarAppender)
            }
            development {
                console(
                    name: "stdout",
                    layout: logPattern,
                    threshold: org.apache.log4j.Level.DEBUG)
            }
        }
    }

    root {
        error "tomcatLog", "rollbar"
        warn "tomcatLog"
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


// Added by the Audit-Logging plugin:
auditLog.auditDomainClassName = 'au.org.ala.audit.AuditLogEvent'
