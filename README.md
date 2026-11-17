# ⚽ World Cup Intelligence Center (WCIC)

> Real-time sports intelligence platform for the 2026 FIFA World Cup.
> Built with n8n as the main orchestrator, PostgreSQL, Redis and GPT-4o agents.

[![Stack](https://img.shields.io/badge/orchestrator-n8n%20Queue%20Mode-orange)]()
[![DB](https://img.shields.io/badge/database-PostgreSQL%2015%20+%20TimescaleDB-blue)]()
[![Cache](https://img.shields.io/badge/cache-Redis%207-red)]()
[![AI](https://img.shields.io/badge/AI-GPT--4o%20Agents-green)]()
[![Infra](https://img.shields.io/badge/infra-Docker%20Compose-blue)]()

---

## What is this project?

WCIC is more than an automation: it is a product platform with a distributed architecture that shows how data intelligence systems are built in real corporate environments.

## Motivation

This project was built to practice:

- Automation architecture
- Systems integration
- Data engineering
- Observability
- Applied artificial intelligence
- Event-driven development

The goal was to simulate a product used by sports media and data analytics companies during major sporting events.

```mermaid
graph LR

A[Sports APIs]
B[n8n Queue Mode]
C[PostgreSQL]
D[Redis]
E[GPT-4o Agents]
F[Grafana]
G[REST API]

A --> B
B --> C
B --> D
B --> E
C --> G
C --> F
```

**What the system does:**

- Collects match data from multiple APIs with fallback and deduplication
- Monitors live events (goals, cards, substitutions) with latency under 2 minutes
- Analyzes news with specialized GPT-4o agents and an impact score
- Processes Twitter and Reddit sentiment during matches
- Generates pre-match predictions with probabilities and an auditable rationale
- Publishes a daily report generated automatically by AI
- Exposes everything through an authenticated REST API for external consumers

---

## Architecture in numbers

| Component | Count |
|---|---|
| n8n workflows | 12 main + 7 subworkflows |
| PostgreSQL tables | 15+ with indexes and materialized views |
| Redis patterns | Cache, Queues, Rate Limiting, Dedup, Circuit Breaker, Pub/Sub |
| AI agents | 4, each with its own responsibility |
| Notification channels | Telegram, Slack, Email, Webhooks |
| Prometheus metrics | 20+ operational and business metrics |

---

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Make (optional, for shorter commands)
- Credentials for the external APIs (see `.env.example`)

### 1. Clone and configure

```bash
git clone https://github.com/amarialeitao/world-cup-intelligence-center.git
cd world-cup-intelligence-center
cp .env.example .env
# Edit .env with your API keys
```

### 2. Start the infrastructure

```bash
docker-compose up -d
```

### 3. Initialize the database

```bash
./scripts/setup-database.sh
```

### 4. Import the workflows into n8n

```bash
./scripts/import-workflows.sh
```

### 5. Check the API connections

```bash
./scripts/test-apis.sh
```

### Service access

| Service | URL | Credentials |
|---|---|---|
| n8n | http://localhost:5678 | `.env N8N_BASIC_AUTH_*` |
| Grafana | http://localhost:3000 | admin / `.env GRAFANA_ADMIN_PASSWORD` |
| Metabase | http://localhost:3001 | set up on first access |
| Prometheus | http://localhost:9090 | no authentication |
| API WCIC | http://localhost:8080/api/v1 | `X-API-Key` header |

---

## Project structure

```
world-cup-intelligence-center/
├── n8n/
│   ├── workflows/          # Workflows exported from n8n (JSON)
│   ├── subflows/           # Reusable sub-workflows (OpenAI agents)
│   └── specs/              # Readable specifications of each workflow (for code review)
├── database/
│   ├── migrations/         # Versioned SQL (run in order)
│   └── seeds/              # Reference data (teams, venues)
├── dashboards/
│   └── grafana/            # Grafana dashboards
├── docker/                 # Per-service configuration (PostgreSQL, Prometheus)
├── docs/                   # Technical documentation and decisions
├── scripts/                # Setup, import and test scripts
└── docker-compose.yml
```

---

## Documentation

| Document | Description |
|---|---|
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Full architecture overview |
| [DECISIONS.md](./docs/DECISIONS.md) | ADRs: why each technology was chosen |
| [API_PROVIDER_DECISION.md](./docs/API_PROVIDER_DECISION.md) | How the sports data API provider was chosen |
| [n8n/specs](./n8n/specs) | Readable specifications of each workflow |

---

## Architectural Patterns

- Event Driven Architecture
- Queue-Based Processing
- Circuit Breaker
- Retry with Exponential Backoff
- Dead Letter Queue
- Cache Aside
- API Gateway Pattern
- AI Agent Orchestration
- Observability First

---

## Roadmap

- [x] Sprint 0 — Base structure and documentation
- [x] Sprint 1 — Database schema
- [ ] Sprint 2 — WF-01 Match Collector + WF-08 Dashboard Sync
- [ ] Sprint 3 — WF-02 Live Events + WF-07 Notification Hub
- [ ] Sprint 4 — WF-03 News Intelligence + WF-04 Sentiment
- [ ] Sprint 5 — WF-05 AI Predictions + WF-11 Accuracy Tracker
- [ ] Sprint 6 — Full observability (Grafana + Prometheus)

---

## Performance Targets

| Metric | Target |
|----------|----------|
| Event Processing Latency | < 2 min |
| Prediction Generation | < 15s |
| Notification Delivery | < 10s |
| Workflow Success Rate | > 99% |
| API Availability | 99.9% |

---

## Technical Skills Demonstrated

- Workflow orchestration with n8n in Queue Mode (horizontal scaling)
- Integration architecture with multiple APIs and automatic fallback
- Relational schema design for time-series data
- Resilience patterns: Circuit Breaker, Dead-letter Queue, Retry with backoff
- Prompt engineering for AI agents with structured, auditable outputs
- Observability with Prometheus and Grafana in a distributed environment
- Security: webhook validation, rate limiting, secrets management
- Containerization of the full stack with Docker Compose

## License

[MIT](LICENSE)
