## Setup

```mermaid
flowchart TD
    A(["I2C Setup"]) --> B["Optional: Setup PORTB for debugging"]

    B --> G["Load test transmit bytes for I2C"]
    G --> K["Clear I2C byte index"]

    K --> L["Make RC3 and RC4 inputs for I2C"]
    L --> M["Clear MSSP control and status registers"]
    M --> N["Read SSPBUF once to clear buffer-full state"]
    N --> O["Clear SSP interrupt flag"]

    O --> P["Load the 7-bit slave address"]
    P --> Q["Shift address left by 1 for SSPADD"]
    Q --> R["Write shifted address into SSPADD"]

    R --> S["Enable general call and clock stretching"]
    S --> T["Set MSSP mode to 7-bit I2C slave"]
    T --> U["Enable MSSP module"]
    U --> V["Release clock by setting CKP"]
    V --> W["Clear SSP interrupt flag again"]
    W --> X["Enable MSSP interrupt"]

    X --> Y["Enable peripheral interrupts"]
    Y --> Z["Enable global interrupts"]
    Z --> AA(["Jump to MainLoop"])
```

## Example: Reset I2C Bus State 
If collision, overflow, buffer-full, or MSSP interrupt flags are set I2C communication iss not possible.
```mermaid
flowchart TD
    A(["ResetI2c"]) --> B["Clear write collision flag WCOL"]
    B --> C["Clear receive overflow flag SSPOV"]
    C --> D["Read SSPBUF to clear buffer-full state. BF"]
    D --> E["Clear MSSP interrupt flag SSPIF"]
    E --> F(["Return"])
```
## Address Phase
```mermaid
flowchart TD
    A(["Address byte arrives"]) --> B["Clear local D/A flag"]
    B --> C["Read address from SSPBUF"]
    C --> D{"Is address 0x00?"}

    D -- "Yes" --> E["Mark this as a general call"]
    E --> Q
    D -- "No" --> G{"Was R/W bit = 1?"}
    G -- "Yes" --> H["Master wants to read from slave"]
    G -- "No" --> I["Master wants to write to slave"]

    H --> J["Set read flag"]
    J --> K["Reset byte index to 0"]
    K --> L["Load TX byte 0 into SSPBUF"]
    L --> M["Increment byte index to 1"]
    M --> Q

    I --> N["Clear read flag"]
    N --> P["Reset byte index to 0"]
    P --> Q["Read SSPBUF to clear BF if needed"]
    Q --> R["Clear MSSP interrupt flag"]
    R --> S["Release SCL by setting CKP"]
    S --> T(["Jump to common ISR exit"])
```

## Data-byte path when master reads from slave
```mermaid
flowchart TD
    A(["Data phase and master is reading"]) --> B{"Byte index = 1?"}
    B -- "Yes" --> C["Use TX byte 1"]
    B -- "No" --> D{"Byte index = 2?"}

    D -- "Yes" --> E["Use TX byte 2"]
    D -- "No" --> F["Use TX byte 2 again as default"]

    C --> G["Write selected byte to SSPBUF"]
    E --> G
    F --> G

    G --> H["Increment byte index"]
    H --> Q["Read SSPBUF to clear BF if needed"]
    Q --> R["Clear MSSP interrupt flag"]
    R --> S["Release SCL by setting CKP"]
    S --> T(["Jump to common ISR exit"])
```
## Data-byte path when master writes to slave
```mermaid
flowchart TD
    A(["Data phase and master is writing"]) --> B["Read one byte from SSPBUF"]
    B --> C["Copy byte into temporary register"]
    C --> D{"Byte index = 0?"}

    D -- "Yes" --> E["Store byte into RX byte 0"]
    D -- "No" --> F{"Byte index = 1?"}

    F -- "Yes" --> G["Store byte into RX byte 1"]
    F -- "No" --> H["Store byte into RX byte 2"]

    E --> Q["Increment byte index"]
    G --> Q
    H --> Q["Read SSPBUF to clear BF if needed"]
    Q --> R["Clear MSSP interrupt flag"]
    R --> S["Release SCL by setting CKP"]
    S --> T(["Jump to common ISR exit"])
```

## Full I2C Slave ISR

.

.


```mermaid
flowchart TD
    A("Enter ServiceI2cSlave") --> B{"Receive
    overflow
    happened?"}
    B -- "Yes" --> C["Set overflow flag"]
    C --> D["Reset the I2C bus state"]
    B -- "No" --> E{"Write
    collision
    happened?"}

    E -- "Yes" --> F["Set collision flag"]
    F --> D
    E -- "No" --> G["Save a snapshot of SSPSTAT"]

    G --> H{"Is this an 
    address byte?"}
    H -- "Yes" --> I["Handle address byte"]
    H -- "No, it is data" --> J["Handle data byte"]

    I --> K["Clear local D/A flag"]
    K --> L["Read SSPBUF to 
    get address 
    and clear BF"]
    L --> M{"Was the 
    address 0x00?"}
    M -- "Yes" --> N["Set general
    call flag"]
    N --> O["Finish ISR,
    clear SSPIF,
    release clock,
    leave interrupt"]
    M -- "No" --> P{"Did master 
    request a read?"}

    P -- "Yes" --> Q["Prepare first tx
     byte for master"]
    Q --> O
    P -- "No" --> R["Prepare to receive
     data from master"]
    R --> O

    J --> S["Set local D/A flag"]
    S --> T{"Are we currently 
    in slave 
    transmit mode?"}

    T -- "Yes" --> U["Choose next 
    tx byte
    by index"]
    U --> V["Write byte
    to SSPBUF"]
    V --> W["Increment tx
    byte index"]
    W --> O

    T -- "No" --> X["Read received data byte from SSPBUF once"]
    X --> Y["Store byte in temporary register"]
    Y --> Z{"Which receive
    slot should 
    get this byte?"}

    Z -- "Index 0" --> AA["Store in
    RX byte 0"]
    Z -- "Index 1" --> AB["Store in 
    RX byte 1"]
    Z -- "Index 2 or more" --> AC["Store in
    RX byte 2"]

    AA --> AD["Increment receive byte index"]
    AB --> AD
    AC --> AD
    AD --> O

    D --> O
```