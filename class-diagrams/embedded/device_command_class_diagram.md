# Device Command Bounded Context Class Diagrams
This document contains the class diagrams of the Device Command Bounded Context in the Embedded application, including the unified view and strictly separated views for each layer (following DDD tactical patterns with ModestIoT framework).

---

## 1. Unified Diagram

```mermaid
---
title: DDD Device Command Bounded Context Class Diagram - Unified
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
        +handle(Command command)
        +setStandbyMode(standby)
        +forceReport()
        +isStandbyMode()
        +getCurrentData()
        +printEdgeStats()
    }
}

namespace application {
    class EdgeService {
        -String baseUrl
        -String hardwareId
        -String apiKey
        -unsigned long lastCommandPollTime
        -unsigned long commandPollInterval
        -CommandCallback commandCallback
        -queue~RemoteCommand~ commandQueue
        -bool processingQueue
        -unsigned long commandsReceived
        -unsigned long commandsExecuted
        -unsigned long commandsFailed
        +begin(url, id, secret, telemetryInterval, commandPollInterval)
        +pollCommands()
        +processCommandQueue()
        +setCommandCallback(callback)
        +setCommandsEnabled(enabled)
        +clearCommandQueue()
        +getCommandQueueSize()
        +printStats()
        -addAuthHeaders()
        -sendAck(commandId, status, failureReason)
    }

    class RemoteCommand {
        +String commandId
        +String type
        +String parameters
        +bool valid
    }

    class CommandProcessor {
        +processCommand(cmd)
        +validateCommand(cmd)
        +getCommandType(cmd)
    }
}

namespace domain {
    class Command {
        +int id
    }

    class CommandHandler {
        <<interface>>
        +handle(Command command)
    }

    class RemoteCommandType {
        <<enum>>
        STANDBY
        WAKE
        RESTART
        REPORT
        CALIBRATE
    }

    class CommandResult {
        +bool success
        +String failureReason
        +unsigned long executionTimeMs
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
        +TOGGLE_LED_COMMAND_ID
        +TURN_ON_COMMAND_ID
        +TURN_OFF_COMMAND_ID
        +START_BLINK_COMMAND_ID
        +STOP_BLINK_COMMAND_ID
        +on()
        +off()
        +toggle()
        +startBlink(intervalMs)
        +stopBlink()
        +update()
        +isBlinking()
        +handle(Command command)
    }

    class OLEDDisplay {
        -Adafruit_SSD1306 display
        -bool initialized
        -DisplayState currentState
        -unsigned long lastUpdateTime
        -unsigned long lastWakeTime
        -DisplayData currentData
        +DISPLAY_ON_COMMAND
        +DISPLAY_OFF_COMMAND
        +DISPLAY_SLEEP_COMMAND
        +DISPLAY_WAKE_COMMAND
        +begin()
        +updateData(data)
        +sleep()
        +wake()
        +off()
        +on()
        +handle(Command command)
        +autoPowerManagement()
    }

    class CommandDispatch {
        <<conceptual>>
        +handler->handle(command)
    }

    class HttpCommandClient {
        -HTTPClient httpClient
        +getPendingCommands(url)
        +sendAck(url, commandId, status)
        +addAuthHeaders()
    }
}

%% Inheritance
CommandHandler <|-- ClairDevice : implements
CommandHandler <|-- Led : implements
CommandHandler <|-- OLEDDisplay : implements

%% Composition - Application
EdgeService *-- RemoteCommand : contains (queue)
EdgeService ..> CommandResult : returns

%% Application Layer dependencies
EdgeService --> HttpCommandClient : uses
CommandProcessor --> RemoteCommand : processes
CommandProcessor --> RemoteCommandType : uses

%% Interfaces Layer dependencies
ClairDevice --> EdgeService : uses
ClairDevice --> Command : handles
ClairDevice --> Led : controls
ClairDevice --> OLEDDisplay : controls

%% Command flow (conceptual)
EdgeService ..> CommandDispatch : dispatches via callback
CommandDispatch --> ClairDevice : delivers command via handle()
CommandDispatch --> Led : delivers LED commands
CommandDispatch --> OLEDDisplay : delivers display commands

%% Infrastructure relationships
HttpCommandClient --> EdgeService : used by
```

## 2. Layer-by-Layer Diagrams

### 2.1. Interfaces Layer

```mermaid
---
title: Device Command - Interfaces Layer Class Diagram
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
        +handle(Command command)
        +setStandbyMode(standby)
        +forceReport()
        +isStandbyMode()
        +getCurrentData()
        +printEdgeStats()
    }
}
```
>note for ClairDevice "Main orchestrator implementing\nCommandHandler interface.\nProcesses: STANDBY, WAKE,\nREPORT, CALIBRATE, RESET,\nLED commands, Display commands"
---

### 2.2. Application Layer

```mermaid
---
title: Device Command - Application Layer Class Diagram
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
    class EdgeService {
        -String baseUrl
        -String hardwareId
        -String apiKey
        -unsigned long lastCommandPollTime
        -unsigned long commandPollInterval
        -CommandCallback commandCallback
        -queue~RemoteCommand~ commandQueue
        -bool processingQueue
        -unsigned long commandsReceived
        -unsigned long commandsExecuted
        -unsigned long commandsFailed
        -unsigned long commandsQueued
        -unsigned long commandProcessDelay
        +begin(url, id, secret, telemetryInterval, commandPollInterval)
        +pollCommands()
        +processCommandQueue()
        +setCommandCallback(callback)
        +setCommandsEnabled(enabled)
        +setCommandProcessDelay(delayMs)
        +clearCommandQueue()
        +getCommandQueueSize()
        +printStats()
        -addAuthHeaders()
        -sendAck(commandId, status, failureReason)
        -buildTelemetryPayload(data)
    }

    class RemoteCommand {
        +String commandId
        +String type
        +String parameters
        +bool valid
    }

    class CommandProcessor {
        +processCommand(cmd)
        +validateCommand(cmd)
        +getCommandType(cmd)
        +extractParameters(cmd)
    }
}

%% Relationships strictly inside Application Layer
EdgeService *-- RemoteCommand : contains (queue)
CommandProcessor --> RemoteCommand : processes
EdgeService --> CommandProcessor : delegates
```
---

### 2.3. Domain Layer

```mermaid
---
title: Device Command - Domain Layer Class Diagram
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
    class Command {
        +int id
    }

    class CommandHandler {
        <<interface>>
        +handle(Command command)
    }

    class RemoteCommandType {
        <<enum>>
        STANDBY
        WAKE
        RESTART
        REPORT
        CALIBRATE
    }

    class CommandResult {
        +bool success
        +String failureReason
        +unsigned long executionTimeMs
    }
}

%% Domain relationships
CommandHandler <|-- Command : handled by
RemoteCommandType --> CommandResult : maps to
```
---

## 2.4. Infrastructure Layer

```mermaid
---
title: Device Command - Infrastructure Layer Class Diagram
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
        +TOGGLE_LED_COMMAND_ID
        +TURN_ON_COMMAND_ID
        +TURN_OFF_COMMAND_ID
        +START_BLINK_COMMAND_ID
        +STOP_BLINK_COMMAND_ID
        +on()
        +off()
        +toggle()
        +startBlink(intervalMs)
        +stopBlink()
        +update()
        +isBlinking()
        +handle(Command command)
        -applyState()
        -applyBlinkState()
    }

    class OLEDDisplay {
        -Adafruit_SSD1306 display
        -int sdaPin
        -int sclPin
        -uint8_t i2cAddress
        -bool initialized
        -DisplayState currentState
        -unsigned long lastUpdateTime
        -unsigned long lastWakeTime
        -DisplayData currentData
        -unsigned long sleepAfterMs
        -unsigned long wakeDurationMs
        +DISPLAY_ON_COMMAND
        +DISPLAY_OFF_COMMAND
        +DISPLAY_SLEEP_COMMAND
        +DISPLAY_WAKE_COMMAND
        +DISPLAY_CLEAR_COMMAND
        +begin()
        +updateData(data)
        +refresh()
        +clear()
        +sleep()
        +wake()
        +off()
        +on()
        +handle(Command command)
        +autoPowerManagement()
        +isInitialized()
        +getState()
        +setSleepTimeout(ms)
    }

    class CommandDispatch {
        <<conceptual>>
        +handler->handle(command)
    }

    class HttpCommandClient {
        -HTTPClient httpClient
        +getPendingCommands(url)
        +sendAck(url, commandId, status)
        +addAuthHeaders()
        +setTimeout(ms)
    }

    class DisplayState {
        <<enum>>
        DISPLAY_ON
        DISPLAY_SLEEP
        DISPLAY_OFF
    }
}

%% Infrastructure relationships
Led ..> CommandDispatch : receives commands via
OLEDDisplay ..> CommandDispatch : receives commands via
HttpCommandClient --> EdgeService : used by
```
---

## 3. Key Flows
### 3.1. Remote Command Polling and Execution Flow

```mermaid
sequenceDiagram
    participant ES as EdgeService
    participant HTTP as HttpCommandClient
    participant Edge as Edge Station
    participant Queue as Command Queue
    participant CB as CommandDispatch
    participant CD as ClairDevice
    participant LED as Led
    participant Display as OLEDDisplay

    Note over ES,Edge: Periodic Polling Cycle (every 5-10s)

    ES->>HTTP: pollCommands()
    HTTP->>Edge: GET /api/v1/device/commands/pending
    Edge-->>HTTP: RemoteCommand[] (STANDBY, WAKE, REPORT, etc.)
    HTTP-->>ES: commands received

    loop Each command
        ES->>Queue: push(command)
        ES->>ES: commandsQueued++
    end

    Note over ES,Queue: Async Processing (with delay between commands)

    ES->>Queue: pop()
    Queue-->>ES: RemoteCommand
    ES->>CB: commandCallback(cmd)
    CB->>CD: handle(Command)

    alt Command Type: STANDBY
        CD->>CD: setStandbyMode(true)
        CD->>LED: off()
        CD->>Display: sleep()
    else Command Type: WAKE
        CD->>CD: setStandbyMode(false)
        CD->>Display: on()
    else Command Type: REPORT
        CD->>CD: forceReport()
    else Command Type: CALIBRATE
        CD->>CD: scd41Device.recalibrate(400)
    end

    CD-->>CB: execution result
    CB-->>ES: success/failure
    ES->>HTTP: sendAck(commandId, status)
    HTTP->>Edge: POST /api/v1/device/commands/{id}/ack
    Edge-->>HTTP: 200 OK
```

### 3.2. Local Command Flow (LED/Display)
```mermaid
sequenceDiagram
    participant CD as ClairDevice
    participant CB as CommandDispatch
    participant LED as Led
    participant Display as OLEDDisplay

    Note over CD,Display: Command from local source (e.g., incident)

    CD->>CB: handle(LED_BLINK_COMMAND)
    CB->>LED: handle(Command)
    LED->>LED: startBlink(500)
    LED->>LED: applyBlinkState()
    LED-->>CD: LED blinking started

    CD->>CB: handle(DISPLAY_SLEEP_COMMAND)
    CB->>Display: handle(Command)
    Display->>Display: sleep()
    Display->>Display: ssd1306_command(DISPLAYOFF)
    Display-->>CD: Display sleeping
```

## 4. Command Types Summary

| Command Type | Command ID | Target | Effect |
|--------------|------------|--------|--------|
| `STANDBY` | `REMOTE_STANDBY_COMMAND (2000)` | `ClairDevice` | Suspends non-essential operations, turns off LED/display |
| `WAKE` | `REMOTE_WAKE_COMMAND (2001)` | `ClairDevice` | Resumes normal operation |
| `RESTART` | `REMOTE_RESTART_COMMAND (2002)` | `ClairDevice` | Resets device (TODO) |
| `REPORT` | `CLAIR_REPORT_COMMAND (1000)` | `ClairDevice` | Forces immediate telemetry report |
| `CALIBRATE` | `CLAIR_CALIBRATE_COMMAND (1001)` | `SCD41Sensor` | Performs forced recalibration to 400ppm |
| `RESET` | `CLAIR_RESET_COMMAND (1002)` | `PMS5003Sensor` | Resets PMS5003 sensor |
| `LED_ON` | `LED_ON_COMMAND (3000)` | `Led` | Turns LED on |
| `LED_OFF` | `LED_OFF_COMMAND (3001)` | `Led` | Turns LED off |
| `LED_BLINK` | `LED_BLINK_COMMAND (3002)` | `Led` | Starts LED blinking (500ms interval) |
| `LED_ACKNOWLEDGE_ALL` | `LED_ACKNOWLEDGE_ALL (3003)` | `Led` | Stops blinking after acknowledge |
| `DISPLAY_ON` | `DISPLAY_ON_COMMAND (400)` | `OLEDDisplay` | Turns display on |
| `DISPLAY_OFF` | `DISPLAY_OFF_COMMAND (401)` | `OLEDDisplay` | Turns display off completely |
| `DISPLAY_SLEEP` | `DISPLAY_SLEEP_COMMAND (402)` | `OLEDDisplay` | Puts display in sleep mode |
| `DISPLAY_WAKE` | `DISPLAY_WAKE_COMMAND (403)` | `OLEDDisplay` | Wakes display from sleep |
| `DISPLAY_CLEAR` | `DISPLAY_CLEAR_COMMAND (404)` | `OLEDDisplay` | Clears display |

## 5. Bounded Context Summary

| Layer | Components | Responsibility |
|-------|------------|----------------|
| **Interfaces** | `ClairDevice` | Main orchestrator, implements CommandHandler, processes all command types |
| **Application** | `EdgeService`, `RemoteCommand`, `CommandProcessor` | Polls Edge for commands, manages command queue, dispatches to handlers, sends ACKs |
| **Domain** | `Command`, `CommandHandler`, `RemoteCommandType`, `CommandResult` | Command abstraction, handler interface, command type enumeration |
| **Infrastructure** | `Led`, `OLEDDisplay`, `CommandDispatch`, `HttpCommandClient` | Concrete actuators, HTTP client for Edge communication, conceptual dispatch mechanism |

