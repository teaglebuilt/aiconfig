# Domain Architecture Reference: Nix

## Overview

Nix is a purely functional package manager and build system that provides reproducible, declarative environments and builds. Architecturally, it serves as the reproducibility foundation — ensuring that development environments, CI pipelines, container images, and deployments are deterministic and hermetic.

---

## Key Architectural Decisions

### Decision 1: Scope of Nix Adoption

**Context:** How much of your stack Nix manages — from "just dev shells" to "everything."

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Dev shells only (nix develop) | Team wants reproducible dev environments, low buy-in | Limited benefit, Nix only manages local tooling |
| Dev shells + CI environments | Want CI and local to be identical | CI needs Nix installed, cache strategy required |
| Dev shells + CI + container images | Want reproducible Docker images from Nix | Nix-built images are different from Dockerfile workflow, team must learn both |
| Full NixOS for servers/infrastructure | Maximum reproducibility, declarative infrastructure | Steep learning curve, smaller ops talent pool, NixOS-specific patterns |
| Nix flakes for everything | Modern Nix, composable, lockfile-based | Flakes still technically experimental (though widely adopted), ecosystem churn |

### Decision 2: Flakes vs Legacy Nix

**Context:** Whether to use Nix flakes (modern, lockfile-based) or traditional Nix expressions.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Flakes | New projects, want lockfiles, composability, standard structure | Experimental flag (though stable in practice), some ecosystem friction |
| Legacy (shell.nix, default.nix) | Existing Nix projects, compatibility with older tooling | No lockfile by default, less standardized structure |
| Flakes with compat layer | Migrating from legacy, want both worlds | Extra complexity in Nix expressions |

### Decision 3: Nix Expression Organization

**Context:** How to structure Nix files in a monorepo or multi-project setup.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Single flake.nix at root | Small project, single dev shell | Doesn't scale, monolithic Nix expression |
| Per-package flakes (workspace flakes) | Monorepo with independent packages | Flake composition complexity, dependency management between flakes |
| Root flake with overlay-per-package | Monorepo where packages share common tooling | All-or-nothing evaluation, large flake |
| Root flake + devShells per package | Monorepo, different packages need different tools | Scales well, each `nix develop .#package-name` gets tailored shell |
| Separate repo for Nix infrastructure | Nix config shared across many projects/repos | Indirection, version coordination |

### Decision 4: Caching and Binary Substitution

**Context:** How to avoid rebuilding everything from source on every machine.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| cache.nixos.org only | Using mostly unmodified nixpkgs packages | Custom packages always build from source |
| Cachix (hosted) | Team/org wants shared binary cache, easy setup | Cost at scale, external dependency |
| Self-hosted Nix cache (nix-serve, Attic) | Want control, air-gapped environments, cost management | Infrastructure to operate |
| CI populates cache on merge | Cache is always warm for main branch | Feature branches may still have cold cache |
| No custom cache (accept build times) | Few custom derivations, fast builds anyway | Slow onboarding and CI for complex Nix setups |

### Decision 5: Container Image Strategy with Nix

**Context:** Whether and how to use Nix to produce OCI container images.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| dockerTools.buildImage | Want minimal, reproducible images from Nix | Different mental model than Dockerfile, layer control is manual |
| dockerTools.buildLayeredImage | Want Nix reproducibility with Docker-like layer caching | Layer splitting heuristics may not match expectations |
| Dockerfile with Nix inside | Team knows Docker, use Nix for tooling inside build stage | Loses some reproducibility (Docker layer caching is not hermetic) |
| Nix-built static binaries → scratch/distroless | Minimal attack surface, smallest possible images | Not all languages produce static binaries easily |
| Skip Nix for images (Dockerfile only) | Team comfortable with Docker, Nix only for dev | Two systems for reproducibility, container builds are not hermetic |

---

## Pattern Options

### Pattern 1: Nix as Development Environment Foundation

**What it is:** Every developer runs `nix develop` (or direnv + nix) to get an identical shell with all tools pinned.
**When to use:** Any team that has "works on my machine" problems, onboarding friction, or CI/local divergence.
**When to avoid:** Solo developer on a simple project where tool version drift doesn't matter.
**Combines well with:** Turborepo (pin Node.js, pnpm versions), Kubernetes (pin kubectl, helm versions), all domains.

### Pattern 2: Nix Flake as Project Contract

**What it is:** The `flake.nix` + `flake.lock` serve as the reproducible contract for the entire project — dev shell, CI environment, build outputs, and deployments all derive from the same source.
**When to use:** Teams that want single-source-of-truth for all tooling and builds.
**When to avoid:** When Nix fluency on the team is too low to maintain it, and the benefit doesn't justify the ramp.
**Combines well with:** ArgoCD (reproducible deploy tooling), CI pipelines (identical environments).

### Pattern 3: NixOS Module Composition for Infrastructure

**What it is:** Server configuration as composable NixOS modules. Each service, monitoring agent, or infrastructure concern is a module that can be mixed and matched.
**When to use:** On-prem or VM-based infrastructure where you want declarative, testable server configuration.
**When to avoid:** Cloud-native Kubernetes environments (NixOS for the host may be overkill if everything runs in containers).
**Combines well with:** Bare-metal or VM infrastructure, edge computing.

### Pattern 4: Nix for Polyglot Monorepo Tooling

**What it is:** Using Nix to manage tooling across a monorepo that spans multiple languages (Node.js, Python, Go, Rust) — pinning each language's toolchain, formatters, linters.
**When to use:** Monorepos with multiple language ecosystems where tool version coordination matters.
**When to avoid:** Single-language monorepos where the language's own version manager is sufficient.
**Combines well with:** Turborepo (Nix manages base tooling, Turborepo orchestrates builds), data platform (Python + JVM tooling).

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| Nix everything zealotry | Forcing Nix on a team that doesn't know it for every concern | Slow velocity, frustration, Nix becomes a bottleneck | Start with dev shells, expand as fluency grows |
| Unpinned nixpkgs | Using `<nixpkgs>` channel instead of pinned flake input | Non-reproducible, builds differ between machines | Pin nixpkgs in flake.lock or use pinned fetchTarball |
| Monolithic flake.nix | Single 500-line flake.nix with everything | Hard to understand, painful to modify | Split into modules, use flake-parts or per-package organization |
| No binary cache | Every developer and CI builds everything from source | 30+ minute dev shell entry, CI bottleneck | Set up Cachix or self-hosted cache, populate on main branch |
| Nix layer without escape hatch | No way to develop without Nix (no fallback Dockerfile or manual instructions) | Blocks contributors who can't install Nix (Windows, corporate lockdown) | Provide alternative dev instructions alongside Nix |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| flake.lock is up to date | Dependencies are intentionally pinned | CI check that `nix flake lock --no-update-lock-file` doesn't fail |
| Dev shell builds | Nix environment isn't broken | `nix develop --command true` in CI |
| Nix flake check passes | All outputs evaluate correctly | `nix flake check` in CI |
| Cache hit rate | Developers aren't building from source | Monitor cache miss rate in CI logs |
| Tool version consistency | CI and local use same tool versions | Compare `nix develop` tool versions against CI versions |

---

## Decision Checklist

Before finalizing Nix architecture:

- [ ] Scope of adoption defined (dev shells, CI, images, full NixOS)
- [ ] Flakes vs legacy decision made
- [ ] Nix expression organization strategy chosen
- [ ] Binary cache strategy in place (Cachix, self-hosted, or none)
- [ ] Team Nix fluency assessed and learning plan established
- [ ] Fallback development path documented for non-Nix users
- [ ] CI pipeline integrates Nix (cached builds, dev shell tests)
- [ ] flake.lock update policy defined (manual, Dependabot/Renovate, scheduled)
- [ ] Container image strategy decided (Nix-built, Dockerfile, hybrid)