# Device Telemetry Bounded Context Class Diagrams
This document contains the class diagrams of the Device Telemetry Bounded Context in the Embedded application, including the unified view and strictly separated views for each layer (following DDD tactical patterns with ModestIoT framework).

---

## 1. Unified Diagram

```mermaid
---
title: DDD Device Telemetry Bounded Context Class Diagram - Unified
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
        +begin()
        +update()
        +on(Event event)
        +handle(Command command)
        +getCurrentData()
        +forceReport()
        +setSimulationEnabled(enabled)
        +setStandbyMode(standby)
        +isSystemReady()
        +getInitStateString()
        -updateAirQualityData()
        -updateParticulateMatterData()
        -generateUnifiedReport()
        -refreshDisplay()
        -updateInitialization()
        -updateSimulationData()
    }
}

namespace application {
    class TelemetryPublisher {
        +begin(url, hardwareId, apiKey, telemetryInterval, commandPollInterval)
        +sendTelemetry(data)
        +sendTelemetryThrottled(data)
        +forceTelemetry(data)
        +isEnabled()
        +setEnabled(enabled)
        +printStats()
        -buildTelemetryPayload(data)
        -addAuthHeaders()
        -calculateHealthStatus(data)
    }

    class TelemetryScheduler {
        +scheduleTelemetry(interval)
        +isTimeToSend()
        +resetTimer()
    }

    class SensorUpdateOrchestrator {
        +triggerAirQualityUpdate()
        +triggerParticulateMatterUpdate()
        +isAirQualityReady()
        +isParticulateMatterReady()
    }
}

namespace domain {
    class ClairData {
        +unsigned long timestamp
        +AirQuality airQuality
        +ParticulateMatter particulateMatter
        +AirQualityIndex airQualityIndex
        +AirQualityStatus status
        +String statusLabel
        +String timeFormatted
        +String uptimeFormatted
        +String country
        +calculateAQI()
        +evaluateStatus(thresholds)
        +print()
    }

    class AirQuality {
        +uint16_t co2
        +float temperature
        +float humidity
        +bool valid
    }

    class ParticulateMatter {
        +uint16_t pm1_0
        +uint16_t pm2_5
        +uint16_t pm10
        +bool valid
    }

    class AirQualityIndex {
        +int aqi
        +String category
    }

    class AirQualityThresholds {
        +uint16_t pm25ModerateLimit
        +uint16_t pm25CriticalLimit
        +uint16_t pm10ModerateLimit
        +uint16_t pm10CriticalLimit
        +uint16_t co2ModerateLimit
        +uint16_t co2CriticalLimit
        +uint8_t humidityModerateLow
        +uint8_t humidityModerateHigh
        +uint8_t humidityCriticalLow
        +uint8_t humidityCriticalHigh
    }

    class AirQualityStatus {
        <<enum>>
        OPTIMAL
        MODERATE
        CRITICAL
    }

    class Event {
        +int id
    }

    class Command {
        +int id
    }

    class Sensor {
        <<abstract>>
        #int pin
        #EventHandler* handler
        +on(Event event)
        +setHandler(eventHandler)
    }

    class EventHandler {
        <<interface>>
        +on(Event event)
    }
}

namespace infrastructure {
    class SCD41Sensor {
        -SensirionI2cScd4x scd4x
        -int sdaPin
        -int sclPin
        -unsigned long readInterval
        -unsigned long lastReadTime
        -bool sensorInitialized
        -bool dataValid
        -uint16_t lastCO2
        -float lastTemperature
        -float lastHumidity
        -char errorMessage[64]
        +DATA_READY_EVENT_ID
        +begin()
        +update()
        +on(Event event)
        +getCO2()
        +getTemperature()
        +getHumidity()
        +isInitialized()
        +isDataValid()
        +printSerialNumber()
        +recalibrate(targetCO2ppm)
        +performForcedRecalibration(targetCO2ppm)
        -readMeasurement()
    }

    class PMS5003Sensor {
        -int rxPin
        -int txPin
        -int setPin
        -int resetPin
        -HardwareSerial serial
        -unsigned long readInterval
        -unsigned long lastReadTime
        -bool sensorInitialized
        -bool dataReady
        -bool isSleeping
        -PMS5003Data lastData
        -uint8_t buffer[32]
        -FRAME_SIZE
        +DATA_READY_EVENT_ID
        +SLEEP_MODE_EVENT_ID
        +WAKE_MODE_EVENT_ID
        +SLEEP_COMMAND_ID
        +WAKE_COMMAND_ID
        +RESET_COMMAND_ID
        +begin()
        +update()
        +on(Event event)
        +getData()
        +sleep()
        +wake()
        +reset()
        +isInitialized()
        +isSleepingMode()
        -readFrame(data)
        -calculateChecksum(buffer, length)
    }

    class PMS5003Data {
        +uint16_t pm1_0
        +uint16_t pm2_5
        +uint16_t pm10
        +bool valid
    }

    class SCD41SensorDevice {
        -SCD41Sensor sensor
        +on(Event event)
        +handle(Command command)
        +getSensor()
        +update()
    }

    class PMS5003SensorDevice {
        -PMS5003Sensor sensor
        +on(Event event)
        +handle(Command command)
        +getSensor()
        +update()
        +processSerialCommand(command)
    }

    class EventPropagation {
        <<conceptual>>
        +handler->on(event)
    }
}

%% Inheritance
EventHandler <|-- Sensor : implements
Sensor <|-- SCD41Sensor : extends
Sensor <|-- PMS5003Sensor : extends
EventHandler <|-- ClairDevice : implements

%% Composition - Infrastructure
SCD41SensorDevice *-- SCD41Sensor : contains
PMS5003SensorDevice *-- PMS5003Sensor : contains
PMS5003Sensor ..> PMS5003Data : produces

%% Composition - Interfaces
ClairDevice *-- SCD41SensorDevice : contains
ClairDevice *-- PMS5003SensorDevice : contains
ClairDevice ..> ClairData : uses
ClairDevice ..> AirQualityThresholds : uses
ClairDevice ..> Event : handles
ClairDevice ..> Command : handles

%% Application Layer dependencies
TelemetryPublisher --> ClairData : uses
TelemetryScheduler --> TelemetryPublisher : controls
SensorUpdateOrchestrator --> SCD41SensorDevice : coordinates
SensorUpdateOrchestrator --> PMS5003SensorDevice : coordinates

%% Event flow (conceptual)
SCD41Sensor ..> EventPropagation : raises DATA_READY_EVENT
PMS5003Sensor ..> EventPropagation : raises DATA_READY_EVENT
EventPropagation --> ClairDevice : delivers event via on()

%% Domain dependencies
ClairData *-- AirQuality : contains
ClairData *-- ParticulateMatter : contains
ClairData *-- AirQualityIndex : contains
ClairData --> AirQualityStatus : uses
ClairData --> AirQualityThresholds : uses for evaluateStatus()
```

## 2. Layer-by-Layer Diagrams

### 2.1. Interfaces Layer

```mermaid
---
title: Device Telemetry - Interfaces Layer Class Diagram
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
        +begin()
        +update()
        +on(Event event)
        +handle(Command command)
        +getCurrentData()
        +forceReport()
        +setSimulationEnabled(enabled)
        +setStandbyMode(standby)
        +isSystemReady()
        +getInitStateString()
        -updateAirQualityData()
        -updateParticulateMatterData()
        -generateUnifiedReport()
        -refreshDisplay()
        -updateInitialization()
        -updateSimulationData()
    }
}
```
>note for ClairDevice "Main orchestrator implementing\nEventHandler and CommandHandler\nfrom ModestIoT framework"
---

### 2.2. Application Layer

```mermaid
---
title: Device Telemetry - Application Layer Class Diagram
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
    class TelemetryPublisher {
        +begin(url, hardwareId, apiKey, telemetryInterval, commandPollInterval)
        +sendTelemetry(data)
        +sendTelemetryThrottled(data)
        +forceTelemetry(data)
        +isEnabled()
        +setEnabled(enabled)
        +printStats()
        -buildTelemetryPayload(data)
        -addAuthHeaders()
        -calculateHealthStatus(data)
    }

    class TelemetryScheduler {
        +scheduleTelemetry(interval)
        +isTimeToSend()
        +resetTimer()
    }

    class SensorUpdateOrchestrator {
        +triggerAirQualityUpdate()
        +triggerParticulateMatterUpdate()
        +isAirQualityReady()
        +isParticulateMatterReady()
    }
}

%% Relationships strictly inside Application Layer
TelemetryScheduler --> TelemetryPublisher : controls
SensorUpdateOrchestrator --> TelemetryPublisher : triggers
```
---

### 2.3. Domain Layer

```mermaid
---
title: Device Telemetry - Domain Layer Class Diagram
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
    class ClairData {
        +unsigned long timestamp
        +AirQuality airQuality
        +ParticulateMatter particulateMatter
        +AirQualityIndex airQualityIndex
        +AirQualityStatus status
        +String statusLabel
        +String timeFormatted
        +String uptimeFormatted
        +String country
        +calculateAQI()
        +evaluateStatus(thresholds)
        +print()
    }

    class AirQuality {
        +uint16_t co2
        +float temperature
        +float humidity
        +bool valid
    }

    class ParticulateMatter {
        +uint16_t pm1_0
        +uint16_t pm2_5
        +uint16_t pm10
        +bool valid
    }

    class AirQualityIndex {
        +int aqi
        +String category
    }

    class AirQualityThresholds {
        +uint16_t pm25ModerateLimit
        +uint16_t pm25CriticalLimit
        +uint16_t pm10ModerateLimit
        +uint16_t pm10CriticalLimit
        +uint16_t co2ModerateLimit
        +uint16_t co2CriticalLimit
        +uint8_t humidityModerateLow
        +uint8_t humidityModerateHigh
        +uint8_t humidityCriticalLow
        +uint8_t humidityCriticalHigh
    }

    class AirQualityStatus {
        <<enum>>
        OPTIMAL
        MODERATE
        CRITICAL
    }

    class Event {
        +int id
    }

    class Command {
        +int id
    }

    class Sensor {
        <<abstract>>
        #int pin
        #EventHandler* handler
        +on(Event event)
        +setHandler(eventHandler)
    }

    class EventHandler {
        <<interface>>
        +on(Event event)
    }
}

%% Domain relationships
ClairData *-- AirQuality : contains
ClairData *-- ParticulateMatter : contains
ClairData *-- AirQualityIndex : contains
ClairData --> AirQualityStatus : uses
ClairData --> AirQualityThresholds : uses

EventHandler <|-- Sensor : implements
```
---

## 2.4. Infrastructure Layer

```mermaid
---
title: Device Telemetry - Infrastructure Layer Class Diagram
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
    class SCD41Sensor {
        -SensirionI2cScd4x scd4x
        -int sdaPin
        -int sclPin
        -unsigned long readInterval
        -unsigned long lastReadTime
        -bool sensorInitialized
        -bool dataValid
        -uint16_t lastCO2
        -float lastTemperature
        -float lastHumidity
        -char errorMessage[64]
        +DATA_READY_EVENT_ID
        +begin()
        +update()
        +on(Event event)
        +getCO2()
        +getTemperature()
        +getHumidity()
        +isInitialized()
        +isDataValid()
        +printSerialNumber()
        +recalibrate(targetCO2ppm)
        +performForcedRecalibration(targetCO2ppm)
        -readMeasurement()
    }

    class PMS5003Sensor {
        -int rxPin
        -int txPin
        -int setPin
        -int resetPin
        -HardwareSerial serial
        -unsigned long readInterval
        -unsigned long lastReadTime
        -bool sensorInitialized
        -bool dataReady
        -bool isSleeping
        -PMS5003Data lastData
        -uint8_t buffer[32]
        -FRAME_SIZE
        +DATA_READY_EVENT_ID
        +SLEEP_MODE_EVENT_ID
        +WAKE_MODE_EVENT_ID
        +SLEEP_COMMAND_ID
        +WAKE_COMMAND_ID
        +RESET_COMMAND_ID
        +begin()
        +update()
        +on(Event event)
        +getData()
        +sleep()
        +wake()
        +reset()
        +isInitialized()
        +isSleepingMode()
        -readFrame(data)
        -calculateChecksum(buffer, length)
    }

    class PMS5003Data {
        +uint16_t pm1_0
        +uint16_t pm2_5
        +uint16_t pm10
        +bool valid
    }

    class SCD41SensorDevice {
        -SCD41Sensor sensor
        +on(Event event)
        +handle(Command command)
        +getSensor()
        +update()
    }

    class PMS5003SensorDevice {
        -PMS5003Sensor sensor
        +on(Event event)
        +handle(Command command)
        +getSensor()
        +update()
        +processSerialCommand(command)
    }

    class EventPropagation {
        <<conceptual>>
        +handler->on(event)
    }
}

%% Infrastructure relationships
SCD41SensorDevice *-- SCD41Sensor : contains
PMS5003SensorDevice *-- PMS5003Sensor : contains
PMS5003Sensor ..> PMS5003Data : produces

%% Event propagation (conceptual)
SCD41Sensor ..> EventPropagation : raises DATA_READY_EVENT
PMS5003Sensor ..> EventPropagation : raises DATA_READY_EVENT
```
---

## 3. Key Flows
### 3.1. Sensor Data Acquisition Flow

```mermaid
sequenceDiagram
    participant HW as Hardware (I2C/UART)
    participant SCD as SCD41Sensor
    participant PMS as PMS5003Sensor
    participant EP as EventPropagation
    participant CD as ClairDevice
    participant CDATA as ClairData
    participant TP as TelemetryPublisher
    participant Edge as Edge Station

    Note over SCD,Edge: Periodic Update Cycle (every 2s)

    SCD->>HW: readMeasurement()
    HW-->>SCD: CO2, Temp, Humidity
    SCD->>EP: handler->on(DATA_READY_EVENT)
    EP->>CD: on(DATA_READY_EVENT)
    CD->>CD: updateAirQualityData()
    CD->>CDATA: update CO2, Temp, Humidity
    CD->>CDATA: evaluateStatus()
    CDATA->>CD: updated status

    PMS->>HW: readFrame()
    HW-->>PMS: PM1.0, PM2.5, PM10
    PMS->>EP: handler->on(DATA_READY_EVENT)
    EP->>CD: on(DATA_READY_EVENT)
    CD->>CD: updateParticulateMatterData()
    CD->>CDATA: update PM values
    CD->>CDATA: calculateAQI()
    CD->>CDATA: evaluateStatus()

    CD->>TP: sendTelemetry(ClairData)
    TP->>Edge: POST /api/v1/device/telemetry
    Edge-->>TP: 200 OK
```


## 4. Telemetry Data Types Summary

| Data Type | Field | Source | Unit | Valid Range |
|-----------|-------|--------|------|-------------|
| **CO2** | `airQuality.co2` | SCD41Sensor | ppm | 400 - 5000 |
| **Temperature** | `airQuality.temperature` | SCD41Sensor | °C | -10 - 60 |
| **Humidity** | `airQuality.humidity` | SCD41Sensor | % | 0 - 100 |
| **PM1.0** | `particulateMatter.pm1_0` | PMS5003Sensor | µg/m³ | 0 - 1000 |
| **PM2.5** | `particulateMatter.pm2_5` | PMS5003Sensor | µg/m³ | 0 - 1000 |
| **PM10** | `particulateMatter.pm10` | PMS5003Sensor | µg/m³ | 0 - 1000 |
| **AQI** | `airQualityIndex.aqi` | Calculated from PM2.5 | index | 0 - 500 |
| **AQI Category** | `airQualityIndex.category` | Calculated from AQI | string | Good, Moderate, Unhealthy for Sensitive, Unhealthy, Very Unhealthy, Hazardous |
| **Status** | `status` | Evaluated from all sensors | enum | OPTIMAL, MODERATE, CRITICAL |
| **Status Label** | `statusLabel` | Evaluated from status | string | Optimal, Moderate, Critical |
| **Timestamp** | `timestamp` | millis() | ms | 0 - 2^32-1 |
| **Time Formatted** | `timeFormatted` | NTP sync | HH:MM:SS | 00:00:00 - 23:59:59 |
| **Uptime Formatted** | `uptimeFormatted` | millis() calculation | HH:MM:SS | 00:00:00 - 99:59:59 |
| **Country** | `country` | Configuration | string | PERU (default) |

### Air Quality Status Evaluation Thresholds

| Parameter | OPTIMAL | MODERATE | CRITICAL |
|-----------|---------|----------|----------|
| **PM2.5 (µg/m³)** | < 35 | 35 - 55 | > 55 |
| **PM10 (µg/m³)** | < 75 | 75 - 150 | > 150 |
| **CO2 (ppm)** | < 1000 | 1000 - 1500 | > 1500 |
| **Humidity (%)** | 30 - 70 | 20 - 30 or 70 - 80 | < 20 or > 80 |

### AQI Calculation (based on PM2.5)

| PM2.5 Range (µg/m³) | AQI Range | Category |
|---------------------|-----------|----------|
| 0 - 12 | 0 - 50 | Good |
| 13 - 35 | 51 - 100 | Moderate |
| 36 - 55 | 101 - 150 | Unhealthy for Sensitive |
| 56 - 150 | 151 - 200 | Unhealthy |
| 151 - 250 | 201 - 300 | Very Unhealthy |
| 251 - 500 | 301 - 500 | Hazardous |

## 5. Bounded Context Summary

| Layer | Components | Responsibility |
|-------|------------|----------------|
| **Interfaces** | `ClairDevice` | Main orchestrator, implements EventHandler, coordinates sensor updates, manages system state (Init/Standby/Normal) |
| **Application** | `TelemetryPublisher` (EdgeService), `TelemetryScheduler`, `SensorUpdateOrchestrator` | Publishes telemetry to Edge via HTTPS, manages send intervals, coordinates sensor read timing |
| **Domain** | `ClairData`, `AirQuality`, `ParticulateMatter`, `AirQualityIndex`, `AirQualityThresholds`, `AirQualityStatus` | Pure business logic: AQI calculation, status evaluation against thresholds, data validation rules |
| **Infrastructure** | `SCD41Sensor`, `PMS5003Sensor`, `SCD41SensorDevice`, `PMS5003SensorDevice`, `EventPropagation` | Hardware communication (I2C for SCD41, UART for PMS5003), event propagation mechanism via handler->on() |
