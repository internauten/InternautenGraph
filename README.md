<!--
Documentation for the internautengraph PrestaShop module.
Copyright (c) 2026 die.internauten.ch GmbH
License: MIT
-->

# internautengraph

[![Module Version](https://img.shields.io/badge/module-2.0.4-2ea44f)](internautengraph/internautengraph.php)
[![PrestaShop](https://img.shields.io/badge/PrestaShop-9.1.4-00B8D4)](https://www.prestashop.com)
[![GitHub release](https://img.shields.io/github/v/release/internauten/InternautenGraph)](https://github.com/internauten/InternautenGraph/releases)
[![Last commit](https://img.shields.io/github/last-commit/internauten/InternautenGraph)](https://github.com/internauten/InternautenGraph/commits/main)
[![Issues](https://img.shields.io/github/issues/internauten/InternautenGraph)](https://github.com/internauten/InternautenGraph/issues)
[![Pull requests](https://img.shields.io/github/issues-pr/internauten/InternautenGraph)](https://github.com/internauten/InternautenGraph/pulls)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

PrestaShop module that reroutes `Mail::Send()` to an external mail transport.

## Features

- Uses the `actionEmailSendBefore` hook to intercept native mail sending before it happens.
- Sends emails through Microsoft Graph `sendMail` or SMTP with STARTTLS.
- Reads the PrestaShop mail templates (`.html` / `.txt`) and replaces template variables.
- Falls back to native PrestaShop mail sending if Graph fails.

## Installation

1. Copy the `internautengraph` module folder to `modules/`.
2. Install the module in the back office.
3. Select the mail transport (`Mail transport`) in the module configuration.
4. Set the values required by the selected transport:
   - Microsoft Graph API:
     - Tenant ID
     - Client ID
     - Client Secret
     - Sender mailbox (Office 365 user)
   - SMTP with STARTTLS:
     - SMTP host
     - SMTP port (typically 587)
     - SMTP username
     - SMTP password
     - SMTP sender email (optionally also SMTP sender name)
5. Enable the module and trigger a first test email from PrestaShop.

## Azure and Office 365 step by step

### 1) Register an app in Microsoft Entra ID

1. Open the Azure portal and go to `Microsoft Entra ID` > `App registrations` > `New registration`.
2. Enter a name, for example `Prestashop Internauten Graph`.
3. Select `Accounts in this organizational directory only`.
4. Save the registration.
5. Note the following values from the overview:
   - `Application (client) ID` (German UI: usually `Anwendungs-ID (Client)`)
   - `Directory (tenant) ID` (German UI: usually `Verzeichnis-ID (Mandant)` or `Mandanten-ID`)

### 2) Create a client secret

1. In the app, go to `Certificates & secrets`.
2. Under `Client secrets`, click `New client secret`.
3. Choose a description and expiry, then save.
4. Copy the secret `Value` immediately and store it securely (it will not be fully shown again later).

### 3) Set Microsoft Graph permissions

1. In the app, go to `API permissions`.
2. Select `Add a permission` > `Microsoft Graph` > `Application permissions`.
3. Add the `Mail.Send` permission.
4. Run `Grant admin consent` for the tenant.
5. Check that the status shows `Granted for <Tenant>`.

### 4) Prepare an Office 365 mailbox as sender

1. Choose an existing user mailbox, for example `shop@example.com`.
2. Make sure the mailbox has an Exchange Online license and is allowed to send.
3. If Conditional Access is enabled, make sure app-only access to Graph is not blocked for this application.
4. Note the exact mailbox address. This address is used as `Sender mailbox` in the module configuration.

### 5) Enter the values in the PrestaShop module

1. In PrestaShop, open `Modules` > `internautengraph` > `Configure`.
2. Set `Enable Graph sending` to `Yes`.
3. Fill in the fields:
   - `Tenant ID` = `Directory (tenant) ID` (German UI: `Verzeichnis-ID (Mandant)` or `Mandanten-ID`)
   - `Client ID` = `Application (client) ID` (German UI: `Anwendungs-ID (Client)`)
   - `Client Secret` = secret value
   - `Sender mailbox` = Exchange Online mailbox (e.g. `shop@example.com`)
4. Save.

### 6) Test the setup

1. Trigger an action in PrestaShop that sends an email (e.g. forgotten password or contact form).
2. Check `Sent Items` of the sender mailbox in Exchange Online.
3. If no email arrives, first check the app permissions, admin consent, and secret validity.
4. If Graph fails, the module automatically falls back to native PrestaShop mail sending.

## Notes

- The module supports two transport modes: `Microsoft Graph API` and `SMTP with STARTTLS`.
- For Graph, the module uses the OAuth2 client credentials flow.
- Sending is rerouted through the `actionEmailSendBefore` hook (no active class override required).
- When the transport configuration is enabled, the selected transport is tried first.
- If the selected transport is unavailable or a request fails, the module falls back to the default PrestaShop mail sending.
- The module configuration has a dedicated `Test recipient email` field with a `Send test email` button to test the currently selected transport directly.
- Transport errors are shown in the module back office (`Last custom transport error`).
- Optional `Debug template variables` switch: writes variable keys and unreplaced placeholders to the PrestaShop logs when needed (for troubleshooting, off by default).
- As in the PrestaShop core, template placeholders are only replaced in the `{name}` form. Variables without braces are automatically completed to `{name}`. Up to version 2.0.2, bare words were replaced as well (e.g. `products` in the CSS class `products-table`).
- Debug logs contain a request ID (`rid=...`) so that related entries per send attempt can easily be filtered.

## Testing with Docker

The local shop runs in the Docker Compose project `WoWGetPrestaLocal`, located next to this repository. Its `docker-compose.yml` mounts the module folder directly into the shop, so file changes are live without copying or symlinking:

```yaml
- ${HOME}/internauten/InternautenGraph/internautengraph:/var/www/wow9.internaut.ch/html/modules/internautengraph
```

Run the commands from `../WoWGetPrestaLocal`:

```bash
docker compose up -d
# Clear the cache after template, hook, or config changes
docker compose exec php sh -c 'rm -rf var/cache/prod var/cache/dev'
```

The front office is available at `http://localhost:8081`.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

Copyright by die.internauten.ch GmbH
