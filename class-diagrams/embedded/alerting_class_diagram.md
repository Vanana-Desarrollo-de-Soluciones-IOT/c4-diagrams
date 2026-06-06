# Alerting Bounded Context Class Diagrams
This document contains the class diagrams of the Alerting Bounded Context in the Embedded application, including the unified view and strictly separated views for each layer (following DDD tactical patterns with ModestIoT framework).

---

## 1. Unified Diagram

```mermaid
---
title: DDD Alerting Bounded Context Class Diagram - Embedded - Unified
---

%%{init: {
  'theme': 'default',
  'themeVariables': {
    'clusterBkg': 'transparent',
    'clusterBorder': '#666666'
  }
}}%%

classDiagram

namespace interfaces {
    class ClairDevice {
        <<orchestrator>>
        +update()
        +handle(Command command)
        +setStandbyMode(standby)
        -updateWarningLed()
        -onIncidentDetected(incident)
        -onIncidentResolved(incident)
    }
}

namespace application {
    class IncidentManager {
        -String baseUrl
        -String hardwareId
        -String apiKey
        -unsigned long pollInterval
        -unsigned long lastPollTime
        -bool enabled
        -Incident activeIncidents[5]
        -int incidentCount
        -PendingAck pendingAcks[10]
        -int pendingAckCount
        -MAX_RETRIES
        -RETRY_INTERVAL_MS
        -void (*onIncidentDetected)(const Incident&)
        -void (*onIncidentResolved)(const Incident&)
        +begin(url, id, key, interval)
        +pollIncidents()
        +process()
        +hasActiveIncidents()
        +getActiveCount()
        +getMostCriticalIncident()
        +getMetricPriority(metric)
        +forceAck(incidentId)
        +setCallbacks(onDetect, onResolve)
        +printStats()
        +isEnabled()
        +setEnabled(enable)
        -addAuthHeaders()
        -findIncidentById(id)
        -queueAck(incidentId, status)
        -sendAckNow(incidentId)
        -sendAckForStatus(incidentId, status)
        -processPendingAcks()
        -addIncident(incident)
        -resolveIncident(id, resolvedAt)
    }

    class Incident {
        +int id
        +String metric
        +String status
        +String occurredAt
        +String resolvedAt
        +bool acknowledged
        +print()
    }

    class PendingAck {
        +int incidentId
        +String status
        +unsigned long lastAttempt
        +int retryCount
        +bool active
    }
}

namespace domain {
    class MetricType {
        <<enum>>
        CO2
        PM25
        TEMP
        HUMIDITY
    }

    class IncidentStatus {
        <<enum>>
        ACTIVE
        RESOLVED
        ACKNOWLEDGED
    }

    class IncidentPriority {
        <<enum>>
        HIGH
        MEDIUM
        LOW
    }

    class AlertRule {
        +String metric
        +float thresholdValue
        +String operator
        +int priority
        +evaluate(actualValue)
    }
}

namespace infrastructure {
    class Led {
        -bool state
        -bool blinking
        -unsigned long lastBlinkTime
        -unsigned long blinkInterval
        -bool blinkState
        -bool activeHigh
        +on()
        +off()
        +startBlink(intervalMs)
        +stopBlink()
        +update()
        +isBlinking()
        +handle(Command command)
    }

    class IncidentHttpClient {
        -HTTPClient httpClient
        +getPendingIncidents(url)
        +sendAck(url, incidentId, status)
        +addAuthHeaders()
        +setTimeout(ms)
    }

    class IncidentAckQueue {
        +add(incidentId, status)
        +remove(incidentId)
        +getNext()
        +size()
        +isEmpty()
    }

    class LedController {
        <<conceptual>>
        +controlByIncident(hasActiveIncidents)
    }
}

%% Inheritance
ClairDevice --> Incident : uses
ClairDevice --> Led : controls

%% Composition - Application
IncidentManager *-- Incident : contains (active incidents array)
IncidentManager *-- PendingAck : contains (pending acks queue)

%% Interfaces Layer dependencies
ClairDevice --> IncidentManager : uses
ClairDevice --> Led : controls via incident state

%% Application Layer dependencies
IncidentManager --> IncidentHttpClient : uses
IncidentManager --> IncidentAckQueue : uses
IncidentManager --> LedController : triggers

%% Domain relationships
AlertRule --> MetricType : uses
AlertRule --> IncidentPriority : maps to
Incident --> MetricType : contains
Incident --> IncidentStatus : contains

%% Infrastructure relationships
LedController --> Led : controls
IncidentHttpClient --> IncidentManager : used by
IncidentAckQueue --> IncidentManager : used by

%% Incident flow (conceptual)
IncidentManager --> LedController : hasActiveIncidents() → LED blinking
```

## 2. Layer-by-Layer Diagrams

### 2.1. Interfaces Layer

```mermaid
---
title: Alerting - Interfaces Layer Class Diagram (Embedded)
---

%%{init: {
  'theme': 'default',
  'themeVariables': {
    'clusterBkg': 'transparent',
    'clusterBorder': '#666666'
  }
}}%%

classDiagram

namespace interfaces {
    class ClairDevice {
        <<orchestrator>>
        +update()
        +handle(Command command)
        +setStandbyMode(standby)
        -updateWarningLed()
        -onIncidentDetected(incident)
        -onIncidentResolved(incident)
    }
}
```
>note for ClairDevice "Main orchestrator that:\n- Initializes IncidentManager\n- Calls updateWarningLed() periodically\n- Controls LED based on hasActiveIncidents()"
---

### 2.2. Application Layer

```mermaid
---
title: Alerting - Application Layer Class Diagram (Embedded)
---
%%{init: {
  'theme': 'default',
  'themeVariables': {
    'clusterBkg': 'transparent',
    'clusterBorder': '#666666'
  }
}}%%

classDiagram

namespace application {
    class IncidentManager {
        -String baseUrl
        -String hardwareId
        -String apiKey
        -unsigned long pollInterval
        -unsigned long lastPollTime
        -bool enabled
        -Incident activeIncidents[5]
        -int incidentCount
        -PendingAck pendingAcks[10]
        -int pendingAckCount
        -MAX_RETRIES
        -RETRY_INTERVAL_MS
        -void (*onIncidentDetected)(const Incident&)
        -void (*onIncidentResolved)(const Incident&)
        +begin(url, id, key, interval)
        +pollIncidents()
        +process()
        +hasActiveIncidents()
        +getActiveCount()
        +getMostCriticalIncident()
        +getMetricPriority(metric)
        +forceAck(incidentId)
        +setCallbacks(onDetect, onResolve)
        +printStats()
        +isEnabled()
        +setEnabled(enable)
        -addAuthHeaders()
        -findIncidentById(id)
        -queueAck(incidentId, status)
        -sendAckNow(incidentId)
        -sendAckForStatus(incidentId, status)
        -processPendingAcks()
        -addIncident(incident)
        -resolveIncident(id, resolvedAt)
    }

    class Incident {
        +int id
        +String metric
        +String status
        +String occurredAt
        +String resolvedAt
        +bool acknowledged
        +print()
    }

    class PendingAck {
        +int incidentId
        +String status
        +unsigned long lastAttempt
        +int retryCount
        +bool active
    }
}

%% Relationships strictly inside Application Layer
IncidentManager *-- Incident : contains (max 5)
IncidentManager *-- PendingAck : contains (max 10)
```
---

### 2.3. Domain Layer

```mermaid
---
title: Alerting - Domain Layer Class Diagram (Embedded)
---
%%{init: {
  'theme': 'default',
  'themeVariables': {
    'clusterBkg': 'transparent',
    'clusterBorder': '#666666'
  }
}}%%

classDiagram

namespace domain {
    class MetricType {
        <<enum>>
        CO2
        PM25
        TEMP
        HUMIDITY
    }

    class IncidentStatus {
        <<enum>>
        ACTIVE
        RESOLVED
        ACKNOWLEDGED
    }

    class IncidentPriority {
        <<enum>>
        HIGH
        MEDIUM
        LOW
    }

    class AlertRule {
        +String metric
        +float thresholdValue
        +String operator
        +int priority
        +evaluate(actualValue)
    }
}

%% Domain relationships
AlertRule --> MetricType : uses
AlertRule --> IncidentPriority : maps to
```
---

## 2.4. Infrastructure Layer

```mermaid
---
title: Alerting - Infrastructure Layer Class Diagram (Embedded)
---
%%{init: {
  'theme': 'default',
  'themeVariables': {
    'clusterBkg': 'transparent',
    'clusterBorder': '#666666'
  }
}}%%

classDiagram

namespace infrastructure {
    class Led {
        -bool state
        -bool blinking
        -unsigned long lastBlinkTime
        -unsigned long blinkInterval
        -bool blinkState
        -bool activeHigh
        +on()
        +off()
        +startBlink(intervalMs)
        +stopBlink()
        +update()
        +isBlinking()
        +handle(Command command)
    }

    class IncidentHttpClient {
        -HTTPClient httpClient
        +getPendingIncidents(url)
        +sendAck(url, incidentId, status)
        +addAuthHeaders()
        +setTimeout(ms)
    }

    class IncidentAckQueue {
        +add(incidentId, status)
        +remove(incidentId)
        +getNext()
        +size()
        +isEmpty()
    }

    class LedController {
        <<conceptual>>
        +controlByIncident(hasActiveIncidents)
    }
}

%% Infrastructure relationships
LedController --> Led : controls
IncidentHttpClient --> IncidentManager : used by
IncidentAckQueue --> IncidentManager : used by
```
---

## 3. Key Flows
### 3.1. Incident Polling and LED Control Flow

```mermaid
sequenceDiagram
    participant IM as IncidentManager
    participant HTTP as IncidentHttpClient
    participant Edge as Edge Station
    participant CD as ClairDevice
    participant LED as Led

    Note over IM,Edge: Periodic Polling Cycle (every 5s)

    IM->>HTTP: pollIncidents()
    HTTP->>Edge: GET /api/v1/alerting/incidents/pending
    Edge-->>HTTP: Incident[] (ACTIVE/RESOLVED)
    HTTP-->>IM: incidents received

    alt New ACTIVE incident
        IM->>IM: addIncident(incident)
        IM->>CD: onIncidentDetected(incident)
        CD->>CD: updateWarningLed()
        CD->>LED: startBlink(500)
        IM->>HTTP: queueAck(id, "ACTIVE")
    end

    alt RESOLVED incident
        IM->>IM: resolveIncident(id, resolvedAt)
        IM->>CD: onIncidentResolved(incident)
        CD->>CD: updateWarningLed()
        CD->>LED: off()
        IM->>HTTP: queueAck(id, "RESOLVED")
    end

    Note over IM,HTTP: Async ACK Processing

    IM->>HTTP: processPendingAcks()
    HTTP->>Edge: POST /api/v1/alerting/incidents/{id}/ack
    Edge-->>HTTP: 200 OK
```

### 3.2. Incident Priority by Metric Flow

```mermaid
sequenceDiagram
    participant IM as IncidentManager
    participant CD as ClairDevice
    participant LED as Led

    Note over IM,LED: Multiple active incidents

    IM->>IM: hasActiveIncidents() = true
    IM->>IM: getMostCriticalIncident()
    
    alt Metric: CO2 (Priority 1 - HIGH)
        IM->>CD: incident.metric = "CO2"
        CD->>LED: startBlink(500)
    else Metric: PM25 (Priority 2 - MEDIUM)
        IM->>CD: incident.metric = "PM25"
        CD->>LED: startBlink(500)
    else Metric: TEMP (Priority 3 - LOW)
        IM->>CD: incident.metric = "TEMP"
        CD->>LED: startBlink(500)
    else Metric: HUMIDITY (Priority 4 - LOWEST)
        IM->>CD: incident.metric = "HUMIDITY"
        CD->>LED: startBlink(500)
    end

    Note over LED: LED behavior is same for all metrics<br>(blinking at 500ms interval)
```

## 4. Incident Types Summary

### 4.1. Incident Metrics and Priority

| Metric | Priority | Description | Typical Threshold |
|--------|----------|-------------|-------------------|
| `CO2` | 1 (HIGH) | Carbon dioxide level too high | > 1500 ppm |
| `PM25` | 2 (MEDIUM) | Particulate matter 2.5 too high | > 55 µg/m³ |
| `TEMP` | 3 (LOW) | Temperature out of range | < 10°C or > 40°C |
| `HUMIDITY` | 4 (LOWEST) | Humidity out of range | < 20% or > 80% |

### 4.2. Incident Status States

| Status | Description | LED Behavior | ACK Required |
|--------|-------------|--------------|--------------|
| `ACTIVE` | Incident is ongoing | Blinking (500ms) | Yes (to Edge) |
| `RESOLVED` | Incident has been resolved | Off | Yes (to Edge) |
| `ACKNOWLEDGED` | Device confirmed receipt | N/A | N/A |

### 4.3. Pending ACK Retry Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| `MAX_RETRIES` | 3 | Maximum number of ACK retry attempts |
| `RETRY_INTERVAL_MS` | 5000 | Delay between retry attempts (ms) |
| `MAX_PENDING_ACKS` | 10 | Maximum pending ACKs in queue |

### 4.4. Incident Limits

| Parameter | Value | Description |
|-----------|-------|-------------|
| `MAX_ACTIVE_INCIDENTS` | 5 | Maximum concurrent active incidents stored |
| `MAX_PENDING_ACKS` | 10 | Maximum pending ACKs in queue |
| `DEFAULT_POLL_INTERVAL` | 5000 | Default incident polling interval (ms) |

### 4.5. Metric Priority Mapping

| Priority Level | Metrics | LED Behavior |
|----------------|---------|--------------|
| **HIGH (1)** | `CO2` | Blinking (500ms) |
| **MEDIUM (2)** | `PM25` | Blinking (500ms) |
| **LOW (3)** | `TEMP` | Blinking (500ms) |
| **LOWEST (4)** | `HUMIDITY` | Blinking (500ms) |

> **Note:** LED behavior is identical for all metrics (blinking at 500ms interval). Priority is currently used only for determining the most critical incident when multiple are active.

## 5. Bounded Context Summary

| Layer | Components | Responsibility |
|-------|------------|----------------|
| **Interfaces** | `ClairDevice` | Main orchestrator that initializes IncidentManager, calls updateWarningLed() periodically, and controls LED based on incident state |
| **Application** | `IncidentManager`, `Incident`, `PendingAck` | Polls Edge for incidents, manages active incidents list (max 5), queues ACKs with retry logic (max 3 retries, 5s interval), triggers callbacks on state changes |
| **Domain** | `MetricType` (enum), `IncidentStatus` (enum), `IncidentPriority` (enum), `AlertRule` | Pure abstractions for incident metrics, status states, priority levels, and alert rule evaluation logic |
| **Infrastructure** | `Led`, `IncidentHttpClient`, `IncidentAckQueue`, `LedController` | LED hardware control, HTTP client for Edge communication, ACK queue management, conceptual LED control by incident state |

## 6. Alerting Configuration Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `MAX_ACTIVE_INCIDENTS` | 5 | Maximum number of concurrent active incidents stored |
| `MAX_PENDING_ACKS` | 10 | Maximum pending ACKs in queue |
| `MAX_RETRIES` | 3 | Maximum ACK retry attempts before giving up |
| `RETRY_INTERVAL_MS` | 5000 | Delay between ACK retry attempts (ms) |
| `DEFAULT_POLL_INTERVAL` | 5000 | Default incident polling interval (ms) |
| `LED_BLINK_INTERVAL_MS` | 500 | LED blink interval when incidents active (ms) |
| `INCIDENT_TIMEOUT_MS` | 5000 | HTTP timeout for incident polling (ms) |

## 7. API Endpoints Summary

| Endpoint | Method | Direction | Purpose |
|----------|--------|-----------|---------|
| `/api/v1/alerting/incidents/pending` | GET | Embedded → Edge | Query pending incidents for device |
| `/api/v1/alerting/incidents/{id}/ack` | POST | Embedded → Edge | Acknowledge incident receipt |

