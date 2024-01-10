<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class Revo_Pos_Base_Vendor {
	protected $namespace = REVO_POS_NAMESPACE_API;

	/**
	 * Get error
	 *
	 * @param string $code
	 * @param string $message
	 * @param int $statusCode
	 *
	 * @return WP_Error
	 */
	public function sendError( $code, $message, $statusCode ): WP_Error {
		return new WP_Error( $code, $message, array( 'status' => $statusCode ) );
	}

	/**
	 * Check plugin active or not
	 *
	 * @return bool
	 */
	public function checkPluginActive( $plugin ): bool {
		if ( ! is_plugin_active( $plugin ) && $plugin !== true ) {
			return false;
		}

		return true;
	}
}

if ( ! function_exists( 'revo_woo_register_vendor_routes' ) ) {
	function revo_woo_register_vendor_routes() {
		require_once REVO_WOO_ABSPATH . 'includes/vendor/class-aliexpress.php';
		require_once REVO_WOO_ABSPATH . 'includes/vendor/class-polylang.php';
		require_once REVO_WOO_ABSPATH . 'includes/vendor/class-checkout-native.php';

		$classes = [
			'Revo_CheckoutNative',
			'Revo_Polylang',
			'Revo_Aliexpress',
		];

		foreach ( $classes as $class ) {
			if ( class_exists( $class ) ) {
				$obj = new $class();
				$obj->rest_init();
			}
		}
	}
}

add_action( 'rest_api_init', 'revo_woo_register_vendor_routes' );