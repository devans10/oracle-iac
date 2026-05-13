Run validation checks for the target environment: $ARGUMENTS

Check:
1. Ansible inventory syntax: ansible-playbook --syntax-check for all playbooks targeting $ARGUMENTS
2. Terraform plan (no apply): cd terraform/environments/$ARGUMENTS && terraform plan
3. Verify required variables are defined in group_vars for $ARGUMENTS
4. Confirm .gitignore is protecting secret file patterns
5. Run ansible-lint on all playbooks

Report any issues found.
