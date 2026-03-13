# Ansible

## Purpose

Ansible is the repository bootstrap layer. It prepares the workspace, seeds `.env` from `.env.example` when needed, and verifies that the repository contract files exist.

## Inventory and variables

- `ansible/inventory/local.ini`
- `ansible/group_vars/local.yml`

## Playbooks

- `ansible/playbooks/bootstrap.yml`
- `ansible/playbooks/validate.yml`

## Commands

```bash
make ansible-check
make ansible-run
```

## Runner model

If `ansible-playbook` is not installed locally, `scripts/ansible-bootstrap.sh` falls back to a containerized runner so the syntax-check path still works.
