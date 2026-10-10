# WP FSE Boilerplate

Studio Val's turn-key starter theme for WordPress Full Site Editing (FSE) — Webpack 5 + Sass, native Gutenberg blocks, modular PHP, automated setup.

## Features

- **Full FSE support** — templates and parts as native `.html` files
- **SCSS workflow** — separate frontend and editor stylesheets, Webpack 5 (not wp-scripts)
- **Native Gutenberg blocks** — registered client-side via `registerBlockType` (no `block.json`), scaffoldable via CLI (static or dynamic)
- **Modular PHP** — `inc/` files split by concern: setup, security, performance, blocks…
- **Security hardened** — XML-RPC off, file editor blocked, version hidden, ABSPATH guards throughout
- **Automated setup** — renames theme, substitutes slugs, installs plugins, creates Git branches
- **MCP-ready** — `.mcp.json` lets Claude Code drive the local WordPress via DDEV WP-CLI

## Quick start

Click **"Use this template"** on GitHub to create your project repo, then:

```bash
git clone https://github.com/<your-org>/<your-project>.git my-project
cd my-project
./bin/setup.sh
```

`main` is the pristine base — `setup.sh` substitutes the placeholders, then commits and creates `staging` + `development`. (The `demo` branch shows an installed example.)

For prerequisites, step-by-step install, and deployment configuration see [docs/setup.md](docs/setup.md).

## Documentation

| Guide                            | Description                                                             |
| -------------------------------- | ----------------------------------------------------------------------- |
| [docs/setup.md](docs/setup.md)   | Prerequisites, install steps, script options, GitHub Actions deployment |
| [docs/blocks.md](docs/blocks.md) | Scaffolding and authoring native Gutenberg blocks                       |

## Author

Made by **Studio Val** — [studio-val.fr](https://studio-val.fr) · [@valentin-grenier](https://github.com/valentin-grenier)

## License

Dual-licensed: tooling and configuration under [MIT](LICENSE), theme code under [GPL-2.0-or-later](LICENSE) (required by WordPress).
