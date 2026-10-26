# Phase 1 architecture

## Scope and sequence

The repository is a modular monorepo. Phase 1 establishes identity, tenant membership, authorization boundaries, database migrations, API conventions, the mobile design system, and navigation. Subsequent vertical slices add departments/projects, goals/approvals, tasks, notes, notifications, scheduling, and offline synchronization in that order.

The backend is a modular monolith. Domain packages own their entities, repositories, services, DTOs, and controllers. Cross-module references use IDs or narrow service interfaces. PostgreSQL is authoritative; Redis and object storage are deferred until a feature needs them. Authentication is delegated to an OIDC provider, while company membership and resource authorization remain in the application.

## Core entity relationships

- `user_accounts` maps an OIDC subject to the local user profile.
- `companies` owns all tenant-scoped business records.
- `company_memberships` joins users to companies with a role and lifecycle status.
- `departments` belongs to one company; department membership cannot cross company boundaries.
- `projects` belongs to one company and has project/department membership links.
- Goals belong to a project and department; milestones belong to goals.
- Tasks belong to a company and project and optionally reference a department, goal, or milestone.
- Notes use explicit typed links and visibility rules; personal notes have no implicit tenant visibility.
- Attachments, audit logs, notifications, outbox events, and offline receipts carry tenant ownership where applicable.

Composite tenant-aware foreign keys will be used wherever they can prevent cross-company associations in the database. Every aggregate uses UUID identifiers, timestamps, and an optimistic-lock version.

## Permission matrix

| Capability | Owner | Company admin | Project manager | Department head | Crew | Freelancer |
|---|---:|---:|---:|---:|---:|---:|
| Manage company/members | Yes | Yes | No | No | No | No |
| Create/manage projects | Yes | Yes | Assigned | No | No | No |
| Approve department plans | Yes | Yes | Assigned | No | No | No |
| Manage department work | Yes | Yes | View | Own department | Assigned tasks | Explicit assignments |
| Complete assigned tasks | Yes | Yes | Yes | Yes | Yes | Yes |
| Tenant-wide reporting | Yes | Yes | Assigned projects | Own department | No | No |

Platform administrators administer subscriptions but receive no implicit tenant-data access. Endpoint checks combine membership role with resource assignment; client-provided company IDs never establish authority.

## Main journeys

1. A user authenticates, creates a company, configures departments, invites members, and creates the first project.
2. A project manager schedules an event and assigns departments.
3. A department head submits goals and milestones; the project manager approves a versioned baseline.
4. Crew complete assigned work, with blockers, evidence, review, and activity history.
5. Users create scoped notes and convert authorized notes or meeting actions into tasks.
6. Outbox-backed notifications and offline operations are delivered idempotently.

## Apple client navigation and initial screens

A native SwiftUI authentication flow uses OAuth 2.0 Authorization Code with PKCE and stores tokens in Keychain. The authenticated shell uses `Home`, `Projects`, `Calendar`, `Notes`, and `Notifications` tabs. Company and project administration are reached contextually and hidden only for usability—server authorization remains authoritative. Phase 1 implements the Apple design system, OIDC session, typed API client, shell, and loading/error/empty states; later slices connect feature screens as their APIs land. iPhone is the primary target, with adaptive layouts suitable for iPad; Android and web clients are out of scope.

## Security and scalability risks

- Cross-tenant access: derive identity from the verified JWT and require active membership in every tenant query; add isolation integration tests per module.
- Token leakage: use system browser OIDC and SecureStore on-device; never persist refresh tokens in SQLite or logs.
- Offline conflicts: assign client operation IDs, persist receipts, use optimistic versions, and require explicit conflict resolution.
- Notification loss: write transactional outbox rows with business changes and deliver asynchronously with idempotency/retries.
- File exposure: validate tenant permission before issuing short-lived signed URLs.
- Time ambiguity: store instants in UTC plus event/company time zone metadata.
- Hot dashboards: use indexed tenant/status/deadline queries and introduce derived read models only after measurement.

## Progress model

Task completion and readiness are separate. Project readiness is a weighted roll-up of required approved milestones; task completion is reported independently. A project cannot complete while required approvals, critical milestones, or blockers remain open.
