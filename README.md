# Vanana C4 Model

This repository contains the C4 model for the Vanana platform.

## Index

- [1. System Context](#1-system-context)
- [2. Containers](#2-containers)
- [3. Platform API Components](#3-platform-api-components)
- [4. IAM Layers](#4-iam-layers)
- [5. Billing Layers](#5-billing-layers)
- [6. Device and Space Layers](#6-device-and-space-layers)
- [7. Air Quality Layers](#7-air-quality-layers)
- [8. Alerting Layers](#8-alerting-layers)
- [9. Analytics Layers](#9-analytics-layers)
- [10. Notifications Layers](#10-notifications-layers)
- [11. Embedded App Components](#11-embedded-app-components)
- [12. Edge Station Components](#12-edge-station-components)

## Diagrams

### 1. System Context

High-level view of the system, users, and external providers.

![Vanana Context](assets/VananaContext-dark.png)

### 2. Containers

Main distribution of applications, APIs, databases, and edge runtime.

![Vanana Containers](assets/VananaContainers-dark.png)

### 3. Platform API Components

Main bounded contexts inside the Platform API.

![Platform API Components](assets/PlatformApiComponents-dark.png)

### 4. IAM Layers

Internal IAM layers: interfaces, application, domain, and infrastructure.

![IAM Layers](assets/IamLayers-dark.png)

### 5. Billing Layers

Internal Billing layers and integration with Stripe/PostgreSQL.

![Billing Layers](assets/BillingLayers-dark.png)

### 6. Device and Space Layers

Internal layers for facilities, spaces, and device management.

![DeviceSpace Layers](assets/DeviceSpaceLayers-dark.png)

### 7. Air Quality Layers

Internal layers for telemetry evaluation and air quality state.

![AirQuality Layers](assets/AirQualityLayers-dark.png)

### 8. Alerting Layers

Internal layers for alerts, escalation, and response actions.

![Alerting Layers](assets/AlertingLayers-dark.png)

### 9. Analytics Layers

Internal layers for aggregations, trends, and historical reporting.

![Analytics Layers](assets/AnalyticsLayers-dark.png)

### 10. Notifications Layers

Internal layers for templates, deliveries, and notification traceability.

![Notifications Layers](assets/NotificationsLayers-dark.png)

### 11. Embedded App Components

Internal components of the sensor device firmware.

![Embedded App Components](assets/EmbeddedAppComponents-dark.png)

### 12. Edge Station Components

Internal components of the edge gateway for local-cloud sync.

![Edge Station Components](assets/EdgeStationComponents-dark.png)
