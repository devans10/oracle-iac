Scaffold a new Ansible role named: $ARGUMENTS

Create the full role structure under ansible/roles/$ARGUMENTS/ with:
- tasks/main.yml with a commented skeleton (include_tasks pattern for sub-task files)
- defaults/main.yml with documented variable defaults
- vars/main.yml stub
- meta/main.yml with galaxy_info filled in
- templates/ directory with a .gitkeep
- handlers/main.yml with a stub restart handler
- README.md describing the role's purpose, variables, dependencies, and example usage

Follow all rules in @.claude/rules/ansible.md
