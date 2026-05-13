# ADR-003: Entra ID SAML 2.0 for SSO

**Status**: Accepted

## Decision
Microsoft Entra ID replaces Oracle OAM as the SSO Identity Provider. Integration uses SAML 2.0 SP-initiated flow with WLS as the Service Provider.

## Scope
- **In scope**: WEB clusters only (CCB-WEB, MDM-WEB)
- **Out of scope**: IWS clusters (use WS-Security), Batch clusters (no interactive UI), SOA machine-to-machine calls

## Implementation notes
- One Enterprise App registration in Entra ID per application
- Entra ID metadata XML: remove `<RoleDescriptor>` tags before WLS import
- SAML cookie path must be `/` (root) for cross-context-path SSO
- Entra ID client secrets stored in Ansible Vault (`group_vars/all/vault.yml`)
