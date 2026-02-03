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
- `HOSTINGER_ACCOUNT`, `HOSTINGER_PASSWORD`, `HOSTINGER_VPS`
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
