# Oracle CC&B / MDM / SOA Suite — IaC & Automated Installation

## Project Purpose
Infrastructure-as-Code and automated installation for an Oracle utility enterprise platform upgrade:
- **Oracle CC&B 25.10** — Customer Care & Billing (OUAF; 3 WLS clusters: Web, IWS, Batch)
- **Oracle MDM 25.10** — Meter Data Management (OUAF; 3 WLS clusters: Web, IWS, Batch)
- **Oracle SOA Suite 12.2.1.4+** — 4 independent WLS domains: soa_int, soa_if, soa_web, soa_sgg
- **Oracle HTTP Server** — 3-node OHS cluster (mod_wl_ohs proxy)
- **Oracle RAC 19c+** — 3 independent clusters (CCB, MDM, SOA) + Data Guard → DR site
- **Oracle KVM** — Hypervisor platform; one WLS Managed Server per Oracle Linux VM
- **Microsoft Entra ID** — SAML 2.0 SSO for WEB clusters
- **BeyondTrust PasswordSafe** — PAM; credential retrieval via REST API (replaces Oracle KMS)

## Stack
- **IaC**: Terraform (libvirt/azurerm/digitalocean providers) + Ansible (OS config, WLS install, app deployment)
- **Language conventions**: Terraform HCL, Ansible YAML, Python (scripts/hooks), Bash (bootstrap/DR scripts)
- **OS**: Oracle Linux 8/9 (guests + KVM hosts)
- **Secrets**: NEVER stored in repo. Retrieved from BeyondTrust PasswordSafe REST API or Ansible Vault (for bootstrap only). See @docs/runbooks/secrets-management.md
- **Target environments**: primary (Site A, KVM), dr (Site B, KVM), dev (KVM), azure-dev (Azure IaaS), do-dev (DigitalOcean)

## Repo Structure
```
terraform/
  modules/
    oracle-linux-vm/    # KVM/libvirt VM module
    azure-linux-vm/     # Azure VM module (Premium SSD, optional data disk)
    do-droplet/         # DigitalOcean Droplet module (Block Storage volume)
  environments/
    primary/            # Production Site A — KVM/libvirt, multi-host anti-affinity
    dr/                 # DR Site B — KVM/libvirt
    dev/                # KVM dev — single-host, minimal scale
    azure-dev/          # Azure dev — single-instance DB + app VMs; uses existing resource group
    do-dev/             # DigitalOcean dev — Droplets + Block Storage volume
ansible/
  roles/            # 26 roles — one per infra/app concern (see Ansible Roles below)
  playbooks/        # Site-wide and component-specific plays
  inventories/      # primary.yml.example, dev.yml.example, azure-dev.yml.example, do-dev.yml.example
  group_vars/       # Shared variables per host group (all/, ccb_all/, mdm_all/, soa_*/, etc.)
  host_vars/        # Per-VM overrides
scripts/
  bootstrap/        # One-time environment bootstrap (Vault init, SSH keys)
  wlst/             # WLST scripts for WLS config, DS password rotation
  beyondtrust/      # PasswordSafe API credential retrieval helpers
  validation/       # Post-install smoke tests
  dr/               # DR activation and failback runbooks
docs/
  architecture/     # ADRs and architecture reference
  runbooks/         # Operational runbooks
  decisions/        # Decision records (ADR format)
.claude/
  commands/         # Custom slash commands for this project
  agents/           # Subagents for specialized tasks
  rules/            # Scoped coding rules
```

## Ansible Roles

| Role | Purpose |
|------|---------|
| `oracle-linux-base` | OS hardening, kernel params, Oracle prereqs |
| `oracle-jdk` | JDK 21 install |
| `oracle-weblogic` | WLS 14.1.1.0 silent install |
| `oracle-node-manager` | Node Manager config and systemd service |
| `wls-domain-ccb` | CC&B WLS domain creation (WLST offline) |
| `wls-domain-mdm` | MDM WLS domain creation (WLST offline) |
| `wls-domain-soa-int` | SOA INT WLS domain creation (WLST offline) |
| `wls-domain-soa-if` | SOA IF WLS domain creation (WLST offline) |
| `wls-domain-soa-web` | SOA WEB WLS domain creation (WLST offline) |
| `wls-domain-soa-sgg` | SOA SGG WLS domain creation (WLST offline) |
| `wls-cluster-config` | WLS cluster, server, JDBC, JMS config (WLST online) |
| `wls-iws-deploy` | CC&B / MDM IWS WAR deployment (WLST) |
| `oracle-ouaf` | OUAF 4.x / SPLEBASE silent install and config |
| `oracle-ccb` | CC&B 25.10 install and initialise-appviewer |
| `oracle-mdm` | MDM 25.10 install |
| `oracle-soa-suite` | SOA Suite 12.2.1.4 silent install |
| `oracle-http-server` | OHS 12.2.1.4 install, mod_wl_ohs proxy config, systemd |
| `oracle-rac-client` | Oracle RAC client, tnsnames.ora, sqlnet.ora |
| `oracle-db-single` | Oracle DB 19c single-instance CDB + PDBs (dev only) |
| `oracle-data-guard` | Data Guard broker setup and DR SCAN TNS config |
| `oracle-kvm-host` | KVM host tuning, libvirt config, storage pools |
| `nfs-server` | NFS server exports (batch output, SOA files, MDM IMD) |
| `nfs-client` | NFS client mounts |
| `beyondtrust-integration` | BeyondTrust PasswordSafe startup scripts per domain |
| `entra-id-saml` | Entra ID SAML 2.0 SP config on WEB clusters (WLST online) |
| `monitoring-agent` | Prometheus node_exporter install and systemd service |

## Key Commands
```bash
# Terraform — production
cd terraform/environments/primary && terraform init -backend-config=../../backend.hcl && terraform plan
cd terraform/environments/dr      && terraform init -backend-config=../../backend.hcl && terraform plan

# Terraform — dev environments
cd terraform/environments/dev      && terraform init && terraform plan
cd terraform/environments/azure-dev && terraform init -backend-config=../../backend.hcl && terraform plan
cd terraform/environments/do-dev    && terraform init -backend-config=../../backend.hcl && terraform plan

# Ansible - full site install (primary)
ansible-playbook ansible/playbooks/site/site.yml -i ansible/inventories/primary.yml

# Ansible - individual app layers (primary)
ansible-playbook ansible/playbooks/infra/kvm-vms.yml -i ansible/inventories/primary.yml
ansible-playbook ansible/playbooks/ccb/install.yml   -i ansible/inventories/primary.yml
ansible-playbook ansible/playbooks/mdm/install.yml   -i ansible/inventories/primary.yml
ansible-playbook ansible/playbooks/soa/install.yml   -i ansible/inventories/primary.yml

# Ansible - dev environment DB install (azure-dev or do-dev)
ansible-playbook ansible/playbooks/infra/oracle-db.yml -i ansible/inventories/azure-dev.yml
ansible-playbook ansible/playbooks/infra/oracle-db.yml -i ansible/inventories/do-dev.yml

# Validation
bash scripts/validation/smoke-test-all.sh primary

# Syntax check (run before committing)
terraform fmt -check -recursive terraform/
ansible-lint ansible/
ansible-playbook --syntax-check ansible/playbooks/site/site.yml -i ansible/inventories/primary.yml.example \
  --vault-password-file /dev/null
```

## IMPORTANT Conventions

### Secrets
- NEVER commit passwords, API keys, keystores, or `.env` files
- WLS/DB passwords retrieved at runtime via `scripts/beyondtrust/get-credential.sh`
- Bootstrap secrets only: use `ansible-vault encrypt_string` — vault password in `~/.vault_pass` (not committed)
- See `.gitignore` for blocked file patterns

### Ansible
- All tasks must be idempotent — use `changed_when` and `failed_when` explicitly
- Always use `become: true` only where root is actually required; prefer `oracle` or `cissys` user
- Variable precedence: `host_vars` > `group_vars/[group]` > `group_vars/all`
- Use `ansible_user: oracle` for app tasks, `ansible_user: root` only for OS-level bootstrap
- Tags: `install`, `configure`, `deploy`, `validate`, `never` — tag all tasks

### Terraform
- KVM (primary/dr/dev): `dmacvicar/libvirt` provider; VMs in `terraform/modules/oracle-linux-vm/`
- Azure (azure-dev): `hashicorp/azurerm` provider; VMs in `terraform/modules/azure-linux-vm/`; resource group is a prerequisite (not created by Terraform)
- DigitalOcean (do-dev): `digitalocean/digitalocean` provider; Droplets in `terraform/modules/do-droplet/`
- Anti-affinity (MS-01 and MS-02 per cluster on different KVM hosts) enforced via provider aliases in `terraform/environments/primary/`; each module call specifies `providers = { libvirt = libvirt.<alias> }`
- Dev environments (dev, azure-dev, do-dev) use single-instance Oracle DB via `oracle-db-single` role — not RAC

### WLS / OUAF Notes
- NO Managed Server migration configured — HA is at the KVM VM layer
- NO shared NFS for domain homes — domain config lives on each VM's local disk
- NFS used ONLY for: batch output files, SOA File Adapter dirs, MDM IMD file drop
- IWS clusters (CCB-IWS, MDM-IWS) are separate from WEB clusters — verify iwsdeploy targets
- Batch clusters are NOT routed through OHS — no `WebLogicCluster` entry for batch

### Entra ID SAML
- SAML applies to WEB clusters only (CCB-WEB, MDM-WEB) — not IWS or Batch
- Entra ID metadata XML must have `<RoleDescriptor>` tags removed before WLS import
- Each domain = separate Enterprise App registration in Entra ID

## Architecture Reference
See @docs/architecture/README.md for the full architecture decision index.
Key ADRs: @docs/decisions/ADR-001-no-wls-migration.md @docs/decisions/ADR-002-minimal-nfs.md @docs/decisions/ADR-003-entra-saml.md
