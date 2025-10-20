# Simulation Job Queue System - C4 Architecture Diagrams (Mermaid)

## 1. System Context Diagram (C1)

```mermaid
C4Context
    title System Context Diagram - Simulation Job Queue System
    
    Person(researcher, "Researcher", "User who submits and monitors simulation jobs")
    Person(admin, "System Administrator", "Manages system configuration and monitoring")
    
    
    System(simSystem, "Simulation System", "Allows users to submit, monitor, and manage simulation jobs using consistent terminology across all interfaces")
    
    System_Ext(machinery, "Machinery Queue", "Distributed task queue using Redis for job processing")
    System_Ext(lambda, "AWS Lambda", "Serverless compute platform for simulation execution")
    System_Ext(sqs, "AWS SQS", "Message queue service for Lambda-based simulations")
    System_Ext(redis, "Redis", "In-memory data store for Machinery queue backend")
    System_Ext(monitoring, "Monitoring System", "System metrics and logs (Prometheus, Grafana)")
    
    Rel_D(researcher, simSystem, "Submits simulations, views results", "HTTPS")
    Rel_D(admin, simSystem, "Configures system, views metrics", "HTTPS")
    
    Rel(simSystem, machinery, "Enqueues simulation tasks", "Machinery Protocol")
    Rel(simSystem, lambda, "Invokes simulation functions", "AWS SDK")
    Rel(simSystem, sqs, "Sends simulation messages", "AWS SQS API")
    Rel(machinery, redis, "Stores task state", "Redis Protocol")
    Rel(simSystem, monitoring, "Sends metrics and logs", "Prometheus/Loki")
    
    UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

---

## 2. Container Diagram (C2)

```mermaid
C4Container
    title Container Diagram - Simulation Job Queue System
    
    Person(researcher, "Researcher", "User who submits and monitors simulations")
    
    System_Boundary(simSystem, "Simulation System") {
        Container(spa, "Web Application", "Vue.js SPA", "Provides simulation submission and monitoring UI using consistent 'Simulation' terminology")
        Container(docs, "User Documentation", "Markdown/HTML", "User manual and API documentation using 'Simulation' ubiquitous language")
        Container(api, "API Application", "Go", "Handles simulation requests, implements domain logic and ports")
        Container(domain, "Domain Core", "Go", "Pure business logic for simulations - no infrastructure dependencies")
        ContainerDb(db, "Application Database", "PostgreSQL", "Stores simulation metadata, status, and results")
    }
    
    System_Ext(machinery, "Machinery Queue", "Task queue with Redis backend")
    System_Ext(lambda, "AWS Lambda", "Serverless execution platform")
    System_Ext(sqs, "AWS SQS", "Message queue service")
    
    Rel(researcher, spa, "Views simulations, submits new simulations", "HTTPS")
    Rel(researcher, docs, "Reads about simulation concepts", "HTTPS")
    
    Rel(spa, api, "Makes API calls using Simulation terminology", "JSON/HTTPS")
    Rel(api, domain, "Uses domain services and aggregates", "Function calls")
    Rel(api, db, "Reads/writes simulation data", "SQL/TLS")
    
    Rel(api, machinery, "Enqueues via MachineryAdapter", "Machinery Protocol")
    Rel(api, lambda, "Invokes via LambdaAdapter", "AWS SDK")
    Rel(api, sqs, "Sends messages via LambdaAdapter", "AWS SQS API")
    
    UpdateRelStyle(researcher, spa, $offsetY="-40")
    UpdateRelStyle(spa, api, $offsetY="-20")
```


---

## 3. Component Diagram - Backend API (C3)

```mermaid
C4Component
    title Component Diagram - API Application (Backend)
    
    Container(spa, "Web Application", "Vue.js SPA", "Frontend making API calls")
    
    Container_Boundary(api, "API Application") {
        Component(router, "HTTP Router", "Go net/http", "Routes requests to appropriate handlers")
        Component(middleware, "Auth Middleware", "Go middleware", "Authentication and authorization")
        Component(simHandler, "SimulationHandler", "Primary Adapter", "Handles HTTP requests for simulation operations")
        
        Component(simService, "SimulationService", "Primary Port Interface", "Defines use cases for simulation operations")
        
        Component(simAggregate, "Simulation Aggregate", "Domain Entity", "Core simulation business logic and rules")
        Component(simScheduler, "SimulationScheduler", "Domain Service", "Orchestrates simulation scheduling logic")
        Component(simValidator, "SimulationValidator", "Domain Service", "Validates simulation parameters")
        
        Component(queuePort, "SimulationQueue", "Secondary Port Interface", "Defines contract for queue operations")
        Component(repoPort, "SimulationRepository", "Secondary Port Interface", "Defines contract for persistence")
        
        Component(machineryAdapter, "MachinerySimulationQueue", "Secondary Adapter", "Implements queue port for Machinery")
        Component(lambdaAdapter, "LambdaSimulationQueue", "Secondary Adapter", "Implements queue port for AWS Lambda")
        Component(pgAdapter, "PostgresSimulationRepo", "Secondary Adapter", "Implements repository port for PostgreSQL")
    }
    
    ContainerDb(db, "Application Database", "PostgreSQL", "Stores simulation data")
    System_Ext(machinery, "Machinery Queue", "Task queue system")
    System_Ext(lambda, "AWS Lambda + SQS", "Serverless platform")
    
    Rel(spa, router, "Makes API calls", "JSON/HTTPS")
    Rel(router, middleware, "Passes request")
    Rel(middleware, simHandler, "Authenticated request")
    
    Rel(simHandler, simService, "Calls use cases", "Go interface")
    
    Rel(simService, simAggregate, "Uses")
    Rel(simService, simScheduler, "Uses")
    Rel(simService, simValidator, "Uses")
    Rel(simService, queuePort, "Enqueues via interface")
    Rel(simService, repoPort, "Persists via interface")
    
    Rel(queuePort, machineryAdapter, "Implemented by")
    Rel(queuePort, lambdaAdapter, "Implemented by")
    Rel(repoPort, pgAdapter, "Implemented by")
    
    Rel(machineryAdapter, machinery, "Translates to Machinery Task", "Machinery Protocol")
    Rel(lambdaAdapter, lambda, "Translates to Lambda Event", "AWS SDK")
    Rel(pgAdapter, db, "SQL queries", "SQL/TLS")
    
    UpdateLayoutConfig($c4ShapeInRow="4", $c4BoundaryInRow="1")
```

---

## 4. Component Diagram - Frontend (C3 - Detailed)

```mermaid
C4Component
    title Component Diagram - Web Application (Vue.js Frontend)
    
    Person(researcher, "Researcher", "System user")
    
    Container_Boundary(spa, "Web Application - Vue.js SPA") {
        Component(router, "Vue Router", "Vue Router", "Client-side routing, navigation guards")
        
        Component(simListView, "SimulationListView", "Vue Component", "Displays list of simulations with filtering and sorting")
        Component(simDetailView, "SimulationDetailView", "Vue Component", "Shows detailed simulation information and logs")
        Component(simSubmitView, "SimulationSubmitView", "Vue Component", "Form for submitting new simulations")
        Component(dashboardView, "DashboardView", "Vue Component", "Overview with statistics and recent simulations")
        
        Component(simCard, "SimulationCard", "Vue Component", "Reusable card displaying simulation summary")
        Component(simForm, "SimulationForm", "Vue Component", "Reusable form with validation for simulation parameters")
        Component(simStatus, "SimulationStatusBadge", "Vue Component", "Visual status indicator")
        Component(simTable, "SimulationTable", "Vue Component", "Sortable, filterable table of simulations")
        
        Component(simStore, "SimulationStore", "Pinia Store Module", "Manages simulation state, actions, and getters")
        Component(authStore, "AuthStore", "Pinia Store Module", "Manages authentication state")
        Component(uiStore, "UIStore", "Pinia Store Module", "Manages UI state (loading, errors, notifications)")
        
        Component(apiClient, "ApiClient", "Service", "HTTP client wrapper with interceptors, error handling")
        Component(simService, "SimulationService", "Service", "Translates between API DTOs and domain models")
        Component(authService, "AuthService", "Service", "Handles authentication, token management")
        
        Component(useSimulation, "useSimulation", "Composable", "Reactive simulation operations (submit, cancel, refresh)")
        Component(useSimulationList, "useSimulationList", "Composable", "Reactive list operations (fetch, filter, sort)")
        
        Component(simModel, "Simulation", "TypeScript Interface", "Frontend domain model matching backend ubiquitous language")
        Component(simDTO, "SimulationDTO", "TypeScript Interface", "Data transfer object for API communication")
    }
    
    Container(api, "API Application", "Go", "Backend API")
    
    Rel(researcher, router, "Navigates to pages", "HTTPS")
    Rel(router, simListView, "Routes to")
    Rel(router, simDetailView, "Routes to")
    Rel(router, simSubmitView, "Routes to")
    Rel(router, dashboardView, "Routes to")
    
    Rel(simListView, simTable, "Uses", "Props & Events")
    Rel(simListView, simCard, "Uses", "Props & Events")
    Rel(simDetailView, simStatus, "Uses", "Props")
    Rel(simSubmitView, simForm, "Uses", "Props & Events")
    
    Rel(simListView, useSimulationList, "Uses", "Reactive data")
    Rel(simDetailView, useSimulation, "Uses", "Reactive data")
    Rel(simSubmitView, useSimulation, "Uses", "Reactive data")
    
    Rel(useSimulation, simStore, "Accesses/mutates")
    Rel(useSimulationList, simStore, "Accesses/mutates")
    
    Rel(simStore, simService, "Calls")
    Rel(authStore, authService, "Calls")
    
    Rel(simService, apiClient, "Makes HTTP requests")
    Rel(authService, apiClient, "Makes HTTP requests")
    
    Rel(simService, simModel, "Returns/accepts")
    Rel(simService, simDTO, "Transforms to/from")
    
    Rel(apiClient, api, "HTTP requests", "JSON/HTTPS")
    
    UpdateLayoutConfig($c4ShapeInRow="4", $c4BoundaryInRow="1")
```

---

## 5. Dynamic Diagram - Submission Flow (C4)

```mermaid
C4Dynamic
    title Dynamic Diagram - Simulation Submission Flow
    
    Person(researcher, "Researcher", "System user")
    
    Container_Boundary(frontend, "Vue.js Frontend") {
        Component(view, "SimulationSubmitView", "Vue Component")
        Component(composable, "useSimulation()", "Composable")
        Component(store, "SimulationStore", "Pinia Store")
        Component(service, "SimulationService", "Service")
        Component(client, "ApiClient", "HTTP Client")
    }
    
    Container(api, "API Backend", "Go")
    ContainerDb(db, "Database", "PostgreSQL")
    System_Ext(queue, "Queue System", "Machinery/Lambda")
    
    Rel(researcher, view, "1. Submits form", "User input")
    Rel(view, composable, "2. submitSimulation()", "Function call")
    Rel(composable, store, "3. Dispatch action", "Pinia")
    Rel(store, service, "4. submit(simulation)", "Method call")
    Rel(service, client, "5. POST request", "HTTP")
    Rel(client, api, "6. /api/v1/simulations", "JSON/HTTPS")
    Rel(api, db, "7. Save metadata", "SQL")
    Rel(api, queue, "8. Enqueue task", "Adapter")
    Rel(api, client, "9. Return DTO", "201 Created")
    Rel(client, service, "10. Response", "Promise")
    Rel(service, store, "11. Update state", "Simulation")
    Rel(store, view, "12. Reactive update", "Vue")
    Rel(view, researcher, "13. Show notification", "UI feedback")
    
    UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

---

## 6. Deployment Diagram - System Deployment

```mermaid
C4Deployment
    title Deployment Diagram - Simulation System
    
    Deployment_Node(browser, "User's Browser", "Chrome/Firefox/Safari") {
        Container(spa, "Vue.js SPA", "JavaScript", "Frontend application")
    }
    
    Deployment_Node(cdn, "CDN", "CloudFront") {
        Container(staticAssets, "Static Assets", "JS/CSS/HTML", "Compiled frontend bundle")
    }
    
    Deployment_Node(kubernetes, "Kubernetes Cluster", "AWS EKS") {
        Deployment_Node(apiPod, "API Pod", "Container") {
            Container(api, "API Application", "Go", "Backend service")
        }
        
        Deployment_Node(workerPod, "Worker Pod", "Container") {
            Container(worker, "Machinery Worker", "Go", "Processes simulation tasks")
        }
    }
    
    Deployment_Node(aws, "AWS", "Cloud Provider") {
        Deployment_Node(rds, "RDS", "Managed PostgreSQL") {
            ContainerDb(db, "Database", "PostgreSQL", "Simulation data")
        }
        
        Deployment_Node(elasticache, "ElastiCache", "Managed Redis") {
            ContainerDb(redis, "Redis", "Redis", "Queue backend")
        }
        
        Deployment_Node(lambdaService, "Lambda Service", "Serverless") {
            Container(lambda, "Simulation Function", "Python/Go", "Serverless execution")
        }
        
        Deployment_Node(sqsService, "SQS", "Message Queue") {
            Container(sqs, "Simulation Queue", "SQS", "Lambda trigger")
        }
    }
    
    Rel(spa, staticAssets, "Loads from", "HTTPS")
    Rel(spa, api, "API calls", "JSON/HTTPS")
    Rel(api, db, "Queries", "SQL/TLS")
    Rel(api, redis, "Queue operations", "Redis Protocol")
    Rel(api, sqs, "Send messages", "AWS SDK")
    Rel(worker, redis, "Poll tasks", "Redis Protocol")
    Rel(sqs, lambda, "Triggers", "Event")
    Rel(lambda, db, "Update results", "SQL/TLS")
    
    UpdateLayoutConfig($c4ShapeInRow="2", $c4BoundaryInRow="1")
```

---

## Alternative Diagrams (Non-C4 Mermaid)

### Sequence Diagram - Detailed Submission Flow

```mermaid
sequenceDiagram
    autonumber
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
    
    Researcher->>View: Fills form and clicks Submit
    View->>Form: Trigger validation
    Form->>Form: Validate SimulationParameters
    Form-->>View: Emit submit event (formData)
    
    Note over View,Comp: Frontend Business Logic
    View->>Comp: submitSimulation(params)
    Comp->>Comp: Create Simulation instance
    Comp->>Comp: Validate domain rules
    
    Note over Comp,Store: State Management
    Comp->>Store: dispatch('submitSimulation')
    Store->>Store: Set isLoading = true
    
    Note over Store,Service: Service/Adapter Layer
    Store->>Service: simulationService.submit(simulation)
    Service->>Service: Transform to SimulationDTO
    Service->>Client: apiClient.post('/simulations', dto)
    Client->>Client: Add auth headers & interceptors
    
    Note over Client,Queue: Backend Processing
    Client->>API: POST /api/v1/simulations
    API->>DB: Save simulation metadata
    API->>Queue: Enqueue via adapter
    API-->>Client: Return SimulationDTO (201)
    
    Note over Service,View: Response Handling
    Client-->>Service: Promise resolves
    Service->>Service: Transform DTO to Simulation
    Service-->>Store: Return Simulation
    Store->>Store: Add to simulations[]
    Store->>Store: Set isLoading = false
    
    Note over View,Researcher: UI Update
    Store-->>Comp: Reactive state update
    Comp-->>View: State propagates (Vue reactivity)
    View->>View: Hide loading spinner
    View->>Researcher: Show success notification
    View->>Researcher: Navigate to simulation detail
```

### Class Diagram - Domain Models

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
        <<Value Object>>
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
        <<Data Transfer Object>>
        +string id
        +string name
        +object parameters
        +string status
        +string createdAt
    }
    
    class SimulationService {
        <<Adapter>>
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
    
    note for Simulation "Domain Model - matches backend ubiquitous language"
    note for SimulationService "Adapter Pattern - translates between domain and API"
```

### State Diagram - Simulation Lifecycle

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
```

