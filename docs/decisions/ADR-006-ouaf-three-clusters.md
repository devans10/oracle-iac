# ADR-006: CC&B and MDM — Separate Web/IWS/Batch Clusters

**Status**: Accepted

## Decision
Both CC&B and MDM use 3 separate WLS clusters within a single WLS domain:
- **Web cluster**: OUAF UI, ADF, Entra ID SAML SP (HTTP session replication enabled)
- **IWS cluster**: WebServices.ear (SOAP/REST inbound web services for SOA integration)
- **Batch cluster**: OUAF batch threads (billing cycle, IMD ingest, VEE, GL extract)

## Consequence
- Batch isolation prevents billing batch CPU/memory pressure from degrading UI response times
- IWS cluster can be independently scaled for integration load without affecting web users
- OHS routes only to Web and IWS clusters — Batch cluster is not OHS-routed
- `iwsdeploy.sh` targets the IWS cluster specifically
