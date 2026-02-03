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
