# StageFlow

StageFlow is a multi-tenant project-management platform for event production teams. This repository currently contains the Phase 1 foundation: a tenant-aware Spring Boot API, PostgreSQL schema, local Keycloak/PostgreSQL infrastructure, architecture documentation, and a native SwiftUI client for Apple platforms.

## Prerequisites

- Java 21
- Maven 3.9+
- Docker with Compose (for PostgreSQL and Keycloak)
- macOS with Xcode 16+ and XcodeGen 2.42+ (for the Apple client)

## Start locally

```bash
cp .env.example .env
docker compose up -d postgres keycloak
cd services/api && mvn spring-boot:run
```

Generate and open the Apple project on macOS:

```bash
cd apps/ios
xcodegen generate
open StageFlow.xcodeproj
```

API health is available at `http://localhost:8080/actuator/health`. The API documentation is at `http://localhost:8080/swagger-ui.html`.

## Validation

```bash
cd services/api && mvn test
cd apps/ios && xcodegen generate && xcodebuild -project StageFlow.xcodeproj -scheme StageFlow -destination 'platform=iOS Simulator,name=iPhone 16' test
```

See [docs/architecture/phase-1.md](docs/architecture/phase-1.md) for scope, decisions, risks, and the implementation sequence.
