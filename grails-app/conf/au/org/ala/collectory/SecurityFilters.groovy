package au.org.ala.collectory

/**
 * Generated by the Shiro plugin. This filters class protects all URLs
 * via access control by convention.
 */
class SecurityFilters {
    def filters = {
        all(uri: "/collection/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/institution/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/admin/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/contact/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/dataProvider/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/dataResource/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/dataHub/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/dataLink/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/license/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/providerCode/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/providerMap/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
        all(uri: "/reports/**") {
            before = {
                // Access control by convention.
                accessControl()
            }
        }
    }
}