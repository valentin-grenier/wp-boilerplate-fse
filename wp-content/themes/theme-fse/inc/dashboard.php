<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Studio Val contact details used by the admin bar and the dashboard widget.
 *
 * Override per project via the `sv_boilerplate_studioval_contact` filter.
 *
 * @return array{email:string,phone:string,phone_display:string,website:string,meeting:string}
 */
function sv_boilerplate_get_studioval_contact() {
	$contact = array(
		'email'         => 'valentin@studio-val.fr',
		'phone'         => '+33625402641',
		'phone_display' => '+33 6 25 40 26 41',
		'website'       => 'https://studio-val.fr',
		'meeting'       => 'https://app.lemcal.com/@valentin-grenier',
	);

	return apply_filters( 'sv_boilerplate_studioval_contact', $contact );
}

/**
 * Remove dashboard widgets
 *
 * @return void
 */
function sv_boilerplate_remove_dashboard_widgets() {
	// Core WordPress widgets
	// remove_meta_box('dashboard_activity',       'dashboard', 'normal'); // Activity
	remove_meta_box( 'dashboard_right_now', 'dashboard', 'normal' ); // At a Glance
	remove_meta_box( 'dashboard_quick_press', 'dashboard', 'side' );   // Quick Draft
	// remove_meta_box('dashboard_primary',        'dashboard', 'side');   // WordPress Events and News

	// Plugin-related widgets (if installed)
	remove_meta_box( 'yoast_db_widget', 'dashboard', 'normal' ); // Yoast SEO
	remove_meta_box( 'rg_forms_dashboard', 'dashboard', 'normal' ); // Gravity Forms
	remove_meta_box( 'wpe_dify_news_feed', 'dashboard', 'normal' ); // WP Engine
	// remove_meta_box('dashboard_site_health',    'dashboard', 'normal'); // Site Health (WP 5.2+)
	// remove_meta_box('dashboard_php_nag',        'dashboard', 'normal'); // PHP Update Required
	remove_meta_box( 'jetpack_summary_widget', 'dashboard', 'normal' ); // Jetpack
	remove_meta_box( 'woocommerce_dashboard_status', 'dashboard', 'normal' ); // WooCommerce
	// remove_meta_box('dashboard_browser_nag',    'dashboard', 'normal'); // Browser outdated notice
}
add_action( 'wp_dashboard_setup', 'sv_boilerplate_remove_dashboard_widgets' );

/**
 * Customize the WordPress admin logo
 *
 * @return void
 */
function sv_boilerplate_custom_admin_logo() {
	$icon_url = get_stylesheet_directory_uri() . '/dist/assets/theme/admin-logo.svg';

	echo '<style type="text/css">
        /* WordPress Admin Bar Logo */
        #wpadminbar #wp-admin-bar-wp-logo {
            width: 80px;
        }

        #wpadminbar #wp-admin-bar-wp-logo > .ab-item .ab-icon {
            margin-right: 0 !important;
            width: 100%;
        }

        #wpadminbar #wp-admin-bar-wp-logo > .ab-item .ab-icon:before {
            background-image: url(' . esc_url( $icon_url ) . ') !important;
            background-size: 67px 20px !important;
            background-repeat: no-repeat !important;
            background-position: center !important;
            content: "" !important;
            width: 67px !important;
            height: 20px !important;
            display: inline-block !important;
        }
        
        /* Additional fallback for different WordPress versions */
        #wpadminbar #wp-admin-bar-wp-logo .ab-icon {
            background-image: url(' . esc_url( $icon_url ) . ') !important;
            background-size: 20px !important;
            background-repeat: no-repeat !important;
            background-position: center !important;
            width: 20px !important;
            height: 20px !important;
            display: inline-block !important;
        }
        
        #wpadminbar #wp-admin-bar-wp-logo .ab-icon:before {
            content: "" !important;
        }
        
        /* Admin dashboard logo (WordPress 5.4+) */
        .wp-admin .wp-admin-bar-wp-logo > .ab-item .ab-icon:before {
            background-image: url(' . esc_url( $icon_url ) . ') !important;
            background-size: 20px 20px !important;
            background-repeat: no-repeat !important;
            background-position: center !important;
            content: "" !important;
            width: 20px !important;
            height: 20px !important;
            display: inline-block !important;
        }
        
        /* Custom submenu styling */
        #wpadminbar .ab-top-secondary .menupop .ab-sub-wrapper {
            min-width: 150px;
        }
    </style>';
}
add_action( 'admin_head', 'sv_boilerplate_custom_admin_logo' );
add_action( 'login_head', 'sv_boilerplate_custom_admin_logo' );
add_action( 'wp_head', 'sv_boilerplate_custom_admin_logo' );

/**
 * Customize WordPress logo submenu in admin bar
 *
 * @return void
 */
function sv_boilerplate_custom_admin_bar_menu() {
	global $wp_admin_bar;

	if ( ! is_admin_bar_showing() ) {
		return;
	}

	// Remove some default WordPress submenu items (keep wp-logo-external for "Get Involved")
	$wp_admin_bar->remove_menu( 'about' );
	$wp_admin_bar->remove_menu( 'wporg' );
	$wp_admin_bar->remove_menu( 'documentation' );
	$wp_admin_bar->remove_menu( 'support-forums' );
	$wp_admin_bar->remove_menu( 'feedback' );
	$wp_admin_bar->remove_menu( 'learn' );

	$contact = sv_boilerplate_get_studioval_contact();

	// Add custom submenu items under "Get Involved".
	$wp_admin_bar->add_menu(
		array(
			'parent' => 'wp-logo-external',
			'id'     => 'studioval-boilerplate',
			'title'  => __( 'Studio Val', 'studioval-boilerplate' ),
			'href'   => $contact['website'],
			'meta'   => array(
				'target' => '_blank',
				'title'  => __( 'Visit Studio Val website', 'studioval-boilerplate' ),
			),
		)
	);

	$wp_admin_bar->add_menu(
		array(
			'parent' => 'wp-logo-external',
			'id'     => 'contact-support',
			'title'  => __( 'Need help?', 'studioval-boilerplate' ),
			'href'   => 'mailto:' . $contact['email'] . '?subject=' . rawurlencode( '[' . get_bloginfo( 'name' ) . '] Support request' ),
			'meta'   => array(
				'title' => __( 'Contact support', 'studioval-boilerplate' ),
			),
		)
	);

	$wp_admin_bar->add_menu(
		array(
			'parent' => 'wp-logo-external',
			'id'     => 'meeting',
			'title'  => __( 'Book a meeting', 'studioval-boilerplate' ),
			'href'   => $contact['meeting'],
			'meta'   => array(
				'target' => '_blank',
				'title'  => __( 'Book a meeting with Studio Val', 'studioval-boilerplate' ),
			),
		)
	);
}
add_action( 'wp_before_admin_bar_render', 'sv_boilerplate_custom_admin_bar_menu' );

/**
 * Register the Studio Val dashboard widget.
 *
 * @return void
 */
function sv_boilerplate_add_studioval_dashboard_widget() {
	wp_add_dashboard_widget(
		'sv_boilerplate_studioval_widget',
		__( 'Studio Val', 'studioval-boilerplate' ),
		'sv_boilerplate_render_studioval_dashboard_widget'
	);

	// Move the widget to the top of the "normal" column.
	global $wp_meta_boxes;

	if ( ! isset( $wp_meta_boxes['dashboard']['normal']['core'] ) ) {
		return;
	}

	$normal_core = $wp_meta_boxes['dashboard']['normal']['core'];

	if ( ! isset( $normal_core['sv_boilerplate_studioval_widget'] ) ) {
		return;
	}

	$widget = array( 'sv_boilerplate_studioval_widget' => $normal_core['sv_boilerplate_studioval_widget'] );
	unset( $normal_core['sv_boilerplate_studioval_widget'] );

	$wp_meta_boxes['dashboard']['normal']['core'] = array_merge( $widget, $normal_core ); // phpcs:ignore WordPress.WP.GlobalVariablesOverride.Prohibited
}
add_action( 'wp_dashboard_setup', 'sv_boilerplate_add_studioval_dashboard_widget' );

/**
 * Read the cached Site Health async-test summary.
 *
 * Returns null when the user has never visited Tools → Site Health (the
 * `health-check-site-status-result` option is populated by the JS test runner
 * on that screen).
 *
 * @return array{good:int,recommended:int,critical:int,total:int,score:int}|null
 */
function sv_boilerplate_get_site_health_summary() {
	$raw = get_option( 'health-check-site-status-result' );

	if ( ! $raw ) {
		return null;
	}

	$data = json_decode( $raw, true );

	if ( ! is_array( $data ) ) {
		return null;
	}

	$good        = isset( $data['good'] ) ? (int) $data['good'] : 0;
	$recommended = isset( $data['recommended'] ) ? (int) $data['recommended'] : 0;
	$critical    = isset( $data['critical'] ) ? (int) $data['critical'] : 0;
	$total       = $good + $recommended + $critical;

	if ( 0 === $total ) {
		return null;
	}

	return array(
		'good'        => $good,
		'recommended' => $recommended,
		'critical'    => $critical,
		'total'       => $total,
		'score'       => (int) round( ( $good / $total ) * 100 ),
	);
}

/**
 * Render the Studio Val dashboard widget.
 *
 * @return void
 */
function sv_boilerplate_render_studioval_dashboard_widget() {
	$contact      = sv_boilerplate_get_studioval_contact();
	$logo_url     = get_template_directory_uri() . '/dist/assets/theme/admin-logo.svg';
	$site_name    = get_bloginfo( 'name' );
	$theme        = wp_get_theme();
	$theme_name   = $theme->get( 'Name' );
	$theme_ver    = $theme->get( 'Version' );
	$wp_ver       = get_bloginfo( 'version' );
	$php_ver      = PHP_VERSION;
	$env          = function_exists( 'wp_get_environment_type' ) ? wp_get_environment_type() : 'unknown';
	$active_plugs = (array) get_option( 'active_plugins', array() );

	$current_user = wp_get_current_user();
	$display_name = $current_user->display_name;

	$env_labels = array(
		'production'  => __( 'Production', 'studioval-boilerplate' ),
		'staging'     => __( 'Staging', 'studioval-boilerplate' ),
		'development' => __( 'Development', 'studioval-boilerplate' ),
		'local'       => __( 'Local', 'studioval-boilerplate' ),
	);
	$env_label  = $env_labels[ $env ] ?? ucfirst( $env );

	$health = sv_boilerplate_get_site_health_summary();

	$support_subject = '[' . $site_name . '] ' . __( 'Support request', 'studioval-boilerplate' );
	$support_body    = sprintf(
		"Site: %s\nTheme: %s %s\nWordPress: %s\nPHP: %s\n\n---\n\n",
		$site_name,
		$theme_name,
		$theme_ver,
		$wp_ver,
		$php_ver
	);

	$bug_subject = '[' . $site_name . '] ' . __( 'Bug report', 'studioval-boilerplate' );
	$bug_body    = sprintf(
		"Site: %s\nEnvironment: %s\nTheme: %s %s\nWordPress: %s\nPHP: %s\n\nActive plugins:\n%s\n\n---\n\n",
		$site_name,
		$env,
		$theme_name,
		$theme_ver,
		$wp_ver,
		$php_ver,
		implode( "\n", $active_plugs )
	);

	$mailto_support = 'mailto:' . $contact['email'] . '?subject=' . rawurlencode( $support_subject ) . '&body=' . rawurlencode( $support_body );
	$mailto_bug     = 'mailto:' . $contact['email'] . '?subject=' . rawurlencode( $bug_subject ) . '&body=' . rawurlencode( $bug_body );
	?>
	<div class="sv-studioval-widget">
		<div class="sv-studioval-widget__header">
			<img class="sv-studioval-widget__logo"
				src="<?php echo esc_url( $logo_url ); ?>"
				alt=""
				width="160"
				height="48" />

			<span class="sv-studioval-widget__env sv-studioval-widget__env--<?php echo esc_attr( $env ); ?>"
				title="<?php esc_attr_e( 'Current environment', 'studioval-boilerplate' ); ?>">
				<?php echo esc_html( $env_label ); ?>
			</span>
		</div>

		<?php if ( $display_name ) : ?>
			<p class="sv-studioval-widget__greeting">
				<?php
				printf(
					/* translators: %s: user display name */
					esc_html__( 'Hello, %s', 'studioval-boilerplate' ),
					esc_html( $display_name )
				);
				?>
			</p>
		<?php endif; ?>

		<p class="sv-studioval-widget__intro">
			<?php esc_html_e( 'Studio Val designed and built this site. Use the shortcuts below to get in touch, book a meeting, or report an issue.', 'studioval-boilerplate' ); ?>
		</p>

		<ul class="sv-studioval-widget__actions">
			<li>
				<a class="sv-studioval-widget__action"
					href="<?php echo esc_url( $mailto_support ); ?>"
					aria-label="<?php esc_attr_e( 'Email Studio Val support', 'studioval-boilerplate' ); ?>">
					<span class="dashicons dashicons-email-alt" aria-hidden="true"></span>
					<span><?php esc_html_e( 'Email', 'studioval-boilerplate' ); ?></span>
				</a>
			</li>
			<li>
				<a class="sv-studioval-widget__action"
					href="tel:<?php echo esc_attr( $contact['phone'] ); ?>"
					aria-label="<?php esc_attr_e( 'Call Studio Val', 'studioval-boilerplate' ); ?>">
					<span class="dashicons dashicons-phone" aria-hidden="true"></span>
					<span><?php echo esc_html( $contact['phone_display'] ); ?></span>
				</a>
			</li>
			<li>
				<a class="sv-studioval-widget__action"
					href="<?php echo esc_url( $contact['website'] ); ?>"
					target="_blank"
					rel="noopener noreferrer"
					aria-label="<?php esc_attr_e( 'Visit studio-val.fr', 'studioval-boilerplate' ); ?>">
					<span class="dashicons dashicons-admin-site" aria-hidden="true"></span>
					<span><?php esc_html_e( 'Website', 'studioval-boilerplate' ); ?></span>
				</a>
			</li>
			<li>
				<a class="sv-studioval-widget__action"
					href="<?php echo esc_url( $contact['meeting'] ); ?>"
					target="_blank"
					rel="noopener noreferrer"
					aria-label="<?php esc_attr_e( 'Book a meeting with Studio Val', 'studioval-boilerplate' ); ?>">
					<span class="dashicons dashicons-calendar-alt" aria-hidden="true"></span>
					<span><?php esc_html_e( 'Book a meeting', 'studioval-boilerplate' ); ?></span>
				</a>
			</li>
			<li>
				<a class="sv-studioval-widget__action sv-studioval-widget__action--danger"
					href="<?php echo esc_url( $mailto_bug ); ?>"
					aria-label="<?php esc_attr_e( 'Report a bug to Studio Val', 'studioval-boilerplate' ); ?>">
					<span class="dashicons dashicons-warning" aria-hidden="true"></span>
					<span><?php esc_html_e( 'Report a bug', 'studioval-boilerplate' ); ?></span>
				</a>
			</li>
		</ul>

		<?php if ( $health ) : ?>
			<?php
			$health_state = 0 < $health['critical'] ? 'critical' : ( 0 < $health['recommended'] ? 'recommended' : 'good' );
			?>
			<a class="sv-studioval-widget__health sv-studioval-widget__health--<?php echo esc_attr( $health_state ); ?>"
				href="<?php echo esc_url( admin_url( 'site-health.php' ) ); ?>">
				<span class="sv-studioval-widget__health-dot" aria-hidden="true"></span>
				<span class="sv-studioval-widget__health-text">
					<?php
					printf(
						/* translators: 1: passed-tests count, 2: total-tests count */
						esc_html__( 'Site Health: %1$d/%2$d checks passed', 'studioval-boilerplate' ),
						(int) $health['good'],
						(int) $health['total']
					);
					?>
				</span>
			</a>
		<?php else : ?>
			<a class="sv-studioval-widget__health sv-studioval-widget__health--unknown"
				href="<?php echo esc_url( admin_url( 'site-health.php' ) ); ?>">
				<span class="sv-studioval-widget__health-dot" aria-hidden="true"></span>
				<span class="sv-studioval-widget__health-text">
					<?php esc_html_e( 'Run Site Health checks', 'studioval-boilerplate' ); ?>
				</span>
			</a>
		<?php endif; ?>
	</div>
	<?php
}

/**
 * Enqueue admin styles for the dashboard widget on the dashboard screen only.
 *
 * @param string $hook_suffix Current admin page hook suffix.
 * @return void
 */
function sv_boilerplate_dashboard_widget_assets( $hook_suffix ) {
	if ( 'index.php' !== $hook_suffix ) {
		return;
	}

	$css_path = get_template_directory() . '/dist/css/admin.css';
	$css_url  = get_template_directory_uri() . '/dist/css/admin.css';

	if ( ! file_exists( $css_path ) ) {
		return;
	}

	wp_enqueue_style(
		'sv-boilerplate-dashboard-widget',
		$css_url,
		array( 'dashicons' ),
		filemtime( $css_path )
	);
}
add_action( 'admin_enqueue_scripts', 'sv_boilerplate_dashboard_widget_assets' );
