# CLAUDE.md — WP FSE Boilerplate

Contexte pour Claude Code au démarrage d'une session sur ce dépôt.

## Ce que c'est

Boilerplate Studio Val pour démarrer un thème WordPress **Full Site Editing** (FSE) clé en main. Le dépôt contient **uniquement le thème + la config DDEV + le tooling** — le core WordPress (`wp-admin/`, `wp-includes/`, `wp-config.php`, etc.) est présent localement pour faire tourner le site mais **n'est pas versionné** (voir `.gitignore`).

Le thème vit dans [wp-content/themes/theme-fse/](wp-content/themes/theme-fse/).

## Stack

- **WordPress** 6.0+, **PHP** 8.0+ (objectif 8.2 à court terme)
- **Webpack 5** custom + **Sass** — **pas** `wp-scripts`. Migration éventuelle prévue plus tard : **ne pas proposer de refactor vers wp-scripts sans validation explicite**.
- **DDEV** (config versionnée dans `.ddev/`)
- **ACF Pro** pour les blocks custom (credentials via `auth.json`, gitignoré)
- **Composer** : WPCS + PHPCompatibility

## Arborescence clé

```
.
├── wp-content/themes/theme-fse/
│   ├── style.css                  # Header du thème (Theme Name, Version, Text Domain)
│   ├── theme.json                 # Config FSE globale (palette, typo, layout)
│   ├── functions.php              # require-only : glob(inc/*.php)
│   ├── inc/                       # Logique PHP découpée par concern
│   │   ├── theme-setup.php        # add_theme_support, menus, sizes
│   │   ├── theme-assets.php       # wp_enqueue avec filemtime() cache-bust
│   │   ├── block-acf.php          # Enregistre tous les blocks via glob(block.json)
│   │   ├── block-bindings.php
│   │   ├── block-categories.php
│   │   ├── block-settings.php
│   │   ├── security.php           # XML-RPC off, file editor off, version hidden…
│   │   ├── performance-hooks.php
│   │   ├── post-types.php
│   │   ├── media-uploads.php
│   │   ├── user-capabilities.php
│   │   ├── dashboard.php
│   │   ├── comments.php
│   │   └── hooks.php
│   ├── templates/                 # Templates FSE (.html) — index, home, single, page, 404…
│   ├── parts/                     # header.html, footer.html
│   ├── styles/                    # Variations de style (JSON)
│   ├── _dev/                      # Source : SCSS, JS, blocks, build config
│   │   ├── blocks/{name}/         # Un dossier par block
│   │   │   ├── block.json         # Metadata (schema officiel WP)
│   │   │   ├── block.php          # Template PHP (rendu ACF)
│   │   │   ├── block.js           # Script éditeur
│   │   │   └── block.scss         # Styles scopés
│   │   ├── scss/                  # theme.scss + editor.scss + partials
│   │   ├── js/                    # theme.js + editor.js
│   │   ├── scripts/make-block.js  # Scaffolder d'un nouveau block
│   │   └── webpack.{common,dev,prod}.js
│   └── dist/                      # Output du build (committé — voir .gitignore)
├── .claude/                          # Config Claude Code + docs d'équipe
│   ├── CLAUDE.md                     # Ce fichier (français)
│   ├── ARCHITECTURE.md               # Map du dépôt + responsabilités (anglais)
│   ├── BLOCKS.md                     # Authoring blocks ACF (anglais)
│   ├── CONVENTIONS.md                # Préfixes, sécurité, i18n, git (anglais)
│   ├── IMPLEMENTATION.md             # Tracker de modernisation Claude-Code-ready (anglais)
│   └── settings.json                 # Permissions allow/deny
├── .ddev/                            # Config DDEV versionnée (incluse dans git)
├── bin/
│   ├── setup.sh                      # Install complet : renomme le thème, substitue les placeholders, active
│   └── cleanup.sh
├── .github/
│   ├── workflows/                    # deploy-staging.yml + deploy-production.yml (FTP)
│   ├── copilot-instructions.md       # Équivalent de ce fichier pour GitHub Copilot
│   └── CODEOWNERS
└── composer.json / auth.json.example / README.md / CHANGELOG.md / LICENSE / .editorconfig / .nvmrc / .env.example
```

## Commandes essentielles

```bash
# Environnement
ddev start                         # Démarre le site local
ddev ssh                           # Shell dans le container web
ddev wp <cmd>                      # WP-CLI dans le container (ex : ddev wp plugin list)

# Backend PHP
composer install                   # Installe WPCS + PHPUnit + dealerdirect installer
composer lint                      # phpcs --standard=WordPress wp-content/themes/
composer lint:fix                  # phpcbf
composer test                      # phpunit

# Frontend (depuis _dev/)
cd wp-content/themes/theme-fse/_dev
npm install
npm run dev                        # Webpack mode dev + BrowserSync
npm run build                      # Build production (minifié)
npm run make-block                 # Scaffold un nouveau block (prompts interactifs)
```

## Conventions de code

- **Langue** : code et commentaires **en anglais**. `CLAUDE.md` (ce fichier) et [`README.md`](../README.md) restent **en français**. Les docs techniques co-localisées dans `.claude/` pour servir de contexte à Claude Code — [`ARCHITECTURE.md`](ARCHITECTURE.md), [`BLOCKS.md`](BLOCKS.md), [`CONVENTIONS.md`](CONVENTIONS.md), [`IMPLEMENTATION.md`](IMPLEMENTATION.md) — sont **en anglais** (et [`../CHANGELOG.md`](../CHANGELOG.md) reste à la racine par convention GitHub).
- **Text-domain** : `fse-boilerplate` (déclaré dans [`style.css`](wp-content/themes/theme-fse/style.css)) — `bin/setup.sh` le substitue à l'install sur un projet client. ⚠️ État actuel : 4 text-domains différents utilisés dans le code (`fse-boilerplate`, `studio-val`, `studio-theme`, `theme-name`) — à normaliser.
- **Hook / function prefix** : `studio_` (ex : `studio_register_blocks`, `studio_enqueue_assets`) — substitué à l'install.
- **Namespace PHP** : `StudioVal\WPBoilerplate\` (PSR-4, autoload configuré dans `composer.json` → `wp-content/themes/theme-fse/inc/`).
- **Namespace block** : `studioval/{slug}` dans `block.json` (déjà appliqué pour le block template).
- **Sécurité WP** : chaque `inc/*.php` **doit** commencer par `if (!defined('ABSPATH')) exit;`. ⚠️ État actuel : 12/14 fichiers sans ce guard — à corriger. Toute sortie doit être escapée (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`), toute entrée sanitize (`sanitize_text_field`, `absint`, etc.), toutes les requêtes SQL via `$wpdb->prepare`, toute action/admin-post protégée par nonce.
- **i18n** : systématique (`__()`, `esc_html__()`, `_e()`, `_x()`…).
- **Blocks** : un dossier par block dans `_dev/blocks/{name}/`. Chaque `block.json` est auto-découvert par [inc/block-acf.php](wp-content/themes/theme-fse/inc/block-acf.php) qui glob récursivement.
- **Cache-busting assets** : `filemtime()` sur le fichier compilé — ne **pas** mettre de version figée.
- **Git** : Semantic Commits au format `type: Scope - Subject` (préterit) — ex. `feat: Single - Added breadcrumb block`. Types et règles détaillés dans [`CONVENTIONS.md`](CONVENTIONS.md#git).

## Fichiers / dossiers à ne jamais modifier

- [wp-admin/](wp-admin/), [wp-includes/](wp-includes/) — core WP, gitignoré, réinstallé par WP à chaque update.
- [wp-config.php](wp-config.php), [wp-config-ddev.php](wp-config-ddev.php), [wp-config-sample.php](wp-config-sample.php) — config sensible (DB, salts).
- `auth.json` (gitignoré) — credentials ACF Pro.
- `vendor/**`, `**/node_modules/**`.
- `wp-content/themes/theme-fse/dist/**` — **ne modifier qu'indirectement** via `npm run build`.
- Les fichiers WP core racine (`wp-activate.php`, `wp-load.php`, `wp-settings.php`, etc.) — gitignorés, jamais touchés à la main.

## Workflow Git

Branches principales (créées automatiquement par `bin/setup.sh`) :

- `main` — production, protégée
- `staging` — pré-prod, déclenche `deploy-staging.yml` sur push
- `development` — intégration continue
- `feature/*` — développement

Déploiement automatique via GitHub Actions (FTP) sur push vers `staging` / `main`. Pas de CI de vérification (lint/test) sur les PR actuellement — à ajouter plus tard.

## Pièges connus

- **Thème non activable tel quel** : le thème source contient les noms par défaut (`studio_`, `fse-boilerplate`, `StudioVal\WPBoilerplate`). `bin/setup.sh` fait la substitution vers les noms du projet client. Ne **pas** activer `theme-fse` directement sur un projet sans avoir d'abord fait tourner le setup.
- **`composer.lock` et `package-lock.json` gitignorés** : la reproductibilité entre machines/CI n'est pas garantie — limitation connue à corriger plus tard.
- **Pas de CI lint/test sur PR** — les workflows GitHub Actions actuels ne font que du déploiement FTP.
- **`_dev/blocks/block/block.js` est volontairement vide** : c'est le squelette consommé par `scripts/make-block.js` pour scaffolder un nouveau block.
- **Règle phpcs** : actuellement `WordPress` (pas `WordPress-Extra`). Les warnings de docblocks manquants ne sont pas bloquants.
- **PHP min** : `composer.json` exige `>=8.0`, `style.css` mentionne `8.0`. Un bump à 8.2 est prévu mais pas encore fait — ne pas supposer les fonctionnalités PHP 8.1+ dans le code.
