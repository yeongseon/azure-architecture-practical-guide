---
description: Getting-started guide for the Practical Journey — prerequisites, Azure subscription setup, Azure CLI and Bicep install, and required environment variables.
---

# Getting Started

Use this page before deploying any Practical Journey stage. It covers the local tools, Azure access, and environment variables that the journey's Bicep templates and driver scripts expect.

## Prerequisites

- Azure CLI installed and authenticated with `az login`.
- Bicep available through Azure CLI.
- An Azure subscription where your identity has at least **Contributor** rights on the target resource group or subscription scope.
- A strong `SQL_ADMIN_PASSWORD` exported in your shell before any stage deployment.
- For Stage 2 and later, these additional environment variables exported before deployment:
    - `SQL_ENTRA_ADMIN_LOGIN`
    - `SQL_ENTRA_ADMIN_OBJECT_ID`
    - `ALERT_EMAIL_ADDRESS`

## Azure subscription setup

Sign in and confirm the subscription that will hold the stage resources:

```bash
az login
az account show --output table
az account set --subscription <subscription-id-or-name>
```

| Command | Purpose |
|---------|---------|
| `az login` | Starts interactive browser sign-in to Azure. |
| `az account show --output table` | Displays the currently active subscription as a formatted table. |
| `--output table` | Renders the output as a human-readable table instead of JSON. |
| `az account set --subscription <subscription-id-or-name>` | Selects the subscription that subsequent commands target. |
| `--subscription <subscription-id-or-name>` | Identifies the subscription to make active, by ID or display name. |

If you are unsure whether you can deploy, confirm that your identity can create or update resource groups in the target subscription. The driver scripts call `az group create`, `az deployment group create`, `az group show`, and `az group delete`, so Contributor rights are the practical minimum.

## Install and verify the CLI toolchain

Install or update Bicep through Azure CLI, then confirm both tools respond locally:

```bash
az bicep install
az bicep version
az version
```

| Command | Purpose |
|---------|---------|
| `az bicep install` | Installs the Bicep CLI that Azure CLI uses to compile `.bicep` templates. |
| `az bicep version` | Prints the installed Bicep CLI version. |
| `az version` | Prints the Azure CLI core and installed component versions. |

The Practical Journey scripts call `az` directly and the stage parameter files use Bicep features such as `readEnvironmentVariable(...)`, so both Azure CLI and the Bicep CLI integration need to work before deployment.

## Required environment variables

Export the SQL administrator password for every stage:

```bash
export SQL_ADMIN_PASSWORD='<choose-a-strong-password>'
```

From Stage 2 onward, export the Microsoft Entra administrator metadata for Azure SQL and the alert notification address as well:

```bash
export SQL_ENTRA_ADMIN_LOGIN='<entra-user-or-group-display-name>'
export SQL_ENTRA_ADMIN_OBJECT_ID='<entra-object-id>'
export ALERT_EMAIL_ADDRESS='<ops-notification-email>'
```

These values are consumed by the stage parameter files under `infra/bicep/stages/stage-0N-*/main.bicepparam`, which read them from the current shell environment.

## Optional overrides

The stage env files under `scripts/practical/stages/` provide defaults for the resource group, region, app base name, and SQL admin login. Override them only when you need a different naming or location choice:

```bash
export RG='rg-practical-storefront-stage03'
export LOCATION='koreacentral'
export APP_BASE_NAME='storefront'
export SQL_ADMIN_LOGIN='storefrontadmin'
```

Stage 5 also has a secondary region in its parameter file. If you need to change it, edit the stage parameter flow deliberately rather than assuming every stage shares the same regional topology.

## Recommended first run

If this is your first pass through the journey:

1. Start with [Stage 1 — MVP](stage-01-mvp.md).
2. Use [`scripts/practical/deploy-stage.sh`](verify-and-destroy.md) to deploy.
3. Run the verification flow immediately after deployment.
4. Tear the stage down before moving to the next one unless you intentionally need it to stay online.

## See Also

- [Practical Journey](index.md)
- [Cost and Time Model](cost-and-time-model.md)
- [Verify and Destroy](verify-and-destroy.md)
- [Stage 1 — MVP](stage-01-mvp.md)

## Sources

- [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Sign in with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
- [Install Bicep tools](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
