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
            apiGateway = container "API Gateway" "Routes client requests to Vanana backend services." "Spring Cloud Gateway / Java" "Gateway"
            iamService = container "IAM Service" "Handles identity, access management, authentication, authorization, and account notifications." "Spring Boot / Java 25" "SpringBoot"
            iamDatabase = container "IAM Database" "Stores users, credentials, roles, permissions, sessions, and identity provider links." "PostgreSQL" "Database"
            iamRedis = container "IAM Redis" "Stores short-lived IAM data such as sessions, tokens, rate limits, and verification codes." "Redis" "Redis"
            billingService = container "Billing Service" "Handles subscriptions, invoices, payment status, and billing workflows." "Spring Boot / Java 25" "SpringBoot"
            billingDatabase = container "Billing Database" "Stores subscriptions, invoices, payment records, plans, and billing events." "PostgreSQL" "Database"
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
        mobileApp -> apiGateway "Calls protected platform APIs through the gateway" "JSON/HTTPS"
        apiGateway -> iamService "Validates access tokens and delegates identity and access management requests" "JSON/HTTPS"
        iamService -> iamDatabase "Stores and retrieves users, credentials, roles, permissions, sessions, and provider links" "SQL"
        iamService -> iamRedis "Stores and retrieves short-lived sessions, tokens, rate limits, and verification codes" "RESP/TCP"
        iamService -> google "Delegates social login and identity verification" "OpenID Connect"
        iamService -> resend "Sends verification, password recovery, invitation, and account notification emails" "REST API"
        apiGateway -> billingService "Delegates subscription, invoice, and payment management requests" "JSON/HTTPS"
        billingService -> billingDatabase "Stores and retrieves subscriptions, invoices, payment records, plans, and billing events" "SQL"
        billingService -> stripe "Creates checkout sessions, manages subscriptions, and receives payment status" "REST API/Webhooks"
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
            include apiGateway
            include iamService
            include iamDatabase
            include iamRedis
            include billingService
            include billingDatabase
            include stripe
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
            element "Database" {
                shape cylinder
                background #4b5563
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
