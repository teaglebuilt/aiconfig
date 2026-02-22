# Domain Architecture Reference: Talos Linux

## Overview

Talos Linux is a minimal, immutable, API-managed operating system purpose-built for Kubernetes. It replaces traditional Linux distributions as the node OS, removing SSH, shell access, and package managers entirely. Architecturally, it enforces infrastructure-as-code at the OS level — nodes are configured declaratively via API and are treated as truly ephemeral, replaceable units.

---

## Key Architectural Decisions

### Decision 1: Where to Run Talos

**Context:** Talos runs on bare metal, VMs, and cloud — the platform shapes the architecture.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Bare metal (homelab, on-prem) | Full control, no hypervisor overhead, learning/production on-prem | Hardware management, PXE/iPXE provisioning, no cloud APIs for autoscaling |
| Cloud VMs (AWS, GCP, Azure) | Want immutable OS in cloud, tighter control than managed K8s | Still paying for VMs, lose some managed K8s benefits (but gain OS-level control) |
| Proxmox / VMware VMs | Homelab or enterprise virtualization, easy snapshot/clone | VM overhead, Talos image management per hypervisor |
| Hetzner / bare metal cloud | Cost-effective bare metal with cloud provisioning APIs | Limited regions, less ecosystem integration than hyperscalers |
| Edge / single-node | IoT or edge clusters, minimal footprint | Single-node limitations, no HA control plane |
| Hybrid (Talos on some nodes, other OS on others) | Migration path, specialized workloads need traditional OS | Mixed fleet management, two OS patterns to maintain |

### Decision 2: Control Plane Topology

**Context:** How the Kubernetes control plane is configured within Talos clusters.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| 3 control plane nodes (standard HA) | Production clusters, standard availability | 3 nodes minimum for etcd quorum |
| Single control plane node | Development, homelab, edge, resource-constrained | No HA, etcd on single node = SPOF |
| 5 control plane nodes | Large clusters, want to survive 2 simultaneous failures | Resource overhead, etcd performance with more members |
| Dedicated control plane (no workloads) | Production best practice, isolate control plane resources | More nodes needed, underutilized control plane resources |
| Control plane + worker (dual role) | Resource-constrained, homelab, small clusters | Control plane competes with workloads for resources |

### Decision 3: Machine Configuration Management

**Context:** How Talos machine configs are generated, stored, and applied.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| `talosctl gen config` + manual management | Small cluster, getting started | Config drift, manual toil |
| Talhelper (declarative config generation) | Want templated, DRY config for multiple nodes | Additional tool, learning curve |
| Terraform + Talos provider | Infrastructure-as-code, automated provisioning | Terraform state management, provider maturity |
| Pulumi + Talos | IaC with general-purpose language (Go, Python, TS) | Smaller community than Terraform for Talos |
| GitOps-managed configs (configs in Git, applied via CI) | Want auditable, reviewable config changes | Pipeline to apply configs, rollback complexity |
| Cluster API (CAPI) + Talos | Kubernetes-native cluster lifecycle management | CAPI complexity, but good for fleet management |
| Omni (SideroLabs managed) | Want managed Talos fleet, SaaS control plane | Vendor dependency, cost |

### Decision 4: Networking CNI

**Context:** Talos ships with Flannel as default CNI but supports alternatives.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Flannel (default) | Simple overlay networking, getting started, homelab | Basic feature set, no network policy enforcement |
| Cilium | Advanced networking, eBPF, network policies, observability | More complex setup, kernel version requirements |
| Calico | Network policies, BGP peering, established ecosystem | Resource overhead, configuration complexity |
| None (bring your own) | Specific CNI requirements, custom networking | Must configure manually, ensure Talos compatibility |

### Decision 5: Storage Architecture

**Context:** Talos nodes are immutable — storage decisions are critical for stateful workloads.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Local path provisioner | Simple, homelab, single-node stateful workloads | No replication, data tied to node |
| Longhorn | Distributed storage, replicated volumes, Rancher ecosystem | Resource overhead, network-attached storage performance |
| Rook-Ceph | Enterprise distributed storage, high performance | Complex to operate, significant resource requirements |
| OpenEBS (Mayastor) | High-performance distributed storage, NVMe-optimized | Newer, requires NVMe or fast disks |
| NFS (external) | Shared storage from NAS, simple integration | Single point of failure, performance limits |
| Cloud provider CSI | Running Talos on cloud VMs with cloud storage | Cloud vendor coupling |
| No cluster storage (externalize state) | Stateless workloads, databases on managed services | Dependency on external services |

### Decision 6: Upgrade and Maintenance Strategy

**Context:** How Talos nodes and Kubernetes versions are upgraded across the cluster.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Rolling upgrade via `talosctl upgrade` | Standard approach, node-by-node | Sequential, time proportional to cluster size |
| Rolling upgrade via System Extensions | Need custom kernel modules or drivers | Extension compatibility per Talos version |
| Blue-green cluster upgrade | Zero-downtime, can validate new cluster before cutover | Double the infrastructure during migration |
| Canary node upgrade | Want to test upgrade on subset before fleet-wide | Monitoring per-node after upgrade, slower rollout |
| Automated via CI pipeline | Want hands-off upgrades triggered by new Talos releases | Need good rollback automation, trust in pipeline |

---

## Pattern Options

### Pattern 1: Talos + Talhelper + GitOps

**What it is:** Talhelper generates Talos machine configs from a declarative `talconfig.yaml`. Configs are committed to Git. CI/CD applies config changes. ArgoCD manages workloads on top.
**When to use:** Most Talos deployments — this is the standard mature pattern.
**When to avoid:** Very small single-node setups where the tooling overhead isn't worth it.
**Combines well with:** ArgoCD (workload GitOps), Nix (pin talosctl/talhelper versions), SOPS (secret encryption).

### Pattern 2: Talos + Cluster API (CAPI)

**What it is:** Kubernetes manages Kubernetes — CAPI provisions and manages Talos clusters declaratively using Kubernetes resources.
**When to use:** Fleet management, need to provision/destroy clusters dynamically, platform team model.
**When to avoid:** Single cluster, when CAPI's complexity isn't justified.
**Combines well with:** Multi-cluster patterns, hub-and-spoke fleet management.

### Pattern 3: Immutable Infrastructure Pipeline

**What it is:** Talos configs, system extensions, and cluster state are all versioned. Upgrades are treated like deployments — build new config, apply, validate, rollback if needed.
**When to use:** Production environments where predictability and auditability matter.
**When to avoid:** Development/experimentation where speed matters more than rigor.
**Combines well with:** Nix (reproducible tooling), CI/CD pipelines, infrastructure testing.

### Pattern 4: Talos for Homelab / Edge

**What it is:** Talos as the OS for homelab servers or edge nodes — minimal footprint, API-managed, no SSH attack surface.
**When to use:** Homelab Kubernetes, edge computing, environments where physical security varies.
**When to avoid:** When you need traditional Linux capabilities (specific drivers, custom kernel modules not available as extensions).
**Combines well with:** Single-node or small HA clusters, Longhorn for storage, Cilium for networking.

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| Treating Talos like traditional Linux | Expecting SSH, package managers, manual config files | Talos has none of these by design — fighting the model | Embrace API-driven management, use talosctl and machine configs |
| Storing machine configs with secrets unencrypted | Machine configs contain cluster secrets (certs, keys) | Secrets in Git in plaintext | SOPS, age, or sealed secrets encryption before committing configs |
| Ignoring system extensions | Needing drivers or kernel modules and not using extensions | Missing hardware support, ISCSI, etc. | Check Talos system extensions for required capabilities |
| Manual talosctl apply on production | Applying config changes ad-hoc without review | Config drift, no audit trail, risky changes | GitOps pipeline for config changes, PR review |
| Not testing upgrades | Upgrading Talos version directly on production nodes | Upgrade breaks workloads, extensions incompatible | Stage upgrades on non-prod, canary a node, verify before fleet |
| Single control plane in production | One control plane node for production workloads | etcd on one node = cluster dies with that node | Minimum 3 control plane nodes for production |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| Machine configs in Git | No manual config drift | CI check that all node configs are committed and tracked |
| Secrets encrypted in configs | No plaintext secrets in Git | Pre-commit hook checking for unencrypted Talos secrets |
| Talos version consistency | All nodes running same Talos version | `talosctl version` across all nodes in CI, alert on mismatch |
| Control plane health | etcd and API server healthy | `talosctl health` in monitoring, alert on degraded |
| System extension compatibility | Extensions match Talos version | Validate extension versions against Talos version before upgrade |
| Node readiness after upgrade | Upgraded nodes rejoin cluster successfully | Post-upgrade health check in CI pipeline |

---

## Combines With

| Domain | Intersection | Key Consideration |
|--------|-------------|-------------------|
| Kubernetes (core) | Talos IS the Kubernetes node OS | All core K8s decisions apply; Talos constrains some (no SSH, no host packages) |
| ArgoCD | ArgoCD manages workloads on Talos clusters | ArgoCD handles the layer above Talos; Talos handles the layer below K8s |
| Multi-cluster | Talos nodes across fleet of clusters | Talos simplifies fleet node management — consistent, API-driven, immutable |
| Nix | Pin talosctl, talhelper, kubectl versions | Nix dev shell ensures everyone uses matching tooling versions |
| Infrastructure (general) | Talos is the infrastructure layer | Replaces traditional OS management (Ansible, Chef, etc.) with API-driven config |

---

## Decision Checklist

Before finalizing Talos architecture:

- [ ] Platform chosen (bare metal, cloud, VM, edge)
- [ ] Control plane topology decided (1, 3, or 5 nodes, dedicated or dual-role)
- [ ] Machine config management approach defined (Talhelper, Terraform, CAPI)
- [ ] CNI selected (Flannel default, Cilium, Calico)
- [ ] Storage solution chosen for stateful workloads
- [ ] System extensions identified for hardware/driver needs
- [ ] Secrets encryption configured for machine configs
- [ ] Upgrade strategy documented (rolling, blue-green, canary)
- [ ] Backup strategy for etcd and critical state
- [ ] VIP or load balancer configured for control plane endpoint