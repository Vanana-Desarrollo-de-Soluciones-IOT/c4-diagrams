workspace "Vanana System Landscape" "System Landscape diagram showing all software systems within the Vanana ecosystem as peers." {

    model {
        # People - estos interactuan con TODOS los sistemas relevantes
        admin = person "Facility Admin" "Owner or operator of multiple air sensors across facilities."
        user = person "Home User" "Customer who uses a personal air sensor at home."

        # All software systems as PEERS - no one is "central" in a landscape diagram
        vanana = softwareSystem "Vanana Platform" "Central platform for monitoring and automating IoT air quality devices."
        google = softwareSystem "Google OAuth2" "External authentication service."
        stripe = softwareSystem "Stripe" "External payment processing platform."
        resend = softwareSystem "Resend" "External transactional email delivery platform."
        hardware = softwareSystem "Clair Hardware" "Physical air quality sensors and actuators."

        # Relationships - people interact with multiple systems
        admin -> vanana "Manages facilities and monitors air quality"
        admin -> google "Authenticates using social login"
        admin -> stripe "Manages subscription and payments"

        user -> vanana "Monitors home air quality"
        user -> google "Authenticates using social login"
        user -> stripe "Subscribes to premium plan"

        # Systems interact with each other as peers
        vanana -> google "Authenticates users via OpenID Connect"
        vanana -> stripe "Processes payments and subscriptions"
        vanana -> resend "Sends transactional emails"
        vanana -> hardware "Commands and receives telemetry"

        # External systems may also have relationships
        stripe -> google "Uses for identity verification on checkout" "OAuth2"
    }

    views {
        systemLandscape "VananaSystemLandscape" {
            description "System Landscape diagram for the Vanana ecosystem - all systems shown as peers"
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape person
                background #374151
            }
            element "software system" {
                background #2563eb
            }
        }
    }
}