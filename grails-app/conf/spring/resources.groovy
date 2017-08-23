import org.codehaus.groovy.grails.context.support.PluginAwareResourceBundleMessageSource
import au.org.ala.collectory.ExtendedPluginAwareResourceBundleMessageSource
import grails.util.Environment

doWithSpring = {
    def config = application.config
    // UTF-8 encoding
    config.grails.views.default.codec = "html"
    config.grails.views.gsp.encoding = "UTF-8"
    config.grails.converters.encoding = "UTF-8"

    // EhCache settings
    if (!config.grails.cache.config) {
        config.grails.cache.config = {
            defaults {1
                eternal false
                overflowToDisk false
                maxElementsInMemory 10000
                timeToLiveSeconds 3600
            }
            cache {
                name 'collectoryCache'
                timeToLiveSeconds (3600 * 24) // day
            }
            cache {
                name 'longTermCache'
                timeToLiveSeconds (3600 * 24 * 7) // week
            }
        }
    }

    // Apache proxyPass & cached-resources seems to mangle image URLs in plugins, so we exclude caching it
    application.config.grails.resources.mappers.hashandcache.excludes = ["**/images/*.*"]

    def loadConfig = new ConfigSlurper(Environment.current.name).parse(application.classLoader.loadClass("defaultConfig"))
    application.config = loadConfig.merge(config) // client app will now override the defaultConfig version

    def beanconf = springConfig.getBeanConfig('messageSource')
    def beandef = beanconf ? beanconf.beanDefinition : springConfig.getBeanDefinition('messageSource')
    if (beandef?.beanClassName == PluginAwareResourceBundleMessageSource.class.canonicalName) {
        //just change the target class of the bean, maintaining all configurations.
        beandef.beanClassName = ExtendedPluginAwareResourceBundleMessageSource.class.canonicalName
    }

    messageSource(ExtendedPluginAwareResourceBundleMessageSource) {
        basenames = ["WEB-INF/grails-app/i18n/messages"] as String[]
        cacheSeconds = (60 * 60 * 6) // 6 hours
        useCodeAsDefaultMessage = false
    }
}

// Place your Spring DSL code here
beans = {
    // Custom message source
    messageSource(ExtendedPluginAwareResourceBundleMessageSource) {
        basenames = ["WEB-INF/grails-app/i18n/messages"] as String[]
        cacheSeconds = (60 * 60 * 6) // 6 hours
        useCodeAsDefaultMessage = false
    }
}

// Place your Spring DSL code here
//beans = {
//}
