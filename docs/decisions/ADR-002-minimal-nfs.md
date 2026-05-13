# ADR-002: Minimal NFS — Domain Homes on Local VM Disk

**Status**: Accepted

## Decision
NFS is used ONLY for shared file exchange points that require multi-host access:
1. Batch output files (CC&B bill extract, GL export)
2. SOA JCA File Adapter inbound/outbound directories
3. MDM IMD file drop from SGG SFTP

## NOT on NFS
- WLS domain homes (local VM disk per VM)
- WLS binaries / FMW software (local VM disk, installed by Ansible)
- WLS server logs (local disk → shipped to SIEM via log agent)
- JMS / TLOG persistent stores (JDBC-backed in Oracle DB)

## Consequence
WLS domain config changes propagate via the WLS Admin Server control channel (T3), not shared filesystem. Application deployments use WLST `deploy()` targeting clusters.
