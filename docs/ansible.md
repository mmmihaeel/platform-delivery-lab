# Ansible

## Purpose

Ansible is the repository bootstrap and contract-check layer. It prepares the workspace, seeds local configuration when needed, and verifies that key repository control files exist before a deeper validation run starts.

## Inventory and variables

| Path | Purpose |
| --- | --- |
| `ansible/inventory/local.ini` | Local inventory for the bootstrap workflow |
| `ansible/group_vars/local.yml` | Shared repository paths and validation inputs |

## Playbooks

| Playbook | Role |
| --- | --- |
| `ansible/playbooks/bootstrap.yml` | Prepare the workspace and verify the repository contract |
| `ansible/playbooks/validate.yml` | Syntax and control-file validation |

## Commands

```bash
make ansible-check
make ansible-run
```

## Runner model

If `ansible-playbook` is not installed locally, `scripts/ansible-bootstrap.sh` falls back to a containerized Ansible runner. That keeps the bootstrap and syntax-check path available without adding a hard local dependency.

## What Ansible is not doing here

Ansible is not presented as a remote host configuration layer in this repository. Its role is narrower and more useful for the local-first story:

- bootstrap consistency
- local contract checks
- repeatable operator setup

## Related documents

- [quickstart.md](quickstart.md)
- [deployment-flow.md](deployment-flow.md)
- [runbooks.md](runbooks.md)
