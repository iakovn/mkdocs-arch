# Simulation Job Queue System - Architecture Diagrams

## 1. System Context Diagram (C1)

```mermaid
graph TB
    subgraph External Users
        Researcher[👤 Researcher<br/>Submits and monitors simulations]
        Admin[👤 System Administrator<br/>Manages configuration]
    end
    
    SimSystem[🎯 Simulation System<br/>Manages simulation jobs with<br/>consistent terminology]
    
    subgraph External Systems
        Machinery[⚙️ Machinery Queue<br/>Distributed task queue]
        Lambda[☁️ AWS Lambda<br/>Serverless compute]
        SQS[📬 AWS SQS<br/>Message queue]
        Redis[💾 Redis<br/>In-memory store]
        Monitoring[📊 Monitoring<br/>Prometheus/Grafana]
    end
    
    Researcher -->|HTTPS| SimSystem
    Admin -->|HTTPS| SimSystem
    SimSystem -->|Machinery Protocol| Machinery
    SimSystem -->|AWS SDK| Lambda
    SimSystem -->|AWS API| SQS
    Machinery -->|Redis Protocol| Redis
    SimSystem -->|Metrics| Monitoring
    
    style SimSystem fill:#d4edda,stroke:#28a745,stroke-width:3px
    style Machinery fill:#f8d7da,stroke:#721c24,stroke-width:2px
    style Lambda fill:#f8d7da,stroke:#721c24,stroke-width:2px
    style SQS fill:#f8d7da,stroke:#721c24,stroke-width:2px
    style Redis fill:#f8d7da,stroke:#721c24,stroke-width:2px
    style Monitoring fill:#f8d7da,stroke:#721c24,stroke-width:2px
```

---

## 2. Container Diagram (C2)

```mermaid
graph TB
    Researcher[👤 Researcher]
    
    subgraph SimSystem[Simulation System]
        SPA[📱 Web Application<br/>Vue.js SPA<br/>Uses 'Simulation' terminology]
        Docs[📄 Documentation<br/>User Manual<br/>Ubiquitous Language]
        API[⚙️ API Application<br/>Go<br/>Ports & Adapters]
        Domain[🎯 Domain Core<br/>Go<br/>Pure business logic]
        DB[(💾 Database<br/>PostgreSQL<br/>Simulation metadata)]
    end
    
    subgraph External[External Systems]
        Machinery[⚙️ Machinery<br/>+ Redis]
        Lambda[☁️ AWS Lambda<br/>+ SQS]
    end
    
    Researcher -->|HTTPS| SPA
    Researcher -->|Reads| Docs
    SPA -->|JSON/HTTPS<br/>Simulation API| API
    API -->|Uses| Domain
    API -->|SQL/TLS| DB
    API -->|MachineryAdapter| Machinery
    API -->|LambdaAdapter| Lambda
    
    style Domain fill:#d4edda,stroke:#28a745,stroke-width:3px
    style SPA fill:#e8f4f8,stroke:#2c5aa0,stroke-width:2px
    style API fill:#e8f4f8,stroke:#2c5aa0,stroke-width:2px
    style Machinery fill:#f8d7da,stroke:#721c24,stroke-width:2px
    style Lambda fill:#f8d7da,stroke:#721c24,stroke-width:2px
```

---

## 3. Backend Component Diagram (C3)

```mermaid
graph TB
    SPA[📱 Vue.js Frontend]
    
    subgraph API[API Application - Go Backend]
        subgraph Primary[Primary Adapters - Driving]
            Router[HTTP Router<br/>net/http]
            Middleware[Auth Middleware]
            Handler[SimulationHandler<br/>HTTP → Domain]
        end
        
        subgraph Ports[Port Interfaces]
            ServicePort[SimulationService<br/>interface - Primary Port]
            QueuePort[SimulationQueue<br/>interface - Secondary Port]
            RepoPort[SimulationRepository<br/>interface - Secondary Port]
        end
        
        subgraph DomainLayer[Domain Layer - Core Business Logic]
            Aggregate[Simulation Aggregate<br/>Entity + Value Objects]
            Scheduler[SimulationScheduler<br/>Domain Service]
            Validator[SimulationValidator<br/>Domain Service]
        end
        
        subgraph Secondary[Secondary Adapters - Driven]
            MachineryAdapter[MachinerySimulationQueue<br/>Translates to Task]
            LambdaAdapter[LambdaSimulationQueue<br/>Translates to Event]
            PGAdapter[PostgresSimulationRepo<br/>SQL Implementation]
        end
    end
    
    subgraph External[External Systems]
        Machinery[⚙️ Machinery<br/>Task Queue]
        Lambda[☁️ AWS Lambda]
        DB[(💾 PostgreSQL)]
    end
    
    SPA --> Router
    Router --> Middleware
    Middleware --> Handler
    Handler --> ServicePort
    ServicePort --> Aggregate
    ServicePort --> Scheduler
    ServicePort --> Validator
    ServicePort --> QueuePort
    ServicePort --> RepoPort
    QueuePort -.implements.-> MachineryAdapter
    QueuePort -.implements.-> LambdaAdapter
    RepoPort -.implements.-> PGAdapter
    MachineryAdapter --> Machinery
    LambdaAdapter --> Lambda
    PGAdapter --> DB
    
    style DomainLayer fill:#d4edda,stroke:#28a745,stroke-width:3px
    style Ports fill:#fff3cd,stroke:#856404,stroke-width:2px
    style Primary fill:#cce5ff,stroke:#004085,stroke-width:2px
    style Secondary fill:#cce5ff,stroke:#004085,stroke-width:2px
```

---

## 4. Frontend Component Diagram - Detailed (C3)

```mermaid
graph TB
    User[👤 Researcher]
    
    subgraph VueSPA[Vue.js Frontend Application]
        subgraph Views[Views - Pages]
            ListView[SimulationListView<br/>List all simulations]
            DetailView[SimulationDetailView<br/>Simulation details]
            SubmitView[SimulationSubmitView<br/>Submit new simulation]
            Dashboard[DashboardView<br/>Overview & stats]
        end
        
        subgraph Components[Reusable Components]
            Card[SimulationCard<br/>Display summary]
            Form[SimulationForm<br/>Input with validation]
            Status[SimulationStatusBadge<br/>Visual status]
            Table[SimulationTable<br/>Sortable table]
        end
        
        subgraph Composables[Composables - Vue 3]
            UseSimulation[useSimulation<br/>Submit, cancel, refresh]
            UseList[useSimulationList<br/>Fetch, filter, sort]
            UseAuth[useAuth<br/>Authentication]
            UseNotify[useNotification<br/>Toast messages]
        end
        
        subgraph StateManagement[State Management - Pinia]
            SimStore[SimulationStore<br/>Actions, Getters, State]
            AuthStore[AuthStore<br/>Auth state]
            UIStore[UIStore<br/>Loading, errors]
        end
        
        subgraph Services[Services Layer - Adapters]
            SimService[SimulationService<br/>DTO ↔ Domain translation]
            AuthService[AuthService<br/>Token management]
            ApiClient[ApiClient<br/>HTTP wrapper]
        end
        
        subgraph Models[Domain Models - Frontend]
            SimModel[Simulation<br/>TypeScript Interface]
            ParamsModel[SimulationParameters<br/>Value Object]
            StatusModel[SimulationStatus<br/>Enum: PENDING, RUNNING...]
        end
    end
    
    Backend[⚙️ Go API Backend]
    
    User --> ListView
    User --> SubmitView
    ListView --> Table
    ListView --> Card
    SubmitView --> Form
    DetailView --> Status
    
    ListView --> UseList
    SubmitView --> UseSimulation
    DetailView --> UseSimulation
    
    UseSimulation --> SimStore
    UseList --> SimStore
    UseAuth --> AuthStore
    
    SimStore --> SimService
    AuthStore --> AuthService
    SimService --> ApiClient
    AuthService --> ApiClient
    
    SimService --> SimModel
    SimStore --> SimModel
    SimModel --> ParamsModel
    SimModel --> StatusModel
    
    ApiClient --> Backend
    
    style Models fill:#d4edda,stroke:#28a745,stroke-width:3px
    style Services fill:#cce5ff,stroke:#004085,stroke-width:2px
    style StateManagement fill:#fff3cd,stroke:#856404,stroke-width:2px
    style Composables fill:#e8f4f8,stroke:#2c5aa0,stroke-width:2px
```

---

## 5. Frontend Code Structure - SimulationSubmitView

```mermaid
graph TB
    subgraph Component[SimulationSubmitView.vue - Single File Component]
        subgraph Template[Template Section]
            HTML[<template><br/>Declarative UI markup]
            FormUsage[<SimulationForm><br/>Component instance]
            NotifUsage[<NotificationToast><br/>Notifications]
        end
        
        subgraph Script[Script Section - Composition API]
            Imports[Import statements<br/>Dependencies]
            ComposableSetup[Setup composables<br/>useSimulation, useNotification]
            ReactiveState[Reactive state<br/>ref, reactive]
            ComputedProps[Computed properties<br/>canSubmit, isFormValid]
            Methods[Methods<br/>handleSubmit, validateForm]
            Lifecycle[Lifecycle hooks<br/>onMounted, onUnmounted]
            Watchers[Watchers<br/>watch formData changes]
        end
        
        subgraph Style[Style Section]
            CSS[<style scoped><br/>Component styles]
        end
    end
    
    subgraph UsedComposables[Composables]
        UseSimComp[useSimulation<br/>submit, cancel, isLoading]
        UseNotifComp[useNotification<br/>showSuccess, showError]
    end
    
    subgraph DomainModels[Domain Models]
        Simulation[Simulation<br/>id, name, parameters, status]
        SimParams[SimulationParameters<br/>iterations, timeout, algorithm]
        SimStatus[SimulationStatus<br/>PENDING &#124; RUNNING &#124; COMPLETED]
    end
    
    subgraph Store[Pinia Store]
        Actions[SimulationStore.actions<br/>submitSimulation]
        State[SimulationStore.state<br/>simulations, loading]
    end
    
    subgraph Service[Service Layer]
        SimServiceSubmit[SimulationService.submit<br/>Transform & API call]
        ApiPost[ApiClient.post<br/>HTTP POST]
    end
    
    Template --> Script
    Script --> ComposableSetup
    ComposableSetup --> UseSimComp
    ComposableSetup --> UseNotifComp
    Methods --> UseSimComp
    Methods --> Simulation
    ReactiveState --> SimParams
    
    UseSimComp --> Actions
    Actions --> SimServiceSubmit
    SimServiceSubmit --> ApiPost
    
    Simulation --> SimParams
    Simulation --> SimStatus
    
    style Component fill:#e8f4f8,stroke:#2c5aa0,stroke-width:3px
    style DomainModels fill:#d4edda,stroke:#28a745,stroke-width:2px
    style Service fill:#cce5ff,stroke:#004085,stroke-width:2px
```

---

## 6. Sequence Diagram - Simulation Submission Flow

```mermaid
sequenceDiagram
    actor Researcher
    participant View as SimulationSubmitView
    participant Form as SimulationForm
    participant Comp as useSimulation()
    participant Store as SimulationStore
    participant Service as SimulationService
    participant Client as ApiClient
    participant API as Go Backend
    participant DB as PostgreSQL
    participant Queue as Queue System
    
    Researcher->>View: 1. Fills form and clicks Submit
    View->>Form: 2. Trigger validation
    Form->>Form: 3. Validate SimulationParameters
    Form-->>View: 4. Emit submit event (formData)
    
    View->>Comp: 5. submitSimulation(params)
    Comp->>Comp: 6. Create Simulation instance
    Comp->>Comp: 7. Validate domain rules
    Comp->>Store: 8. dispatch('submitSimulation')
    Store->>Store: 9. Set isLoading = true
    
    Store->>Service: 10. simulationService.submit(simulation)
    Service->>Service: 11. Transform to SimulationDTO
    Service->>Client: 12. apiClient.post('/simulations', dto)
    Client->>Client: 13. Add auth headers
    
    Client->>API: 14. POST /api/v1/simulations
    API->>DB: 15. Save simulation metadata
    API->>Queue: 16. Enqueue via adapter
    API-->>Client: 17. Return SimulationDTO (201)
    
    Client-->>Service: 18. Promise resolves
    Service->>Service: 19. Transform DTO to Simulation
    Service-->>Store: 20. Return Simulation
    
    Store->>Store: 21. Add to simulations[]
    Store->>Store: 22. Set isLoading = false
    Store-->>Comp: 23. Reactive state update
    Comp-->>View: 24. State propagates (Vue reactivity)
    
    View->>View: 25. Hide loading spinner
    View->>Researcher: 26. Show success notification
    View->>Researcher: 27. Navigate to simulation detail
    
    Note over View,Comp: View Layer<br/>User interaction & UI state
    Note over Comp,Store: Composable Layer<br/>Business logic & reactive state
    Note over Store,Service: State Management<br/>Single source of truth
    Note over Service,Client: Service/Adapter Layer<br/>DTO ↔ Domain translation
    Note over API,Queue: Backend<br/>Hexagonal architecture
```

---

## 7. Class Diagram - Frontend Domain Models

```mermaid
classDiagram
    class Simulation {
        +SimulationId id
        +string name
        +SimulationParameters parameters
        +SimulationStatus status
        +Date createdAt
        +Date updatedAt
        +submit() Promise~void~
        +cancel() Promise~void~
        +validate() ValidationResult
        +isRunning() boolean
        +isCompleted() boolean
    }
    
    class SimulationParameters {
        +number iterations
        +number timeout
        +AlgorithmType algorithm
        +Map~string,any~ customParams
        +validate() boolean
        +toJSON() object
    }
    
    class SimulationId {
        +string value
        +equals(other) boolean
        +toString() string
    }
    
    class SimulationStatus {
        <<enumeration>>
        PENDING
        RUNNING
        COMPLETED
        FAILED
        CANCELLED
    }
    
    class AlgorithmType {
        <<enumeration>>
        MONTE_CARLO
        GENETIC_ALGORITHM
        NEURAL_NETWORK
        CUSTOM
    }
    
    class SimulationDTO {
        +string id
        +string name
        +object parameters
        +string status
        +string createdAt
    }
    
    class SimulationService {
        +submit(simulation) Promise~Simulation~
        +cancel(id) Promise~void~
        +getById(id) Promise~Simulation~
        +list(filters) Promise~Simulation[]~
        -toDTO(simulation) SimulationDTO
        -fromDTO(dto) Simulation
    }
    
    Simulation "1" *-- "1" SimulationId : has
    Simulation "1" *-- "1" SimulationParameters : contains
    Simulation "1" --> "1" SimulationStatus : has
    SimulationParameters --> AlgorithmType : uses
    SimulationService ..> Simulation : creates/returns
    SimulationService ..> SimulationDTO : transforms
    
    note for Simulation "Domain Model\nMatches backend ubiquitous language\nBusiness logic methods"
    note for SimulationService "Adapter Pattern\nTranslates between domain and API\nIsolates DTO changes"
```


---

## 8. State Diagram - Simulation Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING : User submits simulation
    
    PENDING --> RUNNING : Queue picks up task
    PENDING --> CANCELLED : User cancels before start
    PENDING --> FAILED : Validation fails
    
    RUNNING --> COMPLETED : Execution successful
    RUNNING --> FAILED : Execution error
    RUNNING --> CANCELLED : User cancels during execution
    
    COMPLETED --> [*]
    FAILED --> [*]
    CANCELLED --> [*]
    
    note right of PENDING
        Initial state
        Awaiting queue pickup
    end note
    
    note right of RUNNING
        Currently executing
        Progress updates available
    end note
    
    note right of COMPLETED
        Successful completion
        Results available
    end note
    
    note right of FAILED
        Error occurred
        Error logs available
    end note
    
    note right of CANCELLED
        User-initiated cancellation
        Partial results may exist
    end note
```

