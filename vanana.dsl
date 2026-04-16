workspace "Vanana Platform" "High-level architecture for smart device management." {

    model {
        # Users
        admin = person "Facility Admin" "Owner or operator of multiple air sensors across one or more facilities or locations."
        user = person "Home User" "Customer who owns or uses a personal air sensor at home."

        # Central System
        vanana = softwareSystem "Vanana Platform" "Central platform for monitoring, controlling, and automating IoT devices." {
            landingPage = container "Landing Page" "Public website for presenting the Vanana Platform." "HTML / CSS / JavaScript" "WebBrowser,Landing"
            webApp = container "Web App" "Authenticated web application for Vanana users." "Angular" "Angular"
            spa = container "Single Page Application" "Client-side application experience loaded by the web app." "Angular" "WebBrowser,Angular"
            mobileApp = container "Mobile App" "Mobile application for Vanana users." "Flutter" "MobileApp"
            mobileSqliteDatabase = container "Mobile SQLite Database" "Stores local mobile cache, user preferences, and offline data." "SQLite" "SQLite"
            apiGateway = container "API Gateway" "Routes client requests to Vanana backend services." "Spring Cloud Gateway / Java" "Gateway"
            platformApi = container "Platform API" "Handles core Vanana features, identity and access management, facilities, devices, telemetry, and user-facing workflows." "Spring Boot / Java 25" "SpringBoot" {
                iamContext = component "IAM" "Handles authentication, authorization, sessions, roles, permissions, and OAuth2 login flows." "Spring Boot / Java 25" "Bounded Context"
                billingContext = component "Billing" "Handles plans, subscriptions, checkout sessions, invoices, and billing state." "Spring Boot / Java 25" "Bounded Context"
                deviceSpaceContext = component "Device & Space Management" "Manages facilities, spaces, air sensors, device ownership, status, and configuration." "Spring Boot / Java 25" "Bounded Context"
                airQualityContext = component "Air Quality Evaluation" "Receives and evaluates air quality telemetry, metrics, thresholds, and health states." "Spring Boot / Java 25" "Bounded Context"
                alertingContext = component "Alerting & Response" "Creates alerts, notifications, and device response commands from air quality events." "Spring Boot / Java 25" "Bounded Context"
                analyticsContext = component "Analytics" "Builds historical insights, trends, reports, and aggregated air quality summaries." "Spring Boot / Java 25" "Bounded Context"
                notificationsContext = component "Notifications" "Manages notification templates, delivery requests, and notification history." "Spring Boot / Java 25" "Bounded Context"
                sharedContext = component "Shared" "Provides shared kernel code, common primitives, cross-cutting utilities, and reusable infrastructure adapters." "Spring Boot / Java 25" "Shared Kernel"
            }
            platformDatabase = container "Platform PostgreSQL Database" "Stores facilities, devices, telemetry summaries, user preferences, and platform operational data." "PostgreSQL" "Database"
            platformRedis = container "Platform Redis Database" "Stores sessions, access tokens, verification codes, rate limits, and short-lived platform data." "Redis" "Redis"
            clairEmbeddedApp = container "Clair Embedded Application" "Runs on the air sensor device to collect measurements and expose device telemetry locally." "Embedded firmware" "Embedded" {
                embeddedController = component "Embedded Controller" "Inbound adapter that receives local commands and telemetry ticks." "C/C++" "InboundAdapter,Firmware"
                embeddedTelemetryService = component "Embedded Telemetry Service" "Application service that validates and normalizes sensor readings before publish." "C/C++" "ApplicationService,Firmware"
                embeddedDomainModel = component "Embedded Domain Model" "Domain rules for device safety, valid ranges, and state transitions." "C/C++" "DomainModel,Firmware"
                embeddedIoAdapter = component "Embedded IO Adapter" "Outbound adapter for hardware IO, local state cache, and BLE/Wi-Fi telemetry publishing." "GPIO/I2C/UART + BLE/Wi-Fi" "OutboundAdapter,Firmware"
            }
            clairEdgeStationApp = container "Clair Edge Station Application" "Runs on-site as the local edge gateway for air sensor devices and synchronizes data with the platform." "Flask" "Edge" {
                edgeController = component "Edge Controller" "Inbound adapter that exposes local HTTP endpoints for mobile/operator access." "Flask/Python" "InboundAdapter,EdgeComponent"
                edgeProcessingService = component "Edge Processing Service" "Application service that ingests telemetry, deduplicates, and prepares local records." "Python" "ApplicationService,EdgeComponent"
                edgeSyncService = component "Edge Sync Service" "Application service that coordinates offline-first synchronization and command dispatch." "Python" "ApplicationService,EdgeComponent"
                edgeDomainModel = component "Edge Domain Model" "Domain rules for ingestion, deduplication, retry windows, and command routing constraints." "Python" "DomainModel,EdgeComponent"
                edgeIoAdapter = component "Edge IO Adapter" "Outbound adapter for MQTT device messaging, HTTPS cloud sync, and SQLite persistence." "MQTT + HTTPS + SQLite" "OutboundAdapter,EdgeComponent"
            }
            edgeSqliteDatabase = container "Edge SQLite Database" "Stores local device state, telemetry snapshots, and offline synchronization data at the edge." "SQLite" "SQLite"
        }

        # External Systems with specific tags for coloring
        hardware = softwareSystem "Clair Hardware" "Physical devices (sensors and actuators) installed on-site." "External,Hardware"
        google = softwareSystem "Google OAuth2" "External service for secure user authentication." "External,Google"
        stripe = softwareSystem "Stripe" "External platform for payment processing and subscription management." "External,Stripe"
        resend = softwareSystem "Resend" "External platform for transactional email delivery." "External,Email"

        # User Relationships
        admin -> vanana "Manages multiple facilities, sensors, and air quality monitoring operations"
        user -> vanana "Controls a personal air sensor and views home air quality metrics"

        # System Relationships
        vanana -> hardware "Sends commands to and receives telemetry from" "MQTT/HTTPS"
        vanana -> google "Authenticates users using" "OpenID Connect"
        vanana -> stripe "Processes payments and subscriptions via" "REST API"
        vanana -> resend "Sends transactional emails using" "REST API"
        
        # Container Relationships
        admin -> landingPage "Visits the public website to learn about the platform and access the application" "HTTPS"
        user -> landingPage "Visits the public website to learn about the platform and access the application" "HTTPS"
        landingPage -> webApp "Redirects users to the authenticated web application" "HTTPS"
        webApp -> spa "Serves the Angular single page application assets" "HTTPS"
        spa -> apiGateway "Calls protected platform APIs through the gateway" "JSON/HTTPS"
        user -> mobileApp "Uses the mobile application to control devices and view account information" "HTTPS"
        admin -> mobileApp "Uses the mobile application to monitor sensors and manage facilities while on-site" "HTTPS"
        mobileApp -> mobileSqliteDatabase "Stores and retrieves local cache, user preferences, and offline data" "SQLite"
        mobileApp -> apiGateway "Reads processed telemetry and sends remote device commands through the cloud" "JSON/HTTPS"
        apiGateway -> platformApi "Routes core platform API requests" "JSON/HTTPS"
        platformApi -> platformDatabase "Stores and retrieves facilities, devices, telemetry summaries, and operational data" "SQL"
        platformApi -> stripe "Creates checkout sessions, manages subscriptions, and receives payment status" "REST API/Webhooks"
        platformApi -> platformRedis "Stores and retrieves sessions, access tokens, verification codes, rate limits, and short-lived platform data" "RESP/TCP"
        platformApi -> google "Delegates social login and identity verification" "OpenID Connect"
        platformApi -> resend "Sends verification, password recovery, invitation, and account notification emails" "REST API"
        apiGateway -> iamContext "Routes authentication, authorization, and account requests" "JSON/HTTPS"
        apiGateway -> billingContext "Routes subscription and billing requests" "JSON/HTTPS"
        apiGateway -> deviceSpaceContext "Routes facility, space, and device management requests" "JSON/HTTPS"
        apiGateway -> airQualityContext "Routes telemetry ingestion and air quality evaluation requests" "JSON/HTTPS"
        apiGateway -> alertingContext "Routes alert and device response requests" "JSON/HTTPS"
        apiGateway -> analyticsContext "Routes reports, trends, and analytics requests" "JSON/HTTPS"
        apiGateway -> notificationsContext "Routes notification management requests" "JSON/HTTPS"
        iamContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        billingContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        deviceSpaceContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        airQualityContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        alertingContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        analyticsContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        notificationsContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        iamContext -> platformDatabase "Stores and retrieves IAM data" "SQL"
        billingContext -> platformDatabase "Stores and retrieves billing data" "SQL"
        deviceSpaceContext -> platformDatabase "Stores and retrieves device, facility, and space data" "SQL"
        airQualityContext -> platformDatabase "Stores and retrieves air quality evaluation data" "SQL"
        alertingContext -> platformDatabase "Stores and retrieves alerting and response data" "SQL"
        analyticsContext -> platformDatabase "Stores and retrieves analytics and reporting data" "SQL"
        iamContext -> platformRedis "Stores and retrieves sessions, access tokens, verification codes, and rate limits" "RESP/TCP"
        iamContext -> google "Delegates social login and identity verification" "OpenID Connect"
        notificationsContext -> platformDatabase "Stores and retrieves notification templates, delivery requests, and notification history" "SQL"
        notificationsContext -> resend "Sends transactional and alert emails" "REST API"
        billingContext -> stripe "Creates checkout sessions, manages subscriptions, and receives payment status" "REST API/Webhooks"
        clairEmbeddedApp -> hardware "Reads air quality measurements from the physical sensor hardware" "GPIO/I2C/UART"
        hardware -> embeddedIoAdapter "Provides raw measurements and actuator interfaces" "GPIO/I2C/UART"
        embeddedIoAdapter -> embeddedController "Delivers local command payloads and sensor tick inputs" "In-process call"
        embeddedController -> embeddedTelemetryService "Invokes telemetry and command use cases" "In-process call"
        embeddedTelemetryService -> embeddedDomainModel "Applies safety and validity rules" "In-process call"
        embeddedTelemetryService -> embeddedIoAdapter "Publishes telemetry and updates local runtime state" "In-process call"
        embeddedTelemetryService -> hardware "Applies safe device-level actions when required" "GPIO/I2C/UART"
        clairEdgeStationApp -> clairEmbeddedApp "Collects telemetry and sends local device commands" "MQTT/Local network"
        clairEdgeStationApp -> edgeSqliteDatabase "Stores and retrieves local device state, telemetry snapshots, and offline sync data" "SQLite"
        clairEdgeStationApp -> apiGateway "Sends processed air quality telemetry and device status to the cloud" "JSON/HTTPS"
        apiGateway -> clairEdgeStationApp "Delivers remote device commands to the edge station" "JSON/HTTPS"
        embeddedIoAdapter -> clairEdgeStationApp "Publishes local telemetry to the edge station" "MQTT/Local network"
        edgeController -> edgeProcessingService "Invokes local telemetry and health use cases" "In-process call"
        edgeController -> edgeSyncService "Invokes sync and command use cases" "In-process call"
        edgeIoAdapter -> edgeProcessingService "Forwards telemetry messages from embedded devices" "In-process call"
        edgeProcessingService -> edgeDomainModel "Applies ingestion and deduplication rules" "In-process call"
        edgeProcessingService -> edgeIoAdapter "Persists validated telemetry snapshots" "In-process call"
        edgeSyncService -> edgeDomainModel "Applies retry, batching, and routing rules" "In-process call"
        edgeSyncService -> edgeIoAdapter "Reads local queue/checkpoints and pushes telemetry" "In-process call"
        edgeIoAdapter -> apiGateway "Synchronizes edge telemetry and status" "JSON/HTTPS"
        apiGateway -> edgeController "Delivers remote commands to edge station endpoints" "JSON/HTTPS"
        edgeSyncService -> edgeIoAdapter "Dispatches commands to target embedded devices" "MQTT/Local network"
        edgeIoAdapter -> clairEmbeddedApp "Dispatches commands and receives telemetry streams" "MQTT/Local network"
        edgeIoAdapter -> edgeSqliteDatabase "Stores snapshots, queues, and checkpoints" "SQLite"
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
            include platformApi
            include platformDatabase
            include stripe
            include platformRedis
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

        component platformApi "PlatformApiComponents" {
            description "Component diagram for the Platform API"
            include *
            autoLayout lr
        }

        component clairEmbeddedApp "EmbeddedAppComponents" {
            description "Component diagram for the Clair Embedded Application"
            include *
            autoLayout lr
        }

        component clairEdgeStationApp "EdgeStationComponents" {
            description "Component diagram for the Clair Edge Station Application"
            include *
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
            element "Component" {
                background #1d4ed8
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
            element "Firmware" {
                background #a16207
            }
            element "Edge" {
                background #0f766e
            }
            element "EdgeComponent" {
                background #115e59
            }
            element "InboundAdapter" {
                background #0ea5e9
            }
            element "ApplicationService" {
                background #0f766e
            }
            element "DomainModel" {
                background #166534
            }
            element "OutboundAdapter" {
                background #b45309
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
