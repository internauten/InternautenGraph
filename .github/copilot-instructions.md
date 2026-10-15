<!--
Instructions for GitHub Copilot (chat, coding agent, code review) working in this repository.
Copyright (c) 2026 die.internauten.ch GmbH
License: MIT
-->

# Copilot Instructions for InternautenGraph

This file contains an identical copy of the rules in `AGENTS.md` at the repository root.
When changing any rule, update both files in the same commit.

## Project context

- PrestaShop module that reroutes `Mail::Send()` via the `actionEmailSendBefore` hook to Microsoft Graph `sendMail` (OAuth2 client credentials) or SMTP with STARTTLS, with fallback to native PrestaShop mail sending.
- The module folder is `internautengraph/` (lowercase); the main class file is `internautengraph/internautengraph.php` (class `InternautenGraph`). The transport logic lives in `internautengraph/classes/InternautenGraphMailer.php`.
- Target platforms:
  - PrestaShop >= 9.1.4
  - PHP >= 8.3.31
- This repository also serves as a reference example for AI-assisted development.

## Language

- Chat answers, explanations, and suggestions: **German**.
- Code, code comments, commit messages, and all Markdown files (including README files): **English**.

## Working principles

- Keep changes small, understandable, and purposeful.
- Do not change business logic without clear justification in the PR description or commit message.
- Maintain backward compatibility unless a breaking change is explicitly required.
- Avoid destructive bulk changes such as sweeping formatting updates without a clear benefit.
- When requirements are unclear, state your assumptions before proceeding.
- For changes touching more than 3 files or altering module behavior, first present a short step-by-step plan and wait for confirmation before implementing.

## Coding standards

- Use `declare(strict_types=1);` in all new PHP files.
- Use clear naming and keep each class or function focused on a single responsibility.
- Prefer explicit types for parameters, return values, and properties.
- Keep functions short and easy to test.
- Only add inline comments where the logic would otherwise be difficult to follow.

### File headers

Every new or modified file must include a brief file header describing its purpose, a copyright notice for die.internauten.ch GmbH, and a reference to the MIT license.

- PHP files: directly below `declare(strict_types=1);`
- Other file types: at the top of the file, using the file type's comment syntax (e.g. `{* ... *}` in Smarty `.tpl`, `<!-- ... -->` in HTML/Markdown/XML).

```php
// Sends PrestaShop emails through Microsoft Graph or SMTP STARTTLS.
// Copyright (c) 2026 die.internauten.ch GmbH
// License: MIT
```

## PrestaShop module-specific guidance

- Keep the structure of the `internautengraph/` folder consistent (`classes`, `translations`; add `upgrade` when needed).
- Every directory inside the module must contain the standard PrestaShop `index.php` guard file.
- Only change hook names, configuration keys (`INTERNAUTENGRAPH_*`), and database structures when there is a clear migration strategy.
- Database or configuration changes require an upgrade script `internautengraph/upgrade/upgrade-X.Y.Z.php` matching the new module version.
- The fallback to native PrestaShop mail sending must keep working whenever the selected transport is unavailable or fails.
- Do not reintroduce a `Mail` class override; mail rerouting is done exclusively through the `actionEmailSendBefore` hook.
- Template placeholders are replaced only in the `{name}` form, matching the PrestaShop core behavior.
- The module is loaded locally into the PrestaShop environment from `WoWGetPrestaLocal`.
- The PrestaShop core reference code is at `../WoWGetPrestaLocal/html` (relative to this repository). Use it as the primary reference for analysis, comparison, and compatibility checks (e.g. `classes/Mail.php`).

### Security and secrets

- Never log, display, or return the client secret, SMTP password, or access tokens (including in debug logs and in `INTERNAUTENGRAPH_LAST_ERROR`).
- Debug output (`Debug template variables`) must only contain variable keys and placeholders, never variable values or mail content.
- Use TLS for all outgoing connections; do not disable certificate verification.

### Translations

- Never hardcode user-facing text (back office or front end) in PHP, templates, or other source files.
- This module uses the **legacy module translation system**:
  - PHP: `$this->l('...')` in the module class
  - Smarty: `{l s='...' mod='internautengraph'}`
  - Translation files: `internautengraph/translations/{en,de,fr,it}.php`
- Do not switch to the Symfony `trans()` / translation domain system unless explicitly requested.
- Keep `en`, `de`, `fr`, and `it` aligned whenever strings are added or changed.
- In German texts use proper umlauts (`ä`, `ö`, `ü`, `ß`), never ASCII substitutes.

## Local development environment

- Docker Compose project: `../WoWGetPrestaLocal/docker-compose.yml`. Run `docker compose` commands from `../WoWGetPrestaLocal`.
- Services / containers: `db` (`wow-presta-db`, MariaDB), `php` (`wow-presta-php`, PHP-FPM), `nginx` (`wow-presta-nginx`).
- Front office: `http://localhost:8081`. The back office URL, DB credentials, and DB name are in `AGENTS.local.md` (not committed); read it when needed.
- The `internautengraph/` folder is mounted into the shop via Docker volume at `modules/internautengraph`, so file changes are live without copying.
- Clear the cache after template, hook, or config changes: `docker compose exec php sh -c 'rm -rf var/cache/prod var/cache/dev'`
- Logs: `../WoWGetPrestaLocal/html/var/logs/` and the PrestaShop log table (`ps_log`, entries prefixed with `internautengraph`, filter by `rid=...`).
- DB table prefix: `ps_` (use `_DB_PREFIX_` in code, never a hardcoded prefix).
- Never write credentials, tenant/client IDs, secrets, or the back office folder name into committed files.

## Versioning and documentation

- The module version is defined in `internautengraph/internautengraph.php` as `$this->version = 'X.Y.Z';`. Keep this exact format; the release script parses it.
- Increment the version (semantic versioning) for every user-visible change, fix, or feature, and update the version badge in `README.md` accordingly.
- Update `README.md` when functionality or behavior changes.

## Quality assurance

- Add or update suitable tests when changing code. If no automated tests exist, document concrete manual test steps in the PR or final answer (e.g. `Send test email` in the module configuration for both transports, and the fallback path).
- Before finishing, check PHP syntax of changed files:

  ```bash
  find internautengraph -name '*.php' -print0 | xargs -0 -n1 php -l
  ```

- Error messages must be clear and useful to developers and must not expose sensitive data.

## Release conventions

- Release tags follow the pattern `vX.Y.Z`.
- Tags are created and pushed with `./create_release_tag.sh`, which reads the version from the module file. Only run it when explicitly asked, since it pushes to `origin`.
- `.github/workflows/release-on-tag.yml` zips the `internautengraph/` folder on tag push. Do not rename or move that folder, and do not break the version line format.
