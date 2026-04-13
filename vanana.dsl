workspace "Vanana Platform" "Arquitectura de alto nivel para gestión de dispositivos inteligentes." {

    model {
        # Usuarios
        admin = person "Facility Admin" "Administrador encargado de la gestión de instalaciones y edificios."
        user = person "Home User" "Usuario final que controla sus dispositivos domésticos."

        # Sistema Central
        vanana = softwareSystem "Vanana Platform" "Plataforma central para el monitoreo, control y automatización de dispositivos IoT."

        # Sistemas Externos
        hardware = softwareSystem "Clair Hardware" "Dispositivos físicos (sensores y actuadores) instalados en sitio." "External"
        google = softwareSystem "Google OAuth2" "Servicio externo para autenticación segura de usuarios." "External"
        stripe = softwareSystem "Stripe" "Plataforma para el procesamiento de pagos y gestión de suscripciones." "External"

        # Relaciones de Usuario
        admin -> vanana "Gestiona instalaciones y monitorea flotas de dispositivos"
        user -> vanana "Controla dispositivos y visualiza métricas personales"

        # Relaciones del Sistema
        vanana -> hardware "Envía comandos y recibe telemetría de" "MQTT/HTTPS"
        vanana -> google "Autentica usuarios mediante" "OpenID Connect"
        vanana -> stripe "Procesa cobros y suscripciones mediante" "REST API"
        
        # Relación de Hardware a Usuarios (Opcional, pero da contexto)
        hardware -> user "Provee feedback visual/físico en el hogar"
    }

    views {
        systemContext vanana "ContextoVanana" {
            description "Diagrama de Contexto para la Plataforma Vanana"
            include *
            autoLayout lr
        }

        styles {
            # Estilo general para elementos
            element "Element" {
                color #ffffff
                background #1168bd
            }
            # Estilo para Personas (Usuarios)
            element "Person" {
                shape person
                background #08427b
            }
            # Estilo para Sistemas Externos (Gris para diferenciarlos)
            element "External" {
                background #999999
            }
        }
    }
}
