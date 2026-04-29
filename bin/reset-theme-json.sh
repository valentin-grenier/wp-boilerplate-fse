#!/usr/bin/env bash
# Resets theme.json to a blank boilerplate structure — empty arrays/objects,
# all toggle flags set to false, no preset values.

set -euo pipefail

THEME_JSON="$(dirname "$0")/../wp-content/themes/theme-fse/theme.json"

cat > "$THEME_JSON" << 'EOF'
{
	"$schema": "https://schemas.wp.org/trunk/theme.json",
	"version": 3,
	"settings": {
		"useRootPaddingAwareAlignments": false,
		"appearanceTools": false,
		"layout": {
			"contentSize": "",
			"wideSize": "",
			"allowCustomContentAndWideSize": false,
			"allowEditing": false
		},
		"color": {
			"text": false,
			"background": false,
			"link": false,
			"caption": false,
			"button": false,
			"heading": false,
			"custom": false,
			"customDuotone": false,
			"customGradient": false,
			"defaultDuotone": false,
			"defaultGradients": false,
			"defaultPalette": false,
			"gradients": [],
			"duotone": [],
			"palette": []
		},
		"spacing": {
			"blockGap": false,
			"customSpacingSize": false,
			"margin": false,
			"padding": false,
			"units": ["px", "rem", "%", "dvh", "dvw"],
			"defaultSpacingSizes": false,
			"spacingSizes": []
		},
		"typography": {
			"customFontSize": false,
			"defaultFontSizes": false,
			"dropCap": false,
			"fluid": false,
			"fontStyle": false,
			"fontWeight": false,
			"letterSpacing": false,
			"lineHeight": false,
			"textAlign": false,
			"textColumns": false,
			"textDecoration": false,
			"textTransform": false,
			"writingMode": false,
			"fontFamilies": [],
			"fontSizes": []
		},
		"border": {
			"color": false,
			"radius": false,
			"style": false,
			"width": false
		},
		"background": {
			"backgroundImage": false,
			"backgroundSize": false
		},
		"shadow": {
			"defaultPresets": false,
			"presets": []
		},
		"dimensions": {
			"aspectRatio": false,
			"defaultAspectRatios": false,
			"minHeight": false
		},
		"position": {
			"sticky": false
		},
		"custom": {
			"fontWeight": {},
			"lineHeight": {},
			"radius": {},
			"color": {}
		},
		"blocks": {
			"core/image": {
				"lightbox": {
					"enabled": false,
					"allowEditing": false
				}
			}
		}
	},
	"styles": {
		"color": {},
		"spacing": {},
		"typography": {},
		"elements": {
			"button": {},
			"heading": {},
			"h1": {},
			"h2": {},
			"h3": {},
			"h4": {},
			"h5": {},
			"h6": {},
			"link": {},
			"caption": {}
		},
		"blocks": {
			"core/template-part": {
				"spacing": {
					"margin": {
						"top": "0 !important"
					}
				}
			}
		}
	},
	"templateParts": [
		{
			"area": "header",
			"name": "header",
			"title": "Header"
		},
		{
			"area": "footer",
			"name": "footer",
			"title": "Footer"
		}
	],
	"customTemplates": [
		{
			"name": "page-full-width",
			"title": "Page pleine largeur, sans titre",
			"postTypes": ["page"]
		}
	]
}
EOF

echo "✓ theme.json reset to blank structure."
