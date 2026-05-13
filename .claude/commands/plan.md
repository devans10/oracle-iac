Create a step-by-step implementation plan for the following task: $ARGUMENTS

Structure the plan as:
1. Files to create or modify (with paths)
2. Dependencies or prerequisites to verify first
3. Ordered implementation steps
4. Validation steps to confirm success
5. Rollback steps if something goes wrong

Consider: idempotency for Ansible tasks, Terraform state implications, secrets handling (never hardcode), and which target environment (primary/dr) is affected.
