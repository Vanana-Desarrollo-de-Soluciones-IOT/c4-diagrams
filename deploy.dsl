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
            
            embeddedApp = container "Embedded App" "Firmware on air sensor device." "C/C++" "Embedded"
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
        vanana.edgeApp -> vanana.apiGateway "Sync" "HTTPS"
        vanana.embeddedApp -> hardware "Sensors" "GPIO/I2C"
        vanana.embeddedApp -> vanana.edgeApp "Telemetry" "MQTT"

        # ============================================
        # DEVELOPMENT DEPLOYMENT ENVIRONMENT
        # ============================================
        development = deploymentEnvironment "Development" {
            
            bigBankWAN = deploymentNode "Big Bank Wide Area Network" "" "" {
                
                devLaptop = deploymentNode "Developer Laptop" "" "Microsoft Windows 11 or Apple macOS" {
                    
                    # Frontend Section
                    webServerContainer = deploymentNode "Web Server Container" "" "Docker Container" {
                        webServer = deploymentNode "Web Server" "" "nginx" {
                            staticContent = containerInstance vanana.landingPage
                        }
                    }
                    
                    # Dashboard Section
                    dashboardServer = deploymentNode "Dashboard Server" "" "Angular CLI" {
                        webAppInstance = containerInstance vanana.webApp
                        spaInstance = containerInstance vanana.spa
                    }
                    
                    # Mobile Section
                    mobileContainer = deploymentNode "Mobile Container" "" "Android Emulator" {
                        mobileInstance = containerInstance vanana.mobileApp
                        mobileDbInstance = containerInstance vanana.mobileDb
                    }
                    
                    # Backend Section
                    backendContainer = deploymentNode "Backend Container" "" "Docker Container" {
                        
                        jvm = deploymentNode "Java Virtual Machine" "" "Eclipse Temurin - JDK 25 - LTS" {
                            backendInstance = containerInstance vanana.platformApi
                        }
                        
                        gatewayContainer = deploymentNode "Gateway Container" "" "Docker Container" {
                            gatewayInstance = containerInstance vanana.apiGateway
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
                    
                    # Edge Section
                    edgeContainer = deploymentNode "Edge Container" "" "Docker Container" {
                        edgeInstance = deploymentNode "Edge Station" "" "Python 3.11" {
                            edgeAppInstance = containerInstance vanana.edgeApp
                            edgeDbInstance = containerInstance vanana.edgeDb
                        }
                    }
                    
                    # Embedded Section
                    embeddedContainer = deploymentNode "Embedded Simulator" "" "Docker Container / QEMU" {
                        embeddedInstance = containerInstance vanana.embeddedApp
                    }
                }
                
                # External Systems
                dataCenter = deploymentNode "Big Bank Data Center" "" "" {
                    coreSystem = deploymentNode "corebanking-dev" "" "Ubuntu 24.04 LTS" {
                        # External systems for dev
                    }
                }
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
            autoLayout lr
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
                background #ffffff
                color #374151
            }
        }
    }
}
