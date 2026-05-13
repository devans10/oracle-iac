# Security Rules — MANDATORY

- NEVER write passwords, API keys, certificates, or secrets into any file in this repo
- BeyondTrust API credentials (Client ID/Secret): stored in Oracle Wallet on target VM; retrieved via `scripts/beyondtrust/get-credential.sh`
- Ansible Vault: used ONLY for bootstrap secrets; password file path `~/.vault_pass` (not in repo)
- All `.jks`, `.p12`, `.pem`, `.key`, `.pfx` files are in `.gitignore` — never add exceptions
- WLS boot.properties: generated at runtime by startup scripts, never stored statically
- `ansible-vault encrypt_string` for any inline sensitive variable in group_vars
- Terraform state may contain sensitive values — never commit `*.tfstate` or `*.tfstate.backup`
- Entra ID client secrets and tenant IDs: stored as Ansible Vault variables in `group_vars/all/vault.yml`
