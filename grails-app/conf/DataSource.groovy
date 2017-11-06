dataSource {
    pooled = true
    driverClassName = "com.mysql.jdbc.Driver"
    dialect = org.hibernate.dialect.MySQL5InnoDBDialect
    username = "root"
    password = ""
    logSql = false
    dbCreate = "update"
}

hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = "net.sf.ehcache.hibernate.EhCacheProvider"
}

// environment specific settings
environments {
    development {
        dataSource {
            url = "jdbc:mysql://localhost:3306/collectory?autoReconnect=true&connectTimeout=0"
        }
    }
    test {
        dataSource {
            url = "jdbc:mysql://localhost:3306/collectory?autoReconnect=true&connectTimeout=0"
            properties {
                maxActive = 50
                maxIdle = 25
                minIdle = 5
                initialSize = 5
                minEvictableIdleTimeMillis = 60000
                timeBetweenEvictionRunsMillis = 60000
                maxWait = 10000
                validationQuery = ""
            }
        }
    }
    production {
        dataSource {
            url = "jdbc:mysql://alaproddb1-cbr.vm.csiro.au:3306/collectory?autoReconnect=true&connectTimeout=0"
            properties {
                maxActive = 50
                maxIdle = 25
                minIdle = 5
                initialSize = 5
                minEvictableIdleTimeMillis = 60000
                timeBetweenEvictionRunsMillis = 60000
                maxWait = 10000
                validationQuery = ""
            }
        }
    }
}
