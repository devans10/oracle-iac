# ADR-005: SOA Suite — 4 Independent WLS Domains

**Status**: Accepted

## Decision
SOA Suite uses 4 completely separate WLS domains:
- **soa_int**: CC&B ↔ MDM internal integration (BPEL, OSB, Mediator)
- **soa_if**: External interfaces (ERP, payment processors, field service)
- **soa_web**: Web portal integration (REST/SOAP APIs for customer portal)
- **soa_sgg**: Itron Smart Grid Gateway AMI head-end integration

Each domain has its own Admin Server, domain home (local VM disk), RCU schema set, WSM-PM cluster, and independent lifecycle.

## Consequence
- SOA-RAC hosts 4 schema sets (prefixed INT_, IF_, WEB_, SGG_) — recommend separate Oracle PDBs
- Patching and composite deployment for one domain do not affect others
- 4 separate Admin Servers to manage — addressed by Ansible automation
