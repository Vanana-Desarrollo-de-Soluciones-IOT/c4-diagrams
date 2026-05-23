workspace "Vanana Platform - Development Deployment" "Development deployment diagram for Vanana IoT Platform" {

    !identifiers hierarchical

    model {
        # ============================================
        # USERS
        # ============================================
        developer = person "Developer" "Developer working on the Vanana platform."

        # ============================================
        # VANANA PLATFORM SYSTEM WITH CONTAINERS
        # ============================================
        vanana = softwareSystem "Vanana Platform" "Central platform for monitoring, controlling, and automating IoT devices." {
            
            landingPage = container "Landing Page" "Public website for presenting the Vanana Platform." "HTML / CSS / JavaScript" "WebBrowser"
            
            webApp = container "Web App" "Authenticated web application for Vanana users." "Angular" "WebBrowser"
            
            spa = container "Single Page Application" "Client-side application experience." "Angular" "WebBrowser"
            
            mobileApp = container "Mobile App" "Mobile application for Vanana users." "Flutter" "Mobile"
            
            mobileDb = container "Mobile SQLite" "Local mobile cache and offline data." "SQLite" "Database"
            
            apiGateway = container "API Gateway" "Routes client requests to backend services." "Spring Cloud Gateway" "Java"
            
            platformApi = container "Platform API" "Handles core Vanana features." "Spring Boot / Java 25" "Java"
            
            postgresDb = container "PostgreSQL Database" "Stores facilities, devices, telemetry, user data." "PostgreSQL" "Database"
            
            redisDb = container "Redis Database" "Sessions, tokens, cache." "Redis" "Database"
            
            edgeApp = container "Edge Application" "Local edge gateway for devices." "Python Flask" "Python"
            
            edgeDb = container "Edge SQLite" "Local device state and sync data." "SQLite" "Database"
            
            embeddedApp = container "Embedded App" "Firmware on air sensor device." "C++" "Embedded"
            kafka = container "Kafka Message Broker" "Async message broker that decouples edge telemetry from platform processing." "Apache Kafka" "MessageBroker"
        }

        # ============================================
        # EXTERNAL SYSTEMS
        # ============================================
        google = softwareSystem "Google OAuth2" "External authentication service."
        stripe = softwareSystem "Stripe" "Payment processing platform."
        resend = softwareSystem "Resend" "Transactional email delivery."
        hardware = softwareSystem "Clair Hardware" "Physical air sensors."

        # ============================================
        # RELATIONSHIPS
        # ============================================
        developer -> vanana "Develops and tests"
        
        vanana.landingPage -> vanana.webApp "Redirects to"
        vanana.webApp -> vanana.spa "Serves"
        vanana.spa -> vanana.apiGateway "API calls" "JSON/HTTPS"
        vanana.mobileApp -> vanana.mobileDb "Local data" "SQLite"
        vanana.mobileApp -> vanana.apiGateway "API calls" "JSON/HTTPS"
        vanana.apiGateway -> vanana.platformApi "Routes" "JSON/HTTPS"
        vanana.platformApi -> vanana.postgresDb "Persistence" "SQL"
        vanana.platformApi -> vanana.redisDb "Cache/Sessions" "RESP"
        vanana.platformApi -> google "OAuth" "OpenID Connect"
        vanana.platformApi -> stripe "Payments" "REST API"
        vanana.platformApi -> resend "Emails" "REST API"
        vanana.edgeApp -> vanana.edgeDb "Local storage" "SQLite"
        vanana.edgeApp -> vanana.kafka "Publishes telemetry and device status" "Kafka Wire Protocol"
        vanana.kafka -> vanana.platformApi "Delivers telemetry events" "Kafka Wire Protocol"
        vanana.platformApi -> vanana.kafka "Publishes remote device commands" "Kafka Wire Protocol"
        vanana.kafka -> vanana.edgeApp "Delivers remote command events" "Kafka Wire Protocol"
        vanana.embeddedApp -> hardware "Sensors" "GPIO/I2C"
        vanana.embeddedApp -> vanana.edgeApp "Telemetry" "REST/HTTPS"

        # ============================================
        # DEPLOYMENT ENVIRONMENT
        # ============================================
        deploymentEnvironment "Development" {
            
            cloud = deploymentNode "Vanana Cloud" "" "Linux / Docker" {

                # Backend Section
                backendContainer = deploymentNode "Backend Container" "" "Docker Container" {

                    jvm = deploymentNode "Java Virtual Machine" "" "Eclipse Temurin - JDK 25 - LTS" {
                        backendInstance = containerInstance vanana.platformApi
                    }

                    gatewayContainer = deploymentNode "Gateway Container" "" "Docker Container" {
                        gatewayInstance = containerInstance vanana.apiGateway
                    }

                    kafkaContainer = deploymentNode "Kafka Container" "" "Docker Container" {
                        kafkaInstance = containerInstance vanana.kafka
                    }
                }

                # Database Section
                databaseContainer = deploymentNode "Database Server Container" "" "Docker Container" {
                    databaseServer = deploymentNode "Database Server" "" "PostgreSQL 16" {
                        databaseInstance = containerInstance vanana.postgresDb
                    }
                }

                # Redis Section
                redisContainer = deploymentNode "Redis Container" "" "Docker Container" {
                    redisInstance = containerInstance vanana.redisDb
                }
            }

            # Mobile - User's smartphone
            mobileContainer = deploymentNode "Mobile Device" "" "Android / iOS" {
                mobileInstance = containerInstance vanana.mobileApp
                mobileDbInstance = containerInstance vanana.mobileDb
            }

            # Edge Station - On-site local gateway
            edgeContainer = deploymentNode "Edge Station" "" "Physical Hardware / Python" {
                edgeInstance = containerInstance vanana.edgeApp
                edgeDbInstance = containerInstance vanana.edgeDb
            }

            # Embedded Device - Physical sensor hardware
            embeddedContainer = deploymentNode "Embedded Device" "" "Physical Hardware / C++" {
                embeddedInstance = containerInstance vanana.embeddedApp
            }

            # External Systems - Deployed outside Vanana Cloud
            vercel = deploymentNode "Vercel" "" "Static Website Hosting" {
                landingPageContainer = deploymentNode "Landing Page" "" "Vercel" {
                    landingPageInstance = containerInstance vanana.landingPage
                }
                webAppContainer = deploymentNode "Web App" "" "Vercel" {
                    webAppInstance = containerInstance vanana.webApp
                    spaInstance = containerInstance vanana.spa
                }
            }

            externalServices = deploymentNode "External Services" "" "" {
                googleInstance = softwareSystemInstance google
                stripeInstance = softwareSystemInstance stripe
                resendInstance = softwareSystemInstance resend
                hardwareInstance = softwareSystemInstance hardware
            }
        }
    }

    views {
        # ============================================
        # DEPLOYMENT VIEW
        # ============================================
        deployment vanana "Development" "Development" {
            description "Development deployment diagram for Vanana Platform showing local Docker containers."
            include *
            autoLayout lr 100 400
        }
        
        # ============================================
        # STYLES - Matching the C4 Model image
        # ============================================
        styles {
            element "Person" {
                shape person
                background #374151
                color #ffffff
            }
            element "Software System" {
                background #2563eb
                color #ffffff
            }
            element "Container" {
                background #2563eb
                color #ffffff
            }
            element "Container Instance" {
                background #2563eb
                color #ffffff
            }
            element "WebBrowser" {
                shape webbrowser
                background #0f766e
            }
            element "Mobile" {
                shape mobiledeviceportrait
                background #0284c7
            }
            element "Database" {
                shape cylinder
                background #4b5563
            }
            element "Java" {
                background #16a34a
            }
            element "Python" {
                background #0f766e
            }
            element "Embedded" {
                background #ca8a04
            }
            element "Deployment Node" {
                color #374151
            }
        }
    }
}
