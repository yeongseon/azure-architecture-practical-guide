---
content_sources:
  diagrams:
    - id: stage-05-architecture
      type: flowchart
      source: self-generated
      justification: "Diagram combines the Stage 5 active-passive regions, Front Door origin priorities, and SQL failover group listener behavior described in Microsoft Learn guidance."
      based_on:
        - https://learn.microsoft.com/en-us/azure/app-service/tutorial-multi-region-app
        - https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium
        - https://learn.microsoft.com/en-us/azure/azure-sql/database/failover-group-configure-sql-db?view=azuresql
content_validation:
  status: verified
  last_reviewed: '2026-04-24'
  reviewer: agent
  core_claims:
    - claim: Azure Front Door origin groups support active-passive routing by preferring lower-priority healthy origins and failing over when the primary origin becomes unhealthy.
      source: https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium
      verified: true
    - claim: Azure SQL failover groups provide a stable read-write listener endpoint that stays constant across geo-failover events.
      source: https://learn.microsoft.com/en-us/azure/azure-sql/database/failover-group-sql-db?view=azuresql
      verified: true
    - claim: Multi-region App Service designs commonly use Azure Front Door to route traffic to a primary region and fail over to a standby region during outage conditions.
      source: https://learn.microsoft.com/en-us/azure/app-service/tutorial-multi-region-app
      verified: true
    - claim: Active-passive App Service topologies reduce operational complexity compared to active-active while still providing regional disaster recovery coverage.
      source: https://learn.microsoft.com/en-us/azure/architecture/web-apps/guides/multi-region-app-service/multi-region-app-service
      verified: true
---
# Stage 5 — Resilience: Multi-Region Active-Passive

Stage 5 adds regional outage tolerance to the earlier practical journey. The stack stays opinionated and compact: one resource group, two Azure regions, one active web tier, one hot-standby web tier, and a SQL failover group so the application keeps a stable database listener endpoint during failover.

## Trigger

**Business needs regional outage tolerance**.

!!! note "Single resource group across two regions"
    This stage intentionally keeps **everything in one resource group**. The resource group location is metadata only; Azure resources inside the group can still be deployed into both `koreacentral` and `japaneast`.

## What Changes from Stage 4

Stage 5 keeps the Stage 4 baseline for the **primary region** (VNet integration, private SQL endpoint, private DNS) and adds a secondary App Service plan, a secondary web app, a secondary SQL logical server, an Azure SQL failover group, and Front Door origin priorities for active-passive failover.

!!! warning "Secondary region network trade-off"
    The secondary region intentionally uses **public SQL access** to keep this guide simple and cost-effective. The secondary web app connects directly to the secondary SQL server (not the failover group listener) so it can reach the database without VNet integration. After SQL failover, the secondary server becomes the read-write primary and the app is fully functional. In production, you would add a secondary VNet, private endpoint, and private DNS zone mirroring the primary region. The primary region retains full network isolation from Stage 4.

<!-- diagram-id: stage-05-architecture -->
```mermaid
flowchart TD
    FD[Azure Front Door + WAF]
    FD -->|Priority 1| PRIWEB[Primary Web App\nKorea Central]
    FD -. failover .->|Priority 2| SECWEB[Secondary Web App\nJapan East]

    subgraph PRIRG[Primary region resources in single RG]
        PRIPLAN[App Service Plan S1]
        PRIWEB
        SLOT[Deployment Slot]
        PRISQL[Primary SQL Server]
        PRIDB[SQL Database S0]
        KV[Key Vault]
        LAW[Log Analytics Workspace]
        APPI[Application Insights]
        VNET[VNet + Private DNS + SQL Private Endpoint]
    end

    subgraph SECRG[Secondary region resources in single RG]
        SECPLAN[Secondary App Service Plan S1]
        SECWEB
        SECSQL[Secondary SQL Server]
    end

    PRIPLAN --> PRIWEB
    PRIPLAN --> SLOT
    SECPLAN --> SECWEB
    APPI --> PRIWEB
    APPI --> SECWEB
    LAW --> APPI
    KV --> PRIWEB
    KV --> SECWEB
    PRISQL --> PRIDB
    PRIDB --> FOG[SQL Failover Group\nRead-write listener]
    SECSQL --> FOG
    VNET --> PRISQL
```

## Read Before You Deploy

- [Resilience and Region Strategy](../platform/resilience-and-region-strategy.md)
- [Multi-Region Active-Passive vs Active-Active](../patterns/resilience/multi-region-active-passive-vs-active-active.md)
- [Retry, Circuit Breaker, and Bulkhead](../patterns/resilience/retry-circuit-breaker-and-bulkhead.md)
- [Azure Well-Architected Framework — Reliability](../waf/reliability.md)

## Prerequisites

1. Install Azure CLI and confirm the `bicep` command is available.
2. Sign in with an identity that can deploy App Service, Azure Front Door, Key Vault, Azure Monitor, and Azure SQL resources.
3. Ensure the deployment identity can configure Microsoft Entra administrators on both SQL logical servers.
4. Prepare a strong SQL admin password for the bootstrap SQL login.
5. Choose a globally unique `appName` because App Service, Key Vault, SQL server, and Front Door endpoint names must all stay unique.

## Deploy

1. Create or reuse the resource group.

    ```bash
    export RESOURCE_GROUP_NAME="rg-practical-stage-05-resilience-koreacentral"

    az group create \
        --name "$RESOURCE_GROUP_NAME" \
        --location "koreacentral"
    ```

2. Compile the Bicep orchestrator before deployment.

    ```bash
    az bicep build \
        --file infra/bicep/stages/stage-05-resilience/main.bicep \
        --stdout
    ```

3. Deploy the stage.

    ```bash
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file infra/bicep/stages/stage-05-resilience/main.bicep \
        --parameters infra/bicep/stages/stage-05-resilience/main.bicepparam \
        --parameters appName="yourappname" \
        --parameters sqlAdminLogin="sqladminuser" \
        --parameters sqlAdminPassword="<sql-admin-password>" \
        --parameters alertEmail="alerts@example.com"
    ```

4. Record the outputs for the Front Door endpoint, primary web app, secondary web app, failover group name, and failover group read-write listener.

## Verify

Run the smoke test script after deployment.

```bash
bash scripts/practical/verify/failover-smoke.sh scripts/practical/stages/stage-05.env
```

## QA Scenario

1. Open the Front Door endpoint and confirm the application returns HTTP 200 from the primary region.
2. Call `/ops/info` through Front Door and record the reported Azure region.
3. Confirm both web apps exist. Note that the secondary web app uses a direct connection string to the secondary SQL server (public access), so it is in standby until SQL failover makes the secondary server read-write.
4. Confirm the SQL failover group is configured for automatic failover with a 60-minute grace period.
5. Trigger SQL failover to the secondary logical server and confirm the replication roles flipped.
6. Stop the primary web app and wait for Front Door health probes to route traffic to the secondary region.
7. Re-run `/ops/info` through Front Door and confirm the reported region changed to the secondary region.
8. Start the primary web app, fail SQL back, and confirm the environment returns to the normal active-passive posture.

## Best Practices

- **Active-passive before active-active**: choose the simpler multi-region model first unless the business really needs simultaneous active traffic in both regions.
- **Test failover, do not just document it**: the value of this stage comes from rehearsed Front Door and SQL failover behavior, not from topology diagrams alone.
- **Explicit RTO and RPO**: define recovery targets before approving extra regional cost, extra operational overhead, and extra validation work.

## Cost

Expect roughly **$0.45–$0.80/hour** for this stage. The main jump from Stage 4 is that you now run **two S1 App Service plans**, **two web apps**, **two SQL logical servers**, and a **Standard S0 SQL database** so Azure SQL geo-replication and failover groups are supported.

## Destroy

```bash
az group delete \
    --name "$RESOURCE_GROUP_NAME" \
    --yes \
    --no-wait
```

## Read After You Verify

- [Business Continuity and Drills](../operations/business-continuity-and-drills.md)
- [Resilience Targets: RTO/RPO](../reference/resilience-targets-rto-rpo.md)
- [Azure Well-Architected Framework — Pillar Trade-offs](../waf/pillar-trade-offs.md)

## See Also

- [Resilience and Region Strategy](../platform/resilience-and-region-strategy.md)
- [Multi-Region Active-Passive vs Active-Active](../patterns/resilience/multi-region-active-passive-vs-active-active.md)
- [Retry, Circuit Breaker, and Bulkhead](../patterns/resilience/retry-circuit-breaker-and-bulkhead.md)
- [Business Continuity and Drills](../operations/business-continuity-and-drills.md)

## Sources

- [Tutorial: Create Multi-Region App in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/tutorial-multi-region-app)
- [Multi-Region App Service App Approaches for Disaster Recovery](https://learn.microsoft.com/en-us/azure/architecture/web-apps/guides/multi-region-app-service/multi-region-app-service)
- [Origins and origin groups in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium)
- [Failover groups overview and best practices for Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/failover-group-sql-db?view=azuresql)
- [Configure a failover group for Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/failover-group-configure-sql-db?view=azuresql)
