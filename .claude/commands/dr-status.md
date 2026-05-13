Check the current Disaster Recovery readiness status.

Review:
1. scripts/dr/ for the DR activation runbook — confirm steps are current with architecture
2. terraform/environments/dr/ — confirm DR VM definitions match primary
3. ansible/inventories/ — confirm dr inventory is populated and reachable
4. docs/runbooks/ — confirm the DR runbook doc is up to date
5. Data Guard configuration in ansible/roles/oracle-data-guard/

Summarize any gaps or items that need updating.
