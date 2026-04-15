workspace "Vanana Platform" "High-level architecture for smart device management." {

    model {
        # Users
        admin = person "Facility Admin" "Administrator in charge of facility and building management."
        user = person "Home User" "End user who controls their home devices."

        # Central System
        vanana = softwareSystem "Vanana Platform" "Central platform for monitoring, controlling, and automating IoT devices." {
            landingPage = container "Landing Page" "Public website for presenting the Vanana Platform." "HTML / CSS / JavaScript" "WebBrowser,Landing"
            webApp = container "Web App" "Authenticated web application for Vanana users." "Angular" "Angular"
            spa = container "Single Page Application" "Client-side application experience loaded by the web app." "Angular" "WebBrowser,Angular"
            mobileApp = container "Mobile App" "Mobile application for Vanana users." "Flutter" "MobileApp"
            mobileSqliteDatabase = container "Mobile SQLite Database" "Stores local mobile cache, user preferences, and offline data." "SQLite" "SQLite"
            apiGateway = container "API Gateway" "Routes client requests to Vanana backend services." "Spring Cloud Gateway / Java" "Gateway"
            iamService = container "IAM Service" "Handles identity, access management, authentication, authorization, and account notifications." "Spring Boot / Java 25" "SpringBoot"
            iamDatabase = container "IAM Database" "Stores users, credentials, roles, permissions, sessions, and identity provider links." "PostgreSQL" "Database"
            iamRedis = container "IAM Redis" "Stores short-lived IAM data such as sessions, tokens, rate limits, and verification codes." "Redis" "Redis"
            clairEmbeddedApp = container "Clair Embedded Application" "Runs on the air sensor device to collect measurements and expose device telemetry locally." "Embedded firmware" "Embedded"
            clairEdgeStationApp = container "Clair Edge Station Application" "Runs on-site as the local edge gateway for air sensor devices and synchronizes data with the platform." "Flask" "Edge"
            edgeSqliteDatabase = container "Edge SQLite Database" "Stores local device state, telemetry snapshots, and offline synchronization data at the edge." "SQLite" "SQLite"
        }

        # External Systems with specific tags for coloring
        hardware = softwareSystem "Clair Hardware" "Physical devices (sensors and actuators) installed on-site." "External,Hardware"
        google = softwareSystem "Google OAuth2" "External service for secure user authentication." "External,Google"
        stripe = softwareSystem "Stripe" "External platform for payment processing and subscription management." "External,Stripe"
        resend = softwareSystem "Resend" "External platform for transactional email delivery." "External,Email"

        # User Relationships
        admin -> vanana "Manages facilities and monitors device fleets"
        user -> vanana "Controls devices and views personal metrics"

        # System Relationships
        vanana -> hardware "Sends commands to and receives telemetry from" "MQTT/HTTPS"
        vanana -> google "Authenticates users using" "OpenID Connect"
        vanana -> stripe "Processes payments and subscriptions via" "REST API"
        vanana -> resend "Sends transactional emails using" "REST API"
        
        # Hardware to User Relationship
        hardware -> user "Provides visual/physical feedback in the home"

        # Container Relationships
        admin -> landingPage "Visits the public website to learn about the platform and access the application" "HTTPS"
        user -> landingPage "Visits the public website to learn about the platform and access the application" "HTTPS"
        landingPage -> webApp "Redirects users to the authenticated web application" "HTTPS"
        webApp -> spa "Serves the Angular single page application assets" "HTTPS"
        spa -> apiGateway "Calls protected platform APIs through the gateway" "JSON/HTTPS"
        user -> mobileApp "Uses the mobile application to control devices and view account information" "HTTPS"
        mobileApp -> mobileSqliteDatabase "Stores and retrieves local cache, user preferences, and offline data" "SQLite"
        mobileApp -> apiGateway "Calls protected platform APIs through the gateway" "JSON/HTTPS"
        mobileApp -> clairEmbeddedApp "Connects locally to onboard, configure, and control the air sensor device" "Bluetooth/Wi-Fi Direct"
        mobileApp -> clairEdgeStationApp "Connects locally to monitor edge status, configure synchronization, and manage nearby devices" "HTTPS/Local network"
        apiGateway -> iamService "Validates access tokens and delegates identity and access management requests" "JSON/HTTPS"
        iamService -> iamDatabase "Stores and retrieves users, credentials, roles, permissions, sessions, and provider links" "SQL"
        iamService -> iamRedis "Stores and retrieves short-lived sessions, tokens, rate limits, and verification codes" "RESP/TCP"
        iamService -> google "Delegates social login and identity verification" "OpenID Connect"
        iamService -> resend "Sends verification, password recovery, invitation, and account notification emails" "REST API"
        clairEmbeddedApp -> hardware "Reads air quality measurements from the physical sensor hardware" "GPIO/I2C/UART"
        clairEdgeStationApp -> clairEmbeddedApp "Collects telemetry and sends local device commands" "MQTT/Local network"
        clairEdgeStationApp -> edgeSqliteDatabase "Stores and retrieves local device state, telemetry snapshots, and offline sync data" "SQLite"
        clairEdgeStationApp -> apiGateway "Synchronizes edge data and receives platform commands" "JSON/HTTPS"
    }

    views {
        systemContext vanana "VananaContext" {
            description "System Context diagram for the Vanana Platform"
            include *
            autoLayout lr
        }

        container vanana "VananaContainers" {
            description "Container diagram for the Vanana Platform"
            include landingPage
            include webApp
            include spa
            include mobileApp
            include mobileSqliteDatabase
            include apiGateway
            include iamService
            include iamDatabase
            include iamRedis
            include clairEmbeddedApp
            include clairEdgeStationApp
            include edgeSqliteDatabase
            include hardware
            include google
            include resend
            include admin
            include user
            autoLayout lr
        }

        styles {
            element "Element" {
                color #ffffff
                background #2563eb
            }
            element "Person" {
                shape person
                background #374151
            }
            # Specific colors for External Providers
            element "Hardware" {
                background #ea580c
            }
            element "Google" {
                background #4285f4
            }
            element "Stripe" {
                background #635bff
            }
            element "Email" {
                background #000000
            }
            element "Container" {
                background #2563eb
            }
            element "Landing" {
                background #0f766e
            }
            element "Angular" {
                background #dc2626
            }
            element "MobileApp" {
                shape MobileDevicePortrait
                background #0284c7
            }
            element "Gateway" {
                background #7c3aed
            }
            element "SpringBoot" {
                background #16a34a
            }
            element "Embedded" {
                background #ca8a04
            }
            element "Edge" {
                background #0f766e
            }
            element "Database" {
                shape cylinder
                background #4b5563
            }
            element "SQLite" {
                shape cylinder
                background #003b57
            }
            element "Redis" {
                shape cylinder
                background #dc382d
            }
            element "WebBrowser" {
                shape WebBrowser
            }
        }
    }
}
