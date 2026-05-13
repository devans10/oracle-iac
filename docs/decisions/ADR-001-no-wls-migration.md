# ADR-001: No WLS Managed Server Migration — VM-Level HA

**Status**: Accepted  
**Date**: 2025

## Context
The original architecture specified WLS Whole Server Migration (WSM) for Admin Server HA, requiring shared NFS for domain homes.

## Decision
We do not configure WLS Managed Server migration. Each WLS Managed Server runs on a dedicated Oracle Linux VM on Oracle KVM. HA is achieved at the VM layer:
- KVM host failure → VM restarts on alternate KVM host (HA fencing)
- WLS process crash → Node Manager auto-restarts the MS within the same VM

## Consequences
- **Domain homes live on local VM disk** — no NFS required for WLS config
- **No floating VIPs** for managed servers — simplifies network config
- **WLS binaries on local VM disk** — Ansible handles consistent installation across all VMs
- **Anti-affinity enforced in Terraform** — HA pair VMs (MS-01/MS-02) always land on different KVM hosts
