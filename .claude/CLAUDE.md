swarmpod-core is a Ruby gem providing onboarding verify scripts for new SwarmPod team members.

## Structure

- `lib/swarmpod/core.rb` — Gem entry point
- `lib/swarmpod/core/version.rb` — Version constant (reads `VERSION`)
- `bin/` — Executable verify scripts (registered as gem executables)
- `secrets_example/` — Credential template files for new users
- `swarmpod-core.gemspec` — Gem specification

## Secrets

Scripts use `discover_secret(env_var, file_path)` to check `ENV` first,
then fall back to parsing `.sh` files. Expected variables:

- `ANTHROPIC_API_KEY`
- `GITHUB_ACCOUNT`, `GITHUB_ACCESS_TOKEN`
- `GITHUB_USERNAME`, `GITHUB_PERSONAL_ACCESS_TOKEN` (PAT with write:packages for GHCR)
- `HOSTINGER_ACCOUNT`, `HOSTINGER_PASSWORD`, `HOSTINGER_VPS`
- `HOSTINGER_API_TOKEN` (bearer token for Hostinger REST API — generate at hpanel.hostinger.com/profile/api)
- `Z_AI_ACCOUNT`, `Z_AI_PASSWORD`

# On Laptop

SwarmPod Core discover_secret(env_var, file_path) loads secrets from your local filesystem

# In Container

SwarmPod Core discover_secret(env_var, file_path) loads secrets from enviroment variables

# In Docker Compose

SwarmPod Core discover_secret(env_var, file_path) loads secrets from your local filesystem and converts them to enviroment variables accessible in container

## How it works

1. `bin/up` reads all `*.sh` files from `~/.swarmpod/secrets/` in alphabetical
   order.
2. Lines matching `export KEY=value` are extracted. Surrounding quotes on
   values are stripped.
3. The collected key-value pairs are written to `docker/.env.secrets`.
4. Docker Compose loads `.env.secrets` via `env_file`, making every key
   available as an environment variable inside the container.

## Adding a secret

Create a shell file in `~/.swarmpod/secrets/`:

```
# ~/.swarmpod/secrets/anthropic.sh
export ANTHROPIC_API_KEY="sk-ant-..."
```

Restart the container with `bin/up` to pick up changes.

## Notes

- `docker/.env.secrets` is regenerated on every `bin/up` run.
- The secrets directory (`~/.swarmpod/secrets/`) lives outside the repo so
  credentials are never committed to version control.
- If the secrets directory does not exist, `bin/up` prints a warning and
  continues with an empty `.env.secrets` file.

---

## Lessons Learned (from FolkCoder deployment)

These are operational lessons from deploying a SwarmPod-ecosystem Rails app
(folkcoder.com) to production. They apply to any project using swarmpod-core
secrets and Hostinger infrastructure.

### Hostinger VPS

- **Snap Docker must be replaced.** Hostinger VPS ships with Docker via Snap.
  Snap's sandboxing blocks `docker cp` and env file access, which breaks
  Kamal deployments. Fix: `snap remove docker` then install official Docker CE
  from https://download.docker.com/linux/ubuntu.
- **VPS SSH password != Hostinger account password.** The password in
  `HOSTINGER_PASSWORD.sh` is for the web panel. VPS root SSH has a separate
  password set during VPS creation. SSH key auth is the right approach.
- **DNS via API.** Hostinger has a REST API for DNS management:
  `PUT https://developers.hostinger.com/api/dns/v1/zones/{domain}`
  with `Authorization: Bearer <HOSTINGER_API_TOKEN>`. No programmatic way
  to generate the token — must be created at hpanel.hostinger.com/profile/api.

### Kamal Deployment

- **`.kamal/secrets` parsing.** Kamal evaluates this file in a restricted
  shell context. `source` and `eval` don't work reliably. Use simple
  command substitution: `KAMAL_REGISTRY_PASSWORD=$(cut -d= -f2 ~/.swarmpod/secrets/GITHUB_TOKEN.sh)`
- **GHCR auth requires write:packages scope.** The default `gh auth token`
  only has repo/workflow scopes. Either use a GitHub PAT with write:packages
  or use Docker Hub instead.
- **asset_path and Snap Docker.** If you can't replace Snap Docker, remove
  `asset_path` from `config/deploy.yml` to skip the `docker cp` step that
  Snap blocks. Only matters if you have fingerprinted compiled assets.
- **SSL with Kamal.** Enable `config.assume_ssl = true` and
  `config.force_ssl = true` in `production.rb`. Add health check exclusion:
  `config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }`
- **Builder arch.** Set `builder: arch: amd64` in deploy.yml when building
  on Apple Silicon for an x86 VPS.

### Rails 8 Production

- **Tailwind CDN is fine for MVP.** `<script src="https://cdn.tailwindcss.com"></script>`
  with inline config works. No npm, no build step. Replace with proper
  Tailwind installation when the app needs compiled/purged CSS.
- **SQLite works in production** for single-server deploys. Rails 8 Solid
  Cache/Queue/Cable all use SQLite by default. Volume-mount `/rails/storage`
  for persistence across deploys.
- **Import maps are sufficient** when you don't need npm packages. Rails 8
  ships with Hotwire/Turbo/Stimulus via import maps out of the box.

### Workflow

- **Document with screenshots.** Keep a `docs/StepN/` folder for each
  milestone with visual proof. This creates a breadcrumb trail for the
  project owner and future contributors.
- **`.by_claude` as working notes.** A separate file from `.claude/CLAUDE.md`
  for Claude's own session state: decisions made, infrastructure details,
  what's done, what's next. Useful for resuming across sessions.
- **Secrets stay in `~/.swarmpod/secrets/`.** Never hardcode credentials
  in docker-compose.yml, deploy.yml, or env files checked into git. Always
  reference via command substitution or env vars.
