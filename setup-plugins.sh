# Install plugins required for dev
echo "🔧 Installing plugins for development..."

wp plugin install query-monitor --activate
wp plugin install updraftplus --activate
wp plugin install admin-site-enhancements --activate
wp plugin install contact-form-7 --activate

# Install plugins required for production
echo "🔧 Installing plugins for production..."

wp plugin install broken-link-checker
wp plugin install seo-by-rank-math
wp plugin install better-wp-security
wp plugin install complianz-gdpr
wp plugin install webp-converter-for-media
wp plugin install simple-history
wp plugin install plausible-analytics

echo "✅ Plugins installed successfully!"