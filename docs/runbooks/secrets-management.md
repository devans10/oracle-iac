# Runbook: Secrets Management

## Overview
All credentials in this environment are managed by BeyondTrust PasswordSafe. No passwords are stored in the repository, Ansible inventory, or WLS config files at rest.

## BeyondTrust API Setup
1. Create an API Registration in BeyondTrust (Configuration > API Registration)
2. Note the Client ID and Client Secret
3. Store on the Ansible control node: `~/.bt_wallet/credentials`
   ```bash
   mkdir -p ~/.bt_wallet && chmod 700 ~/.bt_wallet
   cat > ~/.bt_wallet/credentials << 'CREDS'
   export BT_CLIENT_ID="your-client-id"
   export BT_CLIENT_SECRET="your-client-secret"
   export BT_API_BASE_URL="https://passwordsafe.company.internal/BeyondTrust/api/public/v3"
   CREDS
   chmod 600 ~/.bt_wallet/credentials
   ```

## Managed Accounts Required
Before running Ansible, ensure these Managed Systems and Accounts exist in PasswordSafe:
- System `CCB-RAC-01`, Account `CISADM` (Oracle DB platform)
- System `MDM-RAC-01`, Account `MDMADM` (Oracle DB platform)
- System `SOA-RAC-01`, Accounts `INT_SOAINFRA`, `IF_SOAINFRA`, `WEB_SOAINFRA`, `SGG_SOAINFRA`
- System `<each-app-vm>`, Account `oracle` (Oracle Linux platform)
- System `<each-app-vm>`, Account `cissys` (Oracle Linux platform)

## Ansible Vault (Bootstrap Only)
Only used for first-run bootstrap before BeyondTrust takes over:
```bash
cp group_vars/all/vault.yml.example group_vars/all/vault.yml
# Edit vault.yml with initial values
ansible-vault encrypt group_vars/all/vault.yml
# Enter vault password; store password at ~/.vault_pass (not committed)
```

## Credential Retrieval During Ansible Runs
The `beyondtrust-integration` role configures startup scripts on each VM to call `scripts/beyondtrust/get-credential.sh` at WLS startup time, injecting credentials into WLS JDBC data sources via WLST.
