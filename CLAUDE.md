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
- **IaC**: Terraform (KVM VM provisioning via libvirt provider) + Ansible (OS config, WLS install, app deployment)
- **Language conventions**: Terraform HCL, Ansible YAML, Python (scripts/hooks), Bash (bootstrap/DR scripts)
- **OS**: Oracle Linux 8/9 (guests + KVM hosts)
- **Secrets**: NEVER stored in repo. Retrieved from BeyondTrust PasswordSafe REST API or Ansible Vault (for bootstrap only). See @docs/runbooks/secrets-management.md
- **Target environments**: primary (Site A), dr (Site B)

## Repo Structure
```
terraform/          # VM provisioning via libvirt Terraform provider
  modules/          # Reusable modules (kvm-host, oracle-linux-vm, networking, etc.)
  environments/     # primary/ and dr/ root modules
ansible/
  roles/            # 25 roles — one per infra/app concern
  playbooks/        # Site-wide and component-specific plays
  inventories/      # Static inventory; dynamic KVM inventory via libvirt plugin
  group_vars/       # Shared variables per host group
  host_vars/        # Per-VM overrides
scripts/
  bootstrap/        # One-time environment bootstrap (Vault init, SSH keys, etc.)
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

## Key Commands
```bash
# Terraform
cd terraform/environments/primary && terraform init && terraform plan
cd terraform/environments/dr      && terraform init && terraform plan

# Ansible - full site install
ansible-playbook ansible/playbooks/site/site.yml -i ansible/inventories/primary.yml

# Ansible - individual app layers
ansible-playbook ansible/playbooks/infra/kvm-vms.yml -i ansible/inventories/primary.yml
ansible-playbook ansible/playbooks/ccb/install.yml   -i ansible/inventories/primary.yml
ansible-playbook ansible/playbooks/mdm/install.yml   -i ansible/inventories/primary.yml
ansible-playbook ansible/playbooks/soa/install.yml   -i ansible/inventories/primary.yml

# Validation
bash scripts/validation/smoke-test-all.sh primary

# Syntax check (run before committing)
terraform fmt -check -recursive terraform/
ansible-lint ansible/
ansible-playbook --syntax-check ansible/playbooks/site/site.yml -i ansible/inventories/primary.yml
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
- Use `libvirt` provider for KVM VM provisioning
- All VMs defined in `terraform/modules/oracle-linux-vm/`
- Anti-affinity (MS-01 and MS-02 per cluster on different KVM hosts) enforced via `cpu_mode` + `placement` in libvirt

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
