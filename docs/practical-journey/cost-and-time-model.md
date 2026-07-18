---
description: Cost and time model for the Practical Journey — compare the five staged deployments, sum the published estimates, and tear each stage down cleanly.
---

# Cost and Time Model

Use this page to compare the published budget and deployment window for each Practical Journey stage before you choose which one to run.

## Stage estimates

| Stage | Trigger | Cost | Time |
|---|---|---|---|
| [Stage 1 — MVP](stage-01-mvp.md) | "We need a real public web app online this week." | ~$0.09–$0.13/hour | 20–30 min |
| [Stage 2 — Production Baseline](stage-02-production-baseline.md) | "The app now matters to the business." | ~$0.14–$0.20/hour | 25–40 min |
| [Stage 3 — Scale / Edge](stage-03-scale-edge.md) | "Traffic is growing and internet exposure is a concern." | ~$0.20–$0.30/hour | 35–50 min |
| [Stage 4 — Network Isolation](stage-04-network-isolation.md) | "Compliance requires private data access." | ~$0.24–$0.36/hour | 35–55 min |
| [Stage 5 — Resilience](stage-05-resilience.md) | "Business needs regional outage tolerance." | ~$0.45–$0.80/hour | 50–75 min |
| **Total (sum of published stage estimates)** | Full sequential walkthrough across all five stages | **~$1.12–$1.79/hour** | **165–250 min** |

## How to read the total

- The **time total** is a straight sum of the five published deployment windows: **165–250 minutes**.
- The **cost total** is the straight sum of the five published hourly estimates: **~$1.12–$1.79/hour**.
- In practice, most readers deploy **one stage at a time**, verify it, and destroy it before moving on. In that common flow, your live hourly burn is the cost of the currently running stage, not the sum of all five.

## Choosing the right stage

Use the trigger sentence as the primary selector:

- Pick Stage 1 when delivery speed matters more than production hardening.
- Pick Stage 2 when secrets, release safety, and alerting can no longer wait.
- Pick Stage 3 when internet exposure and scale behavior are now production concerns.
- Pick Stage 4 when the data path must move behind private networking.
- Pick Stage 5 when regional outage tolerance becomes a real business requirement.

## Destroy instructions

Each stage tears down through the same driver script shape:

```bash
scripts/practical/destroy-stage.sh stage-01
scripts/practical/destroy-stage.sh stage-02
scripts/practical/destroy-stage.sh stage-03
scripts/practical/destroy-stage.sh stage-04
scripts/practical/destroy-stage.sh stage-05
```

The destroy script deletes the stage resource group with `--yes --no-wait`, so Azure removes the resources asynchronously in the background.

## Practical budgeting advice

The stage costs are intentionally progressive: every later stage buys down an additional production risk. Treat the earlier stages as learning and baseline checkpoints, not as sunk cost you must keep running forever.

## See Also

- [Practical Journey](index.md)
- [Getting Started](getting-started.md)
- [Verify and Destroy](verify-and-destroy.md)
- [Stage 5 — Resilience](stage-05-resilience.md)

## Sources

- [Azure pricing](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/azure-services-costs)
- [Azure architecture cost optimization guidance](https://learn.microsoft.com/en-us/azure/well-architected/cost-optimization/)
