# Device State Bounded Context Class Diagrams
This document contains the class diagrams of the Device State Bounded Context in the Embedded application, including the unified view and strictly separated views for each layer (following DDD tactical patterns with ModestIoT framework).

---

## 1. Unified Diagram

```mermaid
---
title: DDD Device State Bounded Context Class Diagram - Unified
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
        +setStandbyMode(standby)
        +isStandbyMode()
        +isSystemReady()
        +getInitStateString()
        +isInitializationComplete()
        +getCurrentStatus()
        +getCurrentStatusLabel()
        -updateInitialization()
        -updateAirQualityData()
        -updateParticulateMatterData()
    }
}

namespace application {
    class StateManager {
        +transitionTo(newState)
        +getCurrentState()
        +canTransitionTo(newState)
        +onStateEnter()
        +onStateExit()
    }

    class InitStateManager {
        +startInitialization()
        +updateInitialization()
        +isInitializationComplete()
        +hasInitializationTimeout()
        +getInitState()
        +getInitStateString()
    }

    class StandbyManager {
        +enableStandby()
        +disableStandby()
        +isStandbyActive()
        +suspendOperations()
        +resumeOperations()
    }

    class StatusEvaluator {
        +evaluateOverallStatus()
        +getCurrentStatus()
        +getStatusLabel()
        +getStatusIcon()
    }
}

namespace domain {
    class DeviceState {
        <<enum>>
        INIT_NOT_STARTED
        INIT_STARTING_SENSORS
        INIT_WAITING_SENSORS
        INIT_COMPLETE
        INIT_PARTIAL
    }

    class OperationalMode {
        <<enum>>
        NORMAL_MODE
        STANDBY_MODE
        SIMULATION_MODE
    }

    class AirQualityStatus {
        <<enum>>
        OPTIMAL
        MODERATE
        CRITICAL
    }

    class SystemHealth {
        +bool allSensorsReady
        +bool timeSynchronized
        +bool wifiConnected
        +bool displayInitialized
        +int healthPercentage
        +evaluateHealth()
    }

    class StateTransition {
        +DeviceState fromState
        +DeviceState toState
        +unsigned long transitionTime
        +bool success
    }
}

namespace infrastructure {
    class StatePersistence {
        +saveState(state)
        +loadState()
        +clearState()
    }

    class StateTimer {
        +unsigned long startTime
        +unsigned long timeoutMs
        +bool hasTimedOut()
        +reset()
        +getElapsedMs()
    }

    class StateEventEmitter {
        <<conceptual>>
        +emitStateChanged(state)
        +emitModeChanged(mode)
    }
}

%% Inheritance
ClairDevice --> DeviceState : uses
ClairDevice --> OperationalMode : uses
ClairDevice --> AirQualityStatus : uses

%% Composition - Application
StateManager --> DeviceState : manages
StateManager --> StateTransition : creates
InitStateManager --> DeviceState : manages
StandbyManager --> OperationalMode : manages
StatusEvaluator --> AirQualityStatus : evaluates

%% Interfaces Layer dependencies
ClairDevice --> StateManager : uses
ClairDevice --> InitStateManager : uses
ClairDevice --> StandbyManager : uses
ClairDevice --> StatusEvaluator : uses
ClairDevice --> SystemHealth : uses

%% Domain relationships
SystemHealth --> AirQualityStatus : influences
StateTransition --> DeviceState : references

%% Infrastructure relationships
StateManager --> StatePersistence : optional
InitStateManager --> StateTimer : uses
StateEventEmitter --> ClairDevice : notifies
```

## 2. Layer-by-Layer Diagrams

### 2.1. Interfaces Layer

```mermaid
---
title: Device State - Interfaces Layer Class Diagram
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
        +setStandbyMode(standby)
        +isStandbyMode()
        +isSystemReady()
        +getInitStateString()
        +isInitializationComplete()
        +getCurrentStatus()
        +getCurrentStatusLabel()
        -updateInitialization()
        -updateAirQualityData()
        -updateParticulateMatterData()
    }
}
```
>note for ClairDevice "Main orchestrator that manages:\n- Initialization state (INIT_NOT_STARTED → STARTING → WAITING → COMPLETE/PARTIAL)\n- Operational mode (NORMAL / STANDBY / SIMULATION)\n- Air quality status (OPTIMAL / MODERATE / CRITICAL)"
---

### 2.2. Application Layer

```mermaid
---
title: Device State - Application Layer Class Diagram
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
    class StateManager {
        +transitionTo(newState)
        +getCurrentState()
        +canTransitionTo(newState)
        +onStateEnter()
        +onStateExit()
    }

    class InitStateManager {
        +startInitialization()
        +updateInitialization()
        +isInitializationComplete()
        +hasInitializationTimeout()
        +getInitState()
        +getInitStateString()
    }

    class StandbyManager {
        +enableStandby()
        +disableStandby()
        +isStandbyActive()
        +suspendOperations()
        +resumeOperations()
    }

    class StatusEvaluator {
        +evaluateOverallStatus()
        +getCurrentStatus()
        +getStatusLabel()
        +getStatusIcon()
    }
}

%% Relationships strictly inside Application Layer
InitStateManager --> StateManager : updates
StandbyManager --> StateManager : updates
StatusEvaluator --> StateManager : provides status
```
---

### 2.3. Domain Layer

```mermaid
---
title: Device State - Domain Layer Class Diagram
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
    class DeviceState {
        <<enum>>
        INIT_NOT_STARTED
        INIT_STARTING_SENSORS
        INIT_WAITING_SENSORS
        INIT_COMPLETE
        INIT_PARTIAL
    }

    class OperationalMode {
        <<enum>>
        NORMAL_MODE
        STANDBY_MODE
        SIMULATION_MODE
    }

    class AirQualityStatus {
        <<enum>>
        OPTIMAL
        MODERATE
        CRITICAL
    }

    class SystemHealth {
        +bool allSensorsReady
        +bool timeSynchronized
        +bool wifiConnected
        +bool displayInitialized
        +int healthPercentage
        +evaluateHealth()
    }

    class StateTransition {
        +DeviceState fromState
        +DeviceState toState
        +unsigned long transitionTime
        +bool success
    }
}

%% Domain relationships
SystemHealth --> AirQualityStatus : influences
StateTransition --> DeviceState : references
```
---

## 2.4. Infrastructure Layer

```mermaid
---
title: Device State - Infrastructure Layer Class Diagram
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
    class StatePersistence {
        +saveState(state)
        +loadState()
        +clearState()
    }

    class StateTimer {
        +unsigned long startTime
        +unsigned long timeoutMs
        +bool hasTimedOut()
        +reset()
        +getElapsedMs()
    }

    class StateEventEmitter {
        <<conceptual>>
        +emitStateChanged(state)
        +emitModeChanged(mode)
    }
}

%% Infrastructure relationships
StatePersistence --> StateManager : persists
StateTimer --> InitStateManager : provides timing
StateEventEmitter --> ClairDevice : emits events
```
---

## 3. Key Flows
### 3.1. Device Initialization State Flow

```mermaid
sequenceDiagram
    participant CD as ClairDevice
    participant IM as InitStateManager
    participant Timer as StateTimer
    participant SCD as SCD41Sensor
    participant PMS as PMS5003Sensor

    Note over CD,PMS: begin() called

    CD->>IM: startInitialization()
    IM->>CD: initState = INIT_STARTING_SENSORS
    IM->>Timer: reset()
    
    CD->>SCD: begin()
    CD->>PMS: begin()
    
    IM->>CD: initState = INIT_WAITING_SENSORS

    Note over CD,PMS: Periodic update() loop

    loop Every 50ms
        CD->>IM: updateInitialization()
        IM->>SCD: isInitialized()?
        IM->>PMS: isInitialized()?
        
        alt Both ready
            IM->>CD: initState = INIT_COMPLETE
            IM->>CD: allSensorsReady = true
        else One ready or timeout
            IM->>Timer: hasTimedOut()?
            alt Timeout reached (10000ms)
                IM->>CD: initState = INIT_PARTIAL
            end
        end
    end
```

### 3.2. Standby Mode State Flow

```mermaid
sequenceDiagram
    participant Edge as Edge Station
    participant CD as ClairDevice
    participant SM as StandbyManager
    participant Display as OLEDDisplay
    participant LED as Led
    participant PMS as PMS5003Sensor
    participant Telemetry as EdgeService

    Note over Edge,Telemetry: STANDBY command received

    Edge->>CD: Command(STANDBY)
    CD->>SM: setStandbyMode(true)
    SM->>CD: standbyMode = true
    
    SM->>Display: off()
    SM->>LED: off()
    SM->>PMS: sleep()
    SM->>Telemetry: setTelemetryEnabled(false)
    
    Note over CD: Device in STANDBY_MODE
    
    Edge->>CD: Command(WAKE)
    CD->>SM: setStandbyMode(false)
    SM->>CD: standbyMode = false
    
    SM->>Display: on()
    SM->>PMS: wake()
    SM->>Telemetry: setTelemetryEnabled(true)
    SM->>CD: forceReport()
```

### 3.3. Air Quality Status State Flow

```mermaid
sequenceDiagram
    participant Sensor as SensorManager
    participant CD as ClairDevice
    participant Data as ClairData
    participant SE as StatusEvaluator
    participant LED as Led
    participant Display as OLEDDisplay

    Note over Sensor,Display: New sensor data ready

    Sensor->>CD: on(DATA_READY_EVENT)
    CD->>Data: updateAirQualityData()
    CD->>Data: updateParticulateMatterData()
    
    CD->>Data: evaluateStatus(thresholds)
    Data->>SE: evaluateStatus()
    
    alt CO2 > 1500 or PM2.5 > 55
        SE->>CD: status = CRITICAL
        CD->>LED: startBlink(500)
        CD->>Display: updateData(CRITICAL)
    else CO2 > 1000 or PM2.5 > 35
        SE->>CD: status = MODERATE
        CD->>LED: off()
        CD->>Display: updateData(MODERATE)
    else
        SE->>CD: status = OPTIMAL
        CD->>LED: off()
        CD->>Display: updateData(OPTIMAL)
    end
```


## 4. State Types Summary

### 4.1. Device Initialization States

| State | Value | Description | Timeout |
|-------|-------|-------------|---------|
| `INIT_NOT_STARTED` | 0 | Initialization not yet started | N/A |
| `INIT_STARTING_SENSORS` | 1 | Sensors begin() called | N/A |
| `INIT_WAITING_SENSORS` | 2 | Waiting for sensors to initialize | 10000ms |
| `INIT_COMPLETE` | 3 | All sensors initialized successfully | N/A |
| `INIT_PARTIAL` | 4 | Timeout reached, partial initialization | N/A |

### 4.2. Operational Modes

| Mode | Description | Behavior |
|------|-------------|----------|
| `NORMAL_MODE` | Full operation | All sensors active, telemetry sending, display on |
| `STANDBY_MODE` | Low power mode | Sensors sleep, telemetry disabled, display off, LED off |
| `SIMULATION_MODE` | Test mode | Synthetic data generation, no hardware reads |

### 4.3. Air Quality Status States

| Status | Label | Condition | LED Behavior |
|--------|-------|-----------|--------------|
| `OPTIMAL` | "Optimal" | All parameters within optimal ranges | Off |
| `MODERATE` | "Moderate" | One or more parameters in moderate range | Off |
| `CRITICAL` | "Critical" | One or more parameters in critical range | Blinking (500ms) |

### 4.4. State Transition Matrix

| From State | Event | To State | Action |
|------------|-------|----------|--------|
| INIT_NOT_STARTED | `begin()` | INIT_STARTING_SENSORS | Start sensor initialization |
| INIT_STARTING_SENSORS | sensors begin() called | INIT_WAITING_SENSORS | Wait for ready flag |
| INIT_WAITING_SENSORS | both sensors ready | INIT_COMPLETE | Enable normal operation |
| INIT_WAITING_SENSORS | timeout (10s) | INIT_PARTIAL | Continue with partial data |
| NORMAL_MODE | `STANDBY` command | STANDBY_MODE | Suspend operations |
| STANDBY_MODE | `WAKE` command | NORMAL_MODE | Resume operations |
| NORMAL_MODE | `setSimulationEnabled(true)` | SIMULATION_MODE | Generate fake data |
| SIMULATION_MODE | `setSimulationEnabled(false)` | NORMAL_MODE | Read real sensors |

## 5. Bounded Context Summary

| Layer | Components | Responsibility |
|-------|------------|----------------|
| **Interfaces** | `ClairDevice` | Main orchestrator that manages and transitions between all device states (initialization, operational mode, air quality status) |
| **Application** | `StateManager`, `InitStateManager`, `StandbyManager`, `StatusEvaluator` | Coordinates state transitions, manages initialization timeout, handles standby mode, evaluates overall status from sensor data |
| **Domain** | `DeviceState` (enum), `OperationalMode` (enum), `AirQualityStatus` (enum), `SystemHealth`, `StateTransition` | Pure state abstractions, valid state transitions, system health rules, state transition records |
| **Infrastructure** | `StatePersistence`, `StateTimer`, `StateEventEmitter` | Optional state persistence, timeout tracking for initialization, conceptual state change events |

## 6. State Configuration Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `INIT_TIMEOUT_MS` | 10000 | Maximum wait time for sensor initialization (ms) |
| `REPORT_INTERVAL` | 10000 | Default telemetry report interval (ms) |
| `SCD41_READ_INTERVAL` | 2000 | SCD41 sensor read interval (ms) |
| `PMS_READ_INTERVAL` | 2000 | PMS5003 sensor read interval (ms) |
| `NTP_SYNC_INTERVAL` | 3600000 | NTP resynchronization interval (ms) |
| `LED_BLINK_INTERVAL` | 500 | LED blink interval when incidents active (ms) |

