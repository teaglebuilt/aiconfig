# Domain Architecture Reference: Cloudflare Networking & Security

> Architectural decisions for Cloudflare's network services — CDN, DNS, Zero Trust, tunnels, and edge security.

---

## Overview

Cloudflare operates a global anycast network across ~300 data centers. Beyond Workers compute, the platform provides CDN/caching, DNS, DDoS protection, WAF, Zero Trust networking, and tunnel-based connectivity. These services layer together to form the network edge for applications.

---

## Key Architectural Decisions

### Decision 1: Origin Connectivity

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Cloudflare Tunnel (cloudflared) | Connecting on-prem or private services without opening firewall ports | Requires daemon on origin, adds hop |
| DNS proxy (orange cloud) | Standard web traffic through Cloudflare's CDN/WAF | Origin IP must be kept secret, limited to HTTP/HTTPS |
| Spectrum | Non-HTTP protocols (TCP/UDP) through Cloudflare | Enterprise only, protocol-specific |
| WARP Connector | Site-to-site connectivity between private networks | Replaces traditional VPN, requires WARP client or connector |

### Decision 2: Caching Strategy

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Default caching (by file extension) | Static assets with standard cache headers | Limited control, may cache unexpected content |
| Cache Rules | Fine-grained control over what gets cached and for how long | More configuration, must understand cache key behavior |
| Workers + Cache API | Programmatic cache control, custom cache keys, stale-while-revalidate | More code, but maximum flexibility |
| R2 + CDN | Large object storage with global caching | Zero egress, but separate from Worker deployment |

### Decision 3: Zero Trust Architecture

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| Access | Identity-aware reverse proxy | Protect internal apps without VPN, SSO integration |
| Gateway | Secure DNS/HTTP filtering | Corporate device security, content filtering |
| Tunnel | Outbound-only connection from origin | Expose private services without public IPs |
| WARP | Device agent | Endpoint connectivity to Cloudflare network |
| Browser Isolation | Remote browser rendering | High-risk browsing, data loss prevention |

### Decision 4: DNS Architecture

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Cloudflare as authoritative DNS | Full CDN/security features, fastest TTFB | Must transfer nameservers |
| CNAME setup (partial) | Can't transfer nameservers (Enterprise) | Limited features, more DNS complexity |
| Secondary DNS | Cloudflare as secondary for redundancy | Enterprise only, zone transfer required |

---

## Pattern Options

### Pattern 1: Full-Stack Edge Application

**What it is:** DNS -> Cloudflare CDN -> Workers (with static assets + API) -> Storage bindings
**When to use:** New applications that can be fully edge-native.
**When to avoid:** Legacy apps that require specific server environments.

### Pattern 2: Edge + Origin Hybrid

**What it is:** DNS -> Cloudflare CDN/WAF -> Tunnel -> Origin servers (K8s, VMs, etc.)
**When to use:** Existing applications that need Cloudflare's security and performance layer.
**When to avoid:** When you can go fully edge-native (simpler, faster).

### Pattern 3: Zero Trust Network

**What it is:** Access + Tunnel + Gateway replaces traditional VPN
**When to use:** Securing access to internal tools, databases, admin panels.
**When to avoid:** Public-facing consumer applications (use standard CDN instead).

---

## Anti-Patterns

| Anti-Pattern | Why It Hurts | What to Do Instead |
|-------------|-------------|-------------------|
| Exposing origin IP | Attackers bypass Cloudflare, hit origin directly | Use Tunnel for origin connectivity, no public IP |
| Over-caching dynamic content | Stale data served to users | Use Cache Rules with appropriate TTLs, bypass cache for authenticated content |
| VPN instead of Zero Trust | Single point of failure, poor UX, full network access | Use Access + Tunnel for per-app access control |
| DNS-only mode (gray cloud) | No CDN, no WAF, no DDoS protection | Proxy traffic through Cloudflare (orange cloud) unless debugging |

---

## Combines With

| Domain | Intersection | Key Consideration |
|--------|-------------|-------------------|
| Workers | Workers run on the same network, zero-latency access to CDN/cache | Use Workers for custom routing, A/B testing, header manipulation |
| Kubernetes | Tunnel connects K8s services to Cloudflare without ingress controllers | Replace LoadBalancer services with Tunnel for cost savings |
| GitOps | Terraform provider for Cloudflare config-as-code | Manage DNS, WAF rules, tunnels declaratively |

---

## Decision Checklist

- [ ] Origin connectivity method selected (Tunnel preferred over public IP)
- [ ] Caching strategy defined for static vs dynamic content
- [ ] WAF rules configured for application-specific threats
- [ ] Zero Trust evaluated for internal tool access
- [ ] DNS proxied through Cloudflare (orange cloud) for full protection
