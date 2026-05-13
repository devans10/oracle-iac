# oracle-iac

Infrastructure-as-Code and automated installation for the Oracle CC&B 25.10 / MDM 25.10 / SOA Suite enterprise upgrade project.

## Architecture Summary

| Application | WLS Domain | Clusters | Notes |
|---|---|---|---|
| Oracle CC&B 25.10 | `ccb_domain` | Web, IWS, Batch | OUAF; SAML 2.0 SSO on Web cluster |
| Oracle MDM 25.10 | `mdm_domain` | Web, IWS, Batch | OUAF; SGG adapters on Batch |
| SOA Suite (INT) | `soa_int` | SOA+OSB, WSM-PM | CC&B ↔ MDM integration |
| SOA Suite (IF) | `soa_if` | SOA+OSB, WSM-PM | External interfaces (ERP, payment) |
| SOA Suite (WEB) | `soa_web` | SOA+OSB, WSM-PM | Web portal integration |
| SOA Suite (SGG) | `soa_sgg` | SOA+OSB, WSM-PM | Itron AMI head-end |
| Oracle HTTP Server | n/a | 3-node | mod_wl_ohs proxy |
| Oracle RAC 19c+ | n/a | 3 clusters | CCB-RAC, MDM-RAC, SOA-RAC |

**Hypervisor**: Oracle Linux KVM — one WLS Managed Server per Oracle Linux VM  
**SSO**: Microsoft Entra ID (SAML 2.0) — WEB clusters only  
**PAM**: BeyondTrust PasswordSafe — credential retrieval via REST API  
**DR**: Active-Passive; Data Guard Maximum Availability Mode; KVM VMs at DR site

## Prerequisites

Before running any automation, ensure the following are in place:

1. **BeyondTrust PasswordSafe** reachable from control node; API registration created; Client ID/Secret in `~/.ps_credentials` (see `docs/runbooks/secrets-management.md`)
2. **Ansible Vault** password at `~/.vault_pass` (not committed)
3. **Oracle software media** staged at the path defined in `group_vars/all/media.yml`
4. **KVM hosts** provisioned with Oracle Linux 8/9; SSH key access from control node
5. **Terraform** >= 1.5; `dmacvicar/libvirt` provider installed
6. **Ansible** >= 2.15; `ansible-lint` >= 6.0
7. **Entra ID Enterprise App** registrations created per `docs/runbooks/entra-id-setup.md`
8. DNS entries for all VM hostnames resolvable from control node

## Quick Start

```bash
# 1. Clone and configure
git clone <repo-url> oracle-iac && cd oracle-iac
cp ansible/inventories/primary.yml.example ansible/inventories/primary.yml
# Edit inventory with actual hostnames/IPs

# 2. Bootstrap secrets (one-time)
bash scripts/bootstrap/init-vault.sh
bash scripts/bootstrap/setup-ssh-keys.sh

# 3. Provision VMs (Terraform)
cd terraform/environments/primary
terraform init -backend-config=../../backend.hcl
terraform plan && terraform apply

# 4. Install and configure everything (Ansible)
cd ../../..
ansible-playbook ansible/playbooks/site/site.yml \
  -i ansible/inventories/primary.yml \
  --vault-password-file ~/.vault_pass

# 5. Validate
bash scripts/validation/smoke-test-all.sh primary
```

## Project Layout

See `CLAUDE.md` for the full directory reference, coding conventions, and Claude Code usage guide.

## Documentation

- Architecture: `docs/architecture/`
- Runbooks: `docs/runbooks/`
- Decision records: `docs/decisions/`
