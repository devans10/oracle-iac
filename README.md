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
| Oracle HTTP Server | n/a | 3-node | mod_wl_ohs proxy (WEB/IWS only — not Batch) |
| Oracle RAC 19c+ | n/a | 3 clusters | CCB-RAC, MDM-RAC, SOA-RAC |

**Hypervisor**: Oracle Linux KVM — one WLS Managed Server per Oracle Linux VM  
**SSO**: Microsoft Entra ID (SAML 2.0) — WEB clusters only  
**PAM**: BeyondTrust PasswordSafe — credential retrieval via REST API  
**DR**: Active-Passive; Data Guard Maximum Availability Mode; KVM VMs at DR site

## Environments

| Environment | Provider | Purpose |
|---|---|---|
| `primary` | KVM / libvirt | Production Site A — full HA topology |
| `dr` | KVM / libvirt | DR Site B — Data Guard standby |
| `dev` | KVM / libvirt | Developer sandbox — single KVM host, minimal scale |
| `azure-dev` | Azure IaaS (azurerm) | Azure developer environment — single-instance DB + app VMs |
| `do-dev` | DigitalOcean (digitalocean) | DigitalOcean developer environment — Droplets + Block Storage |

Dev environments (`dev`, `azure-dev`, `do-dev`) use a single-instance Oracle 19c CDB (CDBDEV) with PDBs for CCB, MDM, and SOA. OHS, Entra ID SAML, NFS, and Data Guard are disabled via inventory feature flags.

## Prerequisites

Before running any automation, ensure the following are in place:

1. **BeyondTrust PasswordSafe** reachable from control node; API registration created; Client ID/Secret stored at `~/.bt_wallet/credentials` (see `docs/runbooks/secrets-management.md`)
2. **Ansible Vault** password at `~/.vault_pass` (not committed)
3. **Oracle software media** staged at `{{ media_base_path }}` — set via `ansible/group_vars/all/main.yml` (default: `/u01/oracle/stage/media`)
4. **KVM hosts** provisioned with Oracle Linux 8/9; SSH key access from control node (for KVM environments)
5. **Terraform** >= 1.5; provider installed for your target environment
6. **Ansible** >= 2.15; `ansible-lint` >= 6.0
7. **Entra ID Enterprise App** registrations created per `docs/runbooks/entra-id-setup.md` (production only)
8. DNS entries for all VM hostnames resolvable from control node

## Quick Start — Production (KVM)

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

## Quick Start — Azure Dev

```bash
# 1. Provision VMs
cp terraform/environments/azure-dev/terraform.tfvars.example \
   terraform/environments/azure-dev/terraform.tfvars
# Edit terraform.tfvars with subscription_id, resource_group_name, ssh_public_key
cd terraform/environments/azure-dev
terraform init -backend-config=../../backend.hcl
terraform apply

# 2. Build inventory from Terraform outputs
cp ansible/inventories/azure-dev.yml.example ansible/inventories/azure-dev.yml
# Replace placeholder IPs with: terraform output db_vm_private_ip, ccb_app_vm_private_ip, etc.

# 3. Install DB and apps
ansible-playbook ansible/playbooks/infra/oracle-db.yml \
  -i ansible/inventories/azure-dev.yml --vault-password-file ~/.vault_pass
ansible-playbook ansible/playbooks/ccb/install.yml \
  -i ansible/inventories/azure-dev.yml --vault-password-file ~/.vault_pass
```

## Quick Start — DigitalOcean Dev

```bash
# 1. Provision Droplets
cp terraform/environments/do-dev/terraform.tfvars.example \
   terraform/environments/do-dev/terraform.tfvars
# Edit terraform.tfvars with do_token, ssh_key_ids, oracle_linux_image
cd terraform/environments/do-dev
terraform init -backend-config=../../backend.hcl
terraform apply

# 2. Build inventory from Terraform outputs
cp ansible/inventories/do-dev.yml.example ansible/inventories/do-dev.yml
# Replace placeholder IPs with: terraform output db_droplet_private_ip, ccb_app_private_ip, etc.

# 3. Install DB and apps
ansible-playbook ansible/playbooks/infra/oracle-db.yml \
  -i ansible/inventories/do-dev.yml --vault-password-file ~/.vault_pass
ansible-playbook ansible/playbooks/ccb/install.yml \
  -i ansible/inventories/do-dev.yml --vault-password-file ~/.vault_pass
```

## Project Layout

```
terraform/
  modules/
    oracle-linux-vm/    # KVM/libvirt VM
    azure-linux-vm/     # Azure VM
    do-droplet/         # DigitalOcean Droplet
  environments/
    primary/            # Production Site A
    dr/                 # DR Site B
    dev/                # KVM dev
    azure-dev/          # Azure dev
    do-dev/             # DigitalOcean dev
ansible/
  roles/                # 26 roles (see CLAUDE.md for full list)
  playbooks/            # Site-wide and per-component plays
  inventories/          # *.yml.example templates for each environment
  group_vars/           # Variables scoped by host group
scripts/
  bootstrap/            # init-vault.sh, setup-ssh-keys.sh
  beyondtrust/          # get-credential.sh
  wlst/                 # rotate-ds-password.py
  validation/           # smoke-test-all.sh
docs/
  architecture/         # Architecture reference index
  decisions/            # ADR-001 through ADR-006
  runbooks/             # secrets-management.md
```

See `CLAUDE.md` for the full directory reference, coding conventions, and Claude Code usage guide.

## Documentation

- Architecture: `docs/architecture/`
- Runbooks: `docs/runbooks/`
- Decision records: `docs/decisions/`
