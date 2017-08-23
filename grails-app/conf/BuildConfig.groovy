grails.servlet.version = "2.5" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.work.dir = "target/work"
grails.project.target.level = 1.6
grails.project.source.level = 1.6

//grails.plugin.location."collectory-plugin" = "../collectory-plugin"

grails.project.fork = [
    test:   false,
    run:    false,
    console:    false,
    war:        false
]

grails.project.dependency.resolver = "maven"

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
    }
    log "error" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve
    legacyResolve false // whether to do a secondary resolve on plugin installation, not advised and here for backwards compatibility

    repositories {
        mavenLocal()
        mavenRepo("http://nexus.ala.org.au/content/groups/public/") {
            updatePolicy 'daily'
        }
    }

    dependencies {
        runtime 'mysql:mysql-connector-java:5.1.43'
        runtime 'net.sf.opencsv:opencsv:2.3'
	runtime 'ant:ant:1.6.5'
        runtime 'commons-httpclient:commons-httpclient:3.1'
        runtime 'org.aspectj:aspectjweaver:1.6.6'
    }

    plugins {
        build ":rest-client-builder:1.0.3"
        build ":release:3.0.1"
        build ":tomcat:7.0.54"
        compile ":asset-pipeline:2.14.1"
        compile ":cache:1.1.8"
        runtime ":elurikkus-commons:0.2-SNAPSHOT"
        runtime ":hibernate:3.6.10.11"
        runtime ":jquery:1.11.1"
        runtime ":audit-logging:1.0.7"
        runtime ":cache-headers:1.1.6"
        runtime ":rest:0.8"
        runtime ":tiny-mce:3.4.4"
        runtime ":cors:1.1.8"
    }
}
