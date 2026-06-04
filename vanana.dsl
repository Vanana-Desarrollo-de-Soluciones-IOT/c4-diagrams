workspace "Vanana Platform" "High-level architecture for smart device management." {

    model {
        # Users
        admin = person "Facility Admin" "Owner or operator of multiple air sensors across one or more facilities or locations."
        user = person "Home User" "Customer who owns or uses a personal air sensor at home."

        # Central System
        vanana = softwareSystem "Vanana Platform" "Central platform for monitoring, controlling, and automating IoT devices." {
            landingPage = container "Landing Page" "Public website for presenting the Vanana Platform." "HTML / CSS / JavaScript" "WebBrowser,Landing"
            webApp = container "Web App" "Authenticated web application for Vanana users." "Angular" "Angular" {
                webSharedContext = component "Shared" "Shared UI shell, NotificationService for OneSignal, reusable components, logos, icons, guards, and cross-cutting presentation helpers." "Angular / TypeScript" "Component"
                webIamContext = component "IAM" "Registration, login, email confirmation, session state, route guards, and notification permissions." "Angular / TypeScript" "Component"
                webDeviceContext = component "Device" "Organizations, spaces, devices, pairing, commands, thresholds, and ACL access to evaluation context." "Angular / TypeScript" "Component"
                webAnalyticsContext = component "Analytics" "Consolidated views, metrics, trends, ICA, and navigation by org/space/device using device and evaluation facades." "Angular / TypeScript" "Component"
                webAlertingContext = component "Alerting" "Active and resolved alerts, severity, pagination, daily summary, and device hierarchy lookups." "Angular / TypeScript" "Component"
                webBillingContext = component "Billing" "Plans, Premium subscription, checkout, and plan state." "Angular / TypeScript" "Component"
                webNotificationsContext = component "Notifications" "Push notifications, permissions, and notification delivery state." "Angular / TypeScript" "Component"
                webEvaluationContext = component "Evaluation" "Device telemetry evaluation, latest technical state, and connection state." "Angular / TypeScript" "Component"
            }
            spa = container "Single Page Application" "Client-side application experience loaded by the web app." "Angular" "WebBrowser,Angular"
            mobileApp = container "Mobile App" "Mobile application for Vanana users." "Flutter" "MobileApp" {
                mobileSharedContext = component "Shared" "Common UI components, app bar, bottom navigation, and icons. No business logic." "Flutter / Dart" "Component"
                mobileIamContext = component "IAM" "Login, registration, session state, and token handling." "Flutter / Dart" "Component"
                mobileDeviceContext = component "Devices" "Organizations, spaces, devices, thresholds, and commands." "Flutter / Dart" "Component"
                mobileEvaluationContext = component "Evaluation" "Reads the latest telemetry and evaluation state for a device." "Flutter / Dart" "Component"
                mobileAnalyticsContext = component "Analytics" "Dashboard, trends, and live telemetry." "Flutter / Dart" "Component"
                mobileAlertsContext = component "Alerts" "Alert list, filters, and daily summary." "Flutter / Dart" "Component"
                mobileNotificationsContext = component "Notifications" "Push notification history." "Flutter / Dart" "Component"
            }
            mobileSqliteDatabase = container "Mobile SQLite Database" "Stores local mobile cache, user preferences, and offline data." "SQLite" "SQLite"
            apiGateway = container "API Gateway" "Routes client requests to Vanana backend services." "Spring Cloud Gateway / Java" "Gateway"
            platformApi = container "Platform API" "Handles core Vanana features, identity and access management, facilities, devices, telemetry, and user-facing workflows." "Spring Boot / Java 25" "SpringBoot" {
                iamContext = component "IAM" "Handles authentication, authorization, sessions, roles, permissions, and OAuth2 login flows." "Spring Boot / Java 25" "Bounded Context"
                iamInterfacesLayer = component "IAM Interfaces" "Controllers and interface adapters that receive IAM requests and map them to use cases." "Spring MVC / Spring Security" "InterfacesLayer,InboundAdapter"
                iamApplicationLayer = component "IAM Application" "Application services and use cases that orchestrate IAM workflows." "Spring Services" "ApplicationLayer,ApplicationService"
                iamDomainLayer = component "IAM Domain" "Domain entities, value objects, policies, and business rules for IAM." "Java Domain" "DomainLayer,DomainModel"
                iamInfrastructureLayer = component "IAM Infrastructure" "Repositories and adapters for persistence, cache, and OAuth providers." "Spring Data / Integrations" "InfrastructureLayer,OutboundAdapter"
                billingContext = component "Billing" "Handles plans, subscriptions, checkout sessions, invoices, and billing state." "Spring Boot / Java 25" "Bounded Context"
                billingInterfacesLayer = component "Billing Interfaces" "Controllers and interface adapters that receive billing requests and map them to use cases." "Spring MVC" "InterfacesLayer,InboundAdapter"
                billingApplicationLayer = component "Billing Application" "Application services and use cases for subscriptions, invoices, and checkout orchestration." "Spring Services" "ApplicationLayer,ApplicationService"
                billingDomainLayer = component "Billing Domain" "Domain entities, value objects, policies, and business rules for billing." "Java Domain" "DomainLayer,DomainModel"
                billingInfrastructureLayer = component "Billing Infrastructure" "Repositories and adapters for PostgreSQL persistence and Stripe integration." "Spring Data / Stripe SDK" "InfrastructureLayer,OutboundAdapter"
                deviceSpaceContext = component "Device & Space Management" "Manages facilities, spaces, air sensors, device ownership, status, and configuration." "Spring Boot / Java 25" "Bounded Context"
                deviceSpaceInterfacesLayer = component "DeviceSpace Interfaces" "Controllers and interface adapters that receive device and space management requests." "Spring MVC" "InterfacesLayer,InboundAdapter"
                deviceSpaceApplicationLayer = component "DeviceSpace Application" "Application services and use cases for facilities, spaces, devices, and ownership workflows." "Spring Services" "ApplicationLayer,ApplicationService"
                deviceSpaceDomainLayer = component "DeviceSpace Domain" "Domain entities, value objects, policies, and business rules for device and space management." "Java Domain" "DomainLayer,DomainModel"
                deviceSpaceInfrastructureLayer = component "DeviceSpace Infrastructure" "Repositories and persistence adapters for facilities, spaces, and devices." "Spring Data" "InfrastructureLayer,OutboundAdapter"
                airQualityContext = component "Air Quality Evaluation" "Receives and evaluates air quality telemetry, metrics, thresholds, and health states." "Spring Boot / Java 25" "Bounded Context"
                airQualityInterfacesLayer = component "AirQuality Interfaces" "Controllers and interface adapters that receive telemetry ingestion and evaluation requests." "Spring MVC" "InterfacesLayer,InboundAdapter"
                airQualityApplicationLayer = component "AirQuality Application" "Application services and use cases for telemetry normalization, evaluation, and health state orchestration." "Spring Services" "ApplicationLayer,ApplicationService"
                airQualityDomainLayer = component "AirQuality Domain" "Domain entities, value objects, thresholds, metrics, and decision rules for air quality evaluation." "Java Domain" "DomainLayer,DomainModel"
                airQualityInfrastructureLayer = component "AirQuality Infrastructure" "Repositories and persistence adapters for telemetry evaluation and historical summaries." "Spring Data" "InfrastructureLayer,OutboundAdapter"
                alertingContext = component "Alerting & Response" "Creates alerts, notifications, and device response commands from air quality events." "Spring Boot / Java 25" "Bounded Context"
                alertingInterfacesLayer = component "Alerting Interfaces" "Controllers and interface adapters that receive alerting and response requests." "Spring MVC" "InterfacesLayer,InboundAdapter"
                alertingApplicationLayer = component "Alerting Application" "Application services and use cases for alert lifecycle, escalation, and response orchestration." "Spring Services" "ApplicationLayer,ApplicationService"
                alertingDomainLayer = component "Alerting Domain" "Domain entities, value objects, policies, and rules for alerts and response actions." "Java Domain" "DomainLayer,DomainModel"
                alertingInfrastructureLayer = component "Alerting Infrastructure" "Repositories and persistence adapters for alerts, actions, and delivery state." "Spring Data" "InfrastructureLayer,OutboundAdapter"
                analyticsContext = component "Analytics" "Builds historical insights, trends, reports, and aggregated air quality summaries." "Spring Boot / Java 25" "Bounded Context"
                analyticsInterfacesLayer = component "Analytics Interfaces" "Controllers and interface adapters that receive analytics and reporting queries." "Spring MVC" "InterfacesLayer,InboundAdapter"
                analyticsApplicationLayer = component "Analytics Application" "Application services and use cases for report generation, aggregation, and trend analysis." "Spring Services" "ApplicationLayer,ApplicationService"
                analyticsDomainLayer = component "Analytics Domain" "Domain entities, value objects, and rules for analytics calculations and reporting semantics." "Java Domain" "DomainLayer,DomainModel"
                analyticsInfrastructureLayer = component "Analytics Infrastructure" "Repositories and persistence adapters for aggregates, snapshots, and report datasets." "Spring Data" "InfrastructureLayer,OutboundAdapter"
                notificationsContext = component "Notifications" "Manages notification templates, delivery requests, and notification history." "Spring Boot / Java 25" "Bounded Context"
                notificationsInterfacesLayer = component "Notifications Interfaces" "Controllers and interface adapters that receive notification management and delivery requests." "Spring MVC" "InterfacesLayer,InboundAdapter"
                notificationsApplicationLayer = component "Notifications Application" "Application services and use cases for template management, routing, and delivery orchestration." "Spring Services" "ApplicationLayer,ApplicationService"
                notificationsDomainLayer = component "Notifications Domain" "Domain entities, value objects, policies, and rules for notification lifecycle and channels." "Java Domain" "DomainLayer,DomainModel"
                notificationsInfrastructureLayer = component "Notifications Infrastructure" "Repositories and adapters for notification persistence and Resend delivery integration." "Spring Data / Resend API" "InfrastructureLayer,OutboundAdapter"
                sharedContext = component "Shared" "Provides shared kernel code, common primitives, cross-cutting utilities, and reusable infrastructure adapters." "Spring Boot / Java 25" "Shared Kernel"
            }
            platformDatabase = container "Platform PostgreSQL Database" "Stores facilities, devices, telemetry summaries, user preferences, and platform operational data." "PostgreSQL" "Database"
            platformRedis = container "Platform Redis Database" "Stores sessions, access tokens, verification codes, rate limits, and short-lived platform data." "Redis" "Redis"
            clairEmbeddedApp = container "Clair Embedded Application" "Runs on the air sensor device to collect measurements and expose device telemetry locally." "Embedded firmware" "Embedded" {
                embeddedController = component "Embedded Controller" "Inbound adapter that receives local commands and telemetry ticks." "C++" "InboundAdapter,Firmware"
                embeddedTelemetryService = component "Embedded Telemetry Service" "Application service that validates and normalizes sensor readings before publish." "C++" "ApplicationService,Firmware"
                embeddedDomainModel = component "Embedded Domain Model" "Domain rules for device safety, valid ranges, and state transitions." "C++" "DomainModel,Firmware"
                embeddedIoAdapter = component "Embedded IO Adapter" "Outbound adapter for hardware IO, local state cache, and BLE/Wi-Fi telemetry publishing." "GPIO/I2C/UART + BLE/Wi-Fi" "OutboundAdapter,Firmware"
            }
            clairEdgeStationApp = container "Clair Edge Station Application" "Runs on-site as the local edge gateway for air sensor devices and synchronizes data with the platform." "Flask" "Edge" {
                edgeSharedContext = component "Shared" "Capa comun de persistencia e infraestructura. Configura Peewee sobre SQLite y migraciones automaticas de esquemas al arranque de Flask." "Python / Peewee" "EdgeComponent"
                edgeProvisioningContext = component "Provisioning" "Mantiene un espejo local en SQLite de los metadatos de los dispositivos registrados en el backend central." "Python" "EdgeComponent"
                edgeIamContext = component "IAM" "Autenticacion local sin latencia de red y publicacion del estado de conexion (presencia)." "Python" "EdgeComponent"
                edgeDeviceContext = component "Device" "Recepcion de telemetria IoT y despacho de comandos enviados desde la nube." "Python" "EdgeComponent"
                edgeAlertingContext = component "Alerting" "Almacenamiento local de incidentes generados por el motor de reglas central para consumo del firmware." "Python" "EdgeComponent"
            }
            edgeSqliteDatabase = container "Edge SQLite Database" "Stores local device state, telemetry snapshots, and offline synchronization data at the edge." "SQLite" "SQLite"
            kafka = container "Kafka Message Broker" "Async message broker that decouples edge telemetry ingestion from platform processing." "Apache Kafka" "MessageBroker"
        }

        # External Systems with specific tags for coloring
        hardware = softwareSystem "Clair Hardware" "Physical devices (sensors and actuators) installed on-site." "External,Hardware"
        google = softwareSystem "Google OAuth2" "External service for secure user authentication." "External,Google"
        stripe = softwareSystem "Stripe" "External platform for payment processing and subscription management." "External,Stripe"
        onesignal = softwareSystem "OneSignal" "External platform for push notifications." "External,Push"
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
        mobileIamContext -> mobileSqliteDatabase "Stores tokens and session state" "SQLite"
        mobileIamContext -> apiGateway "Uses auth APIs" "JSON/HTTPS"
        mobileDeviceContext -> mobileEvaluationContext "Uses device health data" "In-process call"
        mobileDeviceContext -> mobileSqliteDatabase "Stores device state and filters" "SQLite"
        mobileDeviceContext -> apiGateway "Uses device APIs" "JSON/HTTPS"
        mobileAnalyticsContext -> mobileDeviceContext "Uses org and device navigation" "In-process call"
        mobileAnalyticsContext -> apiGateway "Uses analytics APIs" "JSON/HTTPS"
        mobileAlertsContext -> apiGateway "Uses alerts APIs" "JSON/HTTPS"
        mobileNotificationsContext -> apiGateway "Uses notifications APIs" "JSON/HTTPS"
        mobileNotificationsContext -> mobileSqliteDatabase "Stores push history" "SQLite"
        apiGateway -> platformApi "Routes core platform API requests" "JSON/HTTPS"
        platformApi -> platformDatabase "Stores and retrieves facilities, devices, telemetry summaries, and operational data" "SQL"
        platformApi -> stripe "Creates checkout sessions, manages subscriptions, and receives payment status" "REST API/Webhooks"
        platformApi -> platformRedis "Stores and retrieves sessions, access tokens, verification codes, rate limits, and short-lived platform data" "RESP/TCP"
        platformApi -> google "Delegates social login and identity verification" "OpenID Connect"
        platformApi -> resend "Sends verification, password recovery, invitation, and account notification emails" "REST API"
        webNotificationsContext -> onesignal "Uses OneSignal" "OneSignal SDK"
        mobileNotificationsContext -> onesignal "Listens to push events" "OneSignal SDK"
        apiGateway -> iamContext "Routes authentication, authorization, and account requests" "JSON/HTTPS"
        iamContext -> iamInterfacesLayer "Exposes IAM entry points" "In-process call"
        iamInterfacesLayer -> iamApplicationLayer "Invokes IAM use cases" "In-process call"
        iamApplicationLayer -> iamDomainLayer "Applies IAM business rules" "In-process call"
        iamApplicationLayer -> iamInfrastructureLayer "Uses repositories and outbound adapters" "In-process call"
        iamInfrastructureLayer -> platformDatabase "Stores IAM accounts, roles, and permissions" "SQL"
        iamInfrastructureLayer -> platformRedis "Stores sessions and token state" "RESP/TCP"
        iamInfrastructureLayer -> google "Delegates social login and identity verification" "OpenID Connect"
        apiGateway -> billingContext "Routes subscription and billing requests" "JSON/HTTPS"
        billingContext -> billingInterfacesLayer "Exposes billing entry points" "In-process call"
        billingInterfacesLayer -> billingApplicationLayer "Invokes billing use cases" "In-process call"
        billingApplicationLayer -> billingDomainLayer "Applies billing business rules" "In-process call"
        billingApplicationLayer -> billingInfrastructureLayer "Uses repositories and payment adapters" "In-process call"
        billingInfrastructureLayer -> platformDatabase "Stores subscriptions, invoices, and billing state" "SQL"
        billingInfrastructureLayer -> stripe "Creates checkout sessions and updates subscription state" "REST API/Webhooks"
        apiGateway -> deviceSpaceContext "Routes facility, space, and device management requests" "JSON/HTTPS"
        deviceSpaceContext -> deviceSpaceInterfacesLayer "Exposes device and space entry points" "In-process call"
        deviceSpaceInterfacesLayer -> deviceSpaceApplicationLayer "Invokes device and space use cases" "In-process call"
        deviceSpaceApplicationLayer -> deviceSpaceDomainLayer "Applies device and space business rules" "In-process call"
        deviceSpaceApplicationLayer -> deviceSpaceInfrastructureLayer "Uses repositories and outbound adapters" "In-process call"
        deviceSpaceInfrastructureLayer -> platformDatabase "Stores facilities, spaces, devices, and ownership state" "SQL"
        apiGateway -> airQualityContext "Routes telemetry ingestion and air quality evaluation requests" "JSON/HTTPS"
        airQualityContext -> airQualityInterfacesLayer "Exposes telemetry and evaluation entry points" "In-process call"
        airQualityInterfacesLayer -> airQualityApplicationLayer "Invokes air quality use cases" "In-process call"
        airQualityApplicationLayer -> airQualityDomainLayer "Applies air quality business rules" "In-process call"
        airQualityApplicationLayer -> airQualityInfrastructureLayer "Uses repositories and outbound adapters" "In-process call"
        airQualityInfrastructureLayer -> platformDatabase "Stores telemetry evaluations and quality states" "SQL"
        apiGateway -> alertingContext "Routes alert and device response requests" "JSON/HTTPS"
        alertingContext -> alertingInterfacesLayer "Exposes alerting and response entry points" "In-process call"
        alertingInterfacesLayer -> alertingApplicationLayer "Invokes alerting use cases" "In-process call"
        alertingApplicationLayer -> alertingDomainLayer "Applies alerting business rules" "In-process call"
        alertingApplicationLayer -> alertingInfrastructureLayer "Uses repositories and outbound adapters" "In-process call"
        alertingInfrastructureLayer -> platformDatabase "Stores alerts, escalations, and response actions" "SQL"
        apiGateway -> analyticsContext "Routes reports, trends, and analytics requests" "JSON/HTTPS"
        analyticsContext -> analyticsInterfacesLayer "Exposes analytics and reporting entry points" "In-process call"
        analyticsInterfacesLayer -> analyticsApplicationLayer "Invokes analytics use cases" "In-process call"
        analyticsApplicationLayer -> analyticsDomainLayer "Applies analytics business rules" "In-process call"
        analyticsApplicationLayer -> analyticsInfrastructureLayer "Uses repositories and outbound adapters" "In-process call"
        analyticsInfrastructureLayer -> platformDatabase "Stores aggregates, trends, and reporting snapshots" "SQL"
        apiGateway -> notificationsContext "Routes notification management requests" "JSON/HTTPS"
        notificationsContext -> notificationsInterfacesLayer "Exposes notification entry points" "In-process call"
        notificationsInterfacesLayer -> notificationsApplicationLayer "Invokes notification use cases" "In-process call"
        notificationsApplicationLayer -> notificationsDomainLayer "Applies notification business rules" "In-process call"
        notificationsApplicationLayer -> notificationsInfrastructureLayer "Uses repositories and delivery adapters" "In-process call"
        notificationsInfrastructureLayer -> platformDatabase "Stores templates, deliveries, and notification history" "SQL"
        notificationsInfrastructureLayer -> resend "Sends transactional and alert emails" "REST API"
        iamContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        billingContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        deviceSpaceContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        airQualityContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        alertingContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        analyticsContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        notificationsContext -> sharedContext "Uses shared kernel and cross-cutting utilities" "In-process call"
        airQualityContext -> alertingContext "Publishes threshold breach events for alert generation" "In-process event"
        alertingContext -> notificationsContext "Requests delivery for generated alerts" "In-process call"
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
        clairEdgeStationApp -> clairEmbeddedApp "Collects telemetry and sends local device commands" "REST/HTTPS"
        clairEdgeStationApp -> edgeSqliteDatabase "Stores and retrieves local device state, telemetry snapshots, and offline sync data" "SQLite"
        clairEdgeStationApp -> kafka "Publishes air quality telemetry and device status events" "Kafka Wire Protocol"
        kafka -> apiGateway "Delivers telemetry and device events to the platform" "Kafka Wire Protocol"
        apiGateway -> kafka "Publishes remote device commands as events" "Kafka Wire Protocol"
        kafka -> clairEdgeStationApp "Delivers remote command events to the edge" "Kafka Wire Protocol"
        embeddedIoAdapter -> clairEdgeStationApp "Publishes local telemetry to the edge station" "REST/HTTPS"
        webIamContext -> webSharedContext "Uses route guard" "In-process call"
        webIamContext -> spa "Uses spa" "In-process call"
        webAnalyticsContext -> webDeviceContext "Uses device facade" "ACL + Facade + DI"
        webAnalyticsContext -> webEvaluationContext "Uses evaluation facade" "ACL + Facade + DI"
        webAnalyticsContext -> spa "Uses spa" "In-process call"
        webDeviceContext -> webEvaluationContext "Uses evaluation facade" "ACL + Facade + DI"
        webDeviceContext -> spa "Uses spa" "In-process call"
        webAlertingContext -> webDeviceContext "Uses device facade" "ACL + Facade + DI"
        webAlertingContext -> spa "Uses spa" "In-process call"
        webBillingContext -> stripe "Uses Stripe" "REST API/Webhooks"
        webBillingContext -> spa "Uses spa" "In-process call"
        webNotificationsContext -> webSharedContext "Uses NotificationService" "In-process call"
        webNotificationsContext -> spa "Uses spa" "In-process call"
        webEvaluationContext -> webSharedContext "Uses shared UI helpers" "In-process call"
        webEvaluationContext -> spa "Uses spa" "In-process call"
        edgeSharedContext -> edgeSqliteDatabase "Configures ORM and runs schema migrations" "SQLite"
        edgeProvisioningContext -> kafka "Listens to clair.provisioning.devices.changed" "Kafka Wire Protocol"
        edgeProvisioningContext -> edgeSqliteDatabase "Upserts device cache records" "SQLite"
        edgeProvisioningContext -> edgeSharedContext "Uses shared persistence and infrastructure" "In-process call"
        edgeIamContext -> edgeSqliteDatabase "Authenticates locally and tracks device presence" "SQLite"
        edgeIamContext -> kafka "Publishes device presence events" "Kafka Wire Protocol"
        edgeIamContext -> edgeSharedContext "Uses shared persistence and infrastructure" "In-process call"
        edgeDeviceContext -> edgeIamContext "Authenticates telemetry and command requests" "In-process call"
        edgeDeviceContext -> edgeSqliteDatabase "Stores telemetry and command outbox state" "SQLite"
        edgeDeviceContext -> kafka "Publishes telemetry and ACK events" "Kafka Wire Protocol"
        edgeDeviceContext -> clairEmbeddedApp "Sends pending commands and receives telemetry" "REST/HTTPS"
        edgeDeviceContext -> edgeSharedContext "Uses shared persistence and infrastructure" "In-process call"
        edgeAlertingContext -> kafka "Listens to incident change events" "Kafka Wire Protocol"
        edgeAlertingContext -> edgeSqliteDatabase "Stores local incidents and alert state" "SQLite"
        edgeAlertingContext -> clairEmbeddedApp "Exposes pending incidents and receives ACKs" "REST/HTTPS"
        edgeAlertingContext -> edgeSharedContext "Uses shared persistence and infrastructure" "In-process call"

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
            include kafka
            include hardware
            include google
            include onesignal
            include resend
            include admin
            include user
            autoLayout lr
        }

        component webApp "WebAppComponents" {
            description "Component diagram for the authenticated web application"
            include webSharedContext
            include webIamContext
            include webDeviceContext
            include webAnalyticsContext
            include webAlertingContext
            include webBillingContext
            include webNotificationsContext
            include webEvaluationContext
            include spa
            include onesignal
            include stripe
            autoLayout lr
        }

        component mobileApp "MobileAppComponents" {
            description "Component diagram for the mobile application"
            include mobileSharedContext
            include mobileIamContext
            include mobileDeviceContext
            include mobileEvaluationContext
            include mobileAnalyticsContext
            include mobileAlertsContext
            include mobileNotificationsContext
            include mobileSqliteDatabase
            include apiGateway
            include onesignal
            autoLayout lr
        }

        component platformApi "PlatformApiComponents" {
            description "Bounded context component diagram for the Platform API"
            include apiGateway
            include iamContext
            include billingContext
            include deviceSpaceContext
            include airQualityContext
            include alertingContext
            include analyticsContext
            include notificationsContext
            include sharedContext
            include platformDatabase
            include platformRedis
            include google
            include stripe
            include resend
            autoLayout lr
        }

        component platformApi "IamLayers" {
            description "Detailed layered view inside IAM: Interfaces, Application, Domain, and Infrastructure."
            include iamInterfacesLayer
            include iamApplicationLayer
            include iamDomainLayer
            include iamInfrastructureLayer
            include platformDatabase
            include platformRedis
            include google
            autoLayout lr
        }

        component platformApi "BillingLayers" {
            description "Detailed layered view inside Billing: Interfaces, Application, Domain, and Infrastructure."
            include billingInterfacesLayer
            include billingApplicationLayer
            include billingDomainLayer
            include billingInfrastructureLayer
            include platformDatabase
            include stripe
            autoLayout lr
        }

        component platformApi "DeviceSpaceLayers" {
            description "Detailed layered view inside Device & Space Management: Interfaces, Application, Domain, and Infrastructure."
            include deviceSpaceInterfacesLayer
            include deviceSpaceApplicationLayer
            include deviceSpaceDomainLayer
            include deviceSpaceInfrastructureLayer
            include platformDatabase
            autoLayout lr
        }

        component platformApi "AirQualityLayers" {
            description "Detailed layered view inside Air Quality Evaluation: Interfaces, Application, Domain, and Infrastructure."
            include airQualityInterfacesLayer
            include airQualityApplicationLayer
            include airQualityDomainLayer
            include airQualityInfrastructureLayer
            include platformDatabase
            autoLayout lr
        }

        component platformApi "AlertingLayers" {
            description "Detailed layered view inside Alerting & Response: Interfaces, Application, Domain, and Infrastructure."
            include alertingInterfacesLayer
            include alertingApplicationLayer
            include alertingDomainLayer
            include alertingInfrastructureLayer
            include platformDatabase
            autoLayout lr
        }

        component platformApi "AnalyticsLayers" {
            description "Detailed layered view inside Analytics: Interfaces, Application, Domain, and Infrastructure."
            include analyticsInterfacesLayer
            include analyticsApplicationLayer
            include analyticsDomainLayer
            include analyticsInfrastructureLayer
            include platformDatabase
            autoLayout lr
        }

        component platformApi "NotificationsLayers" {
            description "Detailed layered view inside Notifications: Interfaces, Application, Domain, and Infrastructure."
            include notificationsInterfacesLayer
            include notificationsApplicationLayer
            include notificationsDomainLayer
            include notificationsInfrastructureLayer
            include platformDatabase
            include resend
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
            element "Push" {
                background #14b8a6
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
            element "InterfacesLayer" {
                background #0ea5e9
            }
            element "ApplicationLayer" {
                background #0f766e
            }
            element "DomainLayer" {
                background #166534
            }
            element "InfrastructureLayer" {
                background #b45309
            }
        }
    }
}
