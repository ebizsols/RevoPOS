<?php

/**
 * @wordpress-plugin
 *
 * Plugin Name:       RevoPOS - Flutter Woocommerce Point of Sales
 * Plugin URI:        https://revoapps.net
 * Description:       Point of Sales and Admin Manager - for your Woocommerce
 * Version:           3.0.8
 * Author:            Revo Apps
 * Author URI:        https://revoapps.net
 * Text Domain:       revopos
 * Requires PHP:      7.4
 * Build:             2021
 **/

if (!defined('ABSPATH')) {
    exit;
}

define('REVO_POS_ABSPATH', plugin_dir_path(__FILE__));
define('REVO_POS_URL', plugin_dir_url(__FILE__));
define('REVO_POS_PLUGIN_NAME', 'RevoPOS');
define('REVO_POS_PLUGIN_SLUG', 'revo-pos');
define('REVO_POS_PLUGIN_VERSION', '3.0.8');
define('REVO_POS_NAMESPACE_API', 'revo-post');

if (!class_exists('Revo_Pos_Init')) {
    final class Revo_Pos_Init
    {
        static $_instance = null;

        public function __construct()
        {
            $this->includes();
            $this->services();

            if (!is_plugin_active('revo-woocommerce-plugin/revo-woocommerce-plugin.php') && !is_plugin_active('Plugin-Revo-Multivendor/index.php')) {
                add_action('woocommerce_new_order', 'revo_pos_notif_new_order', 10, 1);
                add_action('woocommerce_order_status_changed', 'revo_pos_notif_new_order', 10, 1);

                if (strpos($_SERVER['REQUEST_URI'], 'revo-post') !== false) {
                    add_action('woocommerce_add_order_item_meta', array($this, 'revo_pos_woocommerce_add_order_item_meta'), 10, 3);
                    add_action( 'revo_pos_place_order', array( $this, 'place_order_add_custom_meta' ), 11, 2 );
                    add_filter('woocommerce_rest_prepare_product_variation_object', [$this, 'revo_pos_custom_woocommerce_rest_prepare_product_variation_object']);
                    add_filter('woocommerce_rest_prepare_product_object', [$this, 'revo_pos_custom_change_product_response'], 20, 3);

                    if ( strpos( $_SERVER['REDIRECT_URL'], 'place-order' ) !== false ) {
    				    add_filter( 'woocommerce_get_shop_coupon_data', array( $this, 'get_discount_data' ), 10, 2 );
                    }
                }
            }
        }

        public function includes()
        {
            // helper
            require_once REVO_POS_ABSPATH . 'includes/revo-pos-helper.php';

            // api
            require_once REVO_POS_ABSPATH . 'includes/api/revo-pos-api-routes.php';
            require_once REVO_POS_ABSPATH . 'includes/api/revo-pos-api-functions.php';

            // classes
            require_once REVO_POS_ABSPATH . 'includes/classes/class-revo-pos-flutter-user.php';

            // dashboard section
            if (is_admin()) {
                require_once REVO_POS_ABSPATH . 'includes/admin/class-revo-pos-admin-api.php';
                require_once REVO_POS_ABSPATH . 'includes/classes/class-revo-pos-installation.php';
            }
        }

        public function place_order_add_custom_meta( $cart_items, $order_id ) {
			$order = new WC_Order( $order_id );

			if ( is_plugin_active( 'woocommerce-points-and-rewards/woocommerce-points-and-rewards.php' ) ) {
				$coupons = $order->get_coupons();

				foreach ( $coupons as $coupon ) {
					$coupon_code = $coupon->get_code();

					if ( strpos( $coupon_code, 'wc_points_redemption' ) !== false ) {
						$x_coupon_code = explode( '_', $coupon_code );
						$points        = $x_coupon_code[ ( array_key_last( $x_coupon_code ) - 1 ) ];
						$amount        = end( $x_coupon_code );

						$user_points = WC_Points_Rewards_Manager::get_users_points( get_current_user_id() );

						if ( $user_points < $points ) {
							return;
						}

						WC_Points_Rewards_Manager::decrease_points( $order->get_customer_id(), $points, 'order-redeem', array(
							'discount_code'   => $coupon_code,
							'discount_amount' => $amount
						), $order_id );

						add_post_meta( $order_id, '_wc_points_logged_redemption', [
							'points'        => (int) $points,
							'amount'        => (int) $amount,
							'discount_code' => $coupon_code
						] );

						update_post_meta( $order_id, '_wc_points_redeemed', (string) $points );

						break;
					}
				}
			}
		}

        public function get_discount_data( $data, $code ) {
			if ( strpos( $code, 'wc_points_redemption' ) !== false ) {
				$amount = end( explode( '_', $code ) );

				$user_points = WC_Points_Rewards_Manager::get_users_points( get_current_user_id() );

				if ( $user_points <= 0 || $user_points < $amount ) {
					return $data;
				}

				$data = array(
					'id'                         => true,
					'type'                       => 'fixed_cart',
					'amount'                     => $amount,
					'coupon_amount'              => $amount, // 2.2
					'individual_use'             => false,
					'usage_limit'                => '',
					'usage_count'                => '',
					'expiry_date'                => '',
					'apply_before_tax'           => true,
					'free_shipping'              => false,
					'product_categories'         => array(),
					'exclude_product_categories' => array(),
					'exclude_sale_items'         => false,
					'minimum_amount'             => '',
					'maximum_amount'             => '',
					'customer_email'             => '',
				);

				return $data;
			}
		}

        public function revo_pos_woocommerce_add_order_item_meta($item_id, $cart_item_key, $values)
        {
            if (!is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php')) {
                return true;
            }

            $user_id = wp_validate_auth_cookie(cek_raw('cookie'), 'logged_in');

            if ($user_id != 0) {
                $user = get_userdata($user_id);

                if (in_array('wholesale_customer', $user->roles)) {
                    wc_add_order_item_meta($item_id, '_wwp_wholesale_priced', 'yes', true);
                    wc_add_order_item_meta($item_id, '_wwp_wholesale_role', 'wholesale_customer', true);
                }
            }
        }

        public function revo_pos_custom_change_product_response($response)
        {
            global $woocommerce_wpml;

            if (!empty($woocommerce_wpml->multi_currency) && !empty($woocommerce_wpml->settings['currencies_order'])) {
                $type  = $response->data['type'];
                $price = $response->data['price'];

                foreach ($woocommerce_wpml->settings['currency_options'] as $key => $currency) {
                    $rate = (float)$currency["rate"];
                    $response->data['multi-currency-prices'][$key]['price'] = $rate == 0 ? $price : sprintf("%.2f", $price * $rate);
                }
            }

            return $response;
        }

        public function revo_pos_custom_woocommerce_rest_prepare_product_variation_object($response)
        {

            global $woocommerce_wpml;

            if (!empty($woocommerce_wpml->multi_currency) && !empty($woocommerce_wpml->settings['currencies_order'])) {

                $type  = $response->data['type'];
                $price = $response->data['price'];

                foreach ($woocommerce_wpml->settings['currency_options'] as $key => $currency) {
                    $rate = (float)$currency["rate"];
                    $response->data['multi-currency-prices'][$key]['price'] = $rate == 0 ? $price : sprintf("%.2f", $price * $rate);
                }
            }

            return $response;
        }

        private function services()
        {
            $classes = [
                Revo_Pos_Admin_Api::class,
                Revo_Pos_Flutter_User::class,
            ];

            foreach ( $classes as $class ) {
                if ( class_exists( $class ) ) {
                    $class::instance();
                }
            }
        }

        public static function instance()
        {
            if (is_null(self::$_instance)) {
                self::$_instance = new self();
            }

            return self::$_instance;
        }
    }
}

function revo_pos_boot_plugin()
{
    if (!function_exists('is_plugin_active')) {
        require_once ABSPATH . 'wp-admin/includes/plugin.php';
    }

    if (!is_plugin_active('woocommerce/woocommerce.php')) {
        add_action('admin_notices', function () {
            ?><div class="error">
                <p>
                    <?php _e('<b>RevoPOS</b> plugin missing dependency.<br/><br/>Please ensure you have the <a href="http://wordpress.org/plugins/woocommerce/" target="_blank">WooCommerce</a> plugin installed and activated.<br/>', 'woocommerce-wholesale-prices'); ?>
                </p>
            </div>
            <?php
        });
    }

    return Revo_Pos_Init::instance();
}

$GLOBALS['revowoo'] = revo_pos_boot_plugin();

/**
 * plugin activation
 */
function revo_pos_activate_plugin()
{
    Revo_Pos_Installation::plugin_activator();
}
register_activation_hook(__FILE__, 'revo_pos_activate_plugin');

/**
 * plugin deactivation
 */
function revo_pos_deactivate_plugin()
{
    Revo_Pos_Installation::plugin_deactivator();
}
register_deactivation_hook(__FILE__, 'revo_pos_deactivate_plugin');
