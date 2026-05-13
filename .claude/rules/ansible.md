# Ansible Rules

- All tasks MUST be idempotent; use `creates:`, `changed_when:`, `stat:` guards as needed
- Use `block:` / `rescue:` for error handling in multi-step install sequences
- Prefer `ansible.builtin.*` FQCN over short module names
- Use `loop:` with `loop_control.label` for readability; avoid `with_items` in new code
- Templates: Jinja2 in `roles/<role>/templates/` with `.j2` extension; always `validate:` config files
- Variables: define defaults in `defaults/main.yml`; sensitive overrides go in `group_vars/vault.yml` (Ansible Vault encrypted)
- Tags required on every task: at minimum `install` OR `configure` OR `deploy` OR `validate`
- `become: true` only at task level when root is needed, not play-wide unless bootstrapping
- Oracle filesystem paths: `/u01/oracle/products/` (binaries), `/u01/oracle/config/` (domain homes), `/u01/oracle/logs/` (log files)
- OS user for OUAF apps: `cissys` (group: `cisusr`); WLS admin user: `oracle`
