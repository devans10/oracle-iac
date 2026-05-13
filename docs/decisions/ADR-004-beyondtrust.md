# ADR-004: BeyondTrust PasswordSafe Replaces Oracle KMS

**Status**: Accepted

## Decision
Oracle KMS is removed from the architecture. BeyondTrust PasswordSafe provides:
1. DB password management and rotation (CCB, MDM, SOA schemas)
2. OS service account management (cissys, oracle, wls users)
3. WLS Admin password vaulting
4. SSH session recording for all privileged admin access
5. Secrets Safe for keystores and cert material

## Integration Pattern
At WLS startup, a shell script calls the PasswordSafe REST API (`scripts/beyondtrust/get-credential.sh`), retrieves the current DB password, and injects it via WLST into the WLS JDBC data source — without ever writing the password to a file.

## Bootstrap Exception
Initial deployment uses Ansible Vault for one-time bootstrap credentials. BeyondTrust takes over all credentials after first successful run.
