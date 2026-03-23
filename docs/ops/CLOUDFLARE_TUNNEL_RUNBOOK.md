# CLOUDFLARE_TUNNEL_RUNBOOK

## Purpose
Provision and verify a Cloudflare Tunnel for Day 2 external rollout, route traffic to Lighthouse upstream, and keep rollback actions ready.

## Prerequisites
- Cloudflare account access with permissions for **Zero Trust**, **Tunnels**, and **DNS** in target zone.
- `cloudflared` installed on the Lighthouse host.
- Target hostname prepared (example: `app.example.com`).
- Lighthouse upstream reachable locally from host (example: `http://127.0.0.1:3000`).
- Existing tunnel credentials path known (if reusing tunnel).

Optional checks:
```bash
cloudflared --version
cloudflared tunnel list
```

---

## Create / Verify Tunnel

### A) Create a new tunnel (if not existing)
```bash
cloudflared tunnel login
cloudflared tunnel create great-back-end-day2
```
Record:
- Tunnel Name: `great-back-end-day2`
- Tunnel UUID: `<TUNNEL_UUID>`
- Credentials file: `~/.cloudflared/<TUNNEL_UUID>.json`

### B) Verify existing tunnel
```bash
cloudflared tunnel list
cloudflared tunnel info <TUNNEL_UUID>
```
Expect:
- Tunnel appears in list
- Status is healthy when connector is online

---

## DNS Hostname Binding Steps
Bind public hostname to tunnel:
```bash
cloudflared tunnel route dns <TUNNEL_UUID> app.example.com
```
Verify DNS record in Cloudflare zone:
- Type: `CNAME`
- Name: `app` (or full hostname)
- Target: `<TUNNEL_UUID>.cfargotunnel.com`
- Proxy status: Proxied (orange cloud)

Validation:
```bash
dig +short app.example.com
```

---

## Route to Lighthouse Upstream Steps
Create tunnel config on Lighthouse host (`~/.cloudflared/config.yml`):
```yaml
tunnel: <TUNNEL_UUID>
credentials-file: /root/.cloudflared/<TUNNEL_UUID>.json

ingress:
  - hostname: app.example.com
    service: http://127.0.0.1:3000
  - service: http_status:404
```

Run tunnel:
```bash
cloudflared tunnel run <TUNNEL_UUID>
```

If using service mode:
```bash
cloudflared service install
systemctl enable --now cloudflared
systemctl status cloudflared --no-pager
```

---

## Validation Checklist
- [ ] `cloudflared tunnel list` shows target tunnel.
- [ ] `cloudflared tunnel info <TUNNEL_UUID>` shows active connector.
- [ ] DNS record exists for target hostname and points to `<TUNNEL_UUID>.cfargotunnel.com`.
- [ ] Public request reaches app endpoint (before Access lock-down test).
- [ ] Lighthouse local upstream remains healthy (`curl http://127.0.0.1:3000/health` or equivalent).
- [ ] Baseline screenshots/log snippets captured for evidence.

Suggested smoke checks:
```bash
curl -I https://app.example.com
curl -sS https://app.example.com/health
```

---

## Rollback Quick Actions
1. **Fast traffic stop at edge**
   - Remove/disable DNS binding:
   ```bash
   cloudflared tunnel route dns delete <TUNNEL_UUID> app.example.com
   ```
2. **Stop tunnel connector**
   ```bash
   systemctl stop cloudflared
   # or stop foreground process
   ```
3. **Restore previous DNS target**
   - Repoint hostname to previous endpoint if needed.
4. **Re-enable only after root cause identified**
   - Record incident timeline + mitigation before reopen.

Rollback validation:
- Public hostname no longer reaches Lighthouse app via tunnel.
- Prior access path (if configured) is restored and verified.
