# WP FSE Boilerplate

Studio Val's turn-key starter theme for WordPress Full Site Editing (FSE) — Webpack 5 + Sass, ACF Pro blocks, modular PHP, automated setup.

## Features

- **Full FSE support** — templates and parts as native `.html` files
- **SCSS workflow** — separate frontend and editor stylesheets, Webpack 5 (not wp-scripts)
- **ACF Pro blocks** — server-rendered, auto-discovered, scaffoldable via CLI
- **Modular PHP** — `inc/` files split by concern: setup, security, performance, blocks…
- **Security hardened** — XML-RPC off, file editor blocked, version hidden, ABSPATH guards throughout
- **Automated setup** — renames theme, substitutes slugs, installs plugins, creates Git branches

## Quick start

```bash
./bin/setup.sh --acf-license=YOUR_LICENSE_KEY
```

For prerequisites, step-by-step install, and deployment configuration see [docs/setup.md](docs/setup.md).

## Documentation

| Guide                            | Description                                                             |
|----------------------------------|-------------------------------------------------------------------------|
| [docs/setup.md](docs/setup.md)   | Prerequisites, install steps, script options, GitHub Actions deployment |
| [docs/blocks.md](docs/blocks.md) | Scaffolding and authoring ACF blocks                                    |

## Author

Made by **Studio Val** — [studio-val.fr](https://studio-val.fr) · [@valentin-grenier](https://github.com/valentin-grenier)

## License

MIT — free to use and adapt with attribution.
